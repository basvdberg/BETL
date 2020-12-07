
	  
CREATE  view [dbo].[Obj_transfer] as 
select o.[schema_name], obj_id,  full_obj_name,  obj_type, max_transfer_dt
from dbo.Obj_ext o
left join ( 
	select src_obj_id , max([transfer_start_dt])  max_transfer_dt
	from dbo.transfer 
	where status_id= 100 -- success
	and src_obj_id is not null and [transfer_start_dt] is not null 
	group by src_obj_id 
) t	on o.obj_id = t.src_obj_id 
where 
 full_obj_name like '%stg%%' 
and obj_type in ('view', 'table') 

--order by [schema_name], full_obj_name