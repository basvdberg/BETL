CREATE SCHEMA [static]
    AUTHORIZATION [dbo];
































GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Static betl data, not dependent on customer implementation', @level0type = N'SCHEMA', @level0name = N'static';

