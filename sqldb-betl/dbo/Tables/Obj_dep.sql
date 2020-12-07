CREATE TABLE [dbo].[Obj_dep] (
    [obj_id]        INT            NOT NULL,
    [dep_obj_id]    INT            NOT NULL,
    [dep_type_id]   SMALLINT       NOT NULL,
    [top_sort_rank] SMALLINT       NULL,
    [delete_dt]     DATETIME       NULL,
    [record_dt]     DATETIME       CONSTRAINT [DF__Obj_dep__record___18227982] DEFAULT (getdate()) NULL,
    [record_user]   NVARCHAR (128) CONSTRAINT [DF__Obj_dep__record___19169DBB] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK__Obj_dep__7C69C680D927C550] PRIMARY KEY CLUSTERED ([obj_id] ASC, [dep_obj_id] ASC, [dep_type_id] ASC),
    CONSTRAINT [FK_Obj_dep_Dep_type] FOREIGN KEY ([dep_type_id]) REFERENCES [static].[Dep_type] ([dep_type_id]),
    CONSTRAINT [FK_Obj_dep_Obj2] FOREIGN KEY ([obj_id]) REFERENCES [dbo].[Obj] ([obj_id]),
    CONSTRAINT [FK_Obj_dep_Obj3] FOREIGN KEY ([dep_obj_id]) REFERENCES [dbo].[Obj] ([obj_id])
);



