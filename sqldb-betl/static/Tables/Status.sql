CREATE TABLE [static].[Status] (
    [status_id]   INT            NOT NULL,
    [status_name] VARCHAR (50)   NULL,
    [is_running]  BIT            NULL,
    [description] VARCHAR (255)  NULL,
    [record_dt]   DATETIME       CONSTRAINT [DF__Status__record_d__50F0E28A] DEFAULT (getdate()) NULL,
    [record_user] NVARCHAR (128) CONSTRAINT [DF__Status__record_u__51E506C3] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_Status] PRIMARY KEY CLUSTERED ([status_id] ASC)
);

