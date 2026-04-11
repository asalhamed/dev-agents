# CI/CD Pipeline Patterns

## GitHub Actions — Multi-Stack Monorepo

For a repo with backend (Rust/Scala), Android, video services, and IoT firmware — use path-filtered jobs so unrelated changes don't trigger full CI:

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, 'feature/**', 'hotfix/**', 'release/**']
  pull_request:
    branches: [main]

jobs:
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      backend: ${{ steps.filter.outputs.backend }}
      android: ${{ steps.filter.outputs.android }}
      video: ${{ steps.filter.outputs.video }}
      iot: ${{ steps.filter.outputs.iot }}
      infra: ${{ steps.filter.outputs.infra }}
    steps:
      - uses: actions/checkout@v4
      - uses: dorny/paths-filter@v3
        id: filter
        with:
          filters: |
            backend:
              - 'backend/**'
            android:
              - 'android/**'
            video:
              - 'video-service/**'
            iot:
              - 'firmware/**'
            infra:
              - 'k8s/**'
              - '.github/**'

  backend:
    needs: detect-changes
    if: needs.detect-changes.outputs.backend == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
      - uses: Swatinem/rust-cache@v2
      - run: cargo fmt --check
      - run: cargo clippy -- -D warnings
      - run: cargo test
      - run: cargo audit
      - name: Coverage
        run: cargo tarpaulin --out Xml --fail-under 80
      - name: Security gates
        run: ./reviewer/scripts/automated_gates.sh backend/ --stack rust

  android:
    needs: detect-changes
    if: needs.detect-changes.outputs.android == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
      - name: Lint
        run: ./gradlew ktlintCheck
        working-directory: android
      - name: Build
        run: ./gradlew assembleDebug
        working-directory: android
      - name: Unit tests
        run: ./gradlew testDebugUnitTest
        working-directory: android

  video-service:
    needs: detect-changes
    if: needs.detect-changes.outputs.video == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
      - uses: Swatinem/rust-cache@v2
      - run: cargo fmt --check
        working-directory: video-service
      - run: cargo test
        working-directory: video-service
      - name: Integration test (video pipeline)
        run: |
          docker compose -f docker-compose.test.yml up -d
          cargo test --features integration
          docker compose -f docker-compose.test.yml down
        working-directory: video-service

  deploy-staging:
    needs: [backend, android, video-service]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4
      - name: Build and push images
        run: |
          SHA=$(git rev-parse --short HEAD)
          docker build -t ghcr.io/${{ github.repository }}/backend:main-$SHA backend/
          docker build -t ghcr.io/${{ github.repository }}/video:main-$SHA video-service/
          docker push ghcr.io/${{ github.repository }}/backend:main-$SHA
          docker push ghcr.io/${{ github.repository }}/video:main-$SHA
      - name: Deploy to staging
        run: |
          SHA=$(git rev-parse --short HEAD)
          kustomize edit set image backend=ghcr.io/${{ github.repository }}/backend:main-$SHA
          kustomize edit set image video=ghcr.io/${{ github.repository }}/video:main-$SHA
          kubectl apply -k k8s/overlays/staging
      - name: Smoke test
        run: ./scripts/smoke-test.sh staging

  deploy-production:
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-latest
    environment: production  # requires manual approval in GitHub
    steps:
      - uses: actions/checkout@v4
      - name: Build release images
        run: |
          VERSION=${GITHUB_REF#refs/tags/}
          docker build -t ghcr.io/${{ github.repository }}/backend:$VERSION backend/
          docker push ghcr.io/${{ github.repository }}/backend:$VERSION
      - name: Deploy to production
        run: |
          VERSION=${GITHUB_REF#refs/tags/}
          kustomize edit set image backend=ghcr.io/${{ github.repository }}/backend:$VERSION
          kubectl apply -k k8s/overlays/prod
      - name: Smoke test
        run: ./scripts/smoke-test.sh production
      - name: Verify feature flags OFF for new features
        run: ./scripts/verify-flags.sh
```

## Release Workflow

```yaml
# .github/workflows/release.yml
name: Release

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Release version (e.g., v1.2.0)'
        required: true
      features:
        description: 'Feature IDs included (e.g., F-012,F-013)'
        required: true

jobs:
  create-release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          ref: main

      - name: Create release branch
        run: |
          git checkout -b release/${{ inputs.version }}
          git push origin release/${{ inputs.version }}

      - name: Tag release
        run: |
          git tag -a ${{ inputs.version }} -m "Release ${{ inputs.version }}

          Features: ${{ inputs.features }}"
          git push origin ${{ inputs.version }}

      - name: Generate release notes
        run: |
          echo "## Release ${{ inputs.version }}" > RELEASE_NOTES.md
          echo "" >> RELEASE_NOTES.md
          echo "### Features" >> RELEASE_NOTES.md
          for fid in $(echo "${{ inputs.features }}" | tr ',' ' '); do
            echo "- $fid" >> RELEASE_NOTES.md
          done
          echo "" >> RELEASE_NOTES.md
          echo "### Commits" >> RELEASE_NOTES.md
          git log --oneline $(git describe --tags --abbrev=0 HEAD^)..HEAD >> RELEASE_NOTES.md

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ inputs.version }}
          body_path: RELEASE_NOTES.md
```

## Android Release Pipeline

```yaml
# .github/workflows/android-release.yml
name: Android Release

on:
  push:
    tags: ['v*']

jobs:
  build-release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Set version
        run: |
          VERSION=${GITHUB_REF#refs/tags/v}
          echo "VERSION_NAME=$VERSION" >> $GITHUB_ENV
          echo "VERSION_CODE=$(date +%Y%m%d%H)" >> $GITHUB_ENV

      - name: Build release AAB
        run: ./gradlew bundleRelease
        working-directory: android
        env:
          VERSION_NAME: ${{ env.VERSION_NAME }}
          VERSION_CODE: ${{ env.VERSION_CODE }}

      - name: Upload to Play Store (internal track)
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_SA }}
          packageName: com.company.monitoring
          releaseFiles: android/app/build/outputs/bundle/release/app-release.aab
          track: internal  # internal → beta → production (gradual)
```

## IoT Firmware Release

```yaml
# Firmware releases require OTA safety — always stage before fleet rollout
firmware-release:
  steps:
    - name: Build firmware
      run: cargo build --release --target thumbv7em-none-eabihf
      working-directory: firmware

    - name: Sign firmware image
      run: ./scripts/sign-firmware.sh target/release/firmware.bin

    - name: Calculate checksum
      run: sha256sum target/release/firmware.bin.signed > firmware.sha256

    - name: Upload to staging OTA server
      run: |
        ./scripts/ota-upload.sh \
          --image firmware.bin.signed \
          --version $VERSION \
          --environment staging \
          --rollout-percentage 0  # manually enable after staging validation
```

## Key Rules

- **Never push `:latest`** — every image must have a meaningful tag (SHA or version)
- **Staging is automatic** — every merge to main auto-deploys to staging, no manual step
- **Production is manual** — always requires explicit approval before deploy
- **New features go behind flags** — `verify-flags.sh` enforces this in production deploy
- **Path filtering** — only build/test what changed; don't run all jobs on every push
