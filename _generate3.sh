#!/bin/bash
set -e
cd /home/ahmed/.openclaw/workspace/dev-agents-review

###############################################################################
# PART 3: evals.json for all 17 agents
###############################################################################

mkdir -p android-dev/evals iot-dev/evals video-streaming/evals edge-agent/evals
mkdir -p ml-engineer/evals data-engineer/evals analytics-engineer/evals
mkdir -p marketing/evals sales/evals customer-success/evals finance/evals
mkdir -p legal/evals hr/evals incident-responder/evals compliance-agent/evals
mkdir -p growth-strategist/evals partnerships-agent/evals

cat > android-dev/evals/evals.json << 'EOF'
{
  "skill_name": "android-dev",
  "evals": [
    {
      "id": 1,
      "prompt": "Implement a live video feed screen in Kotlin/Jetpack Compose that connects to an RTSP stream from an IP camera. The screen should show connection status, handle reconnection automatically, and work in the background.",
      "expected_output": "Compose UI with ExoPlayer integration, RTSP URL handling, foreground service for background playback, reconnection logic",
      "files": [],
      "expectations": [
        "ExoPlayer used for RTSP playback (not raw MediaPlayer)",
        "ForegroundService for background playback",
        "Automatic reconnection with exponential backoff",
        "Connection state shown in UI (connecting/playing/error)",
        "No business logic in Composable",
        "Produces implementation-summary contract"
      ]
    },
    {
      "id": 2,
      "prompt": "Implement offline-first alert storage for an Android monitoring app. Alerts come from Kafka via backend API. App should show alerts even when offline and sync when reconnected.",
      "expected_output": "Room database for local storage, WorkManager for background sync, StateFlow for UI updates",
      "files": [],
      "expectations": [
        "Room database stores alerts locally",
        "WorkManager syncs when connectivity available (not raw thread)",
        "UI shows cached data immediately, then updates",
        "Sync is idempotent (safe to retry)",
        "Produces implementation-summary contract"
      ]
    }
  ]
}
EOF

cat > iot-dev/evals/evals.json << 'EOF'
{
  "skill_name": "iot-dev",
  "evals": [
    {
      "id": 1,
      "prompt": "Implement MQTT telemetry publishing for a temperature/humidity sensor on an ESP32. Device should publish every 30s, buffer readings when offline, and reconnect automatically.",
      "expected_output": "MQTT client with buffering, reconnect logic, structured JSON telemetry, no hardcoded credentials",
      "files": [],
      "expectations": [
        "MQTT topic follows defined hierarchy (devices/{id}/telemetry)",
        "Credentials loaded from secure storage (not hardcoded)",
        "Local buffer for offline readings (FIFO, bounded size)",
        "Exponential backoff on reconnect",
        "Telemetry schema versioned",
        "Produces device-spec contract"
      ]
    },
    {
      "id": 2,
      "prompt": "Implement OTA firmware update mechanism for a fleet of IoT devices. Updates must be atomic, verifiable, and rollback-capable if the new firmware fails to boot.",
      "expected_output": "A/B partition OTA with signature verification, rollback on boot failure, status reporting",
      "files": [],
      "expectations": [
        "A/B partition strategy (not overwrite-in-place)",
        "Signature verification before applying update",
        "Watchdog timer triggers rollback if new firmware fails to boot",
        "Update status reported via MQTT",
        "Update is resumable (handles interrupted download)",
        "Produces device-spec contract"
      ]
    }
  ]
}
EOF

cat > video-streaming/evals/evals.json << 'EOF'
{
  "skill_name": "video-streaming",
  "evals": [
    {
      "id": 1,
      "prompt": "Design a streaming pipeline that ingests RTSP from 50 IP cameras, delivers live WebRTC streams to browser clients (target: <1s latency), and records HLS segments to S3.",
      "expected_output": "GStreamer/FFmpeg pipeline design, WebRTC SFU architecture, HLS recording with retention policy",
      "files": [],
      "expectations": [
        "RTSP ingestion to transcoding to WebRTC fork + HLS recording",
        "SFU architecture (not P2P — 50 cameras won't scale with P2P)",
        "TURN server for NAT traversal",
        "HLS segment lifecycle and S3 retention policy defined",
        "Camera disconnect handled (reconnect without manual intervention)",
        "Produces streaming-spec contract"
      ]
    },
    {
      "id": 2,
      "prompt": "A remote site has a 2Mbps uplink shared by 4 cameras. Design a bandwidth-adaptive streaming solution that prioritizes live viewing over recording and degrades gracefully.",
      "expected_output": "Adaptive bitrate strategy, priority queuing, local buffering for recording",
      "files": [],
      "expectations": [
        "Bandwidth budget allocated between live and recording",
        "Live viewing gets priority (recording degrades first)",
        "Adaptive bitrate for live: reduce quality before dropping stream",
        "Local buffering for recording when bandwidth is constrained",
        "Produces streaming-spec contract"
      ]
    }
  ]
}
EOF

cat > edge-agent/evals/evals.json << 'EOF'
{
  "skill_name": "edge-agent",
  "evals": [
    {
      "id": 1,
      "prompt": "Implement a store-and-forward edge gateway that collects MQTT telemetry from 100 local sensors, filters noise, aggregates 1-minute summaries, and syncs to cloud when connectivity is available.",
      "expected_output": "Local MQTT broker, aggregation logic, store-and-forward with bounded buffer, idempotent cloud sync",
      "files": [],
      "expectations": [
        "Local MQTT broker (Mosquitto/EMQX) for device-to-edge",
        "Aggregation: 1-min summary reduces data 60x before cloud upload",
        "Bounded local buffer (e.g., 7 days of data max)",
        "Cloud sync is idempotent (safe to replay)",
        "Edge dashboard works without cloud connectivity",
        "Produces implementation-summary"
      ]
    },
    {
      "id": 2,
      "prompt": "Deploy a person detection ML model on an NVIDIA Jetson edge device. Model should run on video frames, trigger alerts locally, and only send alert clips (not full video) to cloud.",
      "expected_output": "ONNX inference on Jetson, frame processing pipeline, local alert generation, bandwidth-efficient cloud upload",
      "files": [],
      "expectations": [
        "ONNX Runtime with TensorRT backend on Jetson",
        "Only alert clips uploaded (not continuous video)",
        "Local alert notification before cloud sync",
        "Inference rate appropriate for real-time (>= 10 FPS)",
        "Produces implementation-summary"
      ]
    }
  ]
}
EOF

