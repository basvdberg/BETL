CREATE TABLE [dbo].[Stack] (
    [stack_id]    INT            IDENTITY (1, 1) NOT NULL,
    [value]       VARCHAR (4000) NULL,
    [record_dt]   DATETIME       CONSTRAINT [DF__Stack__record_dt__3B6BB5BF] DEFAULT (getdate()) NULL,
    [record_user] NVARCHAR (128) CONSTRAINT [DF__Stack__record_us__3C5FD9F8] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_Stack] PRIMARY KEY CLUSTERED ([stack_id] DESC)
);

