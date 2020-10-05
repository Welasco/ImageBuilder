###################################################################################################################
# Step 1 : Enable Prereqs
# registering the provider
##########################
az feature register --namespace Microsoft.VirtualMachineImages --name VirtualMachineTemplatePreview
az feature show --namespace Microsoft.VirtualMachineImages --name VirtualMachineTemplatePreview | grep state
az feature show --namespace Microsoft.KeyVault --name VirtualMachineTemplatePreview | grep state

# register and enable for shared image gallery
az feature register --namespace Microsoft.Compute --name GalleryPreview

# wait until it says registered
# check you are registered for the providers

az provider show -n Microsoft.VirtualMachineImages | grep registrationState
az provider show -n Microsoft.Storage | grep registrationState
az provider show -n Microsoft.Compute | grep registrationState
az provider show -n Microsoft.KeyVault | grep registrationState
az provider show -n Microsoft.Compute | grep registrationState

###################################################################################################################
# Step 2 : Set Permissions & Create Shared Image Gallery (SIG)
#
# set your environment variables here!!!!
#########################################
# Create SIG  resource group
sigResourceGroup=AIBSIG

# location of SIG (see possible locations in main docs)
location=westus2

# additional region to replication image to
# additionalregion=eastus

# your subscription
# get the current subID : 'az account show | grep id'

subscriptionID=$(az account show | grep id | tr -d '",' | cut -c7-)

# name of the shared image gallery, e.g. myCorpGallery
sigName=VWSSIG

# name of the image definition to be created, e.g. ProdImages
imageDefName=CentOS_82_images

# image distribution metadata reference name
runOutputName=cent82SigRo

# create resource group
az group create -n $sigResourceGroup -l $location

###################################################################################################################
# Step 3: Create a user identify and assign permissions for the resource group where the image will be created
# Create User-assigned managed identity and grant permissions
#############################################################
# create user assigned identity for image builder to access the storage account where the script is located
idenityName=VWSAIBSIGBuiUserId
az identity create -g $sigResourceGroup -n $idenityName

# get identity id
imgBuilderCliId=$(az identity show -g $sigResourceGroup -n $idenityName | grep "clientId" | cut -c16- | tr -d '",')

# get the user identity URI, needed for the template
imgBuilderId=/subscriptions/$subscriptionID/resourcegroups/$sigResourceGroup/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$idenityName

# download preconfigured role definition example
curl https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/solutions/12_Creating_AIB_Security_Roles/aibRoleImageCreation.json -o aibRoleImageCreation.json

imageRoleDefName="Azure Image Builder Image Def"

# update the definition
sed -i -e "s/<subscriptionID>/$subscriptionID/g" aibRoleImageCreation.json
sed -i -e "s/<rgName>/$sigResourceGroup/g" aibRoleImageCreation.json
sed -i -e "s/Azure Image Builder Service Image Creation Role/$imageRoleDefName/g" aibRoleImageCreation.json

# create role definitions
az role definition create --role-definition ./aibRoleImageCreation.json

# grant role definition to the user assigned identity
az role assignment create \
    --assignee $imgBuilderCliId \
    --role $imageRoleDefName \
    --scope /subscriptions/$subscriptionID/resourceGroups/$sigResourceGroup

###################################################################################################################
# Step 4: Create Shared Image Gallery
#############################################################
# create SIG
az sig create \
    -g $sigResourceGroup \
    --gallery-name $sigName

# create SIG image definition

az sig image-definition create \
   -g $sigResourceGroup \
   --gallery-name $sigName \
   --gallery-image-definition $imageDefName \
   --publisher VWS \
   --offer cent82 \
   --sku 8.2-latest \
   --os-type Linux

###################################################################################################################
# Step 5: Modify HelloImage Example
#############################################################
# download the example and configure it with your vars

curl https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/quickquickstarts/1_Creating_a_Custom_Linux_Shared_Image_Gallery_Image/helloImageTemplateforSIG.json -o helloImageTemplateforSIG.json

