CREATE TABLE [static].[Column_type] (
    [column_type_id]          INT            NOT NULL,
    [column_type]             VARCHAR (50)   NULL,
    [column_type_description] VARCHAR (255)  NULL,
    [record_dt]               DATETIME       NULL,
    [record_user]             NVARCHAR (128) NULL,
    CONSTRAINT [PK_Column_type] PRIMARY KEY CLUSTERED ([column_type_id] ASC)
);



