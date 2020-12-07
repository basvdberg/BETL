CREATE TABLE [dbo].[Error] (
    [error_id]               INT            IDENTITY (1, 1) NOT NULL,
    [error_code]             INT            NULL,
    [error_msg]              VARCHAR (5000) NULL,
    [error_line]             INT            NULL,
    [error_procedure]        VARCHAR (255)  NULL,
    [error_procedure_id]     VARCHAR (255)  NULL,
    [error_execution_id]     VARCHAR (255)  NULL,
    [error_event_name]       VARCHAR (255)  NULL,
    [error_severity]         INT            NULL,
    [error_state]            INT            NULL,
    [error_source]           VARCHAR (255)  NULL,
    [error_interactive_mode] VARCHAR (255)  NULL,
    [error_machine_name]     NVARCHAR (255) NULL,
    [error_user_name]        NVARCHAR (128) NULL,
    [transfer_id]            INT            NULL,
    [record_dt]              DATETIME       CONSTRAINT [DF__Error__record_dt__24885067] DEFAULT (getdate()) NULL,
    [record_user]            NVARCHAR (128) NULL,
    CONSTRAINT [PK_error_id] PRIMARY KEY CLUSTERED ([error_id] DESC)
);

