CREATE TABLE [static].[Version] (
    [major_version] INT            NOT NULL,
    [minor_version] INT            NOT NULL,
    [build]         INT            NOT NULL,
    [build_dt]      DATETIME       NULL,
    [record_dt]     DATETIME       DEFAULT (getdate()) NULL,
    [record_user]   NVARCHAR (128) DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_Version] PRIMARY KEY CLUSTERED ([major_version] ASC, [minor_version] ASC, [build] ASC)
);

