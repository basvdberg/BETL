	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
2018-01-02 BvdB centralize error handling. Allow custom code to integrate external logging
exec dbo.log_error -1, 'Something went wrong', 11 , 0, 0, 'aap'
-----------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[log_error](
		@batch_id as int = -1
		, @msg as varchar(255) 
		, @severity as int 
		, @number as int = null 
		, @line as int = null 
		, @procedure as varchar(255) = null
		, @transfer_id as int=-1
		)
AS
BEGIN
	SET NOCOUNT ON;
	declare @sp_name as varchar(255) = object_name(@@PROCID)
	
	set @msg = '-- Error: '+ convert(varchar(255), isnull(@msg,'')) 
	print @msg

	insert into dbo.Logging(log_dt, msg, batch_id,log_type_id)
	values( getdate(), @msg, isnull(@batch_id,-1), 50) 

--	exec dbo.log @batch_id, 'header', '?(?) severity ? ?', @sp_name ,@batch_id, @severity, @msg
    INSERT INTO [dbo].[Error]([error_code],[error_msg],[error_line],[error_procedure],[error_severity],[batch_id], transfer_id) 
    VALUES (
    @number
    , isnull(@msg,'')
    , @line
    , isnull(@procedure,'')
    , @severity
    , @batch_id
	, @transfer_id
	)


	declare @last_error_id as int = SCOPE_IDENTITY()

    if isnull(@transfer_id,-1) > 0 
		update dbo.[Transfer] set transfer_end_dt = getdate(), status_id = 200, last_error_id = @last_error_id
		where transfer_id = @transfer_id

    update dbo.[Batch] set batch_end_dt = getdate(), status_id = 200 , last_error_id = @last_error_id
    where batch_id = @batch_id

	RAISERROR ( @msg, 18,  179 ) 
--	exec dbo.log @batch_id, 'ERROR' , @msg
	
   footer:
END