/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2019-11-28 BvdB Ingest object tree will load the object tree into the meta database. The object tree consists of objects and columns. 
--				   the object tree should be passed as a table valued param. This is mainly done because in Azure data factory it's easy to create 
--                 a data copy task from a source system into a stored procedure using a table valued parameter. 
--
--obj_type_id	obj_type
--10	table
--20	view
--30	schema
--40	database
--50	server
--60	user
--70	procedure
--80	role

declare @obj_tree_param ObjTreeTableParam 
insert into @obj_tree_param 
SELECT  *
FROM dbo.obj_tree_ms_sql_server

[dbo].[Obj_tree_Staging_tables]
select * from @obj_tree_param 
exec [dbo].[ingest_obj_tree] @obj_tree_param
select * from dbo.obj_ext
exec verbose
*/
CREATE procedure [dbo].[ingest_obj_tree] 
	@obj_tree_param ObjTreeTableParam READONLY  --_table_name as sysname -- this is a global temp table that is unique for this transfer
	, @batch_id as int = -1 
	, @detect_table_delete as bit =0
	, @detect_view_delete as bit =0
	-- for example: Set this to 0 if you don't have views in your object tree, but you don't want to mark existing views in the meta database as deleted. 
	, @detect_schema_delete as bit =0

as 
begin 
	 --declare @batch_id as int = -1 , @obj_tree_param ObjTreeTableParam 
	 --insert into @obj_tree_param select * from dbo.Obj_tree_Staging
	
	set nocount on 
	declare @debug as bit = 0 -- set to 1 to print debug info
	--, @transfer_id as int = -1 
	declare @obj_tree ObjTreeTable -- mutable version of @obj_tree ( to keep a record of created obj_id's )
		, @rec_cnt_src as int=0
		, @rec_cnt_new as int=0 
		, @rec_cnt_changed as int =0
		, @rec_cnt_deleted as int =0
		, @rec_cnt_undeleted as int =0
		, @deleted as int=0
		, @inserted as int =0 
		, @status as varchar(255) = 'success'
		, @transfer_id as int 
		, @proc_name as sysname =  object_name(@@PROCID)
		, @now as datetime = getdate() -- all records the same timestamp so that you can join them easier. 
		, @create_dt as datetime 
		, @delete_dt as datetime 

	set @delete_dt =@now
	set @create_dt =@now

	-- standard BETL header code... 
	set nocount on 
	exec dbo.log_batch @batch_id, 'Header', '?(b?)', @proc_name , @batch_id
	-- END standard BETL header code... 

	select @rec_cnt_src = count(*) from @obj_tree_param
	exec log @transfer_id, 'var', '@rec_cnt_src = ?', @rec_cnt_src

	DECLARE @C TABLE (act tinyint) -- act 1= insert , 2 = update, 3= delete , 4= undelete

	--declare @obj_tree_param ObjTreeTableParam 
	--insert into @obj_tree_param select * from dbo.test2
	--declare @obj_tree_param ObjTreeTableParam 
	exec dbo.start_transfer @batch_id = @batch_id, @transfer_id=@transfer_id output, @transfer_name= 'ingest_obj_tree', @result_set = 0 
	--begin try 
	--begin transaction 
		-- begin servers 
		IF OBJECT_ID('tempdb..#servers') IS NOT NULL
			DROP TABLE #servers
	
		select distinct server_name, server_type_id into #servers from @obj_tree_param
		
		MERGE [dbo].[Obj] trg
		USING #servers src
		ON (trg.obj_name = src.server_name and trg.obj_type_id = 50) 
		WHEN NOT MATCHED THEN  -- not exists
			insert (obj_type_id, obj_name, server_type_id, _transfer_id, _create_dt) 
			values (50, server_name, server_type_id , @transfer_id, @create_dt)
		OUTPUT 1 INTO @C;

		insert into @obj_tree 
		select distinct
		  null obj_id
		  , src.src_obj_id
		  , src.external_obj_id 
		  ,src.[server_type_id]
		  ,src.[server_name]
		  ,s.obj_id server_id
		  ,src.[db_name]
		  ,null db_id
		  ,src.[schema_name]
		  ,null schema_id 
		  ,src.[obj_name]
		  ,src.[obj_type_id] 
		  ,[ordinal_position]
		  ,[column_name]
		  ,column_type_id 
		  ,[is_nullable]
		  ,[data_type]
		  ,[max_len]
		  ,[numeric_precision]
		  ,[numeric_scale]
		  ,primary_key_sorting
		  ,default_value 
		  ,get_prefix.prefix
		  ,case when get_prefix.prefix is not null and len(get_prefix.prefix)>0 then substring(get_prefix.obj_name, len(get_prefix.prefix)+2, len(get_prefix.obj_name) - len(get_prefix.prefix)-1) else get_prefix.obj_name end obj_name_no_prefix
		  , _source
		from @obj_tree_param src --@obj_tree_param src
		inner join dbo.obj s on src.server_name = s.obj_name and s.obj_type_id=50 and s.server_type_id = src.server_type_id --lookup server
		left join 		
		( 
			select distinct external_obj_id, util.prefix_first_underscore(obj_name) prefix , obj_name
			from @obj_tree_param where obj_name is not null 
		) get_prefix on src.external_obj_id = get_prefix.external_obj_id-- lookup object id. 
		-- end servers 

		-- begin databases 
		IF OBJECT_ID('tempdb..#dbs') IS NOT NULL
			DROP TABLE #dbs
		
		select distinct db_name, server_id parent_id, server_type_id
		into #dbs
		from @obj_tree src

		MERGE [dbo].[Obj] trg
		USING #dbs src
		ON (trg.obj_name = src.db_name and trg.obj_type_id = 40 and trg.parent_id = src.parent_id) 
		-- undeletes
		WHEN MATCHED and trg._delete_dt is not null THEN -- exists, but marked as deleted
				 UPDATE set 
	 				_delete_dt = null -- undelete
					, _record_dt = @now, _record_user = suser_sname(), _transfer_id = @transfer_id  -- undelete
		-- inserts
		WHEN NOT MATCHED THEN  -- not exists
			INSERT (obj_type_id, obj_name, parent_id, server_type_id, _transfer_id, _create_dt) 
			VALUES (40, src.db_name, parent_id, server_type_id, @transfer_id, @create_dt) 
-- no delete detection because this proc usually is run based on an object tree of 1 specific database. 
--		WHEN NOT MATCHED BY SOURCE and trg._delete_dt is null AND trg.obj_type_id = 40 and trg.parent_id in ( select distinct parent_id from #dbs)  THEN  -- exists but not in source --> mark as deleted
--			UPDATE set _delete_dt = @now , _record_dt = @now, _record_user = suser_sname(), _transfer_id = @transfer_id
		OUTPUT 
			CASE 
			WHEN $action= N'INSERT' THEN 1
--			WHEN $action= N'UPDATE' and inserted._delete_dt is null then 2 -- updated
--			WHEN $action= N'UPDATE' and inserted._delete_dt = @now then 3 -- deleted
			WHEN $action= N'UPDATE' then 4 -- undeleted
--			WHEN $action= N'UPDATE' and inserted._delete_dt is null and trg._delete_dt is not null then 4 -- undeleted
			END INTO @C
		;

		update o
		set db_id = db.obj_id
		from @obj_tree o
		inner join dbo.obj db on o.db_name = db.obj_name and db.parent_id = o.server_id and db.obj_type_id=40

		-- end databases 

		-- begin schemas
		IF OBJECT_ID('tempdb..#schemas') IS NOT NULL
			DROP TABLE #schemas
		
		select distinct src.schema_name, db_id parent_id, server_type_id , _source
		into #schemas
		from @obj_tree src

		MERGE [dbo].[Obj] trg
		USING #schemas src
		ON (trg.obj_name = src.schema_name and trg.obj_type_id = 30 and trg.parent_id = src.parent_id) 
		WHEN MATCHED and trg._delete_dt is not null THEN -- exists, but marked as deleted  
			UPDATE set 
	 			_delete_dt = null -- undelete
				,_record_dt = @now, _record_user = suser_sname(), _transfer_id = @transfer_id  
		WHEN NOT MATCHED THEN  -- not exists->insert
			INSERT (obj_type_id, obj_name, parent_id, server_type_id, _transfer_id, _create_dt)  
			VALUES (30, src.[schema_name], parent_id, server_type_id, @transfer_id, @create_dt)  
		WHEN NOT MATCHED BY SOURCE and trg._delete_dt is null AND trg.obj_type_id = 30 and trg.parent_id IN ( select distinct parent_id from #schemas) 
			and @detect_schema_delete=1 THEN  -- exists but not in source --> mark as deleted
			UPDATE set 
				_delete_dt = @now --delete
				,_record_dt = @now, _record_user = suser_sname(), _transfer_id = @transfer_id
		OUTPUT 
			CASE 
			WHEN $action= N'INSERT' THEN 1
--			WHEN $action= N'UPDATE' and inserted._delete_dt is null then 2 -- updated
			WHEN $action= N'UPDATE' and inserted._delete_dt = @now then 3 -- deleted
			WHEN $action= N'UPDATE' and inserted._delete_dt is null then 4 -- undeleted
			END INTO @C
		;

		update o
		set schema_id = s.obj_id
		from @obj_tree o
		inner join dbo.obj s on o.schema_name = s.obj_name and s.parent_id = o.db_id and s.obj_type_id=30
		-- end schemas

		-- begin tables and views 
		MERGE into [dbo].[Obj] trg
		USING (
				select distinct obj_name, obj_type_id, schema_id, server_type_id, prefix , obj_name_no_prefix, src_obj_id, external_obj_id
				from @obj_tree -- where obj_name is not null --> include empty schemas 
		)  src
		ON (src.obj_name =  trg.obj_name and src.obj_type_id= trg.obj_type_id and trg.parent_id = src.[schema_id] and trg.obj_type_id in (10,20) )
--		ON (isnull(src.obj_name, trg.obj_name) =  trg.obj_name and isnull(src.obj_type_id, trg.obj_type_id) = trg.obj_type_id and trg.parent_id = src.[schema_id]) and trg.obj_type_id in (10,20) 
		WHEN MATCHED and (trg._delete_dt is not null -- marked as deleted
							or isnull(trg.src_obj_id,-1) <>  isnull(src.src_obj_id,-1)  -- changed
							or isnull(trg.external_obj_id,-1) <>  isnull(src.external_obj_id,-1))  -- changed
		THEN -- exists, but marked as deleted  or something changed
			UPDATE set
	 			_delete_dt = null -- undelete
				, _record_dt = @now, _record_user = suser_sname(), _transfer_id = @transfer_id  -- undelete
				, trg.src_obj_id = isnull(src.src_obj_id , trg.src_obj_id) -- never set to null when filled ( e.g. when observe ddppoc is called )
				, trg.external_obj_id = src.external_obj_id

		WHEN NOT MATCHED BY SOURCE 
		--and trg._delete_dt is null 
		AND trg.obj_type_id in (10,20) 
		and trg.parent_id IN ( select distinct [schema_id] from @obj_tree )  
		and  ( ( @detect_table_delete=1 and trg.obj_type_id = 10  ) or ( @detect_view_delete=1  and trg.obj_type_id = 20  ) ) 
		THEN  -- exists but not in source --> mark as deleted 
			UPDATE set
				_delete_dt = isnull(@now,_delete_dt)  -- delete
				, _record_dt = @now, _record_user = suser_sname(), _transfer_id = @transfer_id
		WHEN NOT MATCHED AND src.obj_name is not null and src.obj_type_id is not null THEN  -- not exists but not an empty schema.. 
			INSERT (obj_type_id, obj_name, parent_id, server_type_id, _transfer_id, prefix, obj_name_no_prefix, src_obj_id, _create_dt, external_obj_id) 
			VALUES (src.obj_type_id, src.[obj_name], [schema_id], server_type_id, @transfer_id, prefix, obj_name_no_prefix, src_obj_id, @create_dt, external_obj_id ) 
		OUTPUT 
			CASE 
			WHEN $action= N'INSERT' THEN 1
--			WHEN $action= N'UPDATE' and inserted._delete_dt is null then 2 -- updated
			WHEN $action= N'UPDATE' and inserted._delete_dt = @now then 3 -- deleted
			WHEN $action= N'UPDATE' and inserted._delete_dt is null then 4 -- undeleted
			END INTO @C
		;

		update o
		set obj_id = s.obj_id
		from @obj_tree o
		inner join dbo.obj s on o.obj_name = s.obj_name and s.parent_id = o.schema_id and s.obj_type_id = o.obj_type_id

		-- end tables and views 

		if @debug =1 
			select * from @obj_tree 

		-- begin set property source for each obj
		declare @prop_id as int , @obj_id as int, @source as varchar(255) 
		select @prop_id = property_id
		from static.Property where [property_name] = 'source'

		declare db_cursor cursor for 
				select distinct obj_id, _source from @obj_tree
				where obj_id is not null and _source is not null 
		open db_cursor 
		fetch next from db_cursor into @obj_id , @source
		while @@FETCH_STATUS=0
		begin
			exec dbo.setp_obj_id @prop_id, @source, @obj_id, @transfer_id 
			if @debug =1 
				exec log @transfer_id, 'debug', 'set property source[?] for obj_id[?] to ?', @prop_id, @obj_id, @source
			fetch next from db_cursor into @obj_id , @source
		end 
		close db_cursor 
		deallocate db_cursor 
		-- end set property source for each obj

		-- begin delete propagation if a database or schema is marked as deleted-> also mark descendants as deleted. 
		begin 
			UPDATE child
			set _delete_dt = parent._delete_dt, _record_dt = @now, _record_user = suser_sname(), _transfer_id = @transfer_id
			from dbo.obj child 
			inner join dbo.obj parent on child.parent_id = parent.obj_id 
			where parent._delete_dt is not null 
			and child._delete_dt is null 
			set @rec_cnt_deleted+= isnull(@@ROWCOUNT,0)

			-- if prev statement set schemas to deleted -> check again for tables and views in these schemas
			UPDATE child
			set _delete_dt = parent._delete_dt, _record_dt = @now, _record_user = suser_sname(), _transfer_id = @transfer_id
			from dbo.obj child 
			inner join dbo.obj parent on child.parent_id = parent.obj_id 
			where parent._delete_dt is not null 
			and child._delete_dt is null 
			set @rec_cnt_deleted+= isnull(@@ROWCOUNT,0)

			-- update orphan columns
			update col set _delete_dt = o._delete_dt, _record_dt = @now, _record_user = suser_sname(), _transfer_id = @transfer_id
			from dbo.col col
			inner join dbo.obj o on col.obj_id = o.obj_id 
			where 
				o._delete_dt is not null -- parent is deleted
				and col._delete_dt is null  -- child is not deleted
			set @rec_cnt_deleted+= isnull(@@ROWCOUNT,0)
		end
		-- end delete propagation if a database or schema is marked as deleted-> also mark descendants as deleted. 

		-- if @debug = 1 			select * from @obj_tree

		-- begin columns
		IF OBJECT_ID('tempdb..#mutation') IS NOT NULL
			DROP TABLE #mutation

		;
		with cols as ( 
			select 
				src.ordinal_position
				, src.column_name 
				, src.column_type_id
				, src.is_nullable
				, src.data_type 
				, src.max_len
				, src.numeric_precision
				, src.numeric_scale
				, src.obj_name 
				, src.[schema_name]
				, src.[db_name] 
				, hashbytes('MD5', 
					 util.trim(src.ordinal_position, 0)
				 +'|'+util.trim(src.is_nullable, 0)
				 +'|'+util.trim(src.data_type, 0)
				 +'|'+util.trim(src.max_len, 0)
				 +'|'+util.trim(src.numeric_precision, 0)
				 +'|'+util.trim(src.numeric_scale, 0) 
				 +'|'+util.trim(src.column_type_id, 0) 
				 +'|'+util.trim(src.[primary_key_sorting], 0) 
				 +'|'+util.trim(src.[default_value], 0) 
				 ) _chksum
				, 1 in_src
				, src.[primary_key_sorting]
				, src.[default_value]
				, calc_cols.* 
				, case 
					when left_side = src.obj_name -- column name starts with object name 
						and filtered_right_side  in ( 'key', 'id', 'number', 'nr') then 100 
					when left_side = src.obj_name_no_prefix -- column name starts with object name 
						and filtered_right_side  in ( 'key', 'id', 'number', 'nr') then 100 
					-- e.g. when obj_name = Customer and column_name = customer_key then this is a nat_pkey
--					when SUBSTRING(src.column_name, len(src.column_name)+1-4, 4) = '_key' then 110 
					-- e.g. when obj_name = Customer and column_name = customer_product_key then this is a nat_fkey
					else isnull(static_col.column_type_id , 300) 
				end derived_column_type_id 
				, src.obj_id 
			from @obj_tree src
			left join static.[Column] static_col on static_col.column_name = src.column_name 
			cross apply ( 
			 select 
				len(src.column_name) - (len(src.column_name) -len(src.obj_name_no_prefix)) i
				, case when len(src.column_name) -len(src.obj_name_no_prefix) >0 then len(src.column_name) -len(src.obj_name_no_prefix) else 0 end n 
			) calc_cols_0
			cross apply ( 
				select left(src.column_name, i) left_side 
				 , substring(src.column_name, i+1 , n ) right_side
				 , util.filter_reg_exp(substring(src.column_name, i+1 , n   ) , '^a-z') filtered_right_side
			) calc_cols
			where src.column_name is not null 
		)
		select 
				src.* , 
				case 
				when in_src=1 and trg.obj_id is null then 'NEW'
				when in_src=1 and trg.obj_id is not null and src._chksum <> trg._chksum then 'CHANGED'
				when in_src=1 and trg.obj_id is not null and src._chksum = trg._chksum and trg._delete_dt is null then 'UNCHANGED'
				when in_src=1 and trg.obj_id is not null and src._chksum = trg._chksum and trg._delete_dt is not null then 'UNDELETED'
				when in_src is null and trg.obj_id is not null and trg._delete_dt is null then 'DELETED'
				end mutation
				, case when in_src is null and trg.obj_id is not null then trg._eff_dt else @now end _eff_dt
				, trg.column_id column_id 
				, trg.column_type_id trg_column_type_id
				, trg._delete_dt 
		into #mutation
		from cols src
		full outer join ( 
			SELECT  h.column_name, isnull(h._chksum,0) _chksum, h._eff_dt, h.obj_id, h.column_id , h._delete_dt, h.column_type_id
			FROM  ( select distinct obj_id obj_id from @obj_tree)  tv
			inner join [dbo].[Col] AS h on h.obj_id = tv.obj_id
			WHERE     (_eff_dt =
						  ( SELECT     MAX(_eff_dt) max_eff_dt
							FROM       [dbo].[Col] h2
							WHERE      h.column_id = h2.column_id
						   )
					  )
		) trg on src.obj_id = trg.obj_id AND src.column_name = trg.column_name	
		--where 
		--	not ( src.obj_id is null and trg.obj_id is null ) -- either in src or in target
		--	and ( trg.obj_id is null or trg.obj_id in ( select obj_id from @obj_tree) )  -- scope is all objects that are in cols

		if @debug = 1 
			select * from #mutation --where mutation <> 'UNCHANGED'

		-- new records
		insert into dbo.Col ( obj_id,column_name, _eff_dt,  ordinal_position,is_nullable,data_type,max_len,numeric_precision,numeric_scale
		, _chksum, _transfer_id, column_type_id, primary_key_sorting, default_value) 
		select obj_id,column_name, _eff_dt, ordinal_position,is_nullable,data_type,max_len,numeric_precision,numeric_scale,
		_chksum, -1
		, isnull(column_type_id, derived_column_type_id) -- for new columns we take the derived column type if nothing is entered in obj_tree
		, primary_key_sorting, default_value
		from #mutation
		where mutation = 'NEW'
 
		insert into dbo.Col ( obj_id,column_name, _eff_dt,  ordinal_position,is_nullable,data_type,max_len, numeric_precision,numeric_scale 
		, _delete_dt, column_id, _chksum, _transfer_id, column_type_id, primary_key_sorting, default_value  )
		select obj_id,column_name, _eff_dt,  ordinal_position,is_nullable,data_type,max_len,numeric_precision,numeric_scale
		, null _delete_dt
		, column_id
		, _chksum
		, -1
		, isnull(column_type_id , trg_column_type_id)  trg_column_type_id
		, primary_key_sorting, default_value
		from #mutation
		where mutation in ('CHANGED', 'UNDELETED')

		update c 
		set 
		 	_delete_dt = @now -- delete
			, _record_dt = @now
			, _record_user = suser_sname() 
		from dbo.Col c 
		inner join #mutation m on c.column_id = m.column_id and c._eff_dt = m._eff_dt
		where mutation=	'DELETED' 
		

--		select * from Col where column_id = 2730 and _eff_dt= '2020-07-01 06:45:16.723'
		-- 2020-07-01 06:45:16.723	

		-- end columns
		-- update stats
		insert into @c 
		select case mutation 
			when 'NEW' then 1 
			when 'CHANGED' then 2
			when 'DELETED' then 3 
			when 'UNDELETED' then 4 
		end 
		from #mutation
		where mutation is not null -- in ('NEW', 'CHANGED', 'DELETED' , 'UNDELETED')

	--	commit transaction 
	--end try 
	--begin catch 
	--	declare 
	--		@msg as varchar(255)
	--		, @sev as int
	
	--	set @msg = convert(varchar(255), isnull(ERROR_MESSAGE(),''))
	--	set @sev = ERROR_SEVERITY()
	--	--IF @@TRANCOUNT > 0  
	--	--	rollback transaction 

	--	exec dbo.log 'error', 'Error Occured in dbo.[ingest_obj_tree]: ? ',  @msg 
	--	RAISERROR('Error Occured in dbo.[ingest_obj_tree]: %s', @sev, 1,@msg) -- WITH LOG
	--end catch 
	
	footer:

	select @rec_cnt_new += isnull(sum ( case when act=1 then 1 else 0 end),0)   -- 1= insert
			,@rec_cnt_changed += isnull(sum ( case when 	act=2 then 1 else 0 end),0)   -- 2=update
			,@rec_cnt_deleted += isnull(sum ( case when 	act=3 then 1 else 0 end),0)   -- 3=delete
			,@rec_cnt_undeleted += isnull(sum ( case when 	act=4 then 1 else 0 end),0)   -- 4=undelete
	from @c

	exec dbo.log @transfer_id, 'info', 'ingest_obj_tree new ?, changed ?, deleted ?, undeleted ? ',  @rec_cnt_new , @rec_cnt_changed , @rec_cnt_deleted, @rec_cnt_undeleted

	if @debug=1 
		select @rec_cnt_src rec_cnt_src, @rec_cnt_new rec_cnt_new, @rec_cnt_changed rec_cnt_changed, @rec_cnt_deleted rec_cnt_deleted

	exec dbo.end_transfer @transfer_id, @status, @rec_cnt_src, @rec_cnt_new, @rec_cnt_changed, @rec_cnt_deleted, @rec_cnt_undeleted
	exec dbo.log_batch @batch_id, 'Footer', '?(b?)', @proc_name , @batch_id
end