CREATE TABLE [dbo].[Transform] (
    [transform_id]          INT            NOT NULL,
    [transform_code]        VARCHAR (MAX)  NULL,
    [transform_description] VARCHAR (MAX)  NULL,
    [rationale]             VARCHAR (MAX)  NULL,
    [_create_dt]            DATETIME       CONSTRAINT [DF_Transform__create_dt] DEFAULT (getdate()) NULL,
    [_delete_dt]            DATETIME       NULL,
    [_record_dt]            DATETIME       CONSTRAINT [DF_Trans__record_dt] DEFAULT (getdate()) NULL,
    [_record_user]          NVARCHAR (128) NULL,
    CONSTRAINT [PK_Rule] PRIMARY KEY CLUSTERED ([transform_id] ASC)
);

