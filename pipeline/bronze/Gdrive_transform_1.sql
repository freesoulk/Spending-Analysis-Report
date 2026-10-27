-- Bronze Layer: Raw Data Cleaning
-- Pipeline: B_S_expenses (Spark Declarative Pipeline)
-- Input:  workspace.gdriveingest.expenses (Google Drive managed ingestion table)
-- Output: workspace.s_expenses.s1_expenses (MATERIALIZED VIEW)

CREATE OR REFRESH MATERIALIZED VIEW workspace.s_expenses.S1_expenses AS
SELECT 
    Date,
    Category,
    `Desc`,
    Note,
    CAST(REGEXP_REPLACE(amount, '[^0-9.]', '') AS DECIMAL(10,2)) AS Amount_in_INR,
    `_file_metadata`.file_modification_time AS Row_recivied_time
FROM workspace.gdriveingest.expenses