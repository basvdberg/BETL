
CREATE FUNCTION [dbo].[server_type]()
RETURNS int
AS
BEGIN
	return case 
		when SERVERPROPERTY('Edition') < 4 then 15 -- on premise
		when SERVERPROPERTY('Edition') >= 5 then 10 -- azure
	end 

END