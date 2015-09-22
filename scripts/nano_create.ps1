start-transcript -path $env:temp\transcript0.txt -noclobber

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

bcdedit /set "{current}" device "partition=E:"
bcdedit /set "{current}" osdevice "partition=E:"
bcdedit /set "{current}" path \windows\system32\boot\winload.exe

mkdir E:\Windows\setup\scripts
copy-item a:\postunattend.xml E:\Windows\Panther\unattend.xml -Force
copy-item a:\SetupComplete.cmd E:\Windows\setup\scripts\SetupComplete.cmd -Force

mkdir E:\sdelete
cd E:\sdelete
Invoke-Webrequest http://download.sysinternals.com/files/SDelete.zip -OutFile sdelete.zip
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
[System.IO.Compression.ZipFile]::ExtractToDirectory('e:\sdelete\sdelete.zip', 'e:\sdelete') 

winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
