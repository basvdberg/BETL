
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

CREATE procedure [dbo].[top_sort_obj_dep_old]
	@transfer_id as int = -1
as
begin 
	declare 
--		@transfer_id as int = null,
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
	  ,[rank]       int         default 0
	  ,degree       int         NULL
	  primary key (id) 
	);

	insert into @dep (obj_id, dep_obj_id) 

	select d.obj_id, d.dep_obj_id-- , * 
	from [dbo].[Obj_dep_ext] d
	inner join dbo.obj o on d.obj_id=o.obj_id
	where o.obj_type_id = 10 /*table*/ and dep_type_id = 4 /*'foreign key' */ and d.obj_id <> d.dep_obj_id
	-- add all other tables that have no foreign key dependencies, but are part of the graph
	insert into @dep (obj_id) 
	select dep_obj_id
	from @dep
	except 
	select obj_id
	from @dep

	--select * from @dep

	declare @step_no int

	-- computing the degree of the nodes
	-- the degree is the number of dependencies. e.g. the number of foreign keys to other objects (not to itself). 
	update  d set d.degree = isnull(count_degree,0) 
	from @dep d
	left join ( 
		select obj_id obj_id, count(*) count_degree
		from @dep
		where dep_obj_id is not null 
		group by obj_id 
	) d2
	on d.obj_id = d2.obj_id
	
	if @debug =1 select * from @dep 
	
	set @step_no = 1
	while 1 = 1
	begin
		update @dep set rank = @step_no, degree = NULL  where degree = 0
		if (@@rowcount = 0) break

		update d set d.degree = isnull(count_degree, 0) 
		from @dep d
		left join ( 
			select dep_obj_id obj_id, count(*) count_degree
			from @dep
			where obj_id in (select tt.obj_id from @dep tt where tt.rank = 0) -- meaning unvisited
			and dep_obj_id is not null 
			group by dep_obj_id 
		) d2
		on d.obj_id = d2.obj_id
		where d.degree is not null
		/*
		update d set degree = (
			select count(*) from @dep t
			where t.dep_obj_id = d.obj_id and t.obj_id != t.dep_obj_id
			and t.obj_id in (select tt.obj_id from @dep tt where tt.rank = 0)) -- meaning unvisited
		from @dep d
		where d.degree is not null
		*/
		set @step_no = @step_no + 1
	end

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