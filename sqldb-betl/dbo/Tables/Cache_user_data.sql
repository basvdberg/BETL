CREATE TABLE [dbo].[Cache_user_data] (
    [user_name]     NVARCHAR (128) NOT NULL,
    [log_level]     NVARCHAR (128) NULL,
    [exec_sql]      BIT            NULL,
    [record_dt]     DATETIME       CONSTRAINT [DF__Cache_use__recor__48C5B0DD] DEFAULT (getdate()) NULL,
    [expiration_dt] DATETIME       NULL,
    CONSTRAINT [PK_Cache_1] PRIMARY KEY CLUSTERED ([user_name] ASC)
);






GO
EXECUTE sp_addextendedproperty @name = N'sys_data_classification_recommendation_disabled', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Cache_user_data', @level2type = N'COLUMN', @level2name = N'expiration_dt';


