$source = "http://download.microsoft.com/download/2/C/6/2C6E1B4A-EBE5-48A6-B225-2D2058A9CEFB/Win8.1AndW2K12R2-KB3134758-x64.msu"
$destination = "c:\windows\temp\KB3134758.msu"

Write-Host "Downloading WMF 5.0 RTM..."
Invoke-WebRequest -Uri $source -OutFile $destination

Write-Host "Installing WMF 5.0 RTM..."
if (Test-Path $destination) {
  Start-Process -FilePath "wusa.exe" -ArgumentList "$destination /quiet /norestart" -Wait
} else {
  Write-Error "Cannot find: $destination" -ErrorAction:Stop
}
