CREATE TABLE [dbo].[Col_def] (
    [col_def_id]           INT            IDENTITY (-10, -1) NOT NULL,
    [obj_def_id]           INT            NOT NULL,
    [ordinal_position]     SMALLINT       NULL,
    [column_name]          [sysname]      NOT NULL,
    [column_type_id]       INT            NULL,
    [is_nullable]          BIT            NULL,
    [data_type]            VARCHAR (100)  NULL,
    [max_len]              INT            NULL,
    [numeric_precision]    INT            NULL,
    [numeric_scale]        INT            NULL,
    [part_of_unique_index] BIT            NULL,
    [primary_key_sorting]  VARCHAR (4)    NULL,
    [default_value]        NVARCHAR (255) NULL,
    [_create_dt]           DATETIME       CONSTRAINT [DF_Col_def__create_dt] DEFAULT (getdate()) NULL,
    [_delete_dt]           DATETIME       NULL,
    [_record_dt]           DATETIME       CONSTRAINT [DF_Col_def__record_dt] DEFAULT (getdate()) NULL,
    [_record_user]         [sysname]      CONSTRAINT [DF_Col_def__record_user] DEFAULT (suser_sname()) NULL,
    [_batch_id]            INT            NULL,
    CONSTRAINT [PK_Col_def] PRIMARY KEY CLUSTERED ([col_def_id] DESC),
    CONSTRAINT [FK_Col_def_Obj_def] FOREIGN KEY ([obj_def_id]) REFERENCES [dbo].[Obj_def] ([obj_def_id])
);



