# Data Flow Architecture

## Overview

This document describes the end-to-end data flow for the Spending Analysis Report project.

## Pipeline Stages

### Stage 1: Data Ingestion (Google Drive to Unity Catalog)
- Component: Databricks Managed Ingestion Pipeline (GDrive_ingest)
- Source: Google Drive folder containing expense CSV files
- Target Table: workspace.gdriveingest.expenses
- Columns: Date, Category, Desc, Note, amount (string with non-numeric chars), _file_metadata (struct)

### Stage 2: Bronze Layer (Raw Cleaning)
- Component: Spark Declarative Pipeline (B_S_expenses)
- File: pipeline/bronze/Gdrive_transform_1.sql
- Input: workspace.gdriveingest.expenses
- Output: workspace.s_expenses.s1_expenses (MATERIALIZED VIEW)
- Transformations: REGEXP_REPLACE to strip non-numeric chars, CAST to DECIMAL(10,2), extract file metadata

### Stage 3: Silver Layer (Categorization and Normalization)
- Component: Spark Declarative Pipeline (B_S_expenses)
- File: pipeline/silver/Gdrive_transform_2.sql
- Input: workspace.s_expenses.s1_expenses
- Output: workspace.s_expenses.s2_expenses (MATERIALIZED VIEW)
- Transformations: 35+ fuzzy LIKE rules for category mapping, date normalization (d/M/yyyy to dd/MM/yyyy), sub-categorization (fuel 2W vs 4W by amount), amount casting to INT

### Stage 4: Gold Layer (Aggregation)
- Component: Spark Declarative Pipeline (B_S_expenses)
- File: pipeline/gold/Category_monthly_report.sql
- Input: workspace.s_expenses.s2_expenses
- Output: workspace.s_expenses.s3_expenses (MATERIALIZED VIEW)
- Transformations: DATE_FORMAT for month extraction, GROUP BY month + category, SUM amounts, ORDER BY month

### Stage 5: Visualization (AI/BI Dashboard)
- Component: Databricks AI/BI Dashboard (Lakeview)
- Dashboard: Spending Analysis Report
- Data Source: workspace.s_expenses.s3_expenses
- Widgets: Line chart (monthly trends), Pie chart (category breakdown), Filter (month selector), Table (drill-down)

## Orchestration
- Component: Lakeflow Job (Gdrive_raw_silver)
- Task 1: raw_ingest (GDrive ingestion pipeline, full refresh)
- Task 2: Silver_transform (B_S_expenses SDP pipeline, full refresh, depends on Task 1)
- All historical runs completed successfully