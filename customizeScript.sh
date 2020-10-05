#!/bin/bash -e
# add epel repo & update
sudo yum install -y epel-release && sudo yum update -y
# Add repo key for az cli
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

# Add az cli repo for yum
sudo sh -c 'echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'

# install az cli
sudo yum install -y azure-cli

#install singularity
sudo yum install -y singularity

#install python3
sudo yum install python3

#install R
sudo yum install -y R

#install SAMTools 
sudo yum install -y samtools

#download azcopy v7 & v10, use v7 installer script to install v10 & add to path
wget -O azcopy_v7.tar.gz https://aka.ms/downloadazcopylinux64
mkdir azcopy_v7
tar -xf azcopy_v7.tar.gz -C azcopy_v7
wget -O azcopy_v10.tar.gz https://aka.ms/downloadazcopy-v10-linux
mkdir azcopy_v10
tar -xf azcopy_v10.tar.gz -C azcopy_v10
# this step may fail with updates, the _amd64_10.x.x version path will change
mv azcopy_v10/azcopy_linux_amd64_10.6.0 azcopy_v10/azcopy
cp azcopy_v7/install.sh azcopy_v10/install.sh
cp azcopy_v7/azcopy/azcopy_autocomplete azcopy_v10/azcopy/
cp azcopy_v7/azcopy/startup azcopy_v10/azcopy/
sudo ./azcopy_v10/install.sh
#tmux
sudo yum install -y tmux
#java 11
sudo yum install -y java-11-openjdk

# Add preview banner to MOTD
cat >> /etc/motd << EOF
*******************************************************
**            This VM was built from the:            **
**      !! AZURE VM IMAGE BUILDER Custom Image !!    **
**         You have just been Customized :-)         **
*******************************************************
EOF