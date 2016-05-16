#!/bin/bash

# Build script for Fedora 23:
# 1. Renamed packer to packer.io to avoid clashes with a different packer
#    executable
# 2. Set TMPDIR because otherwise packer creates huge temporary files
#    in /tmp which in Fedora is tmpfs (backed by RAM and limited in
#    size)

# Prerequisites:
# 1. Install packer, create a symlink named packer.io to the packer
#    executable
# 2. Install the Windows virtio drivers - dnf install virtio-win

# To use with Vagrant:
# 1. Install vagrant, vagrant-libvirt packages
# 2. Install vagrant plugins winrm, winrm-fs, vagrant-winrm-syncedfolders

templ_file=$1
if [[ -z $templ_file ]] ; then
    templ_file=qemu-2012r2.json
fi

TMPDIR=$HOME/tmp packer.io build $templ_file

