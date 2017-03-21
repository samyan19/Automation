#SQLInstall_2012_DBE.ps1
#Sam Yanzu
#
#Version 2.0
#Release Notes
#---------------
# * Media is now mounted within the script
#
#This script is to install SQL Server 2012 database engine only
#PRE-REQUISITES
#1. SQL Server Request Form and required actions have been completed
#2. Map '\\internal.closebrothers.com\infrastructure$\SoftwareLibrary\Microsoft\SQL Server' as the Z drive
#3. Mount SQL Server 2012 Media to VM and assign as E drive 


Param(
[Parameter(Mandatory=$true)][ValidateSet('SQL2012','SQL2014')][string]$Version
#$SQLDBEUserName,
#$SQLDBEPassword,
#$SQLAGTUserName,
#$SQLAGTPassword
)

#$SecDBEpasswd = ConvertTo-SecureString $SQLDBEPassword -AsPlainText -Force
#$SQLDBECredential = New-Object System.Management.Automation.PSCredential ($SQLDBEUserName, $SecDBEpasswd)

#$SecAGTpasswd = ConvertTo-SecureString $SQLAGTUserName -AsPlainText -Force
#$SQLAGTCredential = New-Object System.Management.Automation.PSCredential ($SQLAGTPassword, $SecAGTpasswd)

#Set policy to suppress warnings when running remote scripts
Set-ExecutionPolicy Bypass

#Set automation path
#$AUTOMATIONPATH="\\internal.closebrothers.com\infrastructure$\SoftwareLibrary\Microsoft\SQL Server"

#Mount automation
New-PSDrive -Name "Y" -PSProvider FileSystem -Root "\\internal.closebrothers.com\infrastructure$\SoftwareLibrary\Microsoft\SQL Server" -Persist

#Assign version variables
if($Version -eq "SQL2012") {
$CONFIGURATIONFILE = "Y:\Automated-Install\Config-Files\ConfigurationFile_2012_DBE_vRealize.ini"
$ImagePath = "Y:\SQL 2012\SW_DVD9_SQL_Svr_Developer_Edtn_2012w_SP3_64Bit_English_MLF_X20-71004.iso"
}
else
{
Write-Host "Failed - Unrecognised SQL version"
exit
}

Write-Host $CONFIGURATIONFILE

#Mount media
Mount-DiskImage -ImagePath $ImagePath -StorageType ISO
$ISODrive = (Get-DiskImage -ImagePath $ImagePath | Get-Volume).DriveLetter

#Default variables - do not amend
$SETUPPATH="$($ISODrive):\Setup.exe"
$ScriptRoot="Y:\Automated-Install\SQL-Setup-Scripts"

#-----------------Set default variables-----------------------

#Set folder locations
$SQLUSERDBDIR="F:\SQLData"
$SQLUSERDBLOGDIR="G:\SQLLogs"
$SQLTEMPDBDIR="I:\SQLTempDB"
$SQLBACKUPDIR="F:\SQLBackups"
$SQLARCHIVEDBACKUPS="F:\SQLBackups\ArchivedBackups\SystemDatabases"
$SQLMAINTENANCELOGS="D:\Program Files\Microsoft SQL Server\SQL.MAINTENANCE.LOGS"

#Set instance name
$INSTANCENAME="MSSQLSERVER"

#Set sql settings
$SQLSYSADMINACCOUNTS="CLOSEBROTHERSGP\ROLE-G-SQL-SysAdmins"
$SQLCOLLATION="Latin1_General_CI_AS"

#Set service accounts
#$SQLSVCACCOUNT=$SQLDBECredential.UserName
#$SQLSVCPASSWORD=$SQLDBECredential.GetNetworkCredential().Password

#$AGTSVCACCOUNT=$SQLAGTCredential.UserName
#$AGTSVCPASSWORD=$SQLAGTCredential.GetNetworkCredential().Password

#----------------end default variables-----------------

#Set power plan to High Performance
powercfg -setactive scheme_min

#create SQL folders
Write-Host "Creating SQL directories..."
if(!(Test-Path -Path $SQLUSERDBDIR )){
  New-Item -ItemType directory -Path $SQLUSERDBDIR  
}
if(!(Test-Path -Path $SQLUSERDBDIR )){
  New-Item -ItemType directory -Path $SQLTEMPDBDIR  
}
if(!(Test-Path -Path $SQLUSERDBDIR )){
  New-Item -ItemType directory -Path $SQLBACKUPDIR  
}
if(!(Test-Path -Path $SQLUSERDBDIR )){
  New-Item -ItemType directory -Path $SQLARCHIVEDBACKUPS  
}
if(!(Test-Path -Path $SQLUSERDBDIR )){
  New-Item -ItemType directory -Path $SQLMAINTENANCELOGS  
}

#Start installation
Write-Host "SQL install starting..."
#$process=(Start-Process -Verb runas -FilePath $SETUPPATH -ArgumentList  "/CONFIGURATIONFILE=$CONFIGURATIONFILE /INSTANCENAME=$INSTANCENAME /INSTANCEID=$INSTANCENAME /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SQLUSERDBDIR=$SQLUSERDBDIR /SQLUSERDBLOGDIR=$SQLUSERDBLOGDIR /SQLBACKUPDIR=$SQLBACKUPDIR /SQLTEMPDBDIR=$SQLTEMPDBDIR /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /SQLCOLLATION=$SQLCOLLATION /IACCEPTSQLSERVERLICENSETERMS /QS /TCPENABLED=1" -Wait -PassThru)
$process=(Start-Process -Verb runas -FilePath $SETUPPATH -ArgumentList  "/CONFIGURATIONFILE=$CONFIGURATIONFILE /INSTANCENAME=$INSTANCENAME /INSTANCEID=$INSTANCENAME /SQLUSERDBDIR=$SQLUSERDBDIR /SQLUSERDBLOGDIR=$SQLUSERDBLOGDIR /SQLBACKUPDIR=$SQLBACKUPDIR /SQLTEMPDBDIR=$SQLTEMPDBDIR /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /SQLCOLLATION=$SQLCOLLATION /IACCEPTSQLSERVERLICENSETERMS /QS /TCPENABLED=1" -Wait -PassThru)

#configure SQL if build successful
if($process.ExitCode -eq 0)
{
    Write-Host "SQL install complete..."
    
    Write-Host "Apply configuring scripts starting..."
    Invoke-Expression "Y:\Automated-Install\ConfigureSQL.ps1 $INSTANCENAME $ScriptRoot $Version"
    
    #Apply WUG login
    Invoke-Sqlcmd -ServerInstance $INSTANCENAME -InputFile "Y:\AutomatedInstall\Create_WUG_Login.sql"  -DisableVariables -erroraction stop

    #Restart SQL Service
    Restart-Service $INSTANCENAME -Force

    Write-Host "SQL build complete"
}
else
{
    Write-Host "SQL install failed. Please check C:\Program Files\Microsoft SQL Server\110\Setup Bootstrap\Log\Summary.txt for further information. Exit code:" $process.ExitCode
    
    Dismount-DiskImage -ImagePath $ImagePath
    Get-PSDrive -Name Y | Remove-PSDrive
}

