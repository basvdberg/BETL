CREATE TABLE [static].[Column] (
    [column_id]           INT            NOT NULL,
    [column_name]         [sysname]      NOT NULL,
    [column_description]  VARCHAR (255)  NULL,
    [column_type_id]      INT            NULL,
    [ordinal_position]    INT            CONSTRAINT [DF_Column_ordinal_position] DEFAULT ((999)) NULL,
    [data_type]           [sysname]      NULL,
    [max_len]             INT            NULL,
    [default_value]       [sysname]      NULL,
    [is_nullable]         BIT            NULL,
    [primary_key_sorting] VARCHAR (10)   CONSTRAINT [DF_Column_primary_key_sorting] DEFAULT ((1)) NULL,
    [staging]             BIT            NULL,
    [rdw]                 BIT            NULL,
    [idw]                 BIT            NULL,
    [idw_hub]             BIT            NULL,
    [datamart]            BIT            NULL,
    [_record_dt]          DATETIME       CONSTRAINT [DF_Column_record_dt] DEFAULT (getdate()) NULL,
    [_record_user]        NVARCHAR (128) CONSTRAINT [DF_Column_record_user] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_static_Column] PRIMARY KEY CLUSTERED ([column_id] ASC)
);









