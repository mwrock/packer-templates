param (
    [string]$Action="default",
    [string]$testName
)
$here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
if(-not $env:ChocolateyInstall -or -not (Test-Path "$env:ChocolateyInstall")){
    iex ((new-object net.webclient).DownloadString("http://bit.ly/psChocInstall"))
}

if(!(Test-Path $env:ChocolateyInstall\lib\Psake*)) { cinst psake }
if(!(Test-Path $env:ProgramFiles\Oracle\VirtualBox)) { cinst virtualbox }
if(!(Test-Path $env:ChocolateyInstall\lib\WindowsAzurePowershell*)) { cinst WindowsAzurePowershell }
if(!(Test-Path $env:ChocolateyInstall\lib\WindowsAzureLibsForNet*)) { cinst WindowsAzureLibsForNet }
if(!(Get-Command vagrant -ErrorAction SilentlyContinue)) { cinst vagrant }
if(!(Get-Command packer -ErrorAction SilentlyContinue)) { cinst packer }

$psakeDir = (dir $env:ChocolateyInstall\lib\Psake*)
if($psakeDir.length -gt 0) {$psakerDir = $psakeDir[-1]}
."$psakeDir\tools\psake.ps1" "$here/psakeBuild.ps1" $Action -ScriptPath $psakeDir\tools -parameters $PSBoundParameters
