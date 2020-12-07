SELECT r.name role_principal_name, m.name AS member_principal_name
FROM sys.database_role_members rm 
JOIN sys.database_principals r 
    ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m 
    ON rm.member_principal_id = m.principal_id

select 
	isnull(object_schema_name(major_id,db_id()) +'.'+ object_name(major_id),
		case when dp.class_desc='SCHEMA' then 'db schema '+quotename(schema_name(dp.major_id)) else dp.class_desc end ) [object]
	,permission_name [permission]
	, user_name(dp.grantee_principal_id) [GrantedTo]
	, user_name(dp.grantor_principal_id) [GrantedBy]
	, o.is_ms_shipped
	, o.type_desc
	,dp.state_desc
from sys.database_permissions dp
	left join sys.objects o on dp.major_id=o.object_id 
order by 1
option (recompile)


--revoke create schema to [df-ddppoc-bas-s]


DECLARE @permissionlevels TABLE
(
	PermissionLevel NVARCHAR(256)
)

INSERT INTO @permissionlevels
SELECT DISTINCT pp.name AS PermissionLevel
FROM sys.database_role_members roles
LEFT JOIN sys.database_principals p
	ON roles.member_principal_id = p.principal_id
LEFT JOIN sys.database_principals pp
	ON roles.role_principal_id = pp.principal_id

DECLARE @permissionlevel_columns NVARCHAR(1000)
SET @permissionlevel_columns = ''

SELECT @permissionlevel_columns += '[' + PermissionLevel + '],' FROM @permissionlevels

SET @permissionlevel_columns = STUFF(@permissionlevel_columns, LEN(@permissionlevel_columns), 1, '')

DECLARE @sqlstatement NVARCHAR(MAX)

SET @sqlstatement = 'SELECT ServerName '
+ '	, DBName '
+ '	, UserName '
+ '	, TypeOfLogin '
+ '	,' + @permissionlevel_columns
+ 'FROM ( '
+ '	SELECT @@servername AS ServerName '
+ '		, db_name(db_id()) AS DBName '
+ '		, p.name AS UserName '
+ '		, p.type_desc AS TypeOfLogin '
+ '		, pp.name AS PermissionLevel '
+ '		, pp.type_desc AS TypeOfRole '
+ '		, ''x'' AS Autorized '
+ '	FROM sys.database_role_members roles '
+ '	LEFT JOIN sys.database_principals p '
+ '		ON roles.member_principal_id = p.principal_id '
+ '	LEFT JOIN sys.database_principals pp '
+ '		ON roles.role_principal_id = pp.principal_id '
+ ') a '
+ 'PIVOT '
+ '( '
+ '	MAX(Autorized) '
+ '	FOR PermissionLevel IN (' +  @permissionlevel_columns + ') '
+ ') AS pv '
+ 'ORDER BY UserName '

EXEC (@sqlstatement)