


--  select * from [dbo].[Obj_tree_rdw_tables]
CREATE view [dbo].[Obj_tree_rdw_tables] as 

with staging_views as ( 
	select 
	so.obj_id
	, so.db_name
	, 'rdw' schema_name 
	,  so.obj_name obj_name
	, so.schema_obj_name table_name
	, so.[server_name] server_name  -- _target because this object tree is not made persistent. It represents how RDW should look ( but not how it currently looks). 
	, so.server_type_id
	, so._source
	from dbo.obj_ext so
	left join ( 
		select obj_id, count(*) cnt
		from dbo.col
		where column_type_id= 100 -- nat-pkey
		group by obj_id
	) cnt_nat_pkey on cnt_nat_pkey.obj_id = so.obj_id
	where so.obj_type in ( 'view')
	and so.db_name = 'sqldb_ddppoc'
	and so.schema_name = 'staging'
	and isnull(cnt_nat_pkey.cnt,0) > 0 
	and so.server_name = @@servername
) , joined as ( 
	-- join with columns except meta data columns 999
	SELECT 
		st.obj_id, 
		st.server_type_id
		 , st.server_name
		, st.db_name -- target db name
		, st.[schema_name] 
		, st.obj_name 
		, 10 obj_type_id --table 
		,[ordinal_position]
		,[column_name]
		, column_type_id 
		 ,[is_nullable]
		  ,[data_type] 
		  ,[max_len] 
		  ,[numeric_precision]
		  ,[numeric_scale]
		  ,case when column_type_id = 100 and primary_key_sorting is null then 'DESC' else primary_key_sorting end primary_key_sorting
		  ,[default_value]
		  , _source
	from staging_views st
	left  join dbo.Col_ext col on col.obj_id =  st.obj_id 
	where col.Column_type_id<> 999 -- skip meta data fields from staging... 
	and col._delete_dt is null 

union all 
	-- union with static columns for RDW
	select 
	obj_id, 
		st.server_type_id
		 , st.server_name
		, st.db_name -- target db name
		, st.[schema_name] 
		, st.obj_name 
		, 10 obj_type_id --table 
		,col.column_id* 1000 ordinal_position
		,[column_name]
		, column_type_id 
		 ,col.[is_nullable]
		  ,[data_type]
		  ,[max_len]
		  ,null [numeric_precision]
		  ,null [numeric_scale]
		  ,primary_key_sorting
		  ,[default_value]
		  , st._source
	from staging_views st
	cross join static.[Column] col  
	where col.rdw = 1 
)
select 
	obj_id src_obj_id
	, null external_obj_id 
	, server_type_id
	 , server_name
	, db_name [db_name] -- target db name
	, [schema_name] 
	, substring(obj_name, 1, len (obj_name)-4) + '_h' obj_name -- h means historic
	, obj_type_id --table 
    , row_number() over (partition by obj_id order by ordinal_position) [ordinal_position]
    ,[column_name]
	, column_type_id 
     ,[is_nullable]
      ,[data_type]
      ,[max_len]
      ,[numeric_precision]
      ,[numeric_scale]
      ,primary_key_sorting
      ,[default_value]
	  , _source
from joined 
-- order by obj_id, ordinal_position
/*
select * 
from dbo.rdw_object_tree 
order by obj_id, ordinal_position

*/