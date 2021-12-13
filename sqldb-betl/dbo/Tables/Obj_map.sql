CREATE TABLE [dbo].[Obj_map] (
    [trg_obj_id]       INT            NOT NULL,
    [ordinal_position] INT            CONSTRAINT [DF__Obj_map__ordinal__1699586C] DEFAULT ((1)) NOT NULL,
    [src_obj_id]       INT            NOT NULL,
    [join_type_id]     INT            CONSTRAINT [DF__Obj_map__join_ty__178D7CA5] DEFAULT ((-1)) NULL,
    [join_cond]        VARCHAR (4000) NULL,
    [_create_dt]       DATETIME       CONSTRAINT [DF_Obj_def_mapping__create_dt] DEFAULT (getdate()) NULL,
    [_delete_dt]       DATETIME       NULL,
    [_batch_id]        INT            NULL,
    [_record_dt]       DATETIME       CONSTRAINT [DF_Obj_def_mapping_h_record_dt] DEFAULT (getdate()) NULL,
    [_record_user]     NVARCHAR (255) CONSTRAINT [DF_Obj_def_mapping_h_record_user] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_Obj_def_mapping] PRIMARY KEY CLUSTERED ([trg_obj_id] DESC, [ordinal_position] ASC),
    CONSTRAINT [FK_Obj_map_src_obj_id] FOREIGN KEY ([src_obj_id]) REFERENCES [dbo].[Obj] ([obj_id]),
    CONSTRAINT [FK_Obj_map_trg_obj_id] FOREIGN KEY ([trg_obj_id]) REFERENCES [dbo].[Obj] ([obj_id])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'e.g. {{trg}}.customer_id = {{src}}.customer_id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Obj_map', @level2type = N'COLUMN', @level2name = N'join_cond';

