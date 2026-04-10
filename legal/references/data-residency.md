# Data Residency Requirements

## By Region

### European Union (GDPR)
- Personal data (including video of people) must stay in EU unless adequate safeguards
- Options: EU cloud regions, Standard Contractual Clauses, Binding Corporate Rules
- Some customers require: specific EU country (Germany for German customers)

### Middle East
- UAE: data localization for government and financial services
- Saudi Arabia: PDPL requires data to stay in KSA for certain sectors
- Growing trend toward local data centers

### Asia-Pacific
- China: PIPL requires personal data to stay in China
- India: proposed data localization for "critical" personal data
- Australia: Australian Privacy Principles — no strict localization, but adequacy required

## By Industry
- **Financial services:** often require data in same country as operations
- **Healthcare:** HIPAA (US) — no strict localization, but BAA required
- **Government:** almost always requires on-premises or sovereign cloud
- **Oil & gas:** operational data sometimes classified as critical infrastructure

## Technical Approaches

### Regional Deployments
```
EU customers → eu-west-1 (Ireland) or eu-central-1 (Frankfurt)
US customers → us-east-1 (Virginia) or us-west-2 (Oregon)
ME customers → me-south-1 (Bahrain)
```

### Data Localization
- Video and telemetry: stored in customer's region only
- Metadata (anonymized): may be processed centrally for analytics
- Edge processing: keep raw data on-premises, send only summaries to cloud

### Customer-Controlled Encryption Keys
- Customer manages encryption keys (BYOK — Bring Your Own Key)
- We cannot access data without customer's key
- Adds complexity but addresses sovereignty concerns
