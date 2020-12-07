CREATE TABLE [static].[Data_dic] (
    [schema_name] NVARCHAR (128) NOT NULL,
    [object_name] NVARCHAR (128) NOT NULL,
    [column_name] NVARCHAR (128) NOT NULL,
    [definition]  VARCHAR (MAX)  NULL,
    [remark]      VARCHAR (MAX)  NULL,
    CONSTRAINT [PK_Data_dic] PRIMARY KEY CLUSTERED ([schema_name] ASC, [object_name] ASC, [column_name] ASC)
);

