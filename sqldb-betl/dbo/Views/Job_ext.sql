	  

-- select * from dbo.Job_ext
CREATE view [dbo].[Job_ext] as 
SELECT  j.[job_id]
      ,j.[name] job_name
      ,j.[description] job_description
      ,j.[enabled] job_enabled
      ,j.[category_name]
      ,j.[job_schedule_id]
      ,js.[name] schedule_name 
      ,js.[enabled] schedule_enabled
      ,[freq_type]
      ,[freq_interval]
      ,[freq_subday_type]
      ,[freq_subday_interval]
      ,[freq_relative_interval]
      ,[freq_recurrence_factor]
      ,[active_start_date]
      ,[active_end_date]
      ,[active_start_time]
      ,[active_end_time]
  FROM [dbo].[Job] j
  inner join dbo.Job_schedule  js on j.job_schedule_id = js.job_schedule_id
  --inner join dbo.Job_step s on s.job_id = j.job_id
--  order by j.job_id, s.step_id