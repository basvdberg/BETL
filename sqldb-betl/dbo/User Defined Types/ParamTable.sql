CREATE TYPE [dbo].[ParamTable] AS TABLE (
    [param_name]  VARCHAR (255) NOT NULL,
    [param_value] VARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([param_name] ASC));

