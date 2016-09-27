Import-Module C:\windows\system32\windowspowershell\v1.0\Modules\Microsoft.PowerShell.Utility\Microsoft.PowerShell.Utility.psd1
Import-Module C:\windows\system32\windowspowershell\v1.0\Modules\Microsoft.PowerShell.Management\Microsoft.PowerShell.Management.psd1
Import-Module C:\windows\system32\windowspowershell\v1.0\Modules\Storage\Storage.psd1

$sess = New-CimInstance -Namespace root/Microsoft/Windows/WindowsUpdate -ClassName MSFT_WUOperationsSession
Invoke-CimMethod -InputObject $sess -MethodName ApplyApplicableUpdates

$partition = Get-Partition -DriveLetter C
$c_size = $partition.size
$partition = Get-Partition -DriveLetter D
$d_size = $partition.size

Remove-Partition -DriveLetter D -Confirm:$false
Resize-Partition -DriveLetter C -Size ($c_size + $d_size)

schtasks /create /tn "Postinstall" /tr "powershell -file c:\windows\setup\scripts\nano_cleanup_after_reboot.ps1" /sc onstart /RL highest /ru vagrant /rp vagrant /f
shutdown /r /t 0
