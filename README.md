# 💰 Spending Analysis Report

The Problem Statement : Daily financial transactions across various platforms are currently consolidated through manual, daily entry into a single spreadsheet. This approach successfully captures the raw data but fails to provide structured, automated analytics.

The Goal : To establish a method that takes this manually updated, centralized daily log and automatically extracts monthly, category-wise spending insights to better understand financial habits.

> An end-to-end personal finance analytics pipeline built on Databricks — from raw Google Drive expense logs to an interactive BI dashboard.

## 📌 Project Overview

This project is a **complete data engineering and analytics solution** for tracking and analyzing personal monthly expenses. It ingests raw expense data from Google Drive, transforms it through a medallion architecture (Bronze → Silver → Gold), and surfaces insights through an interactive AI/BI dashboard.

The pipeline handles messy real-world data — inconsistent category spellings, non-numeric characters in amount fields, varying date formats — and produces clean, categorized, monthly aggregations ready for visualization.

## 🏗️ Architecture

Google Drive (CSV) → Managed Ingestion (GDrive_ingest) → workspace.gdriveingest.expenses → BRONZE Layer (Gdrive_transform_1.sql → S1_expenses) → SILVER Layer (Gdrive_transform_2.sql → S2_expenses) → GOLD Layer (Category_monthly_report.sql → S3_expenses) → AI/BI Dashboard (Spending Analysis Report)

### Medallion Architecture Details

| Layer | Table | Purpose | Key Transformations |
|-------|-------|---------|-------------------|
| Bronze | workspace.s_expenses.s1_expenses | Raw data landing | Strip non-numeric chars from amount, extract file metadata |
| Silver | workspace.s_expenses.s2_expenses | Cleaned and categorized | Fuzzy category mapping (35+ CASE rules), date normalization, type casting |
| Gold | workspace.s_expenses.s3_expenses | Aggregated reporting | Monthly spend grouped by category, sorted chronologically |

## 🔄 Pipeline Flow

### 1. Data Ingestion (Managed Ingestion Pipeline)
- Source: Google Drive (expense CSV files)
- Pipeline: GDrive_ingest (managed ingestion)
- Target: workspace.gdriveingest.expenses (Unity Catalog table)

### 2. Bronze Transformation
- File: pipeline/bronze/Gdrive_transform_1.sql
- Input: workspace.gdriveingest.expenses
- Output: workspace.s_expenses.s1_expenses (MATERIALIZED VIEW)
- Key: REGEXP_REPLACE to strip non-numeric chars, CAST to DECIMAL(10,2)

### 3. Silver Transformation
- File: pipeline/silver/Gdrive_transform_2.sql
- Input: workspace.s_expenses.s1_expenses
- Output: workspace.s_expenses.s2_expenses (MATERIALIZED VIEW)
- Key: 35+ fuzzy LIKE matching rules for category normalization, date normalization, sub-categorization

### 4. Gold Transformation
- File: pipeline/gold/Category_monthly_report.sql
- Input: workspace.s_expenses.s2_expenses
- Output: workspace.s_expenses.s3_expenses (MATERIALIZED VIEW)
- Key: DATE_FORMAT for month, GROUP BY month + category, SUM amounts

### 5. Orchestration (Lakeflow Job)
- Job: Gdrive_raw_silver
- Task 1: raw_ingest — runs GDrive ingestion pipeline (full refresh)
- Task 2: Silver_transform — runs B_S_expenses SDP pipeline (full refresh, depends on Task 1)
- Status: All historical runs completed successfully ✅

## 📊 Dashboard: Spending Analysis Report

Built with Databricks AI/BI Dashboards (Lakeview):

| Widget | Type | Description |
|--------|------|-------------|
| Report Month Filter | Single-select dropdown | Filter all widgets to a specific month or view all months |
| Total Spends by Month | Line chart (smooth) | Monthly spend trend — ranges from ~28K (July) to ~83K (October) |
| Expenses by Category | Pie chart (faceted by month) | Category-wise spend breakdown per month |
| Detailed Table | Data table | Row-level drill-down: report_month, category, total_amount |

Data Source: workspace.s_expenses.s3_expenses

## 🛠️ Tech Stack

| Component | Technology |
|-----------|------------|
| Cloud Platform | Databricks on AWS |
| Data Storage | Unity Catalog (Delta Lake) |
| Pipeline Framework | Lakeflow Spark Declarative Pipelines (SDP) |
| Ingestion | Databricks Managed Ingestion (Google Drive connector) |
| Orchestration | Lakeflow Jobs |
| SQL Transformations | Spark SQL (MATERIALIZED VIEWS) |
| Visualization | Databricks AI/BI Dashboards (Lakeview) |
| Version Control | Git (GitHub) |

## 📁 Repository Structure

```
Spending-Analysis-Report/
├── README.md                          # Project documentation
├── pipeline/
│   ├── bronze/
│   │   └── Gdrive_transform_1.sql      # Bronze: raw data cleaning
│   ├── silver/
│   │   └── Gdrive_transform_2.sql      # Silver: categorization and normalization
│   └── gold/
│       ├── Category_monthly_report.sql # Gold: monthly category aggregation
│       └── Monthly_total_expenses.sql  # Gold: monthly total aggregation
├── dashboard/
│   └── spending_analysis_report.lvdash.json  # Dashboard definition
├── job/
│   └── gdrive_raw_silver_job.json      # Job orchestration config
└── architecture/
    └── data_flow.md                    # Architecture and data flow details
```

## 🚀 How to Reproduce

### Prerequisites
- Databricks workspace with Unity Catalog enabled
- Google Drive account with expense CSV files
- Databricks SQL Warehouse (for dashboard queries)

### Steps
1. Set up Google Drive ingestion: Create a managed ingestion pipeline in Databricks connecting to your Google Drive folder
2. Create the SDP pipeline: Create a Spark Declarative Pipeline and add the SQL files from pipeline/bronze/, pipeline/silver/, and pipeline/gold/
3. Configure the job: Set up a Lakeflow Job with two tasks (raw ingest then silver transform)
4. Import the dashboard: Use the dashboard/spending_analysis_report.lvdash.json file to recreate the AI/BI dashboard
5. Run the job: Trigger the job to execute the full pipeline, then view the dashboard

## 📈 Key Outcomes

- Automated ETL: Hands-off pipeline from raw CSV files to dashboard-ready aggregates
- Data Quality: Handles messy real-world data with 35+ fuzzy matching rules
- Scalable Architecture: Medallion pattern allows easy addition of new data sources
- Interactive Analytics: Drill-down dashboard with month-level filtering and category-level breakdowns
- Cost Visibility: Monthly spend trends from ~28K to ~83K INR, with category drivers identified

## 📝 About

This is a personal data engineering project showcasing end-to-end analytics pipeline development on Databricks — from data ingestion to interactive visualization. Built as a portfolio piece demonstrating skills in data engineering, cloud data platform, orchestration, analytics, and best practices.

## 📄 License

This project is for personal/portfolio use.
