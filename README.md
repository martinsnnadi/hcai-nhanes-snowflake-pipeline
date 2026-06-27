# NHANES III Ingestion Pipeline
### HCAI Data Warehouse Track | Snowflake Engine

**Supervisor:** Prof. Solomon Sunday Oyelere  
**Milestone:** Week 8 (Bronze Validation & Schema Humanization)

---

## 1. Project & Dataset Profile

Automated parsing, data-type normalization, and secure staging infrastructure for the NHANES III historical cohort. 

### Ingestion Governance & Scoping
*   **Demographics**: Sourced from the **Release 1A Household Adult File (`ADULT.DAT`)** to isolate protected baseline attributes.
*   **Laboratory**: Bypassed Release 1A laboratory files due to documented CDC machine calibration defects. Pipelines route explicitly to the corrected **Second Laboratory 2A File (`LAB2.DAT`)** to ensure data integrity.

---

## 2. Infrastructure Case Study: Bypassing Sandbox Constraints

### The Egress Blocker
Snowflake trial accounts enforce a strict **Zero-Outbound Network Policy**, causing immediate `NameResolutionError` faults when calling external CDC APIs.

### The ELT Resolution
*   Pivoted from an external streaming script to an internal **ELT (Extract, Load, Transform) Architecture**.
*   Raw `.DAT` source structures contain packed fixed-width text with no column delimiters. Uploaded assets directly to internal staging areas with **`FIELD_DELIMITER = NONE`** configurations.
*   This forced Snowflake to load each unbroken row as an intact string block inside a singular `RAW_RECORD VARCHAR` column, handling all parsing computations natively.

---

## 3. Native SQL Byte Slicing & Schema Humanization

Engineered high-performance SQL transformation steps to slice strings inside the warehouse. Replaced rigid `CAST` operators with defensive **`TRY_CAST`** logic to safely catch blank spaces or sentinel codes, while converting cryptic CDC codenames to human-readable variables:

### Demographics Layer (`RAW_DEMO_STAGE`)
*   `PARTICIPANT_SEQN` (ID Anchor) ➔ `SUBSTR(RAW_RECORD, 1, 5)`
*   `BIOLOGICAL_SEX` (Sex profile) ➔ `SUBSTR(RAW_RECORD, 15, 1)`
*   `INTERVIEW_AGE` (Interview age) ➔ `SUBSTR(RAW_RECORD, 18, 2)` *(Corrected from positions 16-17 to resolve screener month skew)*
*   `RACE_ETHNICITY_CODE` (Ethno-demographic group) ➔ `SUBSTR(RAW_RECORD, 12, 1)`
*   `POVERTY_INCOME_RATIO` (Financial index) ➔ `SUBSTR(RAW_RECORD, 36, 6)` *(Captured via native embedded decimal indices)*

### Laboratory Layer (`RAW_LAB_STAGE`)
*   `PARTICIPANT_SEQN` (ID Anchor) ➔ `SUBSTR(RAW_RECORD, 1, 5)`
*   `COTININE_LEVEL` (Tobacco exposure marker) ➔ `SUBSTR(RAW_RECORD, 1246, 4)`
*   `VITAMIN_D_LEVEL` (Nutritional status) ➔ `SUBSTR(RAW_RECORD, 1255, 5)`
*   `THYROID_STIMULATING_HORMONE` (Metabolic regulator) ➔ `SUBSTR(RAW_RECORD, 1274, 5)`

```sql
-- Architectural Snippet: High-Performance Data Slicing
INSERT INTO DEMOGRAPHICS_BRONZE (PARTICIPANT_SEQN, BIOLOGICAL_SEX, INTERVIEW_AGE, POVERTY_INCOME_RATIO)
SELECT 
    TRY_CAST(SUBSTR(RAW_RECORD, 1, 5) AS INT) AS PARTICIPANT_SEQN,
    TRY_CAST(SUBSTR(RAW_RECORD, 15, 1) AS INT) AS BIOLOGICAL_SEX,
    TRY_CAST(SUBSTR(RAW_RECORD, 18, 2) AS INT) AS INTERVIEW_AGE,
    TRY_CAST(SUBSTR(RAW_RECORD, 36, 6) AS FLOAT) AS POVERTY_INCOME_RATIO
FROM RAW_DEMO_STAGE;
```

---

## 4. Data Lineage & Week 8 Validation Audits

### Lineage Metadata
Appended a non-nullable execution tracker column: `PIPELINE_INGEST_TS TIMESTAMP_NTZ`. Because Snowflake restricts dynamic expression defaults during standard table adjustments (`ALTER TABLE ADD COLUMN`), I utilized a two-step pattern: adding the column as an open field first, then running an explicit database `UPDATE` to backfill arrival timestamps.

### Quality Check Verification Profiles
Deployed automated data quality scripts to enforce constraints before rows advance to downstream Silver bias tools:
*   **Primary Key Validation**: Monitors group counts to block duplication inside `PARTICIPANT_SEQN`.
*   **Null-Parsing Performance**: Tracks the percentage of elements that resolve to `NULL` during `TRY_CAST` operations to verify character offsets.
*   **Inter-Table Reference Scan**: Flags orphaned laboratory items that lack a matching demographic anchor profile.

---

## 5. Getting Started inside Snowflake

1. Log into **Snowflake (Snowsight)** and open a fresh SQL Worksheet.
2. Execute the DDL statements in **`models/nhanes_bronze_schema.sql`** to initialize target storage tables.
3. Upload local `adult.dat` and `lab2.dat` files into your database staging structures via the Data UI, ensuring column splitters are disabled (`FIELD_DELIMITER = NONE`).
4. Run the native transformation queries to slice the raw text blocks and populate your conformed data tables.
