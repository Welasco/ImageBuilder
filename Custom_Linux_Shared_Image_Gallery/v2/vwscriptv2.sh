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
# sudo yum install python3

#install R
sudo dnf install epel-release
sudo dnf config-manager --set-enabled PowerTools
sudo yum install -y R

#install SAMTools 
sudo yum install -y samtools

# Install AzCopy
wget https://aka.ms/downloadazcopy-v10-linux
tar -xvf downloadazcopy-v10-linux
sudo cp azcopy_linux_amd64_10.6.0/azcopy /usr/bin/
sudo chmod 755 /usr/bin/azcopy
rm -rf downloadazcopy-v10-linux azcopy_linux_amd64_10.6.0/

#tmux
sudo yum install -y tmux

#java 11
sudo yum install -y java-11-openjdk
sudo yum install -y java-1.8.0-openjdk

# Comments
# /usr/lib/jvm/java-11-openjdk-11.0.8.10-0.el8_2.x86_64/bin/java
# /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.265.b01-0.el8_2.x86_64/bin/java
# which java
# whereis java

# export JAVA_HOME=/opt/jdk1.8.0_20/bin/java
# export JRE_HOME=/opt/jdk1.8.0_20/jre/bin/java
# export PATH=$PATH:$HOME/bin:JAVA_HOME:JRE_HOME

# export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.8.10-0.el8_2.x86_64/bin/java
# export JRE_HOME=/usr/lib/jvm/java-11-openjdk-11.0.8.10-0.el8_2.x86_64/bin/java
# export PATH=$PATH:/usr/lib/jvm/java-11-openjdk-11.0.8.10-0.el8_2.x86_64/bin

# environment-modules
sudo yum install environment-modules -y
# source /etc/profile.d/modules.sh
mkdir /etc/modulefiles/java
wget -O /etc/modulefiles/java/11 https://raw.githubusercontent.com/Welasco/ImageBuilder/master/Custom_Linux_Shared_Image_Gallery/v2/8
wget -O /etc/modulefiles/java/11 https://raw.githubusercontent.com/Welasco/ImageBuilder/master/Custom_Linux_Shared_Image_Gallery/v2/11


# module avail
# module load java/11
# module unload java/11


# Add preview banner to MOTD
sudo tee -a /etc/motd > /dev/null <<'EOF'
*******************************************************
**            This VM was built for VWS from the:    **
**      !! AZURE VM IMAGE BUILDER Custom Image !!    **
**         You have just been Customized :-)         **
*******************************************************
EOF