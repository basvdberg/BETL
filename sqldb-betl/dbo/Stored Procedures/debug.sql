
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2018-12-17 BvdB wrapper proc for enabling debug info
exec debug 1 -- TEST 
*/
CREATE PROCEDURE [dbo].[debug]
	@enable bit = 1 
AS
BEGIN
	SET NOCOUNT ON;
	
	exec dbo.reset 

	if @enable =1
		exec dbo.setp 'log_level', 'debug'

    footer:
	exec my_info
END