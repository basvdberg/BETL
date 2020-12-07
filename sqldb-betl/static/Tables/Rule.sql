CREATE TABLE [static].[Rule] (
    [rule_id]          INT            NOT NULL,
    [rule_description] VARCHAR (MAX)  NULL,
    [rule_rationale]   VARCHAR (MAX)  NULL,
    [rule_sql_example] VARCHAR (MAX)  NULL,
    [_record_dt]       DATETIME       CONSTRAINT [DF_Rule__record_dt] DEFAULT (getdate()) NULL,
    [_record_user]     NVARCHAR (128) NULL,
    CONSTRAINT [PK_Rule] PRIMARY KEY CLUSTERED ([rule_id] ASC)
);

