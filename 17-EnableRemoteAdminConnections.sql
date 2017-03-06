use master;
GO
exec sp_configure 'show advanced options', 1;
GO
reconfigure;
GO
exec sp_configure 'remote admin connections', 1;
GO
reconfigure;
GO
