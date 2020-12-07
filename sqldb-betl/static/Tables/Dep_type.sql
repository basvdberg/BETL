CREATE TABLE [static].[Dep_type] (
    [dep_type_id]          SMALLINT       NOT NULL,
    [dep_type]             VARCHAR (100)  NULL,
    [dep_type_description] VARCHAR (255)  NULL,
    [record_dt]            DATETIME       CONSTRAINT [DF__Dep_type__record__1451E89E] DEFAULT (getdate()) NULL,
    [record_user]          NVARCHAR (128) CONSTRAINT [DF__Dep_type__record__15460CD7] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_Dep_type] PRIMARY KEY CLUSTERED ([dep_type_id] ASC)
);

