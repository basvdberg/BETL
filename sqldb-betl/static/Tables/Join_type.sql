CREATE TABLE [static].[Join_type] (
    [join_type_id] INT            NOT NULL,
    [join_type]    VARCHAR (100)  NULL,
    [record_dt]    DATETIME       DEFAULT (getdate()) NULL,
    [record_user]  NVARCHAR (128) DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_Join_type] PRIMARY KEY CLUSTERED ([join_type_id] ASC)
);

