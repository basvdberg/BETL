
/*---------------------------------------------------------------------------------------------
BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL
-----------------------------------------------------------------------------------------------
--2019-10-01 BvdB top_sort_obj_dep will 
-- apply a topological sort on a a-cylic directed graph. ( mathematically) 
-- or just determine the order in which to process dependencies so that dependent objects can be processed before the
-- object that has the dependencies. 
--
-- This can be used for determining the control flow for pulling tables based on foreign key dependencies. 
-- the foreign key dependencies form a directed graph. Which should be a-cyclic. To-DO: check this. 
-- this procedure returns a list which you can sort on rank to determine the processing order 
-- (and avoid foreign key lookup errors during processing). 
-- it will be applied on all object dependencies of type 'foreign key' 
-- when processing. First process all tables with no top_sort_ranking (e.g. no foreign keys). 
-- Then process descending. Thus starting with highest top_sort_ranking. 

exec [dbo].top_sort_obj_dep
select * from dbo.obj_dep_ext where dep_type_id = 4
*/

CREATE procedure [dbo].[top_sort_obj_dep]
	@transfer_id as int = -1
as
begin 
	declare 
--		@transfer_id as int = null
		@debug as bit = 0

	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'Header', '?', @proc_name
	-- END standard BETL header code... 

	declare @dep table 
	(
	  id int identity 
	  ,obj_id int 
	  ,dep_obj_id int
	  ,[rank]       int
	  primary key (id) 
	);

	insert into @dep (obj_id, dep_obj_id) 

	select d.obj_id, d.dep_obj_id-- , * 
	from [dbo].[Obj_dep_ext] d
	inner join dbo.obj o on d.obj_id=o.obj_id
	where o.obj_type_id = 10 /*table*/ and dep_type_id = 4 /*'foreign key' */ and d.obj_id <> d.dep_obj_id
	and d.obj_db_name = 'ddp_idw'
	-- add all other tables that have no foreign key dependencies, but are part of the graph
	-- it's important to have the leave nodes of the graph as well, because they form the stop criterium for
	-- the algoritm

	insert into @dep (obj_id) 
	select dep_obj_id
	from @dep
	except 
	select obj_id
	from @dep

	declare @rank as smallint = 0

	update @dep
	set rank = 0
	where dep_obj_id is null -- leave nodes

	-- post rank=1 for parents of leave nodes. 
	while @@rowcount>0 and @rank <8 -- while there is something to do and do not continue after 30
	begin 
		--if @debug = 1  			select * , @rank rank_var from @dep

		set @rank += 1

		update @dep
		set rank = @rank
		where dep_obj_id in (
			select  obj_id 
			from @dep 
			where rank = @rank-1 
		)
		and rank is null -- only set rank once. 
		
	end 

	-- if there was a cycle then @dep contains a dubplicate obj_id with different ranking
	if exists ( 
		select d1.obj_id, d1.[rank]
		from @dep d1
		inner join @dep d2 on d1.obj_id = d2.obj_id and d1.rank<> d2.rank
		-- same object id with different ranks
	) 
	begin
		exec log @transfer_id , 'error', 'Cyclic foreign key dependency found. Unable to determine toplogical sorting'

		-- print out the erronous rows
		select d1.obj_id cyclic_foreign_key_obj_id, d1.dep_obj_id, d1.[rank]
		from @dep d1
		inner join @dep d2 on d1.obj_id = d2.obj_id and d1.rank<> d2.rank
	end



	-- select * from @dep
	--with recursive_dep as
	--(
	--  select obj_id, dep_obj_id, 0 as links_traversed 
	--  from @dep where dep_obj_id is null

	--  union all

	--  select dep.obj_id, dep.dep_obj_id, links_traversed+1
	--  from @dep dep
	--  join recursive_dep on dep.dep_obj_id = recursive_dep.obj_id
	--)
	--select obj_id, dep_obj_id, links_traversed
	--from recursive_dep
	--order by links_traversed


	footer:
	
	if @debug =1 select * from @dep 

	-- update all object dependencies. set to top_sort_rank to null where left join does not succeed
	update dbo.Obj_dep 
	set top_sort_rank = [rank]
	from dbo.Obj_dep 
	left join  @dep d on d.obj_id = Obj_dep.obj_id and d.dep_obj_id = Obj_dep.dep_obj_id
	where dbo.Obj_dep.dep_type_id = 4 -- foreign key

	if @debug =1 
	begin
		select d.* , o.full_obj_name, dep_obj.full_obj_name 
		from @dep d
		inner join dbo.Obj_ext o on d.obj_id= o.obj_id
		left join dbo.Obj_ext dep_obj on dep_obj.obj_id= d.dep_obj_id
		order by rank

		select * 
		from dbo.Obj_dep_ext
		where dep_type_id = 4
		order by top_sort_rank 
	end 
	exec dbo.log @transfer_id, 'footer', 'DONE ? ', @proc_name 
	-- END standard BETL footer code... 

end