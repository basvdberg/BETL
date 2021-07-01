	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2018-02-05 BvdB update the transfer details. 
select * from dbo.transfer where transfer_id = 100
exec dbo.update_transfer @transfer_id=100, @rec_cnt_src=418
*/
CREATE procedure [dbo].[update_transfer] 
	@transfer_id int
	, @start_dt as datetime = null
	, @end_dt as datetime = null
	, @transfer_name as varchar(100) = null
	, @rec_cnt_src as int=null
	, @rec_cnt_new as int=null
	, @rec_cnt_changed as int=null
	, @rec_cnt_deleted as int=null
	, @status_id as int = null
	, @last_error_id as int = null
	, @src_obj_id as int = null 
	, @trg_obj_id as int = null 
	, @batch_id as int = -1
as 
begin 
	declare   @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @batch_id, 'header', '?[?] @start_dt ? , @end_dt ?, @rec_cnt_src ? , @rec_cnt_new ?, @status_id ?', @proc_name , @transfer_id, @start_dt, @end_dt, @rec_cnt_src, @rec_cnt_new, @status_id 
	update dbo.Transfer set 
		transfer_start_dt = isnull(@start_dt , transfer_start_dt ) 
		, transfer_end_dt = isnull(@end_dt , transfer_end_dt ) 
		, transfer_name = isnull(@transfer_name , transfer_name) 
		, rec_cnt_src=  isnull(@rec_cnt_src , rec_cnt_src) 
		, rec_cnt_new = isnull(@rec_cnt_new , rec_cnt_new ) 
		, rec_cnt_changed  = isnull(@rec_cnt_changed , rec_cnt_changed ) 
		, rec_cnt_deleted = isnull(@rec_cnt_deleted ,rec_cnt_deleted ) 
		, status_id = isnull(@status_id , status_id) 
		, last_error_id = isnull(@last_error_id , last_error_id) 
		, src_obj_id = isnull(@src_obj_id , src_obj_id) 
		, trg_obj_id = isnull(@trg_obj_id , trg_obj_id) 
	where transfer_id = @transfer_id  
	declare @msg as varchar(255) 
	if @rec_cnt_new is not null 
		exec dbo.log @batch_id, 'INFO', 'rec_cnt_new : ?',  @rec_cnt_new
	if @rec_cnt_src  is not null 
		exec dbo.log @batch_id, 'INFO', 'rec_cnt_src  : ?',  @rec_cnt_src 
		
	footer: 
end