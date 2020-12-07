CREATE TABLE [dbo].[Property_value] (
    [property_id] INT            NOT NULL,
    [obj_id]      INT            NOT NULL,
    [value]       VARCHAR (255)  NULL,
    [record_dt]   DATETIME       CONSTRAINT [DF__Property___recor__5AE46118] DEFAULT (getdate()) NULL,
    [record_user] NVARCHAR (128) CONSTRAINT [DF__Property___recor__5BD88551] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_Property_Value] PRIMARY KEY CLUSTERED ([property_id] ASC, [obj_id] ASC),
    CONSTRAINT [FK_Property_value_Obj1] FOREIGN KEY ([obj_id]) REFERENCES [dbo].[Obj] ([obj_id]),
    CONSTRAINT [FK_Property_value_Property] FOREIGN KEY ([property_id]) REFERENCES [static].[Property] ([property_id])
);



