$ProgressPreference='SilentlyContinue'
Set-ExecutionPolicy Unrestricted -Force

$winUpdateKey = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\au"
if(!(Test-Path $winUpdateKey) ) { New-Item $winUpdateKey -Type Folder -Force | Out-Null }
New-ItemProperty -Path $winUpdateKey -name 'NoAutoUpdate' -value '1' -propertyType "DWord" -force | Out-Null
New-ItemProperty -Path $winUpdateKey -name 'NoAutoRebootWithLoggedOnUsers' -value '1' -propertyType "DWord" -force | Out-Null

dism /online /disable-feature /featurename:MicrosoftWindowsPowerShellISE

Install-PackageProvider -Name NuGet -Force
Install-Module PSWindowsUpdate -Force
Get-WUInstall -WindowsUpdate -AcceptAll -UpdateType Software -IgnoreReboot

$pageFileMemoryKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $pageFileMemoryKey -Name PagingFiles -Value ""
