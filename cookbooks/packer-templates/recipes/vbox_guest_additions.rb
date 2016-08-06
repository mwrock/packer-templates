cookbook_file "#{ENV['temp']}/oracle.cer" do
  source "oracle.cer"
end

dsc_resource "Install Oracle Cert" do
  resource :xCertificateImport
  property :Thumbprint, "7e92b66be51b79d8ce3ff25c15c2df6ab8c7f2f2"
  property :Store, "TrustedPublisher"
  property :Location, "LocalMachine"
  property :Path, "#{ENV['temp']}/oracle.cer"
end

package "virtual box guest additions" do
  source "e:/VBoxWindowsAdditions.exe"
  installer_type :custom
  options "/S"
end
