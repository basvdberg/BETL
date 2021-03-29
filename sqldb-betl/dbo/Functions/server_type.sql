

CREATE FUNCTION [dbo].[server_type]()
RETURNS int
AS
BEGIN
	return case 
		when SERVERPROPERTY('EngineEdition') < 4 then 15 -- on premise
		when SERVERPROPERTY('EngineEdition') >= 5 then 10 -- azure
	end 

END
GO


