if (Test-Path 'C:\Users\vagrant\.vbox_version') {
    Write-Host "Installing Virtualbox Guest Additions" -ForegroundColor green

    # Get current version of Virtualbox
    $vboxVersion = (Get-Content "C:\Users\vagrant\.vbox_version" | Out-String).Trim()
    $url = "http://download.virtualbox.org/virtualbox/$($vboxVersion)/VBoxGuestAdditions_$($vboxVersion).iso"
    $isoPath = "C:\Users\vagrant\VBoxGuestAdditions_$($vboxVersion).iso"

    # Download Guest Additions ISO
    (New-Object System.Net.WebClient).DownloadFile("$($url)","$($isoPath)")

    # Install Virtual CloneDrive and mount the ISO
    choco install -y virtualclonedrive
    $vcdmount = 'C:\Program Files (x86)\Elaborate Bytes\VirtualCloneDrive\VCDMount.exe'
    Start-Process -FilePath "$($vcdmount)" -ArgumentList "$($isoPath)" -Wait

    # Determine where the ISO got mounted
    $cdrom = [System.IO.DriveInfo]::GetDrives() | ? {$_.VolumeLabel -like "VBOX*" } | select -ExpandProperty Name

    # Install the Guest Additions
    Start-Process -FilePath ".\VBoxCertUtil.exe" -ArgumentList "add-trusted-publisher oracle-vbox.cer --root oracle-vbox.cer" -WorkingDirectory "$($cdrom)cert" -Wait
    Write-Host "Installing VBoxGuestAdditions $($vboxVersion)" -ForegroundColor green
    Start-Process -FilePath "$($cdrom)VBoxWindowsAdditions.exe" -ArgumentList "/S" -Wait

    # Unmount and delete the ISO
    Start-Process -FilePath "$($vcdmount)" -ArgumentList "/u" -Wait
    Remove-Item -Force "$($isoPath)"

    Write-Host "Finished installing Virtualbox Guest Additions" -ForegroundColor green
} else {
    Write-Host "Unable to install Virtualbox Guest Additions" -ForegroundColor  red
    ls C:\Users\vagrant\
    sleep 30
}
