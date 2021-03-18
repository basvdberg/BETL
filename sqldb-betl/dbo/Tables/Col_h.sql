CREATE TABLE [dbo].[Col_h] (
    [column_id]            INT            CONSTRAINT [DF_Col_hist_column_id] DEFAULT (NEXT VALUE FOR [seq_col_hist]) NOT NULL,
    [_eff_dt]              DATETIME       CONSTRAINT [DF_Col_hist__eff_dt] DEFAULT (getdate()) NOT NULL,
    [_delete_dt]           DATETIME       NULL,
    [obj_id]               INT            NOT NULL,
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
    [_chksum]              VARBINARY (20) NULL,
    [_record_dt]           DATETIME       CONSTRAINT [DF__Col_hist__record__2764BD12] DEFAULT (getdate()) NULL,
    [_record_user]         [sysname]      CONSTRAINT [DF__Col_hist__record__2858E14B] DEFAULT (suser_sname()) NULL,
    [_transfer_id]         INT            NULL,
    CONSTRAINT [PK__Hst_column] PRIMARY KEY CLUSTERED ([column_id] DESC, [_eff_dt] DESC),
    CONSTRAINT [FK_Col_h_Obj] FOREIGN KEY ([obj_id]) REFERENCES [dbo].[Obj] ([obj_id]),
    CONSTRAINT [FK_Col_hist_Column_type] FOREIGN KEY ([column_type_id]) REFERENCES [static].[Column_type] ([column_type_id])
);





