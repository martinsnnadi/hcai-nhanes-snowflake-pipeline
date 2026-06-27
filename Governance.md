# 📜 HCAI Multi-Cloud Data Stewardship Matrix

This document establishes the official data ownership and operational accountability boundaries for Milestone 2, as reviewed by Professor Solomon Sunday Oyelere.

| Cloud Infrastructure | Data Domain | Technical Custodian (Pipeline Maintenance) | Compliance & Academic Owner |
| :--- | :--- | :--- | :--- |
| **Microsoft Fabric OneLake** | OULAD (Education Analytics) | Martins Nnadi | Professor Solomon Sunday Oyelere |
| **Snowflake Warehouse** | NHANES III (Health Metrics) | Martins Nnadi | Institutional Review Board (IRB) / Health Lead |
| **Amazon AWS S3 Tier** | WESAD (Biometric Telemetry) | Martins Nnadi | Wearable Computing Lab Director |

### Data Management Policies Enforced:
1. **AWS S3 Lifecycle:** Raw biometric elements in `hcai-wesad-bronze-landing` transition to GLACIER at Day 180 and purge completely at Day 365.
2. **Metadata Rule:** No dataset may be exposed to the Silver processing layer without an active `PIPELINE_INGEST_TS` lineage column present.
