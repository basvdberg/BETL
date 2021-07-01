CREATE TABLE [static].[Obj_type] (
    [obj_type_id] INT            NOT NULL,
    [obj_type]    VARCHAR (100)  NULL,
    [record_dt]   DATETIME       CONSTRAINT [DF__Obj_type__record__778AC167] DEFAULT (getdate()) NULL,
    [record_user] NVARCHAR (128) CONSTRAINT [DF__Obj_type__record__787EE5A0] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_obj_type] PRIMARY KEY CLUSTERED ([obj_type_id] ASC)
);



