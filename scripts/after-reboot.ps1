$ProgressPreference='SilentlyContinue'
Get-WUInstall -WindowsUpdate -AcceptAll -UpdateType Software -IgnoreReboot

# The sleeps may seem whacky because they are
# Might beable to remove after 2016 RTMs
# For now after much trial and error, this is what works
Write-Host "waiting 5 minutes"
Start-Sleep -Seconds 300
