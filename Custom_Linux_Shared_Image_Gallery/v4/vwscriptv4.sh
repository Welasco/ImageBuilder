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
# which java
# whereis java

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
echo "############# Installing environment-modules  ################"
echo "##############################################################"
# environment-modules
sudo yum install environment-modules -y
# source /etc/profile.d/modules.sh
sudo mkdir /etc/modulefiles/java

echo "##############################################################"
echo "############ Creating Java environment-modules  ##############"
echo "##############################################################"
# Creating Java 8 environment-modules
JAVAMODULESFILE8="/etc/modulefiles/java/8"
JAVAVERSION8="Java 8"
JAVA8FOLDER=$(ls -d /usr/lib/jvm/java-1.8.0-openjdk-*)/bin
JAVA8FILE=$(ls -d /usr/lib/jvm/java-1.8.0-openjdk-*)/bin/java

sudo tee -a $JAVAMODULESFILE8 > /dev/null <<'EOF'
#%Module1.0
proc ModulesHelp { } {
global dotversion

puts stderr "\tJAVAVERSION"
}

module-whatis "JAVAVERSION"
prepend-path PATH FOLDERPATH
setenv JAVA_HOME FILEPATH
setenv JRE_HOME FILEPATH
EOF

sudo sed -i "s@JAVAVERSION@$JAVAVERSION8@g" $JAVAMODULESFILE8
sudo sed -i "s@FOLDERPATH@$JAVA8FOLDER@g" $JAVAMODULESFILE8
sudo sed -i "s@FILEPATH@$JAVA8FILE@g" $JAVAMODULESFILE8

# Creating Java 11 environment-modules
JAVAMODULESFILE11="/etc/modulefiles/java/11"
JAVAVERSION11="Java 11"
JAVA11FOLDER=$(ls -d /usr/lib/jvm/java-11-openjdk-11*)/bin
JAVA11FILE=$(ls -d /usr/lib/jvm/java-11-openjdk-11*)/bin/java

sudo tee -a $JAVAMODULESFILE11 > /dev/null <<'EOF'
#%Module1.0
proc ModulesHelp { } {
global dotversion

puts stderr "\tJAVAVERSION"
}

module-whatis "JAVAVERSION"
prepend-path PATH FOLDERPATH
setenv JAVA_HOME FILEPATH
setenv JRE_HOME FILEPATH
EOF

sudo sed -i "s@JAVAVERSION@$JAVAVERSION11@g" $JAVAMODULESFILE11
sudo sed -i "s@FOLDERPATH@$JAVA11FOLDER@g" $JAVAMODULESFILE11
sudo sed -i "s@FILEPATH@$JAVA11FILE@g" $JAVAMODULESFILE11


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