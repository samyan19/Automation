$INSTANCENAME="MSSQLSERVER"
$localScriptRoot="Y:\Automated-Install\SQL-Setup-Scripts"
$Version="SQL2012"



Invoke-Expression "Y:\Automated-Install\ConfigureSQL.ps1 $INSTANCENAME $localScriptRoot $Version"