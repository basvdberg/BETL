CREATE TYPE [dbo].[MappingTable] AS TABLE (
    [src_id] INT NOT NULL,
    [trg_id] INT NOT NULL,
    PRIMARY KEY CLUSTERED ([src_id] ASC, [trg_id] ASC));