cat > ml-engineer/evals/evals.json << 'EOF'
{
  "skill_name": "ml-engineer",
  "evals": [
    {
      "id": 1,
      "prompt": "Design an anomaly detection system for vibration sensor data from industrial equipment. The system should detect bearing failures 24-48h before they occur with a false positive rate < 5%.",
      "expected_output": "Model selection (time-series anomaly), feature engineering, false positive budget, drift monitoring plan",
      "files": [],
      "expectations": [
        "Model appropriate for time-series (isolation forest, LSTM autoencoder, or Prophet)",
        "False positive rate requirement explicitly addressed (<5%)",
        "Feature engineering defined (FFT features for vibration)",
        "Training/validation split accounts for temporal ordering (not random split)",
        "Drift detection plan defined",
        "Produces model-spec contract"
      ]
    },
    {
      "id": 2,
      "prompt": "Deploy a person detection model to edge devices (Raspberry Pi 4, 4GB RAM). Model must run at >=10 FPS on 1080p video with <500ms alert latency.",
      "expected_output": "Model selection and optimization for edge, quantization, performance validation",
      "files": [],
      "expectations": [
        "Model size appropriate for RPi4 (MobileNet or YOLO-nano, not full YOLOv8)",
        "INT8 quantization applied",
        "FPS requirement validated on target hardware",
        "Latency (inference + alert) validated end-to-end",
        "Produces model-spec contract"
      ]
    }
  ]
}
EOF

cat > data-engineer/evals/evals.json << 'EOF'
{
  "skill_name": "data-engineer",
  "evals": [
    {
      "id": 1,
      "prompt": "Design a data ingestion pipeline for 50,000 IoT devices publishing telemetry every 30 seconds. Data must be queryable within 60 seconds and retained for 30 days (raw) and 1 year (aggregated).",
      "expected_output": "Kafka ingestion, time-series storage, downsampling strategy, retention policies",
      "files": [],
      "expectations": [
        "Kafka as ingestion layer with device_id partition key",
        "Time-series database selection with rationale",
        "Downsampling: raw (30 days) to hourly (1 year)",
        "Query latency <60s for recent data",
        "Back-pressure handling for burst traffic",
        "Produces implementation-summary contract"
      ]
    },
    {
      "id": 2,
      "prompt": "Design video storage and lifecycle management for 200 cameras recording 24/7. Storage must support instant playback for last 7 days and archived access for up to 1 year.",
      "expected_output": "S3 bucket structure, lifecycle policies, HLS segment management, cost optimization",
      "files": [],
      "expectations": [
        "S3/MinIO bucket structure organized by site/camera/date",
        "Lifecycle policies: hot (7d) to warm (30d) to cold (90d) to archive (365d)",
        "HLS segment and playlist management",
        "Presigned URLs for secure playback",
        "Cost estimate per camera per month",
        "Produces implementation-summary contract"
      ]
    }
  ]
}
EOF

cat > analytics-engineer/evals/evals.json << 'EOF'
{
  "skill_name": "analytics-engineer",
  "evals": [
    {
      "id": 1,
      "prompt": "Design a fleet health dashboard for an IoT monitoring platform with 10,000 devices across 50 sites. Dashboard should show real-time device status, historical uptime trends, and alert on degradation.",
      "expected_output": "Data model, dbt transformations, Grafana/dashboard design, alerting rules",
      "files": [],
      "expectations": [
        "Data model separates raw events from derived metrics",
        "dbt models for uptime calculation, site health aggregation",
        "Dashboard shows: fleet overview, site drill-down, device detail",
        "Real-time refresh for status, hourly for trends",
        "Alerting on fleet-wide degradation (>5% offline)",
        "Produces implementation-summary contract"
      ]
    },
    {
      "id": 2,
      "prompt": "Build an alert effectiveness report that tracks alert-to-resolution time, false positive rate, and alert fatigue metrics across all customers.",
      "expected_output": "Metrics definitions, SQL/dbt models, visualization recommendations",
      "files": [],
      "expectations": [
        "Clear metric definitions (what counts as false positive, resolution time measurement)",
        "dbt models joining alert events with resolution events",
        "False positive rate tracked per alert type and per customer",
        "Alert fatigue metric: alerts-per-day trend vs response rate",
        "Produces implementation-summary contract"
      ]
    }
  ]
}
EOF

cat > marketing/evals/evals.json << 'EOF'
{
  "skill_name": "marketing",
  "evals": [
    {
      "id": 1,
      "prompt": "Write a case study for an oil & gas customer who deployed our IoT monitoring platform across 80 wellheads and reduced field visits by 65%. Include the full case study structure with quantified results.",
      "expected_output": "Complete case study with customer/challenge/solution/results structure, quantified outcomes",
      "files": [],
      "expectations": [
        "Follows case study template (customer/challenge/solution/results)",
        "Quantified results (% reduction, $ savings, time improvement)",
        "Technical content is accurate (MQTT, sensors, dashboard)",
        "Includes customer quote",
        "Clear call-to-action",
        "Produces marketing-brief contract"
      ]
    },
    {
      "id": 2,
      "prompt": "Create product positioning for our IoT remote monitoring platform targeting manufacturing companies. Differentiate from generic SCADA/MES solutions.",
      "expected_output": "Positioning statement, competitive differentiation, messaging framework",
      "files": [],
      "expectations": [
        "Positioning statement follows: For [target], who [need], our [product] is [category] that [benefit]",
        "Clear differentiation from SCADA (complement, not replace)",
        "Messaging leads with outcomes, not features",
        "Addresses top 3 objections specific to manufacturing",
        "Produces marketing-brief contract"
      ]
    }
  ]
}
EOF

cat > sales/evals/evals.json << 'EOF'
{
  "skill_name": "sales",
  "evals": [
    {
      "id": 1,
      "prompt": "Respond to an RFP from a water utility company seeking remote monitoring for 30 water treatment plants. They require SCADA integration, NERC CIP compliance, and 99.9% uptime SLA. Draft the technical proposal.",
      "expected_output": "Complete technical proposal addressing all RFP requirements with architecture, timeline, and pricing",
      "files": [],
      "expectations": [
        "Addresses all stated requirements (SCADA, NERC CIP, 99.9% uptime)",
        "Realistic implementation timeline with phases",
        "Pricing is structured and justified",
        "SLA terms are specific and achievable",
        "References relevant case studies or capabilities",
        "Produces sales-proposal contract"
      ]
    },
    {
      "id": 2,
      "prompt": "A manufacturing prospect says: 'We already have a SCADA system that does monitoring. Why would we need your platform on top of it?' Handle this objection and move the conversation forward.",
      "expected_output": "Objection response using acknowledge/explore/respond framework, with specific differentiators",
      "files": [],
      "expectations": [
        "Acknowledges SCADA value (doesn't dismiss their investment)",
        "Differentiates: remote access, video, ML analytics, mobile",
        "Uses specific examples or data points",
        "Ends with a forward-moving question or next step",
        "Produces sales-proposal contract"
      ]
    }
  ]
}
EOF

