CREATE TABLE [dbo].[Prefix] (
    [prefix_name]         VARCHAR (100) NOT NULL,
    [default_template_id] SMALLINT      NULL,
    CONSTRAINT [PK_Prefix_1] PRIMARY KEY CLUSTERED ([prefix_name] ASC)
);

