	  
-- select * from dbo.Job_ext
create view [dbo].[Job_step_ext] as 
SELECT  j.[job_id]
      ,j.[name] job_name
      ,j.[description] job_description
      ,j.[enabled] job_enabled
      ,j.[category_name]
      --,[job_schedule_id]
      ,js.[name] schedule_name 
      ,js.[enabled] schedule_enabled
	  ,[step_id]
      ,[step_name]
      ,[subsystem]
      ,[command]
      ,[on_success_action]
      ,[on_success_step_id]
      ,[on_fail_action]
      ,[on_fail_step_id]
      ,[database_name]
      
  FROM [dbo].[Job] j
  inner join dbo.Job_schedule  js on j.job_schedule_id = js.job_schedule_id
  inner join dbo.Job_step s on s.job_id = j.job_id
--  order by j.job_id, s.step_id