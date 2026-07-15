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
