Enable-RemoteDesktop
Set-NetFirewallRule -Name RemoteDesktop-UserMode-In-TCP -Enabled True

Write-BoxstarterMessage "Shrinking page file"
$System = GWMI Win32_ComputerSystem -EnableAllPrivileges
$System.AutomaticManagedPagefile = $False
$System.Put()

$CurrentPageFile = gwmi -query "select * from Win32_PageFileSetting where name='c:\\pagefile.sys'"
$CurrentPageFile.InitialSize = 512
$CurrentPageFile.MaximumSize = 512
$CurrentPageFile.Put()

Update-ExecutionPolicy -Policy Unrestricted

Write-BoxstarterMessage "Removing unused features..."
Remove-WindowsFeature -Name 'Powershell-ISE'
Get-WindowsFeature | 
? { $_.InstallState -eq 'Available' } | 
Uninstall-WindowsFeature -Remove

Install-WindowsUpdate -AcceptEula

Write-BoxstarterMessage "Cleaning SxS..."
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

Write-BoxstarterMessage "0ing out empty space..."
wget http://download.sysinternals.com/files/SDelete.zip -OutFile sdelete.zip
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
[System.IO.Compression.ZipFile]::ExtractToDirectory("sdelete.zip", ".") 
./sdelete.exe /accepteula -z c: 

Write-BoxstarterMessage "defragging..."
Optimize-Volume -DriveLetter C

Write-BoxstarterMessage "Setting up winrm"
Set-NetFirewallRule -Name WINRM-HTTP-In-TCP-PUBLIC -RemoteAddress Any
Enable-WSManCredSSP -Force -Role Server

Enable-PSRemoting -Force -SkipNetworkProfileCheck
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
