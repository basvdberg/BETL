


	  
CREATE view [dbo].[Transfer_ext] as 
select 
t.[transfer_id]
,t.[transfer_name]
,t.[src_obj_id]
,t.[trg_obj_id]
,t.[trg_obj_name]
,t.[transfer_start_dt] AT TIME ZONE 'UTC' AT TIME ZONE 'Central Europe Standard Time' [transfer_start_dt] 
,t.[transfer_end_dt] AT TIME ZONE 'UTC' AT TIME ZONE 'Central Europe Standard Time' [transfer_end_dt] 
,s.status_name transfer_status
,t.[rec_cnt_src]
,t.[rec_cnt_new]
,t.[rec_cnt_changed]
,t.[rec_cnt_deleted]
,t.[last_error_id]
,b.batch_id
, b.[batch_start_dt] AT TIME ZONE 'UTC' AT TIME ZONE 'Central Europe Standard Time' [batch_start_dt]  
,b.[batch_end_dt]  AT TIME ZONE 'UTC' AT TIME ZONE 'Central Europe Standard Time' [batch_end_dt]  
, b.batch_name
, s.status_name batch_status 
from dbo.Transfer t
left join dbo.Batch b on t.batch_id = b.batch_id 
left join static.Status s on s.status_id = t.status_id