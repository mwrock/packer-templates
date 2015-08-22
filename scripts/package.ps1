$OS = Get-WmiObject -Class win32_OperatingSystem -namespace "root\CIMV2"

Enable-RemoteDesktop
if ($OS.Version -eq "6.1.7601") {
    C:\Windows\System32\netsh.exe advfirewall firewall add rule name="Remote Desktop" dir=in localport=3389 protocol=TCP action=allow
    } else {
    Set-NetFirewallRule -Name RemoteDesktop-UserMode-In-TCP -Enabled True
}

Write-BoxstarterMessage "Removing page file"
$pageFileMemoryKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $pageFileMemoryKey -Name PagingFiles -Value ""

Update-ExecutionPolicy -Policy Unrestricted

# cmdlet not available in win 7
if ($OS.Version -ne "6.1.7601") {
    Write-BoxstarterMessage "Removing unused features..."
    Remove-WindowsFeature -Name 'Powershell-ISE'
    Get-WindowsFeature | 
    ? { $_.InstallState -eq 'Available' } | 
    Uninstall-WindowsFeature -Remove
}

if ($OS.Version -eq "6.1.7601") {
    # Skipping updates specific to Win10 upgrade & telemetry noted at:
    # https://github.com/bmrf/tron/blob/d7c8e00a4300bcffa6095aa9361850f7430fd3d2/tron.bat#L1301-L1326
    # (KB971033/KB2952664/KB3021917/KB3068708/KB3075249/KB3080149)
    # This should prevent the 3+GiB KB3035583 from being downloaded
    Install-WindowsUpdate -criteria "IsHidden=0 and IsInstalled=0 and Type='Software' and BrowseOnly=0 and UpdateID!='62c68477-0f45-46aa-8af8-d0c189d6dd8e' and UpdateID!='761d6bfd-33b5-4988-9d0c-417f0284168f' and UpdateID!='89febea4-e23a-4ff5-9ca9-d4fc9e768a70' and UpdateID!='0cd9efd9-d371-4e7d-8381-15ae5b55ea79' and UpdateID!='6cc5cc49-03a2-4609-882e-7889c547814e' and UpdateID!='48aa5065-93fc-4cc8-b071-80cb1da35f7b'" -AcceptEula
    } else {
    Install-WindowsUpdate -AcceptEula
}
if(Test-PendingReboot){ Invoke-Reboot }

Write-BoxstarterMessage "Cleaning SxS..."
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

@(
    "$env:localappdata\Nuget",
    "$env:localappdata\temp\*",
    "$env:windir\logs",
    "$env:windir\panther",
    "$env:windir\temp\*",
    "$env:windir\winsxs\manifestcache"
) | % {
        if(Test-Path $_) {
            Write-BoxstarterMessage "Removing $_"
            Takeown /d Y /R /f $_
            Icacls $_ /GRANT:r administrators:F /T /c /q  2>&1 | Out-Null
            Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
        }
    }

Write-BoxstarterMessage "defragging..."
if ($OS.Version -eq "6.1.7601") {
    Defrag.exe c: /H
    } else {
    Optimize-Volume -DriveLetter C
}


Write-BoxstarterMessage "0ing out empty space..."
wget http://download.sysinternals.com/files/SDelete.zip -OutFile sdelete.zip
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
[System.IO.Compression.ZipFile]::ExtractToDirectory("sdelete.zip", ".") 
./sdelete.exe /accepteula -z c:

mkdir C:\Windows\Panther\Unattend
if ($OS.Version -eq "6.1.7601") {
    copy-item a:\postunattendwin7.xml C:\Windows\Panther\Unattend\unattend.xml
    } else {
    copy-item a:\postunattend.xml C:\Windows\Panther\Unattend\unattend.xml
}

Write-BoxstarterMessage "Recreate pagefile after sysprep"
$System = GWMI Win32_ComputerSystem -EnableAllPrivileges
$System.AutomaticManagedPagefile = $true
$System.Put()

Write-BoxstarterMessage "Setting up winrm"
if ($OS.Version -eq "6.1.7601") {
    C:\Windows\System32\netsh.exe advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow
    } else {
    Set-NetFirewallRule -Name WINRM-HTTP-In-TCP-PUBLIC -RemoteAddress Any
}

if ($OS.Version -eq "6.1.7601") {
    Enable-PSRemoting -Force -SkipNetworkProfileCheck
    Enable-WSManCredSSP -Force -Role Server
    } else {
    Enable-WSManCredSSP -Force -Role Server

    Enable-PSRemoting -Force -SkipNetworkProfileCheck
}
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
