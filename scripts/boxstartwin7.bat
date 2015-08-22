@ECHO OFF
if exist c:\ProgramData\chocolatey\bin (
    rem no-op indefinitely
) else (
    if exist C:\Windows\System32\WindowsPowerShell\v1.0\pspluginwkr-v3.dll (
        C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File a:\boxstarter.ps1
    ) else (
        C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File a:\powershellv4.ps1
      )
  )
