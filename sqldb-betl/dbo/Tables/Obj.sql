CREATE TABLE [dbo].[Obj] (
    [obj_id]             INT            CONSTRAINT [DF_Obj_seq_obj_id] DEFAULT (NEXT VALUE FOR [seq_Obj]) NOT NULL,
    [obj_name]           NVARCHAR (255) NOT NULL,
    [obj_type_id]        INT            NOT NULL,
    [parent_id]          INT            NULL,
    [prefix]             NVARCHAR (50)  NULL,
    [obj_name_no_prefix] NVARCHAR (255) NULL,
    [server_type_id]     INT            CONSTRAINT [DF_Obj_h_server_type] DEFAULT ((10)) NULL,
    [identifier]         INT            NULL,
    [src_obj_id]         INT            NULL,
    [external_obj_id]    INT            NULL,
    [_create_dt]         DATETIME       NULL,
    [_delete_dt]         DATETIME       NULL,
    [_transfer_id]       INT            NULL,
    [_record_dt]         DATETIME       CONSTRAINT [DF_Obj_h_record_dt] DEFAULT (getdate()) NULL,
    [_record_user]       NVARCHAR (255) CONSTRAINT [DF_Obj_h_record_user] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_Obj] PRIMARY KEY CLUSTERED ([obj_id] ASC),
    CONSTRAINT [FK_Obj_h_Obj_type] FOREIGN KEY ([obj_type_id]) REFERENCES [static].[Obj_type] ([obj_type_id]),
    CONSTRAINT [FK_Obj_h_Server_type] FOREIGN KEY ([server_type_id]) REFERENCES [static].[Server_type] ([server_type_id]),
    CONSTRAINT [FK_Obj_Obj] FOREIGN KEY ([parent_id]) REFERENCES [dbo].[Obj] ([obj_id]),
    CONSTRAINT [FK_Obj_src_Obj] FOREIGN KEY ([src_obj_id]) REFERENCES [dbo].[Obj] ([obj_id])
);










GO
CREATE UNIQUE NONCLUSTERED INDEX [UI_Obj_h_obj_name_obj_type_parent_id]
    ON [dbo].[Obj]([obj_name] ASC, [obj_type_id] ASC, [parent_id] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'this is the id of the originating object ( lineage)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Obj', @level2type = N'COLUMN', @level2name = N'src_obj_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'this is the id in the database. e.g. in object_id sys.objects.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Obj', @level2type = N'COLUMN', @level2name = N'external_obj_id';

