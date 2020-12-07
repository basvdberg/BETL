-- select * from static.Column_enriched_ext 
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2020-061-23 BvdB This will enrich the dbo.col meta data using the input in static.Column_enriched. Main reason is adding column_type_id. 
select * from dbo.col_ext where schema_name = 'idw_imp'
exec enrich_columns
*/    

CREATE procedure [dbo].[enrich_columns] as

begin 
	declare @cnt_rows as int 
	update col set column_type_id = ce.column_type_id -- nat_pkey
	from dbo.Col_ext col 
	inner join static.Column_enriched_ext ce on ce.column_name = col.column_name and ce.obj_name = col.obj_name and ce.schema_name = col.schema_name 
	and col.obj_type = ce.obj_type 
	where isnull(col.column_type_id,0)  <> isnull( ce.column_type_id , 0) 
	
	select @cnt_rows = @@rowcount 
	-- next set column type to attribute for columns that have been removed from static.Column_enriched but are still nat_pkey
	;
	with obj as ( 
		select distinct ce.obj_name, ce.schema_name, ce.obj_type
		from static.Column_enriched_ext ce 
	) 
	update col set column_type_id = 300
	from obj obj
	inner join dbo.Col_ext col  on obj.obj_name = col.obj_name and obj.schema_name = col.schema_name and col.obj_type = obj.obj_type 
	left join static.Column_enriched_ext ce on ce.column_name = col.column_name and ce.obj_name = col.obj_name and ce.schema_name = col.schema_name 
	and col.obj_type = ce.obj_type 
	where col.column_type_id in ( 100, 105) 
	and ce.column_name is null -- not found in static table

	select @cnt_rows += @@rowcount 

	--insert into static.Column_enriched ( schema_name, table_name, column_name, [column_type_id]) values ( 'idw_imp' , 'persoon', 'vk_code', 100) 

	-- enrich rules as well ... 
	exec dbo.setr 500, 'gvb', 'gvb_reg_datum'
	exec dbo.setr 110, 'gvb', 'gvb_eind_geld_datum'
	exec dbo.setr 110, 'gvb', 'gvb_eind_norm_datum'

	exec dbo.setr 500, 'bericht', 'bericht_reg_datum'
	exec dbo.setr 100, 'bericht', 'bericht_ontv_datum'
	exec dbo.setr 100, 'bericht', 'bericht_zend_datum'

	exec dbo.setr 200, 'persoon', null
	exec dbo.setr 100, 'persoon', 'persoon_reg_datum'
	exec dbo.setr 100, 'persoon', 'persoon_inga_geld_datum'
	exec dbo.setr 110, 'persoon', 'persoon_eind_geld_datum'

	exec dbo.setr 200, 'sur', null
	exec dbo.setr 210, 'sur', null
	exec dbo.setr 100, 'sur', 'sur_inga_geld_datum'
	exec dbo.setr 110, 'sur', 'sur_eind_geld_datum'

	exec dbo.setr 100, 'hur', 'hur_reg_datum'
	exec dbo.setr 100, 'hur', 'hur_inga_geld_datum'
	exec dbo.setr 100, 'hur', 'hur_inga_enti_datum'
	exec dbo.setr 110, 'hur', 'hur_eind_geld_datum'
	exec dbo.setr 110, 'hur', 'hur_eind_enti_datum'



	select @cnt_rows cnt_rows
end