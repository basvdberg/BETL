CREATE TABLE [dbo].[Batch] (
    [batch_id]        INT            IDENTITY (1, 1) NOT NULL,
    [batch_name]      NVARCHAR (128) NULL,
    [batch_start_dt]  DATETIME       CONSTRAINT [DF__Batch__batch_sta__524F1B17] DEFAULT (getdate()) NULL,
    [batch_end_dt]    DATETIME       NULL,
    [status_id]       INT            CONSTRAINT [DF_Batch_status_id] DEFAULT ((-1)) NULL,
    [last_error_id]   INT            CONSTRAINT [DF_Batch_last_error_id] DEFAULT ((-1)) NULL,
    [prev_batch_id]   INT            CONSTRAINT [DF_Batch_prev_batch_id] DEFAULT ((-1)) NULL,
    [exec_server]     NVARCHAR (128) CONSTRAINT [DF__Batch__exec_serv__53433F50] DEFAULT (@@servername) NULL,
    [exec_host]       NVARCHAR (128) CONSTRAINT [DF__Batch__exec_host__54376389] DEFAULT (host_name()) NULL,
    [exec_user]       NVARCHAR (128) CONSTRAINT [DF__Batch__exec_user__552B87C2] DEFAULT (suser_sname()) NULL,
    [guid]            NVARCHAR (255) NULL,
    [continue_batch]  BIT            CONSTRAINT [DF__Batch__continue___561FABFB] DEFAULT ((0)) NULL,
    [batch_seq]       INT            NULL,
    [parent_batch_id] INT            NULL,
    CONSTRAINT [PK_run_id] PRIMARY KEY CLUSTERED ([batch_id] DESC),
    CONSTRAINT [FK_Batch_Batch] FOREIGN KEY ([prev_batch_id]) REFERENCES [dbo].[Batch] ([batch_id]),
    CONSTRAINT [FK_Batch_Error] FOREIGN KEY ([last_error_id]) REFERENCES [dbo].[Error] ([error_id])
);

