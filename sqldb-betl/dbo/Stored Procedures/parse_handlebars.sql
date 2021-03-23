
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2020-03-03 BvdB handlebars is a templating language that we use for expressing sql templates. The main reason for this is that it supports iterations (#each). 
-- we only implemented a part of the handlebars language.

-- Applies to: Data Factory v2

exec reset
exec my_info
exec getp ''
exec verbose
exec parse_handlebars 184, 'select_staging'

select * from [dbo].[rdw_object_tree] where obj_id = 151
expressions: 
- #if column_type_id in (100,300)
- #unless @last
-- #if primary_key_sorting
expression consist of: <helper-name><helper-argument>
helper-argument can be: @last | <column-name> condition sub-expression | <column-name>

select * from col_ext_unpivot
where obj_id = 156
order by ordinal_position

exec [dbo].[parse_handlebars] 69, 'create_table_if_not_exists'
exec [dbo].[parse_handlebars] 158, 'drop_and_create_table'
exec [dbo].[parse_handlebars] 156, 'update_idw'

select * from col_ext_unpivot where obj_id = 156
select * from obj_ext 

*/
CREATE procedure [dbo].[parse_handlebars] 
	@obj_id as int 
	, @template_name as varchar(255)
	, @transfer_id as int =-1 

as 


begin 
--declare 	@obj_id as int =184	, @transfer_id as int =-1, @template_name as varchar(255) 

	DECLARE @open_pos int=0			
			, @debug as bit =0
		, @close_pos int=0
			, @value varchar(max)
			, @root hierarchyid = '/'
			, @prev_parent hierarchyid
			, @parent hierarchyid
			, @parent_str as varchar(255)
			, @node hierarchyid 
			, @delete_dt datetime
			
			 ,@node_str as varchar(255)
			, @c as char
			, @next_c as char
			, @l as int 
			, @i as int
			, @j as int 

			, @obj_id_test as int 
			, @output as varchar(max) =''	
			, @proc_name as sysname =  object_name(@@PROCID)
			, @nl as varchar(2) = char(13)+char(10)
			, @suffix as varchar(max) 
			, @suffix_prefix as varchar(max)
			, @template as varchar(max)
			, @splitlist as SplitList 
			, @helper as varchar(255)
			, @column_name as sysname
			, @condition as varchar(255) 
			, @expression as varchar(255) 
			, @msg as varchar(255) = ''
			, @src_obj_id as int 
			, @trg_obj_id as int 
			, @now as nvarchar(255)  = convert(nvarchar(255), getdate() ) 

				-- standard BETL header code... 
	set nocount on 
	exec dbo.log @transfer_id, 'HEADER', '? obj_id=? transfer_id=?', @proc_name , @obj_id, @transfer_id
	-- END standard BETL header code... 

	select @obj_id_test = obj_id , @src_obj_id = src_obj_id , @delete_dt = _delete_dt
	,@trg_obj_id= (select max(obj_id) from dbo.obj where src_obj_id = @obj_id ) -- should not happen to have multiple targets, but can happen. 
	from dbo.obj 
	where obj_id =@obj_id 

	if @debug = 1 
		select  @src_obj_id src_obj_id, @obj_id obj_id, @trg_obj_id trg_obj_id  , 'running in debug mode. set @debug to 0 to run in ADF ' _output

	if @obj_id_test is null or ( @delete_dt is not null  )  -- deleted 
	begin 
		if @delete_dt is not null 
			exec log @transfer_id, 'ERROR', 'object ? was deleted at ? ', @obj_id , @delete_dt
		else
			exec log @transfer_id, 'ERROR', 'object ? does not exist ', @obj_id 

		--set @msg = 'object with id: ' + convert(varchar(255), @obj_id)  + ' not found'
		--set @output = @msg
		--RAISERROR(@msg , 15 , 0)  WITH NOWAIT
		goto footer
	end 


	-- test ordinal_position is unique
	if exists ( 
		select ordinal_position, count(*) 
		from dbo.col_ext c  
		where obj_id = @obj_id 
				and  _delete_dt is null  
		
		group by ordinal_position
		having count(*) >1 
	) 
	begin 
		exec log @transfer_id, 'ERROR', 'ordinal_position for the columns in object ? is not unique. ', @obj_id 
		--set @msg = 'ordinal_position for the columns in object : ' + convert(varchar(255), @obj_id)  + ' is not unique'
		--set @output = @msg
		--RAISERROR(@msg , 15 , 0)  WITH NOWAIT
		goto footer
	end 


/*
	set @template = '
-- begin select rdw columns 100 and 300 from {{schema_name}}.{{obj_name}}[{{obj_id}}]
SELECT
{{#each columns}}
	 {{#if column_type_id in (100,300)}}
	  [{{column_name}}]{{#unless @last}},{{/unless}}
	 {{/endif}}
{{/each}}
FROM staging.[{{obj_name}}]
EXCEPT
SELECT
{{#each columns}}
	 {{#if column_type_id in (100,300)}}
	  [{{column_name}}]{{#unless @last}},{{/unless}}
	 {{/endif}}
{{/each}}
FROM rdw.[{{obj_name}}]
-- end select rdw columns 100 and 300 from {{schema_name}}.{{obj_name}}[{{obj_id}}]
'
	/*
	set @template =
	'-- begin create table {{schema_name}}.{{obj_name}}[{{obj_id}}]
	-- in our DEV invironment we just drop the target table. Of course this is not done in Test, Acceptance and Prod..
	IF OBJECT_ID(''{{schema_name}}.{{obj_name}}'', ''U'') IS NOT NULL 
		DROP TABLE {{schema_name}}.{{obj_name}};

	CREATE TABLE {{schema_name}}.{{obj_name}}(
	{{#each columns}}
	  {{column_name}} {{data_type}}{{data_size}} {{is_nullable}} {{default_value}}{{#unless @last}},{{/unless}}
	{{/each}}
	)

	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N''PK_{{schema_name}}_{{obj_name}}_{{obj_id}}'')
	ALTER TABLE {{schema_name}}.{{obj_name}} ADD CONSTRAINT
		PK_{{schema_name}}_{{obj_name}}_{{obj_id}} PRIMARY KEY CLUSTERED 
		(
		{{#each columns}}
			{{#if primary_key_sorting}}
				{{column_name}} {{primary_key_sorting}}
				{{#unless @last}},{{/unless}}
			{{/if}}
		{{/each}}
		) 

	-- end create table {{schema_name}}.{{obj_name}}[{{obj_id}}]
	'
	*/
	*/

	select @template = template_code 
	from static.template 
	where template_name = @template_name

	if @template is null 
	begin 
		exec log @transfer_id, 'ERROR', 'invalid template name ?', @template_name
		set @output = 'ERROR template does not exist'
		set @msg = 'template ''' + @template_name  + ''' not found'
		set @output = @msg
		RAISERROR(@msg , 15 , 0)  WITH NOWAIT
		goto footer
	end

	exec log @transfer_id, 'INFO', 'begin generating abstract syntax tree '
	-- BEGIN parse the handle bars expressions into an abstract syntax tree ( ast) 
	if object_id('tempdb..#ast') is not null 
		drop table #ast

	create table #ast( 
		node hierarchyid  -- hierarchical id in the tree
		, type varchar(max)  -- const or expresion
		, s varchar(max)    -- values of expression or constant
		, helper varchar(255) 
		, column_name varchar(255) 
		, condition varchar(255) 
		, expression varchar(255) 
	) 

	set @open_pos = CHARINDEX('{{', @template, 0)

	set @value = SUBSTRING(@template, @close_pos, @open_pos-@close_pos)
	--print @value -- for debug purpose   

	set @parent = @root
	set @node = @parent.GetDescendant(null, NULL)
	insert into #ast(node,s,type)  values ( @node, @value, 'const') 

	WHILE @open_pos>0 -- while there are open mustaches -> update ast 
	BEGIN
		set @close_pos = CHARINDEX('}}', @template, @open_pos+2) 
		if @close_pos=0 
		begin 
			exec log @transfer_id, 'error', 'syntax error no closing mustaches found after positiion ?+2 ', @open_pos 
			goto footer
		end	

		set @value = SUBSTRING(@template, @open_pos+2, @close_pos- @open_pos-2)
--		set @suffix = util.suffix(@value,' ')
		set @c = substring(@value, 1, 1) 

		delete from @splitlist 
		set @helper = null
		set @column_name= null 
		set @condition = null 
		set @expression = null 

		--select * from util.split('column_type_id in (100,300)', ' ')
		insert into @splitlist 
		select * 
		from util.split(@value, ' ') 

		set @node_str = @node.ToString() 
		set @parent_str = @parent.ToString()
		exec log @transfer_id, 'Progress', '?..?: "?", "?" ?,?', @open_pos, @close_pos, @value ,@c, @node_str, @parent_str

		if @c = '#'
		begin -- move down the hierarchy
			select @helper = item from @splitlist  where i =1 
			select @column_name = item from @splitlist  where i =2
			select @condition = item from @splitlist  where i =3 
			select @expression = item from @splitlist  where i =4 
			if @helper = '#each' or substring(@column_name,1,1)= '@' -- switch column name and expression
			begin
				set @expression = @column_name
				set @column_name=null 
			end

			set @parent = @parent.GetDescendant(@node,null) 
			set @node = null 
			--set @node = @parent.GetDescendant(@node, NULL)
--			set @node_str = isnull(@parent.ToString(),'') + '.'+  isnull(@node.ToString() , '') 
			--exec log @transfer_id, 'Progress' , 'parent.node ? ', @node_str 
	
			insert into #ast(node,type,s, helper, column_name, condition, expression)  values ( @parent, 'expression', @value, @helper, @column_name, @condition, @expression ) 
		end
		if @c = '/'
		begin -- move up the hierarchy
			select @expression = item from @splitlist  where i =1 -- more than 3-> bad luck.. 

			set @parent = @node.GetAncestor(1) 
			set @node = @parent.GetDescendant(@node, NULL)

			insert into #ast(node,type,s, helper, column_name, condition, expression)  values ( @node, 'expression', @value, @helper, @column_name, @condition, @expression ) 
			set @parent = @node.GetAncestor(2) 
			set @node = @node.GetAncestor(1) 
		end

		if @c not in ( '#', '/') 
		begin
			select @column_name = item from @splitlist  where i =1

			set @node = @parent.GetDescendant(@node, NULL)
			insert into #ast(node,type,s, helper, column_name, condition, expression)  values ( @node, 'expression', @value, @helper, @column_name, @condition, @expression ) 
		end

		--exec log @transfer_id, 'Progress', '?..?: "?", "?" "?" "?" "?" ', @open_pos, @close_pos, @value ,@helper, @column_name, @condition, @expression
		set @open_pos = CHARINDEX('{{', @template, @close_pos+2) -- find next open mustaches
		if @open_pos>0
		begin
			set @i = @close_pos+2
			set @j = @open_pos-@close_pos-2
			set @value = SUBSTRING(@template, @i, @j )
			-- do not insert blank space between two # or / expressions
			set @next_c = substring(@template, @open_pos+2, 1)

			set @node_str = @node.ToString() 
			set @parent_str = @parent.ToString()
			exec log @transfer_id, 'Progress', '?,?: "?", "?" ?,?', @i, @j, @value ,@next_c, @node_str, @parent_str

			if  @c in ( '#', '/') and @next_c in ( '#', '/') 
				set @value = trim(NCHAR(0x09) + NCHAR(0x20) + NCHAR(0x0D) + NCHAR(0x0A) from  @value) 
			
			--if @i = 193
			--begin
			--	exec log @transfer_id, 'progress', 'AAP c "?", next_c "?" value "?"' , @c, @next_c, @value 
			--	set @node_str = @node.ToString() 
			--	set @parent_str = @parent.ToString()
			--	exec log @transfer_id, 'Progress', '?.?.?', @open_pos, @parent_str, @node_str
			--end

			set @l = datalength(@value)
			if @l>0 
			begin 
				exec log @transfer_id, 'Progress', '?+2..?:"?" ? ( type:const)' , @close_pos, @open_pos, @value , @l
				set @node = @parent.GetDescendant(@node, NULL)
				insert into #ast(node,s, type)  values ( @node, @value,  'const') 
			end 
		end

		
		set @node_str = @node.ToString() 
		set @parent_str = @parent.ToString()
		exec log @transfer_id, 'Progress', '?.?.?', @open_pos, @parent_str, @node_str

	END -- WHILE @open_pos>0 -- while there are open mustaches -> update ast 

	set @value = SUBSTRING(@template, @close_pos+2, datalength(@template)-@close_pos-1 )
	set @parent = @node.GetAncestor(1) 
	set @node = @parent.GetDescendant(@node, NULL)
	
	insert into #ast(node,s, type)  values ( @node,  @value,  'const') 
	exec log @transfer_id, 'INFO', 'done generating abstract syntax tree '

	-- END parse the handle bars expressions into an abstract syntax tree ( ast) 
	
	if @debug=1 
	-- print the ast 
		select 'ast' this
		, node.ToString() node_string
		, * 
		, datalength(s) len_s from #ast

	-- next map values to expressions in ast . this will transform the ast
	-- when encountering an #each subtree we apply an iteration. we will substitute the tree with 
	-- values 
 
	;
	if object_id('tempdb..#result') is not null 
		drop table #result
	
	select 
	'ast_binded' this
	, ast.node.ToString() node_string
	, ast.node
	, ast.type
	, ast.s
	, ast.helper
	, ast.column_name
	, ast.condition
	, ast.expression
	--, ast.node.GetDescendant(null, NULL) new_node
	--, ast.node.GetDescendant(null, NULL).ToString() new_node_string
	,case 
		when parent.helper = '#each' then ast.node.GetAncestor(1) 
		when grand_parent.helper = '#each' then ast.node.GetAncestor(2) 
		when great_grand_parent.helper = '#each' then ast.node.GetAncestor(3) 
		else ast.node end sort_node
	, cols.ordinal_position
	, case 
		when ast.type='expression' then coalesce( col_values._value , obj._value, src_obj._value, trg_obj._value, params._value) 
		when ast.type='const' then ast.s
	end _value
	, ast.node.GetAncestor(1) parent
	, parent.s parent_s
	, ast.node.GetAncestor(2) grand_parent
	, grand_parent.s grand_parent_s
	into #result
	from #ast ast
	left join #ast parent on ast.node.GetAncestor(1) = parent.node 
	left join #ast grand_parent on ast.node.GetAncestor(2) = grand_parent.node 
	left join #ast great_grand_parent on ast.node.GetAncestor(3) = great_grand_parent.node 
	full outer join ( 
		select ordinal_position
		from dbo.col_ext c  
		where obj_id = @obj_id 
				and _delete_dt is null  
		
	) cols on parent.s = '#each columns' or grand_parent.s = '#each columns'
	or great_grand_parent.s = '#each columns' 
	-- for every child that has a parent of type #each columns -> cross join with columns 
	left join ( 
		select * 
		from dbo.col_ext_unpivot c 
		where obj_id =  @obj_id 
	--	cross apply ( select row_number() over (partition by ast.node.GetAncestor(1) order by ast.node.ToString()) nr  ) 
	)  col_values on ast.type = 'expression' and col_values._name = ast.column_name and col_values.ordinal_position = cols.ordinal_position
	left join dbo.Obj_ext_all_unpivot obj on obj._obj_id = @obj_id and ast.type='expression' and ast.s = obj._name and col_values._name is null
	left join dbo.Obj_ext_all_unpivot src_obj on src_obj._obj_id = @src_obj_id and ast.type='expression' and ast.s = 'src_'+src_obj._name and col_values._name is null
	left join dbo.Obj_ext_all_unpivot trg_obj on trg_obj._obj_id = @trg_obj_id and ast.type='expression' and ast.s = 'trg_'+trg_obj._name and col_values._name is null
	left join ( 
		select '_transfer_id' _name, convert(nvarchar(255), @transfer_id)  _value
		union all 
		select '_eff_dt' _name, @now _value
		union all 
		select 'template_name' _name, @template_name _value
	) params on ast.type='expression' and ast.s = params._name 
	
	-- prevent match with obj and col at the same time 
	exec log @transfer_id, 'INFO', 'ast merged with object tree to fill expressions'

	if @debug=1
		select * , sort_node.ToString() sort_node_string from #result
		order by sort_node, ordinal_position, node

	if object_id('tempdb..#result2') is not null 
		drop table #result2
	select 
		'line_nr_and_if#' this2
		, row_number() over ( order by r.sort_node, r.ordinal_position, r.node) line_nr 
		, par.node parent_node_lookup
		, r.* 
		, par._value parent_r_value
		, r.ordinal_position  ordinal_position2
		, rank() over (partition by r.sort_node order by r.ordinal_position desc) seq
		--, rank() over (order by r.ordinal_position desc) seq
		--, row_number() over (order by r.ordinal_position desc) seq
	into #result2 

	from #result r
	left join #result par on r.parent = par.node and r.ordinal_position = par.ordinal_position
	left join #result grand_par on r.grand_parent = grand_par.node and r.ordinal_position = grand_par.ordinal_position

	where 
		-- exclude some branches
		-- eg #if primary_key_sorting 
		not (isnull(par.helper,'') = '#if' and isnull(par._value,'') ='') -- the value of an #if expression is bounded in previous step
																					-- eg  #if primary_key_sorting requires a value for the attribute primary_key_sorting  
		and
		not (isnull(grand_par.helper,'')  = '#if' and isnull(grand_par._value,'') ='') 
		and 
		not (isnull(r.helper,'') = '#if' and isnull(r._value,'') ='') 
		and 
		not (isnull(left(r.s,1),'') = '/') -- skip all closing tags
		-- eg. #if column_type_id in (100,300)
		and 
		not (isnull(r.helper,'') = '#if' and isnull(r.condition,'') = 'in' and isnull(charindex(r._value, r.expression),0)=0 ) 
		and 
		not (isnull(par.helper,'') = '#if' and isnull(par.condition,'') = 'in' and isnull(charindex(par._value, par.expression),0)=0 ) 
		and 
		not (isnull(grand_par.helper,'') = '#if' and isnull(grand_par.condition,'') = 'in' and isnull(charindex(grand_par._value, grand_par.expression),0)=0 ) 

		-- when par starts with #if -> _value must not be empty ( e.g. null or '') ) 
	order by 2 

	if @debug=1 
		select * from #result2 order by 2

	exec log @transfer_id, 'INFO', 'output generated and conditions evaluated'

	if object_id('tempdb..#result3') is not null 
		drop table #result3

	-- next -> execute sql expressions #sql. .this is done last for performance reasons. 
	declare @line_nr int , @sql nvarchar(max), @sql_output nvarchar(max) = '' --, @helper varchar(255), @expression varchar(255), @value varchar(255) 

	declare c cursor for select line_nr, helper, expression, _value from #result2 where helper = '#sql'
	open c 
	
	fetch next from c into @line_nr , @helper, @expression, @value 
	while @@FETCH_STATUS = 0 
	begin 
		set @sql = 'select @retvalOUT='+ isnull(@expression,'?')  + '( ''' +  isnull(@value,'')  + ''')'
		if @debug = 1 
			print '-- sql statement : '+ isnull(@sql, '') 

		EXEC sp_executesql @sql, N'@retvalOUT nvarchar(max) OUTPUT' , @retvalOUT=@sql_output OUTPUT;

		if @debug = 1 
			print '-- output sql statement : '+ isnull(@sql_output, '') + ', line_nr:'+isnull(convert(varchar(max), @line_nr) ,'?') 
		
		--set @sql_output  =@sql
		update #result2 set _value = @sql_output , s='executed_sql' -- expressions are skipped in next step
		
		where line_nr = @line_nr 

		fetch next from c into @line_nr , @helper, @expression, @value 
	end
	close c
	deallocate c

	select line_nr, _value, trim(NCHAR(0x09) + NCHAR(0x20) + NCHAR(0x0D) + NCHAR(0x0A)  FROM line._value) trimmed_value
	into #result3
	from #result2 line
	where _value is not null and datalength(_value)>0 and isnull(left(s,1),'')  <> '#'
		and not (isnull(line.seq,0) = 1 and isnull(line.parent_s,'') = '#unless @last') -- when parent = #unless @last-> seq must be <>1

	--select * , datalength(line._value),  datalength(line.trimmed_value)
	--from #result3 line
	--left join #result3 prev_line on line.line_nr = prev_line.line_nr +1 and datalength(line.trimmed_value)=0 and datalength(prev_line.trimmed_value)=0
	--where prev_line.line_nr is null -- no empty prev line exist .. skip multiple empty lines
	
	set @output=''
	
	select @output += isnull(line._value ,'')
	from #result3 line
	--left join #result3 prev_line on line.line_nr = prev_line.line_nr +1 and line._value='' and prev_line._value=''
	--where prev_line.line_nr is null -- no empty prev line exist .. skip multiple empty lines
	order by line.line_nr asc

	footer:

	exec log @transfer_id, 'info', @output
	select @output _output 

	--SELECT column_name 
	--FROM dbo.col_ext 
	--where obj_id = @obj_id
	--order by ordinal_position asc
	-- standard BETL footer code... 
	set nocount on 
	exec dbo.log @transfer_id, 'FOOTER', '?(t?)', @proc_name , @transfer_id
	-- END standard BETL footer code... 



end