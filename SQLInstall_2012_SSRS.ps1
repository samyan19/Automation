#SQLInstall_2012_SSIS.ps1
#Sam Yanzu

#This script is to install SQL Server 2012 SSIS only
#PRE-REQUISITES
#1. SQL Server Request Form and required actions have been completed
#2. Map '\\internal.closebrothers.com\infrastructure$\SoftwareLibrary\Microsoft\SQL Server' as the Z drive
#3. Mount SQL Server 2012 Media to VM and assign as E drive 

#Default variables - do not amend
$CONFIGURATIONFILE="Y:\Automated-Install\Config-Files\ConfigurationFile_2012_SSRS.ini"
$SETUPPATH="H:\Setup.exe"

#------------Set user variables-------------------

#Set service accounts
$d= Get-Credential 
$RSSVCACCOUNT=$d.UserName
$RSSVCPASSWORD=$d.GetNetworkCredential().Password

#Set instance name
$INSTANCENAME="MSSQLSERVER"

#------------end setting user variables------------------

#Start installation
Write-Host "SSRS install starting..."
$process=(Start-Process -Verb runas -FilePath $SETUPPATH -ArgumentList  "/CONFIGURATIONFILE=$CONFIGURATIONFILE /INSTANCENAME=$INSTANCENAME /INSTANCEID=$INSTANCENAME /RSSVCACCOUNT=$RSSVCACCOUNT /RSSVCPASSWORD=$RSSVCPASSWORD /IACCEPTSQLSERVERLICENSETERMS /QS" -Wait -PassThru)

#configure SQL if build successful
if($process.ExitCode -eq 0)
{
    Write-Host "SSRS install complete"
}
else
{
    Write-Host "SSRS install failed. Please check Summary.txt for further information. Exit code:" $process.ExitCode
}

