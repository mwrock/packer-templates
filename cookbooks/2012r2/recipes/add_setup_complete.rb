directory "C:/Windows/setup/scripts" do
  recursive true
end

file "restart winmgmt on first boot" do
  content "netsh advfirewall firewall set rule name=\"WinRM-HTTP\" new action=allow"
  path "C:/Windows/setup/scripts/SetupComplete.cmd"
end
