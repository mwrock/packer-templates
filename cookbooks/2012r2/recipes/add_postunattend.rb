directory 'Remove old panther directory' do
  path 'C:\Windows\Panther'
  recursive true
  action :delete
end

directory 'create unattend directory' do
  path 'C:\Windows\Panther\Unattend'
  recursive true
end

template 'C:/Windows/Panther/Unattend/unattend.xml' do
  source 'postunattend.xml.erb'
end
