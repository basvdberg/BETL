



CREATE view [dbo].[Obj_ext] as 

select * from [dbo].[Obj_ext_all]
where _delete_dt is null --and is_definition=0