cat > customer-success/evals/evals.json << 'EOF'
{
  "skill_name": "customer-success",
  "evals": [
    {
      "id": 1,
      "prompt": "Create a device onboarding checklist and plan for a new customer deploying 50 sensors and 8 cameras across 2 sites. Include pre-deployment, installation, validation, and training phases.",
      "expected_output": "Comprehensive onboarding plan with checklists for each phase, timeline, and success criteria",
      "files": [],
      "expectations": [
        "Pre-deployment site survey checklist (network, power, mounting)",
        "Device provisioning steps (certificates, MQTT config)",
        "Data validation checklist (devices online, data flowing, correct values)",
        "Training plan for customer team",
        "Produces customer-health contract"
      ]
    },
    {
      "id": 2,
      "prompt": "A customer's health score dropped from Green to Yellow. Device uptime fell to 96%, support tickets doubled, and their champion just left the company. Create a churn risk assessment and action plan.",
      "expected_output": "Risk assessment with specific factors, action plan with owners and timeline",
      "files": [],
      "expectations": [
        "Identifies all risk factors with severity",
        "Root cause investigation plan for uptime drop",
        "Plan to identify and build relationship with new champion",
        "Specific actions with owners and deadlines",
        "Executive escalation if needed",
        "Produces customer-health contract"
      ]
    }
  ]
}
EOF

cat > finance/evals/evals.json << 'EOF'
{
  "skill_name": "finance",
  "evals": [
    {
      "id": 1,
      "prompt": "Calculate device-level unit economics for our IoT monitoring platform. We charge $25/device/month, connectivity costs $8/device/month (cellular), and cloud costs $2/device/month. We have 5,000 devices and 15 customers. Include LTV/CAC analysis.",
      "expected_output": "Complete unit economics analysis with per-device margin, LTV, CAC, and recommendations",
      "files": [],
      "expectations": [
        "Per-device margin calculated correctly",
        "All cost components included (connectivity, compute, storage, support)",
        "LTV calculation with stated assumptions (churn rate, gross margin)",
        "CAC calculation and LTV/CAC ratio",
        "Recommendations for margin improvement",
        "Produces financial-report contract"
      ]
    },
    {
      "id": 2,
      "prompt": "Design a pricing model for adding video surveillance to our existing IoT monitoring platform. Consider hardware costs (cameras), storage costs (30-day retention), and competitive positioning. Propose tiered pricing.",
      "expected_output": "Tiered pricing model with cost analysis, margin targets, and competitive justification",
      "files": [],
      "expectations": [
        "Multiple pricing tiers (e.g., basic/pro/enterprise)",
        "Cost breakdown per camera per month (storage, compute, bandwidth)",
        "Margin analysis per tier (target >60% gross margin)",
        "Comparison to competitors or alternatives",
        "Produces financial-report contract"
      ]
    }
  ]
}
EOF

cat > legal/evals/evals.json << 'EOF'
{
  "skill_name": "legal",
  "evals": [
    {
      "id": 1,
      "prompt": "Review our video monitoring feature for GDPR compliance. We record video from customer sites (EU), store it in AWS eu-west-1 for 30 days, and use AI person detection. Identify gaps and recommend fixes.",
      "expected_output": "GDPR gap analysis for video surveillance feature with specific remediation recommendations",
      "files": [],
      "expectations": [
        "Lawful basis assessment (legitimate interest for B2B surveillance)",
        "Data minimization review (resolution, retention, scope)",
        "DPIA requirement identified (systematic monitoring)",
        "Right to erasure: technical challenges with video documented",
        "Cross-border transfer assessment",
        "Produces compliance-audit contract"
      ]
    },
    {
      "id": 2,
      "prompt": "Draft SLA terms for our IoT monitoring platform. The customer requires 99.9% uptime, alert delivery within 5 minutes, and P1 support response within 1 hour. Include liability caps and exclusions.",
      "expected_output": "SLA terms with uptime definition, measurement methodology, credits, liability caps, and exclusions",
      "files": [],
      "expectations": [
        "Uptime defined precisely (what's measured, what's excluded)",
        "Credit schedule for SLA misses",
        "Liability cap defined (1-3x annual fees)",
        "Standard exclusions listed (customer network, force majeure)",
        "Alert delivery SLA with measurement methodology",
        "Produces compliance-audit contract"
      ]
    }
  ]
}
EOF

cat > hr/evals/evals.json << 'EOF'
{
  "skill_name": "hr",
  "evals": [
    {
      "id": 1,
      "prompt": "Write a job description for a Senior Embedded Software Engineer for our IoT team. Must have Rust or C experience, MQTT knowledge, and OTA update experience. Include interview process and success criteria.",
      "expected_output": "Complete JD with responsibilities, requirements, interview process, and 90-day success criteria",
      "files": [],
      "expectations": [
        "Role responsibilities are specific to IoT (not generic embedded)",
        "Requirements distinguish must-have from nice-to-have",
        "Compensation range included and benchmarked",
        "Interview process defined (stages, duration, interviewers)",
        "90-day success criteria are specific and measurable",
        "Produces hiring-plan contract"
      ]
    },
    {
      "id": 2,
      "prompt": "Plan the hiring sequence for an IoT startup going from 5 to 15 people over the next 12 months. Current team: CTO, 1 backend, 1 embedded, 1 frontend, 1 DevOps. Prioritize and justify the order.",
      "expected_output": "Sequenced hiring plan with role priorities, timeline, justification, and budget impact",
      "files": [],
      "expectations": [
        "Hiring sequence has clear rationale (bottleneck-driven)",
        "Each role justified by specific need (not speculative)",
        "Timeline is realistic (3-6 months for rare skills)",
        "Budget impact calculated (salary + equity + recruiting)",
        "Produces hiring-plan contract"
      ]
    }
  ]
}
EOF

cat > incident-responder/evals/evals.json << 'EOF'
{
  "skill_name": "incident-responder",
  "evals": [
    {
      "id": 1,
      "prompt": "The video pipeline is down. WebRTC connections are failing for all customers. RTSP ingestion is working but the SFU is returning 503 errors. Triage this incident, determine severity, and coordinate response.",
      "expected_output": "Incident triage with severity classification, investigation steps, mitigation plan, and communication",
      "files": [],
      "expectations": [
        "Severity correctly classified as P1 (all customers affected)",
        "Triage steps are specific and ordered (check SFU pods, check TURN, check resources)",
        "Communication plan for customers",
        "Mitigation before root cause (restore service first)",
        "Produces incident-report contract"
      ]
    },
    {
      "id": 2,
      "prompt": "Write a blameless postmortem for an incident where 15% of IoT devices disconnected simultaneously due to an MQTT broker configuration change during a routine deployment. Outage lasted 25 minutes.",
      "expected_output": "Complete blameless postmortem with timeline, root cause, action items",
      "files": [],
      "expectations": [
        "Timeline is factual and timestamped",
        "Root cause goes beyond symptoms (why was the config change deployed without testing)",
        "Blameless language (systems, not people)",
        "Action items have owners and due dates",
        "Lessons learned section with preventive measures",
        "Produces incident-report contract"
      ]
    }
  ]
}
EOF

