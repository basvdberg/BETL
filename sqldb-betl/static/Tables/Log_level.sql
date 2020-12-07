CREATE TABLE [static].[Log_level] (
    [log_level_id]          SMALLINT       NOT NULL,
    [log_level]             VARCHAR (50)   NULL,
    [log_level_description] VARCHAR (255)  NULL,
    [record_dt]             DATETIME       CONSTRAINT [DF_Log_level_record_dt] DEFAULT (getdate()) NULL,
    [record_user]           NVARCHAR (128) CONSTRAINT [DF_Log_level_record_user] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_Log_level_1] PRIMARY KEY CLUSTERED ([log_level_id] ASC)
);

