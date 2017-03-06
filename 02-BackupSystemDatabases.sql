-- ===========================
-- Backup Database Template
-- ===========================
BACKUP DATABASE master 
	TO  DISK = N'F:\SQLBackups\ArchivedBackups\SystemDatabases\master.bak' 
WITH 
	NOFORMAT, 
	COMPRESSION,
	NOINIT,  
	NAME = N'master-Full Database Backup', 
	SKIP, 
	STATS = 10;
GO
BACKUP DATABASE model 
	TO  DISK = N'F:\SQLBackups\ArchivedBackups\SystemDatabases\model.bak' 
WITH 
	NOFORMAT, 
	COMPRESSION,
	NOINIT,  
	NAME = N'model-Full Database Backup', 
	SKIP, 
	STATS = 10;
GO
BACKUP DATABASE msdb 
	TO  DISK = N'F:\SQLBackups\ArchivedBackups\SystemDatabases\msdb.bak' 
WITH 
	NOFORMAT, 
	COMPRESSION,
	NOINIT,  
	NAME = N'msdb-Full Database Backup', 
	SKIP, 
	STATS = 10;
GO