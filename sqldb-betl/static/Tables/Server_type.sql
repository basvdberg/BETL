CREATE TABLE [static].[Server_type] (
    [server_type_id] INT            NOT NULL,
    [server_type]    VARCHAR (100)  NULL,
    [compatibility]  VARCHAR (255)  NULL,
    [record_dt]      DATETIME       DEFAULT (getdate()) NULL,
    [record_user]    NVARCHAR (128) DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_Server_type] PRIMARY KEY CLUSTERED ([server_type_id] ASC)
);

