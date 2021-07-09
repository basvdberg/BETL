CREATE TABLE [dbo].[Obj_def] (
    [obj_def_id]    INT            IDENTITY (-10, -1) NOT NULL,
    [parent_obj_id] INT            NOT NULL,
    [obj_name]      NVARCHAR (255) NOT NULL,
    [obj_type_id]   INT            NOT NULL,
    [src_obj_id]    INT            NULL,
    [_create_dt]    DATETIME       CONSTRAINT [DF_Obj_def__create_dt] DEFAULT (getdate()) NULL,
    [_delete_dt]    DATETIME       NULL,
    [_batch_id]     INT            NULL,
    [_record_dt]    DATETIME       CONSTRAINT [DF_Obj_def_h_record_dt] DEFAULT (getdate()) NULL,
    [_record_user]  NVARCHAR (255) CONSTRAINT [DF_Obj_def_h_record_user] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_Obj_def] PRIMARY KEY CLUSTERED ([obj_def_id] ASC),
    CONSTRAINT [FK_Obj_def_h_Obj_type] FOREIGN KEY ([obj_type_id]) REFERENCES [static].[Obj_type] ([obj_type_id]),
    CONSTRAINT [FK_Obj_def_parent_Obj] FOREIGN KEY ([parent_obj_id]) REFERENCES [dbo].[Obj] ([obj_id]),
    CONSTRAINT [UIX_Obj_def] UNIQUE NONCLUSTERED ([parent_obj_id] ASC, [obj_name] ASC)
);