cat > compliance-agent/evals/evals.json << 'EOF'
{
  "skill_name": "compliance-agent",
  "evals": [
    {
      "id": 1,
      "prompt": "Perform a SOC2 Type II gap analysis for our IoT monitoring platform. Focus on Security (CC6, CC7) and Availability (A1) controls. We have: RBAC, TLS everywhere, daily backups, but no centralized logging and manual access reviews.",
      "expected_output": "Gap analysis with control assessment, severity ratings, and remediation plan",
      "files": [],
      "expectations": [
        "All relevant CC6/CC7/A1 controls assessed",
        "Existing controls acknowledged (RBAC, TLS, backups)",
        "Gaps identified with severity (centralized logging: High, manual access reviews: Medium)",
        "Remediation plan with owners, timelines, and priorities",
        "Evidence collection plan included",
        "Produces compliance-audit contract"
      ]
    },
    {
      "id": 2,
      "prompt": "Assess GDPR compliance for our video monitoring feature deployed in the EU. We process video with AI person detection, store 30 days in AWS eu-west-1, and have no DPIA. What are the gaps?",
      "expected_output": "GDPR assessment focused on video surveillance with specific gaps and remediation",
      "files": [],
      "expectations": [
        "DPIA requirement identified as critical gap",
        "Lawful basis assessment for video + AI processing",
        "Data minimization review (retention period, resolution, scope)",
        "Right to erasure challenges documented",
        "Produces compliance-audit contract"
      ]
    }
  ]
}
EOF

cat > growth-strategist/evals/evals.json << 'EOF'
{
  "skill_name": "growth-strategist",
  "evals": [
    {
      "id": 1,
      "prompt": "We're an IoT monitoring startup with 5 customers in manufacturing. Should we go deeper in manufacturing or expand to oil & gas? Analyze both verticals and recommend a strategy with 90-day plan.",
      "expected_output": "Vertical analysis comparing manufacturing depth vs O&G expansion, with recommendation and action plan",
      "files": [],
      "expectations": [
        "Both verticals analyzed (market size, buyer, sales cycle, requirements)",
        "Clear recommendation with rationale (not 'it depends')",
        "TAM/SAM estimates sourced",
        "90-day plan with specific milestones",
        "Risk assessment for chosen strategy",
        "Produces gtm-strategy contract"
      ]
    },
    {
      "id": 2,
      "prompt": "Design a GTM strategy for launching our video surveillance add-on to existing IoT customers. We have 15 customers with 5,000 devices. Video is a new capability.",
      "expected_output": "GTM strategy for video upsell to existing base with pricing, positioning, and rollout plan",
      "files": [],
      "expectations": [
        "Leverages existing customer relationships (land-and-expand)",
        "Positioning differentiates from standalone VMS solutions",
        "Pricing strategy with rationale",
        "Rollout plan: pilot customers first, then broader launch",
        "Success metrics defined",
        "Produces gtm-strategy contract"
      ]
    }
  ]
}
EOF

cat > partnerships-agent/evals/evals.json << 'EOF'
{
  "skill_name": "partnerships-agent",
  "evals": [
    {
      "id": 1,
      "prompt": "Evaluate a technology partnership with Axis Communications (camera manufacturer). We want 'Axis Certified Compatible' status to access their dealer network. Assess the opportunity, define integration requirements, and draft the partnership brief.",
      "expected_output": "Partnership brief with value exchange, technical requirements, timeline, success metrics, and risks",
      "files": [],
      "expectations": [
        "Value exchange defined for both parties",
        "Technical integration scope defined (VAPIX, ONVIF, test cameras)",
        "Certification process timeline estimated",
        "Success metrics defined (leads, revenue, co-marketing)",
        "Risks identified with mitigation",
        "Produces partnership-brief contract"
      ]
    },
    {
      "id": 2,
      "prompt": "Design a channel partner program for system integrators who will sell and deploy our IoT monitoring platform. Define partner tiers, revenue share, enablement requirements, and program structure.",
      "expected_output": "Channel partner program design with tiers, economics, enablement, and governance",
      "files": [],
      "expectations": [
        "Multiple partner tiers (e.g., Authorized, Gold, Platinum)",
        "Revenue share/discount model defined per tier",
        "Enablement requirements (training, certification, demo environment)",
        "Deal registration and conflict resolution process",
        "Produces partnership-brief contract"
      ]
    }
  ]
}
EOF

echo "✅ Part 3: All 17 evals.json created"

###############################################################################
# PART 4: Shared eval markdown files
###############################################################################

# Function to create eval markdown files
create_eval() {
  local dir="$1" file="$2" title="$3" tags="$4" input="$5" expected="$6" pass="$7" fail="$8"
  mkdir -p "$dir"
  cat > "$dir/$file" << EVALEOF
# $title

**Tags:** $tags

## Input

$input

## Expected Behavior

$expected

## Pass Criteria

$pass

## Fail Criteria

$fail
EVALEOF
}

# android-dev
create_eval "shared/evals/android-dev" "eval-001-live-video-feed.md" \
  "Live Video Feed — RTSP Playback in Compose" \
  "android, video, exoplayer, compose, rtsp" \
  "Implement a live video feed screen in Kotlin/Jetpack Compose that connects to an RTSP stream from an IP camera. Show connection status, handle reconnection automatically, and support background playback." \
  "Agent produces a Compose screen with ExoPlayer for RTSP playback, a ForegroundService for background streaming, exponential backoff reconnection, and UI state management via StateFlow. No business logic in Composables." \
  "- [ ] ExoPlayer used for RTSP playback (not raw MediaPlayer)
- [ ] ForegroundService for background playback
- [ ] Automatic reconnection with exponential backoff
- [ ] Connection state shown in UI (connecting/playing/error)
- [ ] No business logic in Composable functions
- [ ] Produces implementation-summary contract" \
  "- Uses deprecated MediaPlayer API for RTSP
- No background playback support
- Hardcoded RTSP URLs
- Business logic mixed into Composables
- No reconnection logic"

create_eval "shared/evals/android-dev" "eval-002-offline-alerts.md" \
  "Offline-First Alert Storage" \
  "android, offline-first, room, workmanager, sync" \
  "Implement offline-first alert storage for an Android monitoring app. Alerts come from backend API (sourced from Kafka). App should display alerts immediately from local cache and sync in background when connectivity is available." \
  "Agent creates Room database for local storage, WorkManager for background sync, and StateFlow-based UI updates. Sync is idempotent and uses network constraints." \
  "- [ ] Room database stores alerts locally
