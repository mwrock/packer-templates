$OS = Get-WmiObject -Class win32_OperatingSystem -namespace "root\CIMV2"

function Check-Command($cmdname)
{
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

Enable-RemoteDesktop
if (Check-Command -cmdname 'Set-NetFirewallRule') {
    Set-NetFirewallRule -Name RemoteDesktop-UserMode-In-TCP -Enabled True
    } else {
    C:\Windows\System32\netsh.exe advfirewall firewall add rule name="Remote Desktop" dir=in localport=3389 protocol=TCP action=allow
}

Write-BoxstarterMessage "Removing page file"
$pageFileMemoryKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $pageFileMemoryKey -Name PagingFiles -Value ""

Update-ExecutionPolicy -Policy Unrestricted

if (Check-Command -cmdname 'Uninstall-WindowsFeature') {
    Write-BoxstarterMessage "Removing unused features..."
    Remove-WindowsFeature -Name 'Powershell-ISE'
    Get-WindowsFeature | 
    ? { $_.InstallState -eq 'Available' } | 
    Uninstall-WindowsFeature -Remove
}


Install-WindowsUpdate -AcceptEula
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
if (Check-Command -cmdname 'Optimize-Volume') {
    Optimize-Volume -DriveLetter C
    } else {
    Defrag.exe c: /H
}


Write-BoxstarterMessage "0ing out empty space..."
if (Check-Command -cmdname 'wget') {
    wget http://download.sysinternals.com/files/SDelete.zip -OutFile sdelete.zip
    [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
    [System.IO.Compression.ZipFile]::ExtractToDirectory("sdelete.zip", ".")
    ./sdelete.exe /accepteula -z c:
    } else {
    $url = "http://download.sysinternals.com/files/SDelete.zip"
    $file = "$env:temp\sdelete.zip"
    if(Test-Path $file){Remove-Item $file -Force}
    $downloader=new-object net.webclient
    $wp=[system.net.WebProxy]::GetDefaultProxy()
    $wp.UseDefaultCredentials=$true
    $downloader.Proxy=$wp
    $downloader.DownloadFile($url, $file)
    $shell = new-object -com shell.application
    $zip = $shell.NameSpace($file)
    foreach($item in $zip.items())
    {
    $shell.Namespace("$env:temp").copyhere($item)
    }
    $sdelcommand = "$env:temp\sdelete.exe /accepteula -z c:"
    iex "& $sdelcommand"
}

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
if (Check-Command -cmdname 'Set-NetFirewallRule') {
    Set-NetFirewallRule -Name WINRM-HTTP-In-TCP-PUBLIC -RemoteAddress Any
    } else {
    C:\Windows\System32\netsh.exe advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow
}

if ($OS.Version -eq "6.1.7601") {
    if (Test-Path "C:\Windows\System32\WindowsPowerShell\v1.0\pspluginwkr-v3.dll"){
        Enable-PSRemoting -Force -SkipNetworkProfileCheck
        } else {
        Enable-PSRemoting -Force
        }
    Enable-WSManCredSSP -Force -Role Server
    } else {
    Enable-WSManCredSSP -Force -Role Server

    Enable-PSRemoting -Force -SkipNetworkProfileCheck
}
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