sed -i -e "s/<subscriptionID>/$subscriptionID/g" helloImageTemplateforSIG.json
sed -i -e "s/<rgName>/$sigResourceGroup/g" helloImageTemplateforSIG.json
sed -i -e "s/<imageDefName>/$imageDefName/g" helloImageTemplateforSIG.json
sed -i -e "s/<sharedImageGalName>/$sigName/g" helloImageTemplateforSIG.json

sed -i -e "s/<region1>/$location/g" helloImageTemplateforSIG.json
# sed -i -e "s/<region2>/$additionalregion/g" helloImageTemplateforSIG.json
sed -i -e "s/<runOutputName>/$runOutputName/g" helloImageTemplateforSIG.json

sed -i -e "s%<imgBuilderId>%$imgBuilderId%g" helloImageTemplateforSIG.json

# *** Don't forget to change the json for your desired image:
# "source": {
#     "type": "PlatformImage",
#         "publisher": "OpenLogic",
#         "offer": "CentOS",
#         "sku": "8_2",
#         "version": "latest"
# },

###################################################################################################################
# Step 4 : Create the Image
#############################################################
# submit the image confiuration to the VM Image Builder Service

az resource create \
    --resource-group $sigResourceGroup \
    --properties @helloImageTemplateforSIG.json \
    --is-full-object \
    --resource-type Microsoft.VirtualMachineImages/imageTemplates \
    -n helloImageTemplateforSIG01

# start the image build

az resource invoke-action \
     --resource-group $sigResourceGroup \
     --resource-type  Microsoft.VirtualMachineImages/imageTemplates \
     -n helloImageTemplateforSIG01 \
     --action Run 

# wait minimum of 15mins (this includes replication time to both regions)

# start the image build

az resource invoke-action \
     --resource-group $imageResourceGroup \
     --resource-type  Microsoft.VirtualMachineImages/imageTemplates \
     -n VWShelloImageTemplateLinux01 \
     --action Run 

# wait approx 15mins

###################################################################################################################
# Step 4 : Create the VM
#############################################################
# download the example and configure it with your vars

az vm create \
  --resource-group $sigResourceGroup \
  --name VWSaibImgVm01 \
  --admin-username azureuser \
  --location $location \
  --image "/subscriptions/$subscriptionID/resourceGroups/$sigResourceGroup/providers/Microsoft.Compute/galleries/$sigName/images/$imageDefName/versions/latest" \
  --generate-ssh-keys

# and login...

# ssh aibuser@<pubIp>

# You should see the image was customized with a Message of the Day as soon as your SSH connection is established!

# *******************************************************
# **            This VM was built from the:            **
# ...

###################################################################################################################
# Step 5 : Clean up
#############################################################

# BEWARE : This is DELETING the Image created for you, be sure this is what you want!!!

# delete permissions asssignments, roles and identity
az role assignment delete \
    --assignee $imgBuilderCliId \
    --role "$imageRoleDefName" \
    --scope /subscriptions/$subscriptionID/resourceGroups/$sigResourceGroup

az role definition delete --name "$imageRoleDefName"

az identity delete --ids $imgBuilderId
# delete AIB Template
az resource delete \
    --resource-group $sigResourceGroup \
    --resource-type Microsoft.VirtualMachineImages/imageTemplates \
    -n helloImageTemplateforSIG01

# get image version created by AIB, this always starts with 0.*
sigDefImgVersion=$(az sig image-version list \
   -g $sigResourceGroup \
   --gallery-name $sigName \
   --gallery-image-definition $imageDefName \
   --subscription $subscriptionID --query [].'name' -o json | grep 0. | tr -d '"')

# delete image version
az sig image-version delete \
   -g $sigResourceGroup \
   --gallery-image-version $sigDefImgVersion \
   --gallery-name $sigName \
   --gallery-image-definition $imageDefName \
   --subscription $subscriptionID

# delete image definition
az sig image-definition delete \
   -g $sigResourceGroup \
   --gallery-name $sigName \
   --gallery-image-definition $imageDefName \
   --subscription $subscriptionID

# delete SIG
az sig delete -r $sigName -g $sigResourceGroup

# delete RG
az group delete -n $sigResourceGroup -y