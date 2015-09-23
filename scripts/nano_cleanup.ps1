Import-Module C:\windows\system32\windowspowershell\v1.0\Modules\Microsoft.PowerShell.Utility\Microsoft.PowerShell.Utility.psd1
Import-Module C:\windows\system32\windowspowershell\v1.0\Modules\Microsoft.PowerShell.Management\Microsoft.PowerShell.Management.psd1
Import-Module C:\windows\system32\windowspowershell\v1.0\Modules\Storage\Storage.psd1

$partition = Get-Partition -DriveLetter C
$c_size = $partition.size
$partition = Get-Partition -DriveLetter D
$d_size = $partition.size

Remove-Partition -DriveLetter D -Confirm:$false
Resize-Partition -DriveLetter C -Size ($c_size + $d_size)

Optimize-Volume -DriveLetter C

# C:\Sdelete\sdelete.exe /accepteula -z c:

# shutdown /s /t 0