CREATE TABLE [static].[Template] (
    [template_id]          SMALLINT       NOT NULL,
    [template_name]        VARCHAR (100)  NULL,
    [template_code]        NVARCHAR (MAX) NULL,
    [template_description] VARCHAR (255)  NULL,
    [_record_dt]           DATETIME       CONSTRAINT [DF__Template__record__20B7BF83] DEFAULT (getdate()) NULL,
    [_record_name]         NVARCHAR (128) CONSTRAINT [DF__Template__record__21ABE3BC] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_Template] PRIMARY KEY CLUSTERED ([template_id] ASC)
);










GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Template_name]
    ON [static].[Template]([template_name] ASC);


GO


