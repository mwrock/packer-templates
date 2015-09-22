$partition = Get-Partition -DriveLetter C
$c_size = $partition.size
$partition = Get-Partition -DriveLetter D
$d_size = $partition.size

Remove-Partition -DriveLetter D -Confirm:$false
Resize-Partition -DriveLetter C -Size ($c_size + $d_size)

Optimize-Volume -DriveLetter C

C:\Sdelete\sdelete.exe /accepteula -z c:
