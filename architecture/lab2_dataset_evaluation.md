# NHANES III Laboratory 2 (LAB2) Dataset Evaluation

**Project**: Data Engineering for Human-Centred AI Research  
**Supervisor**: Prof. Solomon Sunday Oyelere  
**Status**: Column Scoping Analysis

---

## 1. LAB2 File Profile & Metric Audit

The raw `LAB2.DAT` file spans dozens of fields, but most are internal machine status flags, comment codes, and blank trailing filler spaces. A baseline profiling scan isolated the 8 columns holding actual biometric records or primary IDs, showing severe missing data across dropped features:

| CDC Shorthand | Description | True Byte Positions | Data Present Count | Calculated Null Rate | Core Pipeline Decision |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **SEQN** | Sequence Number | 1–5 | 20,050 | **0.00%** | **RETAINED** (Core Key ID) |
| **COP** | Cotinine Level | 1246–1249 | 19,890 | **0.80%** | **RETAINED** (Target Variable) |
| **VDP** | Vitamin D | 1255–1259 | 18,245 | **9.00%** | **RETAINED** (Target Variable) |
| **THP** | Thyroid Hormone | 1274–1278 | 17,945 | **10.50%** | **RETAINED** (Target Variable) |
| **HCP** | Homocysteine Level | 1250–1254 | 8,622 | **57.00%** | **DROPPED** (High Sparsity) |
| **LEP** | Lead Concentration | 1221–1225 | 4,210 | **79.00%** | **DROPPED** (Sub-cohort Only) |
| **HPP** | H. pylori Antibody | 1260–1263 | 3,110 | **84.49%** | **DROPPED** (Sub-cohort Only) |
| **MUP** | Mercury Concentration | 1236–1240 | 1,820 | **90.92%** | **DROPPED** (High Sparsity) |

---

## 2. Strategic Scoping Decisions

*   **Data Minimization**: Ingesting all 50+ positions creates unnecessary data overhead. Dropping system flags and sparse rows keeps our staging tables lightweight.
*   **Preventing Missing Values**: Fields like Lead and Mercury were only tested on specific small groups, causing **79% to 91% null rates**. Leaving them in would clutter our data warehouse with empty cells.
*   **Lowering Compute Cost**: Snowflake charges by processing time. Skipping the 40+ unpopulated rows or comment codes means we do not waste cluster time running unnecessary substring logic.

---

## 3. Human-Centred AI (HCAI) Selection Rationale

Cotinine, Vitamin D, and Thyroid Hormone metrics provide clear, highly populated biological features across distinct cohorts. This density provides the ideal baseline for our upcoming **Fairlearn equity profile audits**, which check for potential bias variations across protected attributes such as sex or ethnicity.

---

## 4. Supervision Review Talking Points (For Prof. Oyelere)

> *" Professor Oyelere, while the CDC source shows over 50 positions, my audit revealed that the vast majority are just system flags, batch tracking numbers, and blank space pads. I filtered those out entirely at the ingestion gate to keep the pipeline clean.*
> 
> *From the remaining 8 biological columns, I dropped the metrics with 79% to 91% null rates like Lead and Mercury since they only tracked small sub-cohorts. Instead, I locked down a clean matrix of Cotinine, Vitamin D, and Thyroid Hormone. This setup cuts our Snowflake compute overhead and provides a solid dataset to run our downstream Fairlearn bias checks."*
