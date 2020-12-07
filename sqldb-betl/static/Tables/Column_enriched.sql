CREATE TABLE [static].[Column_enriched] (
    [schema_name]    NVARCHAR (128) NOT NULL,
    [obj_name]       NVARCHAR (128) NOT NULL,
    [obj_type]       VARCHAR (100)  CONSTRAINT [DF_Column_enriched_obj_type] DEFAULT ('table') NOT NULL,
    [column_name]    NVARCHAR (128) NOT NULL,
    [column_type_id] INT            CONSTRAINT [DF_Key_column_column_type_id] DEFAULT ((100)) NULL,
    [description]    VARCHAR (255)  NULL,
    [_record_dt]     DATETIME       CONSTRAINT [DF_Key_column__record_dt] DEFAULT (getdate()) NULL,
    [_record_user]   NVARCHAR (255) CONSTRAINT [DF_Key_column__record_user] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_Column_enriched] PRIMARY KEY CLUSTERED ([schema_name] ASC, [obj_name] ASC, [obj_type] ASC, [column_name] ASC)
);

