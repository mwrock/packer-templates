Import-Module C:\windows\system32\windowspowershell\v1.0\Modules\Microsoft.PowerShell.Utility\Microsoft.PowerShell.Utility.psd1
Import-Module C:\windows\system32\windowspowershell\v1.0\Modules\Microsoft.PowerShell.Management\Microsoft.PowerShell.Management.psd1
Import-Module C:\windows\system32\windowspowershell\v1.0\Modules\Storage\Storage.psd1

start-transcript -path $env:temp\transcript1.txt -noclobber

Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

Optimize-Volume -DriveLetter C

$FilePath="c:\zero.tmp"
$Volume= Get-Volume -DriveLetter C
$ArraySize= 64kb
$SpaceToLeave= $Volume.Size * 0.05
$FileSize= $Volume.SizeRemaining - $SpacetoLeave
$ZeroArray= new-object byte[]($ArraySize)
 
$Stream= [io.File]::OpenWrite($FilePath)
try {
   $CurFileSize = 0
    while($CurFileSize -lt $FileSize) {
        $Stream.Write($ZeroArray,0, $ZeroArray.Length)
        $CurFileSize +=$ZeroArray.Length
    }
} finally {
    if($Stream) {
        $Stream.Close()
    }
}
 
Del $FilePath

schtasks /delete /tn "Postinstall" /f
shutdown /s /t 0