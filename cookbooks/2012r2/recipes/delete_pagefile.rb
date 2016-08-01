powershell_script 'delete pagefile' do
  code <<-EOH
    $pageFileMemoryKey = "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management"
    Set-ItemProperty -Path $pageFileMemoryKey -Name PagingFiles -Value ""
  EOH
end
