CREATE TABLE [dbo].[Rule_mapping] (
    [rule_id]     INT            NOT NULL,
    [obj_id]      INT            NOT NULL,
    [column_id]   INT            NOT NULL,
    [record_dt]   DATETIME       CONSTRAINT [DF_Rule_mapping_record_dt] DEFAULT (getdate()) NULL,
    [record_user] NVARCHAR (128) CONSTRAINT [DF_Rule_mapping_record_user] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_Rule_mapping] PRIMARY KEY CLUSTERED ([rule_id] ASC, [obj_id] ASC, [column_id] ASC),
    CONSTRAINT [FK_Rule_mapping_Obj] FOREIGN KEY ([obj_id]) REFERENCES [dbo].[Obj] ([obj_id]),
    CONSTRAINT [FK_Rule_mapping_Rule] FOREIGN KEY ([rule_id]) REFERENCES [static].[Rule] ([rule_id])
);

