/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB Sets the target schema for @full_obj_name 
*/
CREATE procedure [dbo].[set_target_schema] 
	@full_obj_name as varchar(4000) ,
	@target_schema_name as varchar(4000), 
	@batch_id as int = -1 
as 
begin 
	-- standard BETL header code... 
	set nocount on 
	declare   @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @batch_id, 'header', '? ? , ?', @proc_name , @full_obj_name, @target_schema_name
	-- END standard BETL header code... 
	declare @schema_id as int
	exec dbo.get_obj_id @target_schema_name , @schema_id output
	exec dbo.setp 'target_schema_id'
		, @schema_id 
		, @full_obj_name
	-- standard BETL footer code... 
    footer:
	exec dbo.log @batch_id, 'footer', 'DONE ? ? , ? (?)', @proc_name , @full_obj_name, @target_schema_name, @schema_id 
	-- END standard BETL footer code... 
end