- [ ] WorkManager syncs when connectivity available
- [ ] UI shows cached data immediately, then updates
- [ ] Sync is idempotent (safe to retry)
- [ ] Error handling across layers (network → domain errors)
- [ ] Produces implementation-summary contract" \
  "- Uses raw threads instead of WorkManager
- No local storage (crashes when offline)
- Sync is not idempotent (duplicates on retry)
- No error handling for network failures"

# iot-dev
create_eval "shared/evals/iot-dev" "eval-001-mqtt-telemetry.md" \
  "MQTT Telemetry Publishing — ESP32" \
  "iot, mqtt, esp32, telemetry, offline-buffer" \
  "Implement MQTT telemetry publishing for a temperature/humidity sensor on an ESP32. Publish every 30s, buffer readings when offline, and reconnect with exponential backoff." \
  "Agent produces MQTT client code with proper topic hierarchy, versioned telemetry schema, secure credential loading, bounded offline buffer, and reconnection logic." \
  "- [ ] MQTT topic follows hierarchy (devices/{id}/telemetry)
- [ ] Credentials loaded from secure storage (not hardcoded)
- [ ] Local buffer for offline readings (FIFO, bounded)
- [ ] Exponential backoff on reconnect with jitter
- [ ] Telemetry schema includes version field
- [ ] Produces device-spec contract" \
  "- Hardcoded credentials in source
- No offline buffering
- Flat topic structure
- No reconnection logic
- Unbounded buffer (memory leak risk)"

create_eval "shared/evals/iot-dev" "eval-002-ota-firmware.md" \
  "OTA Firmware Update with Rollback" \
  "iot, ota, firmware, rollback, security" \
  "Implement OTA firmware update mechanism for a fleet of IoT devices. Updates must be atomic (A/B partition), signature-verified, and rollback-capable if new firmware fails to boot." \
  "Agent designs A/B partition OTA with Ed25519 signature verification, watchdog-triggered rollback, resumable downloads, and MQTT status reporting." \
  "- [ ] A/B partition strategy (not overwrite-in-place)
- [ ] Signature verification before applying update
- [ ] Watchdog triggers rollback on failed boot
- [ ] Update status reported via MQTT
- [ ] Download is resumable
- [ ] Produces device-spec contract" \
  "- In-place firmware overwrite (bricking risk)
- No signature verification
- No rollback mechanism
- Full re-download on interruption"

# video-streaming
create_eval "shared/evals/video-streaming" "eval-001-rtsp-webrtc-pipeline.md" \
  "RTSP → WebRTC + HLS Pipeline" \
  "video, rtsp, webrtc, hls, sfu, gstreamer" \
  "Design a streaming pipeline that ingests RTSP from 50 IP cameras, delivers live WebRTC streams to browsers (<1s latency), and records HLS segments to S3." \
  "Agent designs GStreamer/FFmpeg pipeline with SFU architecture for WebRTC, TURN server for NAT traversal, HLS recording with S3 lifecycle policies, and camera disconnect handling." \
  "- [ ] RTSP ingestion → transcoding → WebRTC + HLS fork
