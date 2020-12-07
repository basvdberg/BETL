CREATE TABLE [dbo].[Job] (
    [job_id]          INT            IDENTITY (10, 10) NOT NULL,
    [name]            VARCHAR (255)  NULL,
    [description]     VARCHAR (255)  NULL,
    [enabled]         BIT            DEFAULT ((1)) NULL,
    [category_name]   VARCHAR (255)  NULL,
    [job_schedule_id] INT            NULL,
    [record_dt]       DATETIME       CONSTRAINT [DF_Job_record_dt] DEFAULT (getdate()) NULL,
    [record_user]     NVARCHAR (128) CONSTRAINT [DF_Job_record_user] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_Job] PRIMARY KEY CLUSTERED ([job_id] ASC),
    CONSTRAINT [FK_Job_Job_schedule] FOREIGN KEY ([job_schedule_id]) REFERENCES [dbo].[Job_schedule] ([job_schedule_id])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Job]
    ON [dbo].[Job]([name] ASC);

