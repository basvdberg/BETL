CREATE TABLE [dbo].[Transfer] (
    [transfer_id]       INT            IDENTITY (1, 1) NOT NULL,
    [batch_id]          INT            CONSTRAINT [DF_Transfer_batch_id] DEFAULT ((-1)) NULL,
    [transfer_name]     VARCHAR (255)  NULL,
    [src_obj_id]        INT            CONSTRAINT [DF_Transfer_src_obj_id] DEFAULT ((-1)) NULL,
    [trg_obj_id]        INT            NULL,
    [trg_obj_name]      NVARCHAR (255) NULL,
    [transfer_start_dt] DATETIME       NULL,
    [transfer_end_dt]   DATETIME       NULL,
    [status_id]         INT            CONSTRAINT [DF_Transfer_status_id] DEFAULT ((-1)) NULL,
    [rec_cnt_src]       INT            NULL,
    [rec_cnt_new]       INT            NULL,
    [rec_cnt_changed]   INT            NULL,
    [rec_cnt_deleted]   INT            NULL,
    [rec_cnt_undeleted] INT            NULL,
    [last_error_id]     INT            CONSTRAINT [DF_Transfer_last_error_id] DEFAULT ((-1)) NULL,
    [prev_transfer_id]  INT            CONSTRAINT [DF_Transfer_prev_transfer_id] DEFAULT ((-1)) NULL,
    [transfer_seq]      INT            CONSTRAINT [DF_Transfer_transfer_seq] DEFAULT ((-1)) NULL,
    [guid]              VARCHAR (255)  NULL,
    [_record_dt]        DATETIME       CONSTRAINT [DF_Transfer_record_dt] DEFAULT (getdate()) NULL,
    [_record_user]      NVARCHAR (128) CONSTRAINT [DF_Transfer_record_user] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_transfer_id] PRIMARY KEY CLUSTERED ([transfer_id] DESC),
    CONSTRAINT [FK_Transfer_Batch] FOREIGN KEY ([batch_id]) REFERENCES [dbo].[Batch] ([batch_id]),
    CONSTRAINT [FK_Transfer_Error] FOREIGN KEY ([last_error_id]) REFERENCES [dbo].[Error] ([error_id]),
    CONSTRAINT [FK_Transfer_Status] FOREIGN KEY ([status_id]) REFERENCES [static].[Status] ([status_id]),
    CONSTRAINT [FK_Transfer_Transfer] FOREIGN KEY ([prev_transfer_id]) REFERENCES [dbo].[Transfer] ([transfer_id])
);









