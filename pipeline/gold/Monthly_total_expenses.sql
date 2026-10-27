-- Gold Layer: Monthly total expenses aggregation
-- Pipeline: B_S_expenses (Spark Declarative Pipeline)
-- Input:  workspace.s_expenses.s2_expenses (Silver MATERIALIZED VIEW)
-- Output: workspace.s_expenses.s3_monthly_expenses (MATERIALIZED VIEW)
-- Key: DATE_FORMAT for month grouping, SUM all amounts

CREATE OR REFRESH MATERIALIZED VIEW workspace.s_expenses.S3_monthly_expenses AS
SELECT 
    DATE_FORMAT(spent_date, 'yyyy-MM') AS report_month, 
    SUM(spends_in_inr) AS total_amount
FROM 
    workspace.s_expenses.s2_expenses
GROUP BY 
    DATE_FORMAT(spent_date, 'yyyy-MM')