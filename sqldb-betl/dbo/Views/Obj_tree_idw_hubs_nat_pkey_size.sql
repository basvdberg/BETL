
CREATE view [dbo].[Obj_tree_idw_hubs_nat_pkey_size] as 

	select obj_name, count(*) nat_pkey_size
	from [dbo].[Obj_tree_idw_hub_cols]  h
	where column_type_id in ( 100,105) 
	group by obj_name