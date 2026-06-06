<!--
-- ========================================================
-- WEEK 5-6: NHANES DEMOGRAPHIC & HEALTH MODULE INGESTION
-- Enforcing strict relational data types inside Snowflake
-- ========================================================

CREATE OR REPLACE TRANSIENT TABLE NHANES_BRONZE_DEMOGRAPHICS (
    SEQN INT NOT NULL,                  -- Unique Sequence ID (Primary Key)
    RIAGENDR INT,                       -- Gender category code
    RIDAGEYR INT,                       -- Age at time of screening (Years)
    RIDRETH1 INT,                       -- Race/Hispanic origin category code
    DMDEDUC2 INT,                       -- Education Level (Adults 20+)
    DMDMARTL INT,                       -- Marital Status code
    INDFMPIR FLOAT,                     -- Family income-to-poverty ratio
    INGESTION_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TRANSIENT TABLE NHANES_BRONZE_LABORATORY (
    SEQN INT NOT NULL,                  -- Unique Sequence ID (Foreign Key Link)
    LBXGH FLOAT,                        -- Glycohemoglobin (%) - Diabetes proxy
    LBDGLVSI FLOAT,                     -- Fasting Glucose (mmol/L)
    LBXTC FLOAT,                        -- Total Cholesterol (mg/dL)
    INGESTION_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- HCAI Provenance Check: Validate database relational tracking schemas
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE 'NHANES_BRONZE_%';
-->
