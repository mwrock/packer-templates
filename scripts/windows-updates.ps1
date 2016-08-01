$ProgressPreference='SilentlyContinue'

Get-WUInstall -WindowsUpdate -AcceptAll -UpdateType Software -IgnoreReboot
