CREATE view Logging_ext as 

SELECT [log_id]
      ,[log_dt]   AT TIME ZONE 'UTC' AT TIME ZONE 'Central Europe Standard Time' [log_dt]  
      ,[msg]
      ,[transfer_id]
      ,[batch_id]
      ,[log_level_id]
      ,[log_type_id]
      ,[exec_sql]
  FROM [dbo].[Logging]