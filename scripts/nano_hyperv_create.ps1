start-transcript -path $env:temp\transcript0.txt -noclobber

mkdir c:\NanoServer
cd c:\NanoServer
xcopy /s d:\NanoServer\*.* .
Import-Module .\NanoServerImageGenerator\NanoServerImageGenerator.psd1
$adminPassword = ConvertTo-SecureString "vagrant" -AsPlainText -Force

New-NanoServerImage `
  -MediaPath D:\ `
  -BasePath .\Base `
  -TargetPath .\Nano\Nano.vhdx `
  -ComputerName Nano `
  -Package @('Microsoft-NanoServer-DSC-Package','Microsoft-NanoServer-IIS-Package') `
  -Containers `
  -DeploymentType Guest `
  -Edition Standard `
  -AdministratorPassword $adminPassword

Mount-DiskImage -ImagePath "c:\NanoServer\nano\Nano.vhdx"

Copy-Item `
  -Path "G:\*" `
  -Destination "E:\" `
  -Force `
  -Recurse `
  -Exclude "System Volume Information" `
  -ErrorAction SilentlyContinue

mkdir E:\Windows\setup\scripts
mkdir E:\Windows\Panther

copy-item a:\postunattend.xml E:\Windows\Panther\unattend.xml -Force
copy-item a:\SetupComplete.cmd E:\Windows\setup\scripts\SetupComplete.cmd -Force
copy-item a:\nano_cleanup.ps1 E:\Windows\setup\scripts\nano_cleanup.ps1 -Force
copy-item a:\nano_cleanup_after_reboot.ps1 E:\Windows\setup\scripts\nano_cleanup_after_reboot.ps1 -Force

bcdedit /set "{current}" device "partition=E:"
bcdedit /set "{current}" osdevice "partition=E:"
bcdedit /set "{current}" path \windows\system32\boot\winload.exe

winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
