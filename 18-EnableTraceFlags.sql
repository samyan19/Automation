use master
GO
/*----------------------------------------------------
* create a stored proc to turn on the trace flags
-----------------------------------------------------*/
IF OBJECT_ID('usp_TraceFlagsOn') IS NOT NULL
    DROP PROC usp_TraceFlagsOn
GO

CREATE PROC usp_TraceFlagsOn
AS

--Suppress successful log backup messages
DBCC TRACEON (3226,-1);

--Improves space management, especially for tempdb. More details are given in KB328551, and the PSS Tempdb advice confirms it is useful in all versions of SQL Server
DBCC TRACEON (1118,-1);
 
--Grow all database files uniformly accross filegroup
DBCC TRACEON (1117,-1);

--Force backups to use CHECKSUM parameter. More details are given in KB2656988
DBCC TRACEON (3023,-1);

--Enable all optimizer fixes within the product
DBCC TRACEON (4199,-1);

--Improve Auto Statistics Update behaviour. More details are given in KB2754171
DBCC TRACEON (2371,-1);

--Write XML of deadlock graph to SQL Error log
DBCC TRACEON (1222,-1);


GO

/*-------------------------------------------------
* run the stored proc to turn on the trace flags
--------------------------------------------------*/
use master
go
exec usp_TraceFlagsOn;


/*------------------------------
* assign proc as startup proc
----------------------------------*/
USE master;
GO
-- first set the server to show advanced options
EXEC sp_configure 'show advanced option', '1';
RECONFIGURE;
-- then set the scan for startup procs option to 1
EXEC sp_configure 'scan for startup procs', '1';
RECONFIGURE;

-- set the stored proc to run at SQL Server start-up
exec sp_procoption N'usp_TraceFlagsOn', 'startup', 'on'

/*--------------------------------
* verify trace flags that are on
----------------------------------*/
DBCC TRACESTATUS(-1);

/*---------------------------------------
* Check that proc is in startup procs
----------------------------------------*/
USE master
GO
SELECT value, value_in_use, description
FROM sys.configurations
WHERE name = 'scan for startup procs'
GO