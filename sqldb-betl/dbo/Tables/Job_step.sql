CREATE TABLE [dbo].[Job_step] (
    [job_step_id]        INT             IDENTITY (1, 1) NOT NULL,
    [step_id]            INT             DEFAULT ((1)) NULL,
    [step_name]          VARCHAR (255)   NULL,
    [subsystem]          VARCHAR (255)   DEFAULT ('SSIS') NULL,
    [command]            NVARCHAR (4000) NULL,
    [on_success_action]  INT             DEFAULT ((3)) NULL,
    [on_success_step_id] INT             DEFAULT ((0)) NULL,
    [on_fail_action]     INT             DEFAULT ((2)) NULL,
    [on_fail_step_id]    INT             NULL,
    [database_name]      VARCHAR (255)   DEFAULT ('master') NULL,
    [job_id]             INT             NULL,
    CONSTRAINT [PK_job_step] PRIMARY KEY CLUSTERED ([job_step_id] ASC),
    CONSTRAINT [FK_Job_step_Job] FOREIGN KEY ([job_id]) REFERENCES [dbo].[Job] ([job_id])
);

