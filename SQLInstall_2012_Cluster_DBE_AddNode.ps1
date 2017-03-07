#SQLInstall_2012_DBE.ps1
#Sam Yanzu

#This script is to install SQL Server 2012 database engine only
#PRE-REQUISITES
#1. SQL Server Request Form and required actions have been completed
#2. Map '\\internal.closebrothers.com\infrastructure$\SoftwareLibrary\Microsoft\SQL Server' as the Z drive
#3. Mount SQL Server 2012 Media to VM and assign as E drive 

#Set policy to suppress warnings when running remote scripts
Set-ExecutionPolicy Bypass

#Default variables - check paths are correct
$CONFIGURATIONFILE="Y:\Automated-Install\Config-Files\ConfigurationFile_2012_Cluster_DBE_AddNode.ini"
$SETUPPATH="H:\Setup.exe"
$ScriptRoot="Y:\Automated-Install\SQL-Setup-Scripts"
$Version="SQL2012"

#-----------------Set user variables-----------------------

#Set instance name
$INSTANCENAME="MSSQLSERVER"

#Set service accounts
$d= Get-Credential 'DBE service account'
$SQLSVCACCOUNT=$d.UserName
$SQLSVCPASSWORD=$d.GetNetworkCredential().Password

$a= Get-Credential 'AGT service account'
$AGTSVCACCOUNT=$a.UserName
$AGTSVCPASSWORD=$a.GetNetworkCredential().Password

#----------------end setting user variables-----------------

#------------------Cluster variables---------------------------
$FAILOVERCLUSTERNETWORKNAME="PDC2SQLV01"
#-------------------end cluster variables-----------------------

#Set power plan to High Performance
powercfg -setactive scheme_min

#Start installation
Write-Host "SQL install starting..."
$process=(Start-Process -Verb runas -FilePath $SETUPPATH -ArgumentList  "/CONFIGURATIONFILE=$CONFIGURATIONFILE /FAILOVERCLUSTERNETWORKNAME=$FAILOVERCLUSTERNETWORKNAME /INSTANCENAME=$INSTANCENAME /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /IACCEPTSQLSERVERLICENSETERMS /QS" -Wait -PassThru)

#configure SQL if build successful
if($process.ExitCode -eq 0)
{
    Write-Host "SQL install complete..."
}
else
{
    Write-Host "SQL install failed. Please check C:\Program Files\Microsoft SQL Server\110\Setup Bootstrap\Log\Summary.txt for further information. Exit code:" $process.ExitCode
}

