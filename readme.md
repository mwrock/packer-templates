# packer-templates
A packer template that simplifies the creation of windows vagrant boxes.

This repo and much of its cotent is covered in detail from [this blog post](http://www.hurryupandwait.io/blog/creating-windows-base-images-for-virtualbox-and-hyper-v-using-packer-boxstarter-and-vagrant).

## Prerequisites

In order to run the template, you will need the following:
1. [Packer](https://packer.io/docs/installation.html) installed with a minimum version of 0.8.1.
2. [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
3. An ISO file. The template is hardcoded to look for this at `iso/9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO`. New evaluation ISOs of windows 2012R2 can be downloaded from [msdn](https://msdn.microsoft.com/en-us/evalcenter.aspx).

## Invoking the template
You may invoke packer to run the template with:
```
packer build -force .\vbox-2012r2.json
```

## Converting to Hyper-V
This repo includes powershell scripts that can create a Hyper-V vagrant box from the output virtualbox .vmdk file. This repo leverages [psake](https://github.com/psake/psake) and [chocolatey](https://chocolatey.org) to ensure that all prerequisites are installed and then runs the above packer command followed by the scripts needed to produce a vagrant .box file that can create a Hyper-V file.

## Troubleshooting Boxstarter package run
[Boxstarter](http://boxstarter.org) is used as the means of proviioning. Due to the fact that provisioning takes place in the builder and not a provisioner, it can be difficult to gain vivibility into why things go wrong from the same console where poacker is invoked.

Boxstarter will log all package activity output to `$env:LocalAppData\Boxstarter\boxstarter.log` on the guest.