- [ ] SFU architecture (not P2P for 50 cameras)
- [ ] TURN server for NAT traversal
- [ ] HLS segment lifecycle and S3 retention defined
- [ ] Camera disconnect auto-reconnect
- [ ] Produces streaming-spec contract" \
  "- P2P architecture (won't scale to 50 cameras)
- No TURN server (20% of viewers can't connect)
- No recording retention policy
- No disconnect handling"

create_eval "shared/evals/video-streaming" "eval-002-bandwidth-constrained-site.md" \
  "Bandwidth-Constrained Remote Site" \
  "video, bandwidth, adaptive, edge, recording" \
  "A remote site has 2Mbps uplink shared by 4 cameras. Design a bandwidth-adaptive solution that prioritizes live viewing over recording and degrades gracefully." \
  "Agent designs bandwidth allocation strategy with priority queuing, adaptive bitrate for live streams, local buffering for recording, and graceful degradation plan." \
  "- [ ] Bandwidth budget allocated between live and recording
- [ ] Live viewing gets priority over recording
- [ ] Adaptive bitrate: reduce quality before dropping
- [ ] Local buffering for recording when constrained
- [ ] Degradation strategy documented
- [ ] Produces streaming-spec contract" \
  "- No bandwidth budgeting
- Recording and live compete equally
- Stream drops entirely instead of degrading
- No local buffering"

# edge-agent
create_eval "shared/evals/edge-agent" "eval-001-store-and-forward.md" \
  "Store-and-Forward Edge Gateway" \
  "edge, mqtt, aggregation, sync, offline" \
  "Implement a store-and-forward edge gateway for 100 local sensors: collect MQTT telemetry, filter noise, aggregate 1-minute summaries, and sync to cloud when connectivity is available." \
  "Agent designs local MQTT broker, aggregation pipeline with 60x data reduction, bounded local buffer (7-day retention), and idempotent cloud sync." \
  "- [ ] Local MQTT broker for device-to-edge communication
- [ ] 1-minute aggregation reduces data volume
- [ ] Bounded local buffer (7 days max)
- [ ] Cloud sync is idempotent
- [ ] Works fully offline (local dashboard)
- [ ] Produces implementation-summary" \
  "- No local MQTT broker (devices connect directly to cloud)
- No aggregation (raw data forwarded)
- Unbounded buffer
- Sync not idempotent"

create_eval "shared/evals/edge-agent" "eval-002-edge-ml-deployment.md" \
  "Edge ML Deployment — Person Detection on Jetson" \
  "edge, ml, onnx, jetson, inference" \
  "Deploy a person detection ML model on NVIDIA Jetson. Run inference on video frames, trigger alerts locally, send only alert clips (not full video) to cloud." \
  "Agent configures ONNX Runtime with TensorRT backend, processes video frames at ≥10 FPS, generates local alerts, and uploads only alert clips to save bandwidth." \
  "- [ ] ONNX Runtime with TensorRT backend
- [ ] Only alert clips uploaded (not continuous video)
- [ ] Local alert before cloud sync
- [ ] ≥10 FPS inference rate
- [ ] Produces implementation-summary" \
  "- Streams full video to cloud for processing
- CPU-only inference (too slow)
- No local alerting
- Cloud-dependent operation"

# ml-engineer
create_eval "shared/evals/ml-engineer" "eval-001-vibration-anomaly.md" \
  "Vibration Anomaly Detection for Industrial Equipment" \
  "ml, anomaly-detection, time-series, vibration, predictive-maintenance" \
  "Design an anomaly detection system for vibration sensor data from industrial equipment. Detect bearing failures 24-48h before they occur with false positive rate <5%." \
  "Agent selects appropriate time-series model, defines FFT-based feature engineering, addresses false positive budget, uses temporal train/validation split, and includes drift detection plan." \
  "- [ ] Appropriate time-series model (isolation forest, LSTM autoencoder, or Prophet)
- [ ] False positive rate <5% explicitly addressed
- [ ] FFT features for vibration data
- [ ] Temporal train/validation split (not random)
- [ ] Drift detection plan defined
- [ ] Produces model-spec contract" \
  "- Random train/test split (data leakage)
- No false positive rate consideration
- Generic features (no FFT)
- No drift monitoring"

create_eval "shared/evals/ml-engineer" "eval-002-edge-person-detection.md" \
  "Edge Person Detection on Raspberry Pi 4" \
  "ml, edge, quantization, person-detection, rpi" \
  "Deploy a person detection model to Raspberry Pi 4 (4GB RAM). Must run at ≥10 FPS on 1080p video with <500ms alert latency." \
  "Agent selects lightweight model (YOLOv8-nano or MobileNet), applies INT8 quantization, validates FPS on target hardware, and measures end-to-end alert latency." \
  "- [ ] Lightweight model appropriate for RPi4
- [ ] INT8 quantization applied
- [ ] FPS validated on target hardware
- [ ] End-to-end latency validated
- [ ] Produces model-spec contract" \
  "- Full-size model that won't fit in 4GB RAM
- No quantization (too slow)
- Only tests on GPU server, not RPi4
- No end-to-end latency measurement"

# data-engineer
create_eval "shared/evals/data-engineer" "eval-001-iot-ingestion-pipeline.md" \
  "IoT Telemetry Ingestion Pipeline" \
  "data, kafka, time-series, ingestion, iot" \
  "Design a data ingestion pipeline for 50,000 IoT devices publishing telemetry every 30s. Data must be queryable within 60s and retained for 30 days raw, 1 year aggregated." \
  "Agent designs Kafka-based ingestion with device_id partition key, time-series storage selection with rationale, downsampling strategy, and retention policies." \
  "- [ ] Kafka ingestion with device_id partition key
- [ ] Time-series DB selection with rationale
- [ ] Downsampling: raw 30d → hourly 1y
- [ ] Query latency <60s for recent data
- [ ] Back-pressure handling
- [ ] Produces implementation-summary" \
  "- No Kafka (direct DB writes, won't scale)
- No downsampling (infinite storage growth)
- No retention policy
- No back-pressure handling"

create_eval "shared/evals/data-engineer" "eval-002-video-storage-lifecycle.md" \
  "Video Storage Lifecycle Management" \
  "data, video, s3, lifecycle, storage" \
  "Design video storage for 200 cameras recording 24/7. Instant playback for 7 days, archived access for 1 year. Minimize cost." \
  "Agent designs S3 bucket structure, lifecycle policies (hot→warm→cold→archive), HLS segment management, presigned URLs for playback, and cost estimates." \
  "- [ ] S3 bucket organized by site/camera/date
- [ ] Lifecycle: hot(7d) → warm(30d) → cold(90d) → archive(365d)
- [ ] HLS segment management
- [ ] Presigned URLs for secure playback
- [ ] Cost per camera estimated
- [ ] Produces implementation-summary" \
  "- Flat bucket structure
- No lifecycle policies (all in hot storage)
- Public bucket access
- No cost analysis"

# analytics-engineer
create_eval "shared/evals/analytics-engineer" "eval-001-fleet-health-dashboard.md" \
  "Fleet Health Dashboard" \
  "analytics, dashboard, dbt, grafana, fleet" \
  "Design a fleet health dashboard for 10,000 devices across 50 sites. Show real-time device status, uptime trends, and alert on fleet-wide degradation." \
  "Agent produces data model, dbt transformations, dashboard layout (fleet→site→device drill-down), refresh strategy, and alerting rules." \
  "- [ ] Data model separates raw from derived metrics
- [ ] dbt models for uptime and site health
- [ ] Dashboard: fleet overview → site → device drill-down
- [ ] Real-time status, hourly trends
- [ ] Alert on >5% fleet offline
- [ ] Produces implementation-summary" \
  "- No drill-down capability
- Raw data displayed (no aggregation)
- No alerting
- Manual refresh only"

create_eval "shared/evals/analytics-engineer" "eval-002-alert-metrics.md" \
  "Alert Effectiveness Metrics" \
  "analytics, alerts, metrics, false-positive, fatigue" \
  "Build an alert effectiveness report tracking alert-to-resolution time, false positive rate, and alert fatigue metrics across all customers." \
  "Agent defines metrics clearly, creates dbt models joining alert and resolution events, tracks false positive rate by type, and identifies alert fatigue patterns." \
  "- [ ] Clear metric definitions
- [ ] dbt models joining alerts with resolutions
- [ ] False positive rate per alert type and customer
- [ ] Alert fatigue metric (alerts/day vs response rate)
- [ ] Produces implementation-summary" \
  "- Vague metric definitions
- No join between alerts and resolutions
- No per-customer breakdown
- No fatigue analysis"

# marketing
create_eval "shared/evals/marketing" "eval-001-iot-case-study.md" \
  "IoT Customer Case Study — Oil & Gas" \
  "marketing, case-study, oil-gas, content" \
  "Write a case study for an oil & gas customer who deployed IoT monitoring across 80 wellheads and reduced field visits by 65%." \
  "Agent produces complete case study following template: customer profile, challenge (quantified), solution (technical), results (measured), and customer quote." \
  "- [ ] Follows case study template
- [ ] Quantified results (%, $, time)
- [ ] Technical accuracy
- [ ] Customer quote included
- [ ] Clear call-to-action
- [ ] Produces marketing-brief" \
  "- Generic without quantified results
- Technically inaccurate
- No customer voice
- Feature-focused instead of outcome-focused"

create_eval "shared/evals/marketing" "eval-002-product-positioning.md" \
  "Product Positioning for Manufacturing" \
  "marketing, positioning, messaging, manufacturing" \
  "Create product positioning for IoT remote monitoring targeting manufacturing. Differentiate from SCADA/MES." \
  "Agent creates positioning statement, competitive differentiation (complement not replace SCADA), outcome-led messaging, and objection responses." \
  "- [ ] Clear positioning statement format
- [ ] Differentiation from SCADA
- [ ] Outcome-led messaging
- [ ] Top 3 objections addressed
- [ ] Produces marketing-brief" \
  "- Feature-led messaging
- Positions as SCADA replacement (wrong)
- No competitive differentiation
- Generic audience"

# sales
create_eval "shared/evals/sales" "eval-001-rfp-response.md" \
  "RFP Response — Water Utility" \
  "sales, rfp, proposal, utilities" \
  "Respond to an RFP from a water utility for remote monitoring of 30 treatment plants. Requirements: SCADA integration, NERC CIP compliance, 99.9% uptime." \
  "Agent drafts technical proposal addressing all RFP requirements, with architecture, timeline, pricing, and SLA terms." \
  "- [ ] All RFP requirements addressed
- [ ] Realistic implementation timeline
- [ ] Pricing structured and justified
- [ ] SLA terms specific and achievable
- [ ] Relevant references cited
- [ ] Produces sales-proposal" \
  "- Missing RFP requirements
- Unrealistic timeline
- No pricing breakdown
- SLA terms we can't meet"

create_eval "shared/evals/sales" "eval-002-objection-handling.md" \
  "SCADA Objection Handling" \
  "sales, objection, scada, manufacturing" \
  "Handle: 'We already have SCADA. Why do we need your platform?' Move the conversation forward." \
  "Agent acknowledges SCADA value, differentiates (remote access, video, ML, mobile), provides specific examples, and proposes next step." \
  "- [ ] Acknowledges SCADA value
- [ ] Specific differentiators
- [ ] Data points or examples
- [ ] Forward-moving next step
- [ ] Produces sales-proposal" \
  "- Dismisses SCADA
- Generic response
- No next step proposed
- Adversarial tone"

# customer-success
create_eval "shared/evals/customer-success" "eval-001-device-onboarding.md" \
  "Device Onboarding — 50 Sensors + 8 Cameras" \
  "cs, onboarding, deployment, checklist" \
  "Create onboarding plan for 50 sensors and 8 cameras across 2 sites. Include pre-deployment, installation, validation, and training." \
  "Agent produces comprehensive checklist covering site survey, provisioning, validation, and training with timeline and success criteria." \
  "- [ ] Pre-deployment site survey checklist
- [ ] Device provisioning steps
- [ ] Data validation checklist
- [ ] Customer training plan
- [ ] Produces customer-health" \
  "- No site survey
- Manual provisioning with shared credentials
- No validation step
- No training plan"

create_eval "shared/evals/customer-success" "eval-002-churn-risk.md" \
  "Churn Risk Assessment" \
  "cs, churn, health-score, retention" \
  "Customer health dropped Green→Yellow: uptime 96%, tickets doubled, champion departed. Create risk assessment and action plan." \
  "Agent identifies all risk factors, plans root cause investigation for uptime, strategies for new champion engagement, and creates action plan with owners/deadlines." \
  "- [ ] All risk factors identified with severity
- [ ] Root cause investigation for uptime
- [ ] New champion identification plan
- [ ] Actions with owners and deadlines
- [ ] Produces customer-health" \
  "- Ignores champion departure
- No investigation of uptime drop
- Generic action plan
- No timeline or owners"

# finance
create_eval "shared/evals/finance" "eval-001-unit-economics.md" \
  "Device-Level Unit Economics" \
  "finance, unit-economics, ltv, cac" \
  "Calculate unit economics: \$25/device/month revenue, \$8 connectivity, \$2 cloud. 5,000 devices, 15 customers. Include LTV/CAC." \
  "Agent calculates per-device margin, total COGS breakdown, LTV with assumptions, CAC, LTV/CAC ratio, and margin improvement recommendations." \
  "- [ ] Per-device margin calculated
- [ ] All cost components included
- [ ] LTV with stated assumptions
- [ ] CAC and LTV/CAC ratio
- [ ] Recommendations for improvement
- [ ] Produces financial-report" \
  "- Missing cost components
- No assumptions documented
- No LTV/CAC analysis
- No recommendations"

create_eval "shared/evals/finance" "eval-002-pricing-model.md" \
  "Video Add-on Pricing Model" \
  "finance, pricing, video, tiering" \
  "Design pricing for video surveillance add-on. Consider camera costs, storage (30-day retention), and competitive positioning. Propose tiered pricing." \
  "Agent creates tiered pricing with cost analysis per camera, margin targets >60%, competitive comparison, and packaging rationale." \
  "- [ ] Multiple pricing tiers
- [ ] Cost breakdown per camera/month
- [ ] Margin >60% per tier
- [ ] Competitive comparison
- [ ] Produces financial-report" \
  "- Single price point
- No cost analysis
- Negative margin tiers
- No competitive context"

# legal
create_eval "shared/evals/legal" "eval-001-video-privacy-review.md" \
  "GDPR Video Privacy Review" \
  "legal, gdpr, video, privacy, dpia" \
  "Review video monitoring for GDPR: recording EU sites, AWS eu-west-1 storage, AI person detection. Identify gaps." \
  "Agent assesses lawful basis, data minimization, DPIA requirement, right to erasure challenges, and cross-border transfer risks." \
  "- [ ] Lawful basis assessed
- [ ] Data minimization reviewed
- [ ] DPIA requirement identified
- [ ] Right to erasure challenges documented
- [ ] Cross-border assessment
- [ ] Produces compliance-audit" \
  "- No lawful basis analysis
- Ignores DPIA requirement
- No right to erasure discussion
- Assumes compliance without evidence"

create_eval "shared/evals/legal" "eval-002-sla-drafting.md" \
  "SLA Terms Drafting" \
  "legal, sla, liability, uptime" \
  "Draft SLA: 99.9% uptime, 5-min alert delivery, 1-hour P1 response. Include liability caps and exclusions." \
  "Agent produces SLA with precise uptime definition, credit schedule, liability cap (1-3x fees), standard exclusions, and measurement methodology." \
  "- [ ] Uptime defined precisely
- [ ] Credit schedule for SLA misses
- [ ] Liability cap defined
- [ ] Exclusions listed
- [ ] Alert delivery SLA with measurement
- [ ] Produces compliance-audit" \
  "- Vague uptime definition
- No credit schedule
- Unlimited liability
- No exclusions"

# hr
create_eval "shared/evals/hr" "eval-001-embedded-engineer-jd.md" \
  "Senior Embedded Engineer Job Description" \
  "hr, hiring, jd, embedded, iot" \
  "Write JD for Senior Embedded Software Engineer: Rust/C, MQTT, OTA. Include interview process and 90-day success criteria." \
  "Agent produces specific JD with IoT-focused responsibilities, must-have vs nice-to-have skills, compensation range, interview stages, and measurable success criteria." \
  "- [ ] IoT-specific responsibilities
- [ ] Must-have vs nice-to-have separated
- [ ] Compensation range included
- [ ] Interview process defined
- [ ] 90-day success criteria measurable
- [ ] Produces hiring-plan" \
  "- Generic embedded JD
- No IoT context
- No compensation info
- No success criteria"

create_eval "shared/evals/hr" "eval-002-hiring-sequence.md" \
  "Hiring Sequence — 5 to 15 People" \
  "hr, hiring, sequence, startup, planning" \
  "Plan hiring from 5→15 over 12 months. Current: CTO, backend, embedded, frontend, DevOps. Prioritize and justify." \
  "Agent sequences hires by bottleneck priority, justifies each with specific need, includes realistic timelines, and calculates budget impact." \
  "- [ ] Sequence rationale is bottleneck-driven
- [ ] Each role justified by specific need
- [ ] Realistic timeline (3-6mo for rare skills)
- [ ] Budget impact calculated
- [ ] Produces hiring-plan" \
  "- Random ordering
- Speculative hires
- Unrealistic timeline
- No budget consideration"

# incident-responder
create_eval "shared/evals/incident-responder" "eval-001-video-pipeline-incident.md" \
  "Video Pipeline Incident — SFU Down" \
  "incident, video, triage, p1, sfu" \
  "Video pipeline down: WebRTC failing for all customers, SFU returning 503. RTSP ingestion working. Triage and coordinate response." \
  "Agent classifies as P1, provides ordered triage steps, establishes customer communication, prioritizes mitigation over root cause." \
  "- [ ] Correctly classified as P1
- [ ] Triage steps specific and ordered
- [ ] Customer communication plan
- [ ] Mitigation before root cause
- [ ] Produces incident-report" \
  "- Misclassified severity
- Generic triage
- No customer communication
- Root cause before mitigation"

create_eval "shared/evals/incident-responder" "eval-002-postmortem.md" \
  "Blameless Postmortem — MQTT Broker Config Change" \
  "incident, postmortem, blameless, mqtt" \
  "Write postmortem: 15% of devices disconnected after MQTT broker config change during deployment. 25-minute outage." \
  "Agent produces blameless postmortem with factual timeline, root cause analysis (deployment process gap), action items with owners, and lessons learned." \
  "- [ ] Factual timestamped timeline
- [ ] Root cause beyond symptoms
- [ ] Blameless language
- [ ] Action items with owners and dates
- [ ] Preventive measures
- [ ] Produces incident-report" \
  "- Blames individuals
- Symptoms only (no root cause)
- No action items
- No lessons learned"

# compliance-agent
create_eval "shared/evals/compliance-agent" "eval-001-soc2-gap-analysis.md" \
  "SOC2 Type II Gap Analysis" \
  "compliance, soc2, gap-analysis, security" \
  "SOC2 gap analysis for IoT platform. Have: RBAC, TLS, daily backups. Missing: centralized logging, automated access reviews." \
  "Agent assesses CC6/CC7/A1 controls, acknowledges existing controls, identifies gaps with severity, and creates remediation plan with evidence requirements." \
  "- [ ] All relevant controls assessed
- [ ] Existing controls acknowledged
- [ ] Gaps with severity ratings
- [ ] Remediation plan with owners/timelines
- [ ] Evidence collection plan
- [ ] Produces compliance-audit" \
  "- Incomplete control coverage
- Ignores existing controls
- No severity ratings
- No remediation plan"

create_eval "shared/evals/compliance-agent" "eval-002-gdpr-video.md" \
  "GDPR Assessment — Video + AI in EU" \
  "compliance, gdpr, video, ai, dpia" \
  "GDPR compliance for video + AI person detection in EU. 30-day retention, AWS eu-west-1. No DPIA exists." \
  "Agent identifies missing DPIA as critical, assesses lawful basis for video+AI, reviews data minimization, and documents right to erasure challenges." \
  "- [ ] DPIA identified as critical gap
- [ ] Lawful basis for video+AI assessed
- [ ] Data minimization reviewed
- [ ] Right to erasure challenges noted
- [ ] Produces compliance-audit" \
  "- Misses DPIA requirement
- No lawful basis analysis
- Ignores AI processing implications
- No remediation timeline"

# growth-strategist
create_eval "shared/evals/growth-strategist" "eval-001-vertical-selection.md" \
  "Vertical Selection — Manufacturing vs Oil & Gas" \
  "strategy, vertical, market-analysis, gtm" \
  "5 manufacturing customers. Go deeper in manufacturing or expand to oil & gas? Analyze and recommend with 90-day plan." \
  "Agent analyzes both verticals on market size, buyer, cycle, requirements. Makes clear recommendation with rationale, TAM/SAM, and actionable 90-day plan." \
  "- [ ] Both verticals analyzed
- [ ] Clear recommendation with rationale
- [ ] TAM/SAM estimates sourced
- [ ] 90-day plan with milestones
- [ ] Risk assessment
- [ ] Produces gtm-strategy" \
  "- No analysis, just opinion
- 'It depends' non-answer
- No market sizing
- Vague plan with no milestones"

create_eval "shared/evals/growth-strategist" "eval-002-gtm-strategy.md" \
  "GTM Strategy — Video Upsell to Existing Customers" \
  "strategy, gtm, upsell, video, land-expand" \
  "Launch video surveillance add-on to 15 existing IoT customers (5,000 devices). Design GTM strategy." \
  "Agent leverages existing relationships (land-and-expand), differentiates from standalone VMS, proposes pricing, plans phased rollout, and defines success metrics." \
  "- [ ] Leverages existing customer base
- [ ] VMS differentiation
- [ ] Pricing strategy
- [ ] Phased rollout plan
- [ ] Success metrics defined
- [ ] Produces gtm-strategy" \
  "- Treats as net-new GTM (ignores existing base)
- No differentiation from VMS
- No pricing
- No rollout plan"

# partnerships-agent
create_eval "shared/evals/partnerships-agent" "eval-001-camera-vendor-partnership.md" \
  "Camera Vendor Partnership — Axis Communications" \
  "partnerships, camera, axis, technology, integration" \
  "Evaluate Axis Communications technology partnership for 'Certified Compatible' status and access to dealer network." \
  "Agent creates partnership brief with value exchange, technical scope (VAPIX/ONVIF), certification timeline, success metrics, and risks." \
  "- [ ] Value exchange for both parties
- [ ] Technical scope defined
- [ ] Certification timeline estimated
- [ ] Success metrics
- [ ] Risks with mitigation
- [ ] Produces partnership-brief" \
  "- One-sided value proposition
- No technical scope
- No timeline
- No risk assessment"

create_eval "shared/evals/partnerships-agent" "eval-002-channel-partner.md" \
  "Channel Partner Program Design" \
  "partnerships, channel, reseller, program" \
  "Design channel partner program for system integrators selling/deploying our IoT platform. Define tiers, revenue share, enablement." \
  "Agent creates multi-tier program with revenue model, enablement requirements, deal registration, and conflict resolution." \
  "- [ ] Multiple partner tiers
- [ ] Revenue share per tier
- [ ] Enablement requirements
- [ ] Deal registration process
- [ ] Produces partnership-brief" \
  "- Single tier (no incentive to grow)
- No revenue model
- No enablement
- No conflict resolution"

echo "✅ Part 3 & 4: All evals.json and shared eval markdown files created"
