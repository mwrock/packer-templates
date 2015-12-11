$ErrorActionPreference = "Stop"

. a:\Test-Command.ps1

Enable-RemoteDesktop
netsh advfirewall firewall add rule name="Remote Desktop" dir=in localport=3389 protocol=TCP action=allow

Update-ExecutionPolicy -Policy Unrestricted

if (Test-Command -cmdname 'Uninstall-WindowsFeature') {
    Write-BoxstarterMessage "Removing unused features..."
    Remove-WindowsFeature -Name 'Powershell-ISE'
    Get-WindowsFeature |
    ? { $_.InstallState -eq 'Available' } |
    Uninstall-WindowsFeature -Remove
}

Install-WindowsUpdate -AcceptEula

if (($PSVersionTable.PSVersion|Select-Object -ExpandProperty Major) -eq "2") {
  if (!(Test-Path "C:\Users\vagrant\.rebooted")) {
    Add-Content "C:\Users\vagrant\.rebooted" "rebooting before PowerShell upgrade"
    shutdown /r /c "rebooting before PowerShell upgrade" /t 05
    sleep 10
  }

  Write-Host 'Upgrading PowerShell to avoid known issues in v1 and v2'
  choco install -y powershell
  if(Test-PendingReboot) {
    shutdown /r /c "rebooting after PowerShell upgrade" /t 05
    sleep 10
  }
} elseif (Test-Path "C:\Users\vagrant\.rebooted") {
  Remove-Item -Force "C:\Users\vagrant\.rebooted"
  Write-Host "This is Powershell $PSVersionTable.PSVersion"
} else {
  Write-Host "This is Powershell $PSVersionTable.PSVersion"
}

Write-BoxstarterMessage "Removing page file"
$pageFileMemoryKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $pageFileMemoryKey -Name PagingFiles -Value ""

mkdir C:\Windows\Panther\Unattend
copy-item a:\postunattend.xml C:\Windows\Panther\Unattend\unattend.xml

if(Test-PendingReboot){ Invoke-Reboot }

Write-BoxstarterMessage "Setting up winrm"
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow

$enableArgs=@{Force=$true}
try {
 $command=Get-Command Enable-PSRemoting
  if($command.Parameters.Keys -contains "skipnetworkprofilecheck"){
      $enableArgs.skipnetworkprofilecheck=$true
  }
}
catch {
  $global:error.RemoveAt(0)
}
Enable-PSRemoting @enableArgs
Enable-WSManCredSSP -Force -Role Server
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
Write-BoxstarterMessage "winrm setup complete"
