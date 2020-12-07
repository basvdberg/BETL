CREATE TABLE [dbo].[Job_schedule] (
    [job_schedule_id]        INT       IDENTITY (10, 10) NOT NULL,
    [name]                   [sysname] NOT NULL,
    [enabled]                INT       NOT NULL,
    [freq_type]              INT       NOT NULL,
    [freq_interval]          INT       NOT NULL,
    [freq_subday_type]       INT       NOT NULL,
    [freq_subday_interval]   INT       NOT NULL,
    [freq_relative_interval] INT       NOT NULL,
    [freq_recurrence_factor] INT       NOT NULL,
    [active_start_date]      INT       NOT NULL,
    [active_end_date]        INT       NOT NULL,
    [active_start_time]      INT       NOT NULL,
    [active_end_time]        INT       NOT NULL,
    CONSTRAINT [PK_Job_schedule] PRIMARY KEY CLUSTERED ([job_schedule_id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Job_schedule]
    ON [dbo].[Job_schedule]([job_schedule_id] ASC);

