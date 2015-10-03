iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/mwrock/boxstarter/master/BuildScripts/bootstrapper.ps1'))
Enable-Net40

$task = "C:\Windows\System32\schtasks.exe"
&$task /Create /TN "setup_boxstarter" /SC ONLOGON /TR "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File a:\boxstarter.ps1" /RL HIGHEST

$exe = "C:\Windows\System32\shutdown.exe"
&$exe /t 30 /r
