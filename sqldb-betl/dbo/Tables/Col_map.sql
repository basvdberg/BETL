CREATE TABLE [dbo].[Col_map] (
    [col_map_id]       INT            IDENTITY (1, 1) NOT NULL,
    [col_id]           INT            NOT NULL,
    [ordinal_position] INT            NOT NULL,
    [src_col_id]       INT            NOT NULL,
    [join_type_id]     INT            NULL,
    [join_exp]         VARCHAR (4000) NULL,
    [_create_dt]       DATETIME       CONSTRAINT [DF_Col_def_mapping__create_dt] DEFAULT (getdate()) NULL,
    [_delete_dt]       DATETIME       NULL,
    [_batch_id]        INT            NULL,
    [_record_dt]       DATETIME       CONSTRAINT [DF_Col_def_mapping_h_record_dt] DEFAULT (getdate()) NULL,
    [_record_user]     NVARCHAR (255) CONSTRAINT [DF_Col_def_mapping_h_record_user] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_Col_map] PRIMARY KEY CLUSTERED ([col_map_id] ASC)
);



