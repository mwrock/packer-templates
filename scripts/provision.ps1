$ErrorActionPreference = "Stop"

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

Write-Host "Enabling file sharing firewale rules"
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes

if(Test-Path "C:\Users\vagrant\VBoxGuestAdditions.iso") {
    Write-Host "Installing Guest Additions"
    certutil -addstore -f "TrustedPublisher" A:\oracle.cer
    cinst 7zip.commandline -y
    Move-Item C:\Users\vagrant\VBoxGuestAdditions.iso C:\Windows\Temp
    7z x C:\Windows\Temp\VBoxGuestAdditions.iso -oC:\Windows\Temp\virtualbox

    Start-Process -FilePath "C:\Windows\Temp\virtualbox\VBoxWindowsAdditions.exe" -ArgumentList "/S" -WorkingDirectory "C:\Windows\Temp\virtualbox" -Wait

    Remove-Item C:\Windows\Temp\virtualbox -Recurse -Force
    Remove-Item C:\Windows\Temp\VBoxGuestAdditions.iso -Force
}

Write-Host "defragging..."
Optimize-Volume -DriveLetter C

Write-Host "0ing out empty space..."
$FilePath="c:\zero.tmp"
$Volume = Get-WmiObject win32_logicaldisk -filter "DeviceID='C:'"
$ArraySize= 64kb
$SpaceToLeave= $Volume.Size * 0.05
$FileSize= $Volume.FreeSpace - $SpacetoLeave
$ZeroArray= new-object byte[]($ArraySize)
 
$Stream= [io.File]::OpenWrite($FilePath)
try {
   $CurFileSize = 0
    while($CurFileSize -lt $FileSize) {
        $Stream.Write($ZeroArray,0, $ZeroArray.Length)
        $CurFileSize +=$ZeroArray.Length
    }
}
finally {
    if($Stream) {
        $Stream.Close()
    }
}
 
Del $FilePath

Write-Host "copying auto unattend file"
mkdir C:\Windows\Panther\Unattend
copy-item a:\postunattend.xml C:\Windows\Panther\Unattend\unattend.xml
