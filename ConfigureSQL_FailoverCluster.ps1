#ConfigureSQL.ps1
#Sam Yanzu

#This script is used to run the SQL confguration scripts
#PRE-REQUISITES
#1. Map '\\internal.closebrothers.com\infrastructure$\SoftwareLibrary\Microsoft\SQL Server' as the Z drive

#$INSTANCENAME = Name of the instance. If default instance enter MSSQLSERVER
#$ScriptRoot = Path to the SQL Setup Scripts
param([string]$INSTANCENAME,[string]$ScriptRoot,[string]$Version)

#Set execution policy to suppress warning when running script from remote loaction
Set-ExecutionPolicy Bypass

#Add sqlps path to environment variable
if($Version -eq "SQL2012") {
$env:PSModulePath = $env:PSModulePath + ";D:\Program Files (x86)\Microsoft SQL Server\110\Tools\PowerShell\Modules\"
}
elseif($Version -eq "SQL2014") {
$env:PSModulePath = $env:PSModulePath + ";D:\Program Files (x86)\Microsoft SQL Server\120\Tools\PowerShell\Modules\"
}
else
{
Write-Host "Failed - Unrecognised SQL version"
exit
}

#Load SQLPS Module if not exists
IF (!(Get-Module -Name sqlps))
    {
        Write-Host 'Loading SQLPS Module' -ForegroundColor DarkYellow
        Push-Location
        Import-Module sqlps -DisableNameChecking
        Pop-Location
    }
  
#Run configuration scripts     

$scripts = Get-ChildItem $ScriptRoot | Where-Object {$_.Extension -eq ".sql"}
  
foreach ($s in $scripts)
    {
        Write-Host "Running Script : " $s.Name -BackgroundColor DarkGreen -ForegroundColor White
        $script = $s.FullName
        try {
            Invoke-Sqlcmd -ServerInstance $INSTANCENAME -InputFile $script -DisableVariables -erroraction stop 
        } catch {
            Write-Host ($_) -ForegroundColor Red
        }
    }

