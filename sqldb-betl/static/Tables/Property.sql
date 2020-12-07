CREATE TABLE [static].[Property] (
    [property_id]    INT            NOT NULL,
    [property_name]  VARCHAR (255)  NULL,
    [enabled]        BIT            CONSTRAINT [DF_Property_enabled] DEFAULT ((0)) NULL,
    [description]    VARCHAR (255)  NULL,
    [property_scope] VARCHAR (50)   NULL,
    [default_value]  VARCHAR (255)  NULL,
    [apply_table]    BIT            NULL,
    [apply_view]     BIT            NULL,
    [apply_schema]   BIT            NULL,
    [apply_db]       BIT            NULL,
    [apply_srv]      BIT            NULL,
    [record_dt]      DATETIME       CONSTRAINT [DF__Property__record__4BA21D88] DEFAULT (getdate()) NULL,
    [record_user]    NVARCHAR (128) CONSTRAINT [DF__Property__record__4C9641C1] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_Property_1] PRIMARY KEY CLUSTERED ([property_id] ASC)
);



