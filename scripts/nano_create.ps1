mkdir c:\NanoServer
cd c:\NanoServer
xcopy /s d:\NanoServer\*.* .
. .\new-nanoserverimage.ps1
$adminPassword = ConvertTo-SecureString "Pass@word1" -AsPlainText -Force

New-NanoServerImage `
  -MediaPath D:\ `
  -BasePath .\Base `
  -TargetPath .\Nano `
  -ComputerName Nano `
  -OEMDrivers `
  -ReverseForwarders `
  -AdministratorPassword $adminPassword

Mount-DiskImage -ImagePath "c:\NanoServer\nano\Nano.vhd"

Copy-Item `
  -Path "F:\*" `
  -Destination "E:\" `
  -Force `
  -Recurse `
  -Exclude "System Volume Information" `
  -ErrorAction SilentlyContinue

mkdir E:\Windows\Panther\Unattend
copy-item a:\postunattendNano.xml C:\Windows\Panther\Unattend\unattend.xml

bcdedit /set "{current}" device "partition=E:"
bcdedit /set "{current}" osdevice "partition=E:"
bcdedit /set "{current}" path \windows\system32\boot\winload.exe

Restart-Computer -Force