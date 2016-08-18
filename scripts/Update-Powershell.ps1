<# 
.SYNOPSIS 
    Installs Windows Management Framework (Includes Powershell 4.0)
.DESCRIPTION 
    Installs NET Framework 4.5 dependency
    Installs Windows Management Framework 4.0
    Seed file to run boxstarter.ps1 after restart
    Restart system from pending install of WMF 4.0
.NOTES 
    Author     : Derek Groh - derekgroh@gmail.com
#> 
$ErrorActionPreference = "Stop"

Function Download-File-NET($file, $destination)
{
    $file = "https://download.microsoft.com/download/E/2/1/E21644B5-2DF2-47C2-91BD-63C560427900/NDP452-KB2901907-x86-x64-AllOS-ENU.exe"
    $destination = "C:\windows\temp\NDP452-KB2901907-x86-x64-AllOS-ENU.exe"
    $Username = ""
    $Password = ""

    $WebClient = New-Object System.Net.WebClient
    $WebClient.Credentials = New-Object System.Net.Networkcredential($Username, $Password)
    $WebClient.DownloadFile( $file, $destination )
}

Function Download-File-WMF($file, $destination)
{
    $file = "https://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x64-MultiPkg.msu"
    $destination = "C:\windows\temp\Windows6.1-KB2819745-x64-MultiPkg.msu"
    $Username = ""
    $Password = ""

    $WebClient = New-Object System.Net.WebClient
    $WebClient.Credentials = New-Object System.Net.Networkcredential($Username, $Password)
    $WebClient.DownloadFile( $file, $destination )
}
Download-File-NET
Download-File-WMF
(Start-Process -FilePath 'C:\windows\temp\NDP452-KB2901907-x86-x64-AllOS-ENU.exe' -ArgumentList "/quiet" -Wait -Passthru).ExitCode
(Start-Process -FilePath 'C:\windows\temp\Windows6.1-KB2819745-x64-MultiPkg.msu' -ArgumentList "/quiet /norestart" -Wait -Passthru).ExitCode
New-Item -Path 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup' -name 'boxstarter.cmd' -type 'file' -value 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File a:\boxstarter.ps1 && DEL "%~f0"' 
Shutdown /r /t 0 