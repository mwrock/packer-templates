Vagrant.configure(2) do |config|

  # Change to the name of your vagrant box
  config.vm.box = "windows7-ent"

  # This is important as the first boot takes a LONG time.
  config.vm.boot_timeout = 900

  # Run a "provisioner just to prove that things are working
  config.vm.provision "shell", inline: "Write-Host 'Heyyyyy, I did it....'"

  # Show the GUI and use 2GB of RAM
  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = "2048"
  end

end

