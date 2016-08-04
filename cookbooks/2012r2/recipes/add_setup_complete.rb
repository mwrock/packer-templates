directory "C:/Windows/setup/scripts" do
  recursive true
end

file "restart winmgmt on first boot" do
  content "wmic path Win32_OperatingSystem get version"
  path "C:/Windows/setup/scripts/SetupComplete.cmd"
end
