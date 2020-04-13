# Enable TLS 1.2
# https://devblogs.microsoft.com/nuget/deprecating-tls-1-0-and-1-1-on-nuget-org/
registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' do
  values [{name: 'SchUseStrongCrypto', type: :dword, data: '1'}]
  action :create
end

registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' do
  values [{name: 'SchUseStrongCrypto', type: :dword, data: '1'}]
  action :create
end

powershell_script 'install Nuget package provider' do
  code 'Install-PackageProvider -Name NuGet -Force'
  not_if '(Get-PackageProvider -Name Nuget -ListAvailable -ErrorAction SilentlyContinue) -ne $null'
end

%w{PSWindowsUpdate xNetworking xRemoteDesktopAdmin xCertificate}.each do |ps_module|
  powershell_script "install #{ps_module} module" do
    code "Install-Module #{ps_module} -Force"
    not_if "(Get-Module #{ps_module} -list) -ne $null"
  end
end