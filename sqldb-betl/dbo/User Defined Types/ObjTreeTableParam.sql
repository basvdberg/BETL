CREATE TYPE [dbo].[ObjTreeTableParam] AS TABLE (
    [src_obj_id]          INT            NULL,
    [external_obj_id]     INT            NULL,
    [server_type_id]      INT            NULL,
    [server_name]         NVARCHAR (128) NULL,
    [db_name]             NVARCHAR (128) NULL,
    [schema_name]         [sysname]      NULL,
    [obj_name]            [sysname]      NULL,
    [obj_type_id]         INT            NULL,
    [ordinal_position]    INT            NULL,
    [column_name]         [sysname]      NULL,
    [column_type_id]      INT            NULL,
    [is_nullable]         INT            NULL,
    [data_type]           NVARCHAR (128) NULL,
    [max_len]             INT            NULL,
    [numeric_precision]   INT            NULL,
    [numeric_scale]       INT            NULL,
    [primary_key_sorting] VARCHAR (4)    NULL,
    [default_value]       [sysname]      NULL,
    [_source]             VARCHAR (255)  NULL);







