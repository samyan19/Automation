#SQLInstall_2016_DBE.ps1
#Sam Yanzu

#This script is to install SQL Server 2016 database engine only
#PRE-REQUISITES
#1. SQL Server Request Form and required actions have been completed
#2. Map '\\internal.closebrothers.com\infrastructure$\SoftwareLibrary\Microsoft\SQL Server' as the Z drive
#3. Mount SQL Server 2016 Media to VM and assign as E drive 

#Set policy to suppress warnings when running remote scripts
Set-ExecutionPolicy Bypass

#Default variables - do not amend
$CONFIGURATIONFILE="Y:\Automated-Install\Config-Files\ConfigurationFile_2016_DBE.ini"
$SETUPPATH="H:\Setup.exe"
$ScriptRoot="Y:\Automated-Install\SQL-Setup-Scripts"
$Version="SQL2016"

#-----------------Set user variables-----------------------

#Set folder locations
$SQLUSERDBDIR="F:\SQLData"
$SQLUSERDBLOGDIR="G:\SQLLogs"
$SQLTEMPDBDIR="I:\SQLTempDB"
$SQLBACKUPDIR="F:\SQLBackups"
$SQLARCHIVEDBACKUPS="F:\SQLBackups\ArchivedBackups\SystemDatabases"
$SQLMAINTENANCELOGS="D:\Program Files\Microsoft SQL Server\SQL.MAINTENANCE.LOGS"

#Set instance name
$INSTANCENAME="MSSQLSERVER"

#Set service accounts
$d= Get-Credential 'DBE service account'
$SQLSVCACCOUNT=$d.UserName
$SQLSVCPASSWORD=$d.GetNetworkCredential().Password

$a= Get-Credential 'AGT service account'
$AGTSVCACCOUNT=$a.UserName
$AGTSVCPASSWORD=$a.GetNetworkCredential().Password

#Set sql settings
$SQLSYSADMINACCOUNTS="CLOSEBROTHERSGP\ROLE-U-SP2016-PP-DatabaseEngineer"
$SQLCOLLATION="Latin1_General_CI_AS"

#----------------end setting user variables-----------------

#Set power plan to High Performance
powercfg -setactive scheme_min

#create SQL folders
Write-Host "Creating SQL directories..."
New-Item -ItemType directory -Path $SQLUSERDBDIR
New-Item -ItemType directory -Path $SQLUSERDBLOGDIR
New-Item -ItemType directory -Path $SQLTEMPDBDIR
New-Item -ItemType directory -Path $SQLBACKUPDIR
New-Item -ItemType directory -Path $SQLARCHIVEDBACKUPS
New-Item -ItemType directory -Path $SQLMAINTENANCELOGS

#Start installation
Write-Host "SQL install starting..."
$process=(Start-Process -Verb runas -FilePath $SETUPPATH -ArgumentList  "/CONFIGURATIONFILE=$CONFIGURATIONFILE /INSTANCENAME=$INSTANCENAME /INSTANCEID=$INSTANCENAME /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SQLUSERDBDIR=$SQLUSERDBDIR /SQLUSERDBLOGDIR=$SQLUSERDBLOGDIR /SQLBACKUPDIR=$SQLBACKUPDIR /SQLTEMPDBDIR=$SQLTEMPDBDIR /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /SQLCOLLATION=$SQLCOLLATION /IACCEPTSQLSERVERLICENSETERMS /QS /TCPENABLED=1" -Wait -PassThru)

#configure SQL if build successful
if($process.ExitCode -eq 0)
{
    Write-Host "SQL install complete..."
    
    Write-Host "Apply configuring scripts starting..."
    Invoke-Expression "Y:\Automated-Install\ConfigureSQL.ps1 $INSTANCENAME $ScriptRoot $Version"
    
    Write-Host "SQL build complete"
    Write-Host "Installing SSMS..."

    Start-Process -FilePath "Y:\SQL 2016\SSMS-Setup-ENU.exe" -ArgumentList "/install /quiet /log D:/DBA/ssms_log.txt" -Wait
    Write-Host "SSMS build complete"
}
else
{
    Write-Host "SQL install failed. Please check C:\Program Files\Microsoft SQL Server\130\Setup Bootstrap\Log\Summary.txt for further information. Exit code:" $process.ExitCode
}

