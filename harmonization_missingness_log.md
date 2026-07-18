# NHANES III Health Data Harmonisation Log

---

### 1. Sentinel Code Resolution
*   **Assumption**: Historical CDC codes of `99` for age and `99.99` for the poverty ratio represent non-responses rather than true biological or financial metrics.
*   **Action**: Implemented conditional `CASE WHEN` SQL checks to convert these numerical flags into database `NULL` states, preventing skew in downstream calculations.

### 2. Multi-Modal Lab Alignment
*   **Assumption**: High-value lab parameters (`8888` / `9999` ranges) flag inadequate blood volume samples or mechanical tracking failures.
*   **Action**: Stripped out out-of-bound sentinel values across Cotinine, Vitamin D, and TSH arrays. 

### 3. Cohort Consolidation
*   **Assumption**: A health profile is only useful for algorithmic bias auditing if both demographic identity traits and biological outcomes are simultaneously visible.
*   **Action**: Executed a strict relational `INNER JOIN` over `PARTICIPANT_SEQN` keys, removing unanchored or orphaned entries and creating a consolidated participant profile matrix.

### 4. Missingness & Validity Summary

Diagnostic profile metrics over 18,162 joined records to track missing data and sentinel values:

*   **INTERVIEW_AGE**: 0 anomalies (0.00%). 100% clean data profile.
*   **POVERTY_INCOME_RATIO**: 1,789 sentinel codes (9.85%). Records converted to NULL due to missing survey income lines.
*   **COTININE_LEVEL**: 1,132 out-of-bound values (6.23%). Converted to NULL due to machine dropouts or low sample volumes.
*   **VITAMIN_D_LEVEL**: 0 anomalies (0.00%). 100% clean data profile.
*   **THYROID_STIMULATING_HORMONE**: 1,848 sentinel codes (10.18%). Highest missingness rate in the cohort; converted to NULL.

### 🏁 Data Validity Verdict
All out-of-bound sentinel values are converted to database NULL markers to isolate invalid rows. This ensures the `PARTICIPANT_HEALTH_SILVER` table prevents distorted statistical skews during downstream modeling.
