#!/bin/bash -e

echo "##############################################################"
echo "################ Script for CentOS 7.8 #######################"
echo "##############################################################"

# add epel repo & update
echo "##############################################################"
echo "###### Installing updating modules ###########################"
echo "##############################################################"
sudo yum update -y

echo "##############################################################"
echo "###### Installing epel-release ###############################"
echo "##############################################################"
sudo yum install -y epel-release

echo "##############################################################"
echo "################### Installing Azure CLI #####################"
echo "##############################################################"
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

echo "##############################################################"
echo "################### Installing singularity ###################"
echo "##############################################################"
#install singularity
sudo yum install -y singularity

#install python3
# sudo yum install python3

echo "##############################################################"
echo "################### Installing R #############################"
echo "##############################################################"
#install R
#sudo dnf install epel-release
#sudo dnf config-manager --set-enabled PowerTools
# sudo yum install -y config-manager
sudo yum install -y R

echo "##############################################################"
echo "################### Installing SAMTools ######################"
echo "##############################################################"
#install SAMTools 
sudo yum install -y samtools

echo "##############################################################"
echo "################### Installing AzCopy ########################"
echo "##############################################################"
# Install AzCopy
wget https://aka.ms/downloadazcopy-v10-linux -O downloadazcopy-v10-linux.tar.gz
mkdir azcopy
tar -xvzf downloadazcopy-v10-linux.tar.gz -C azcopy --strip-components 1
sudo cp azcopy/azcopy /usr/bin/
sudo chmod 755 /usr/bin/azcopy
rm -rf downloadazcopy-v10-linux.tar.gz azcopy/

echo "##############################################################"
echo "################### Installing tmux ##########################"
echo "##############################################################"
#tmux
sudo yum install -y tmux

echo "##############################################################"
echo "################### Installing Java ##########################"
echo "##############################################################"
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

echo "##############################################################"
echo "#################### Installing htop #########################"
echo "##############################################################"
sudo yum install htop -y

echo "##############################################################"
echo "#################### Installing git ##########################"
echo "##############################################################"
sudo yum install git -y

echo "##############################################################"
echo "#################### Installing docker #######################"
echo "##############################################################"
wget -qO- https://get.docker.com/ | sh
# sudo systemctl enable docker
# sudo systemctl start docker
# sudo usermod -aG docker $USER

echo "##############################################################"
echo "#################### Installing Nextflow #####################"
echo "##############################################################"
wget -qO- https://get.nextflow.io | bash
sudo mv nextflow /usr/bin/
sudo chmod 755 /usr/bin/nextflow

echo "##############################################################"
echo "## Installing environment-modules and loading java modules ###"
echo "##############################################################"
# environment-modules
sudo yum install environment-modules -y
# source /etc/profile.d/modules.sh
# *** Needs beter handler for java version
sudo mkdir /etc/modulefiles/java
sudo wget -O /etc/modulefiles/java/8 https://raw.githubusercontent.com/Welasco/ImageBuilder/master/Custom_Linux_Shared_Image_Gallery/v3/8
sudo wget -O /etc/modulefiles/java/11 https://raw.githubusercontent.com/Welasco/ImageBuilder/master/Custom_Linux_Shared_Image_Gallery/v3/11


# module avail
# module load java/11
# module unload java/11

echo "##############################################################"
echo "######################## Updating MOTD #######################"
echo "##############################################################"
# Add preview banner to MOTD
sudo tee -a /etc/motd > /dev/null <<'EOF'
*******************************************************
**            This VM was built for VWS from the:    **
**      !! AZURE VM IMAGE BUILDER Custom Image !!    **
**         You have just been Customized :-)         **
*******************************************************
EOF