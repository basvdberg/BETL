CREATE TABLE [static].[Obj_type] (
    [obj_type_id]    INT            NOT NULL,
    [obj_type]       VARCHAR (100)  NULL,
    [obj_type_level] INT            NULL,
    [record_dt]      DATETIME       DEFAULT (getdate()) NULL,
    [record_user]    NVARCHAR (128) DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_obj_type] PRIMARY KEY CLUSTERED ([obj_type_id] ASC)
);

