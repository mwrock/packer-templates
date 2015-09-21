$partition = Get-Partition -DriveLetter C
$c_size = $partition.size
$partition = Get-Partition -DriveLetter D
$d_size = $partition.size

Remove-Partition -DriveLetter E -Confirm:$false
Resize-Partition -DriveLetter C -Size ($c_size + $d_size)

Optimize-Volume -DriveLetter C

wget http://download.sysinternals.com/files/SDelete.zip -OutFile sdelete.zip
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
[System.IO.Compression.ZipFile]::ExtractToDirectory("sdelete.zip", ".") 
./sdelete.exe /accepteula -z c:

winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
