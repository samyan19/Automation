use master;
GO
exec sp_configure 'show advanced options', 1;
GO
reconfigure;
GO
exec sp_configure 'optimize for ad hoc workloads', 1;
GO
reconfigure;
GO
