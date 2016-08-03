cookbook_file "#{ENV['temp']}/oracle.cer" do
  source "oracle.cer"
end

windows_certificate "#{ENV['temp']}/oracle.cer" do
    store_name  "MY"
end

package "virtual box guest additions" do
  source "e:/VBoxWindowsAdditions.exe"
end
