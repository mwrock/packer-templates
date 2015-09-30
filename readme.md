# packer-templates
A packer template that simplifies the creation of minimally sized windows vagrant boxes.

This repo and much of its cotent is covered in detail from [this blog post](http://www.hurryupandwait.io/blog/creating-windows-base-images-for-virtualbox-and-hyper-v-using-packer-boxstarter-and-vagrant). Also see [this post](http://www.hurryupandwait.io/blog/a-packer-template-for-windows-nano-server-weighing-300mb) specifically for the nano template.

## Prerequisites

In order to run the template, you will need the following:
1. [Packer](https://packer.io/docs/installation.html) installed with a minimum version of 0.8.6.
2. [Virtualbox](https://www.virtualbox.org/wiki/Downloads)

## Invoking the template
You may invoke packer to run the template with:
```
packer build -force -only virtualbox-iso .\vbox-2012r2.json
```

## Converting to Hyper-V
This repo includes powershell scripts that can create a Hyper-V vagrant box from the output virtualbox .vmdk file. This repo leverages [psake](https://github.com/psake/psake) and [chocolatey](https://chocolatey.org) to ensure that all prerequisites are installed and then runs the above packer command followed by the scripts needed to produce a vagrant .box file that can create a Hyper-V file.

See [this blog post](http://www.hurryupandwait.io/blog/creating-a-hyper-v-vagrant-box-from-a-virtualbox-vmdk-or-vdi-image) for more detail on converting virtualbox disks to Hyper-V.

## Troubleshooting Boxstarter package run
[Boxstarter](http://boxstarter.org) is used as the means of provisioning except on nano. Due to the fact that provisioning takes place in the builder and not a provisioner, it can be difficult to gain visibility into why things go wrong from the same console where packer is invoked.

Boxstarter will log all package activity output to `$env:LocalAppData\Boxstarter\boxstarter.log` on the guest.
