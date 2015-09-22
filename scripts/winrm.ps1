set-item wsman:\localhost\client\auth\Basic -Value $true
set-item wsman:\localhost\service\auth\Basic -Value $true
set-item wsman:\localhost\service\allowunencrypted -Value $true -Force
