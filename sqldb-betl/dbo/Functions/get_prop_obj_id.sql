	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB 
select dbo.get_prop_obj_id('etl_meta_fields', 63) 
*/
CREATE function [dbo].[get_prop_obj_id] (
	@prop varchar(255)
	, @obj_id int = null 
	)
returns varchar(255) 
as 
begin
	-- standard BETL header code... 
	--set nocount on 
	declare   @res as varchar(255) 
--			, @debug as bit =0
			, @progress as bit =0
			, @property_id  as int 
	--		, @proc_name as varchar(255) =  object_name(@@PROCID);
	
	-- END standard BETL header code... 
	--return dbo.get_prop_obj_id @obj_id 
	
	select @property_id = [property_id] from [static].[Property]
	where property_name = @prop 
	if @property_id is null 
		return 'invalid property !'
	;
	with q as ( 
	select o.obj_id, o.obj_name, p.property, p.value, p.default_value,
	case when p.[obj_id] = o.[obj_id] then 0 
		when p.[obj_id] = o.parent_id then 1 
		when p.[obj_id] = o.grand_parent_id then 2 
		when p.[obj_id] = o.great_grand_parent_id then 3 end moved_up_in_hierarchy
	from dbo.prop_ext p 
	left join dbo.obj_ext_all o on 
		p.[obj_id] = o.[obj_id] 
		or p.[obj_id] = o.parent_id
		or p.[obj_id] = o.grand_parent_id
		or p.[obj_id] = o.great_grand_parent_id
	where property = @prop
	and o.[obj_id] = @obj_id 
	) 
	, q2 as ( 
	select *, row_number() over (partition by [obj_id] order by moved_up_in_hierarchy asc) seq_nr 
	 from q 
	 where isnull(value , default_value) is not null 
	) 
	select --* 
	@res= isnull(value , default_value) 
	from q2 
	where seq_nr = 1
	return @res
end