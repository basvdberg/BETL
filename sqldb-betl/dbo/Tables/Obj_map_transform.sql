CREATE TABLE [dbo].[Obj_map_transform] (
    [obj_map_id]       INT            NOT NULL,
    [transform_id]     INT            NOT NULL,
    [ordinal_position] INT            NOT NULL,
    [_create_dt]       DATETIME       CONSTRAINT [DF_Obj_map_transform__create_dt] DEFAULT (getdate()) NULL,
    [_delete_dt]       DATETIME       NULL,
    [_batch_id]        INT            NULL,
    [_record_dt]       DATETIME       CONSTRAINT [DF_Obj_map__h_record_dt] DEFAULT (getdate()) NULL,
    [_record_user]     NVARCHAR (255) CONSTRAINT [DF_Obj_map_mapping_h_record_user] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_Obj_map_transform] PRIMARY KEY CLUSTERED ([obj_map_id] ASC, [transform_id] ASC),
    CONSTRAINT [FK_Obj_map_transform_id] FOREIGN KEY ([transform_id]) REFERENCES [dbo].[Transform] ([transform_id])
);

