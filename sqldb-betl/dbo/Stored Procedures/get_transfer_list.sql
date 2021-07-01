/* 
returns a list of tables that should be transfered for a specific source system (@source)
in a specific schema ( e.g. staging or rdw). 
this list can be configured for staging with the include_staging property

-- exec get_transfer_list 'aa', 'staging', 'o'
*/ 
CREATE procedure get_transfer_list
	@source as varchar(255)   -- e.g aa
	, @schema as varchar(255) -- e.g. staging or rdw
	, @sotap as char(1) = 's'

as 
begin 
	-- only implemented for staging yet. 
	with result as( 
	select 
		obj.obj_id src_obj_id
		--, obj.schema_obj_name src_schema_obj_name
		, obj.db_name + '.'+ obj.obj_name src_obj_name
		, target_obj.obj_id trg_obj_id
		, target_obj.obj_name trg_obj_name
		, source_alias.inherited_value source
		, '
select q.*
, {{batch_id}} _batch_id 
from '+isnull(obj.db_name,'') + '.'+ isnull(obj.obj_name,'')  +' as q
		' select_sql ,
		case when @sotap in ( 's', 'o') then 
		row_filter.inherited_value
		else null end row_filter

	from dbo.obj_ext obj 
	left join dbo.obj_ext target_obj on target_obj.src_obj_id = obj.obj_id 
	inner join dbo.prop_ext pe on obj.obj_id = pe.obj_id 
	left join dbo.prop_ext source_alias on obj.obj_id = source_alias.obj_id  and source_alias.property = 'source'
	left join dbo.prop_ext row_filter on obj.obj_id = row_filter.obj_id  and row_filter.property = 'row_filter'
	where 
	pe.property = 'include_staging'
	and pe.inherited_value = 1 
	and obj.obj_type in ( 'table', 'view')
	and source_alias.inherited_value = @source
	) 

	select * , concat(select_sql, row_filter) sql
	from result
end 
/*

exec setp 'row_filter', 
'where
q.gva_nr_ps in ( 
select distinct gva_nr_ps 
from poc.ods_aa_thssur _filter 
where _filter.dat_tyd_mut > ''2017-09-26 22:13:28.348859''  and _filter.dat_tyd_mut < ''2017-10-26 22:13:28.348859''
)'
, '[TAI].[poc].[dbo]'

exec setp 'row_filter', 'limit 1000', '[TAI].[poc].[dbo].[bpm_zaakgegevens]'

exec setp 'row_filter', 
'limit 10'
, '[TAI].[poc].[dbo]'


*/