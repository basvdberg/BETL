CREATE TABLE [dbo].[Obj_map] (
    [obj_map_id]       INT            IDENTITY (1, 1) NOT NULL,
    [obj_def_id]       INT            NOT NULL,
    [obj_id]           INT            NOT NULL,
    [join_type_id]     INT            NULL,
    [ordinal_position] INT            NOT NULL,
    [_create_dt]       DATETIME       CONSTRAINT [DF_Obj_def_mapping__create_dt] DEFAULT (getdate()) NULL,
    [_delete_dt]       DATETIME       NULL,
    [_batch_id]        INT            NULL,
    [_record_dt]       DATETIME       CONSTRAINT [DF_Obj_def_mapping_h_record_dt] DEFAULT (getdate()) NULL,
    [_record_user]     NVARCHAR (255) CONSTRAINT [DF_Obj_def_mapping_h_record_user] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_Obj_def_mapping] PRIMARY KEY CLUSTERED ([obj_map_id] ASC),
    CONSTRAINT [FK_Obj_def_mapping_Obj] FOREIGN KEY ([obj_id]) REFERENCES [dbo].[Obj] ([obj_id])
);

