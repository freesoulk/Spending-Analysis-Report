{
  "job_name": "Gdrive_raw_silver",
  "description": "Orchestrates the full pipeline: Google Drive ingestion then Bronze/Silver/Gold transformations",
  "max_concurrent_runs": 1,
  "performance_target": "PERFORMANCE_OPTIMIZED",
  "tasks": [
    {
      "task_key": "raw_ingest",
      "description": "Run managed ingestion pipeline to pull expense CSVs from Google Drive into Unity Catalog",
      "type": "pipeline_task",
      "pipeline_id": "d9e4aba9-4cd7-404b-9516-48aae982d053",
      "pipeline_name": "GDrive_ingest",
      "full_refresh": true,
      "depends_on": []
    },
    {
      "task_key": "Silver_transform",
      "description": "Run B_S_expenses Spark Declarative Pipeline (Bronze to Silver to Gold)",
      "type": "pipeline_task",
      "pipeline_id": "ce5b572b-64f0-4796-8101-0e4cc1c63e70",
      "pipeline_name": "B_S_expenses",
      "full_refresh": true,
      "depends_on": ["raw_ingest"]
    }
  ],
  "run_history": {
    "total_runs": 5,
    "all_successful": true,
    "last_run_status": "SUCCESS"
  }
}