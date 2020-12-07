CREATE TABLE [static].[Log_type] (
    [log_type_id]      SMALLINT       NOT NULL,
    [log_type]         VARCHAR (50)   NULL,
    [min_log_level_id] INT            NULL,
    [record_dt]        DATETIME       DEFAULT (getdate()) NULL,
    [record_user]      NVARCHAR (128) DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_Log_type_1] PRIMARY KEY CLUSTERED ([log_type_id] ASC)
);

