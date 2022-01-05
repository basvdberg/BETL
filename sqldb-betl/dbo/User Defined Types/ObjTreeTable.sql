CREATE TYPE [dbo].[ObjTreeTable] AS TABLE (
    [obj_id]              INT            NULL,
    [external_obj_id]     INT            NULL,
    [server_type_id]      INT            NULL,
    [server_name]         NVARCHAR (128) NULL,
    [server_id]           INT            NULL,
    [db_name]             NVARCHAR (128) NULL,
    [db_id]               INT            NULL,
    [schema_name]         [sysname]      NULL,
    [schema_id]           INT            NULL,
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
    [prefix]              NVARCHAR (255) NULL,
    [obj_name_no_prefix]  NVARCHAR (255) NULL,
    [_source]             VARCHAR (255)  NULL,
    [src_obj_id]          INT            NULL,
    [obj_def_id]          INT            NULL);











