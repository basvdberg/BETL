CREATE TYPE [dbo].[ColumnTable] AS TABLE (
    [ordinal_position]     INT           NOT NULL,
    [column_name]          VARCHAR (255) NULL,
    [column_value]         VARCHAR (255) NULL,
    [data_type]            VARCHAR (255) NULL,
    [max_len]              INT           NULL,
    [column_type_id]       INT           NULL,
    [is_nullable]          BIT           NULL,
    [prefix]               VARCHAR (64)  NULL,
    [entity_name]          VARCHAR (64)  NULL,
    [foreign_column_name]  VARCHAR (64)  NULL,
    [foreign_sur_pkey]     INT           NULL,
    [numeric_precision]    INT           NULL,
    [numeric_scale]        INT           NULL,
    [part_of_unique_index] BIT           NULL,
    [identity]             BIT           NULL,
    [src_mapping]          VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([ordinal_position] ASC));

