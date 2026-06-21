# 🔬 National Health and Nutrition Examination Survey (NHANES III)
### HCAI Cloud Data Warehouse Track | Version 1.0 (Snowflake)

**Academic Supervisor:** Professor Solomon Sunday Oyelere  
**Project Horizon:** 24-Week Parallel Processing Research Roadmap  
**Current Milestone:** Week 8 (Bronze Layer Validation & Schema Humanization)

---

## 📋 1. Project & Dataset Profile

This repository houses the secure, high-performance data warehousing architecture built for the **NHANES III Historical Cohort**. It handles the automated extraction, parsing, and data-type normalization of human demographic and biochemical markers before passing them to downstream Human-Centered AI (HCAI) equity checks.

### 📊 Ingestion Scoping & Quality Governance
Rather than blindly streaming data tables, this pipeline executes a strategic, audited extraction policy to ensure data quality:
*   **Demographics Module:** Extracted from the core **Release 1A Household Adult File (`ADULT.DAT`)** to isolate baseline identity variables.
*   **Laboratory Module:** Bypassed the original Release 1A laboratory files due to documented CDC machine calibration anomalies. To ensure absolute data integrity, the pipeline explicitly routes to the re-issued **Second Laboratory 2A File (`LAB2.DAT`)** to extract biochemically accurate patient records.

---

## ⚙️ 2. Cloud Architecture Case Study: Overcoming Trial Sandbox Restrictions

During the active deployment phase within Snowflake, the architecture encountered a major cloud security boundary:
*   **The Problem:** Snowflake trial sandbox profiles enforce a strict **Zero-Outbound Network Policy**, completely blocking external access integrations and throwing immediate compilation `NameResolutionError` faults.
*   **The Pivot:** Transitioned from a programmatic API streaming model to an optimized internal **ELT (Extract, Load, Transform) Architecture**. 
*   **The Parsing Challenge:** Historical NHANES III raw files are tightly packed fixed-width `.DAT` blocks with no delimiters or commas. A standard file configuration reader will completely scramble the records.
*   **The Resolution:** The pipeline utilizes the Snowflake Data UI to stage the files natively inside the database, enforcing an abstract **`FIELD_DELIMITER = NONE`** property. This forces Snowflake to ingest each unbroken text row as an intact string block inside a single `RAW_RECORD VARCHAR` column, pushing all parsing logic to the data warehouse's engine.

---

## 🛠️ 3. Native SQL Byte Slicing & Schema Humanization

Once the strings are staged, a high-performance SQL transformation parses the rows natively. This layer implements the precise byte configurations from our layout audit, shifting to a defensive **`TRY_CAST`** pattern to prevent blank records from crashing the platform while renaming cryptic CDC variables into plain, clear English names:

### 👤 Demographics Layer (`RAW_DEMO_STAGE`)
*   `PARTICIPANT_SEQN`: Sequence ID Key ➔ `SUBSTR(RAW_RECORD, 1, 5)`
*   `BIOLOGICAL_SEX`: Gender Assignment ➔ `SUBSTR(RAW_RECORD, 15, 1)`
*   `INTERVIEW_AGE`: Core Age ➔ `SUBSTR(RAW_RECORD, 18, 2)` *(Corrected from bytes 16-17 to prevent screener month skew)*
*   `RACE_ETHNICITY_CODE`: Socio-demographic marker ➔ `SUBSTR(RAW_RECORD, 12, 1)`
*   `POVERTY_INCOME_RATIO`: Financial index ➔ `SUBSTR(RAW_RECORD, 36, 6)` *(Mapped with native embedded decimal layout)*

### 🧪 Laboratory Layer (`RAW_LAB_STAGE`)
*   `PARTICIPANT_SEQN`: Mapping Key ➔ `SUBSTR(RAW_RECORD, 1, 5)`
*   `COTININE_LEVEL`: Tobacco exposure biochemical marker ➔ `SUBSTR(RAW_RECORD, 1246, 4)`
*   `VITAMIN_D_LEVEL`: 25-hydroxyvitamin D status ➔ `SUBSTR(RAW_RECORD, 1255, 5)`
*   `THYROID_STIMULATING_HORMONE`: Metabolic regulator ➔ `SUBSTR(RAW_RECORD, 1274, 5)`

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

## 🛡️ 4. Data Lineage & Week 8 Validation Audits

### 📋 Lineage Metadata
To meet core HCAI governance guidelines, every table is appended with a non-nullable execution marker: **`PIPELINE_INGEST_TS TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()`**. Because Snowflake restricts dynamic expression defaults during standard table adjustments, the pipeline utilizes a two-step script pattern: adding the column as an open field first and executing an explicit database `UPDATE` update block to backfill arrival histories.

### 🔍 Week 8 Verification Script
The repository incorporates automated quality check profiles to verify structural integrity before data advances to downstream bias tools:
*   **Primary Key Validation:** Checks for duplication anomalies within the primary key columns (`PARTICIPANT_SEQN`).
*   **Null-Parsing Performance:** Tracks the percentage of data elements that failed to parse correctly during `TRY_CAST` string slicing.
*   **Inter-Table Reference Scan:** Identifies and isolates unanchored laboratory items that do not map to a matching demographic profile.

---

## 🚀 5. Getting Started inside Snowflake

1. Open your web browser, log into your **Snowflake Web Interface (Snowsight)**, and create a new SQL Worksheet.
2. Run the initialization statements inside **`models/nhanes_bronze_schema.sql`** to prepare your clean target tables.
3. Upload your local `adult.dat` and `lab.dat` files into your staged database objects via the Data dashboard, checking that column delimiters are disabled (`FIELD_DELIMITER = NONE`).
4. Execute the native transformation block to slice the rows and populate your plain English data catalogs.
