iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/mwrock/boxstarter/master/BuildScripts/bootstrapper.ps1'))
Enable-Net40

$task = "C:\Windows\System32\schtasks.exe"
&$task /Create /TN "setup_boxstarter" /SC ONLOGON /TR "a:\boxstartwin7.bat" /RL HIGHEST

$exe = "C:\Windows\System32\shutdown.exe"
&$exe /t 30 /r
