function Get-HttpToFile ($url, $file){
    Write-Verbose "Downloading $url to $file"
    if(Test-Path $file){Remove-Item $file -Force}
    $downloader=new-object net.webclient
    $wp=[system.net.WebProxy]::GetDefaultProxy()
    $wp.UseDefaultCredentials=$true
    $downloader.Proxy=$wp
    try {
        $downloader.DownloadFile($url, $file)
    }
    catch{
        if($VerbosePreference -eq "Continue"){
            Write-Error $($_.Exception | fl * -Force | Out-String)
        }
        throw $_
    }
}

Write-Host "Deleting cached certificates (eliminating cert update errors related to Microsoft-Windows-CAPI2 / Event ID 4107)"
Remove-Item C:\Windows\System32\config\systemprofile\AppData\LocalLow\Microsoft\CryptnetUrlCache\Content\* -force -recurse
Remove-Item C:\Windows\System32\config\systemprofile\AppData\LocalLow\Microsoft\CryptnetUrlCache\MetaData -force -recurse

Write-Host "Downloading Windows Management Framework 4.0"
Get-HttpToFile "http://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x64-MultiPkg.msu" "$env:temp\Windows6.1-KB2819745-x64-MultiPkg.msu"
Write-Host "Installing Windows Management Framework 4.0"
$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "c:\Windows\system32\wusa.exe"
$pinfo.Verb="runas"
$pinfo.Arguments = "$env:temp\Windows6.1-KB2819745-x64-MultiPkg.msu /quiet /norestart"
$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start() | Out-Null
$p.WaitForExit()
$e = $p.ExitCode
if($e -ne 0){
    Write-Host "Installer exited with $e"
}

$exe = "C:\Windows\System32\shutdown.exe"
&$exe /t 10 /r
