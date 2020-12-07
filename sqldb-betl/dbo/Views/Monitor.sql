

--select * from Logging
--select * from Batch_ext
-- select * from Monitor order by 1 desc
create view [dbo].[Monitor] as 

select replicate(' ', 5-len(batch_id))+ isnull(batch_id,'') + isnull('.'+ replicate(' ', 5-len(transfer_id))+ transfer_id, '') +'.'+  format (start_dt, 'yyyyMMdd.HHmmss.fff') 
id   ,  batch_name, transfer_name, msg, start_dt, end_dt, datediff(second, start_dt, end_dt) duration_sec, [status]  
, rec_cnt_src, rec_cnt_new, rec_cnt_changed, rec_cnt_deleted, rec_cnt_undeleted
from 
( 
	select convert(varchar(10), b.batch_id) batch_id , b.batch_name [batch_name] , '0' transfer_id, null transfer_name, null msg, b.batch_start_dt start_dt, b.batch_end_dt end_dt, batch_status [status], null rec_cnt_src, null rec_cnt_new, null rec_cnt_changed, null rec_cnt_deleted, null rec_cnt_undeleted
	from dbo.Batch_ext b 
	union all 
	select convert(varchar(10),t.batch_id), null, convert(varchar(10), nullif(t.transfer_id,-1)) transfer_id  , t.transfer_name, null msg, t.transfer_start_dt, t.transfer_end_dt, t.transfer_status [status], null rec_cnt_src, null rec_cnt_new, null rec_cnt_changed, null rec_cnt_deleted, null rec_cnt_undeleted
	from Transfer_ext t
	union all 
	select convert(varchar(10),isnull(nullif(l.batch_id,-1) , t.batch_id)) , null batch_name, convert(varchar(10), isnull(nullif(l.transfer_id,-1),0) )  , null transfer_name, msg msg, l.log_dt start_dt, null end_dt, null status , rec_cnt_src, rec_cnt_new, rec_cnt_changed, rec_cnt_deleted, rec_cnt_undeleted
	from Logging_ext l
	left join dbo.Transfer t on l.transfer_id = t.transfer_id 
) q
where start_dt > dateadd(day,-3, getdate()) 

--order by 1 desc

/*
t.transfer_id, t.transfer_name--, l.* 
from Transfer_ext t
left join dbo.Batch_ext b on b.batch_id=t.batch_id
--full outer join Logging l on (l.transfer_id <> -1 and l.transfer_id = t.transfer_id) or (l.batch_id <> -1 and l.batch_id = b.batch_id) 


*/