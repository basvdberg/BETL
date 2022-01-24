CREATE TABLE [dbo].[Logging] (
    [log_id]       INT           IDENTITY (1, 1) NOT NULL,
    [log_dt]       DATETIME      CONSTRAINT [DF_Log_log_dt] DEFAULT (getdate()) NULL,
    [msg]          VARCHAR (MAX) NULL,
    [batch_id]     INT           CONSTRAINT [DF_Log_batch_id] DEFAULT ((-1)) NULL,
    [log_level_id] SMALLINT      CONSTRAINT [DF_Log_log_level_id] DEFAULT ((-1)) NULL,
    [log_type_id]  SMALLINT      NULL,
    [exec_sql]     BIT           NULL,
    CONSTRAINT [PK_log_id] PRIMARY KEY CLUSTERED ([log_id] DESC),
    CONSTRAINT [FK_Log_Log_level] FOREIGN KEY ([log_level_id]) REFERENCES [static].[Log_level] ([log_level_id]),
    CONSTRAINT [FK_Log_Log_type] FOREIGN KEY ([log_type_id]) REFERENCES [static].[Log_type] ([log_type_id])
);



