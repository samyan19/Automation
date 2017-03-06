use master;
GO
exec sp_configure 'show advanced options', 1;
GO
reconfigure;
GO
exec sp_configure 'min server memory (MB)', 1024;
GO
reconfigure;
GO
