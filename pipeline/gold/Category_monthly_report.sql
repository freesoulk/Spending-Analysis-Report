-- Gold Layer: Monthly Category Report
-- Pipeline: B_S_expenses (Spark Declarative Pipeline)
-- Input:  workspace.s_expenses.s2_expenses (Silver)
-- Output: workspace.s_expenses.s3_expenses (MATERIALIZED VIEW)
-- Purpose: Aggregate spend by month and category for dashboard consumption

CREATE OR REFRESH MATERIALIZED VIEW workspace.s_expenses.S3_expenses AS
SELECT 
    DATE_FORMAT(spent_date, 'yyyy-MM') AS report_month, 
    category,
    SUM(spends_in_inr) AS total_amount
FROM 
    workspace.s_expenses.s2_expenses
GROUP BY 
    DATE_FORMAT(spent_date, 'yyyy-MM'),  
    category
ORDER BY 
    report_month ASC