use master;
GO
exec sp_configure 'show advanced options', 1;
GO
reconfigure;
GO
exec sp_configure 'cost threshold for parallelism', 50;
GO
reconfigure;
GO
