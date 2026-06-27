# HCAI Multi-Cloud Data Stewardship Matrix

Official data ownership and operational accountability boundaries for Milestone 2.

| Cloud Infrastructure | Data Domain | Technical Custodian | Compliance & Academic Owner |
| :--- | :--- | :--- | :--- |
| **Microsoft Fabric OneLake** | OULAD (Education Analytics) | Martins Nnadi | Prof. Solomon Sunday Oyelere |
| **Snowflake Warehouse** | NHANES III (Health Metrics) | Martins Nnadi | Institutional Review Board (IRB) / Health Lead |
| **Amazon AWS S3 Tier** | WESAD (Biometric Telemetry) | Martins Nnadi | Wearable Computing Lab Director |

### Enforced Data Management Policies:
1. **AWS S3 Lifecycle**: Raw biometric assets in `hcai-wesad-bronze-landing` transition to GLACIER at Day 180 and permanently purge at Day 365.
2. **Metadata Lineage Gate**: No dataset may advance to the Silver processing layer unless the `PIPELINE_INGEST_TS` lineage tracking column is present and active.
