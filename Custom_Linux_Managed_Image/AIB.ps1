###################################################################################################################
# registering the provider
##########################
az feature register --namespace Microsoft.VirtualMachineImages --name VirtualMachineTemplatePreview
az feature show --namespace Microsoft.VirtualMachineImages --name VirtualMachineTemplatePreview | grep state
az feature show --namespace Microsoft.KeyVault --name VirtualMachineTemplatePreview | grep state

# wait until it says registered
# check you are registered for the providers

az provider show -n Microsoft.VirtualMachineImages | grep registrationState
az provider show -n Microsoft.Storage | grep registrationState
az provider show -n Microsoft.Compute | grep registrationState
az provider show -n Microsoft.KeyVault | grep registrationState

###################################################################################################################
# set your environment variables here!!!!
#########################################
# destination image resource group
imageResourceGroup=AIB

# location (see possible locations in main docs)
location=WestUS2

# your subscription
# get the current subID : 'az account show | grep id'
subscriptionID=$(az account show | grep id | tr -d '",' | cut -c7-)

# name of the image to be created
imageName=VWSaibCustomLinuxImg01

# image distribution metadata reference name
runOutputName=VWSaibCustLinManImg01ro

# create resource group
az group create -n $imageResourceGroup -l $location
###################################################################################################################
# Create User-assigned managed identity and grant permissions
#############################################################
# create user assigned identity for image builder to access the storage account where the script is located
idenityName=VWSaibBuiUserId
az identity create -g $imageResourceGroup -n $idenityName

#Result:
# 
# $ az identity create -g $imageResourceGroup -n $idenityName
# {
#   "clientId": "a9a7c5cf-21a7-4421-b562-ca254b705c25",
#   "clientSecretUrl": "https://control-westus2.identity.azure.net/subscriptions/4b4ea128-f1cf-47ab-8468-4e9e2ece06e6/resourcegroups/AIB/providers/Microsoft.ManagedIdentity/userAssignedIdentities/VWSaibBuiUserId/credentials?tid=72f988bf-86f1-41af-91ab-2d7cd011db47&oid=eca88ea5-b5b5-4056-80d5-45b35d94dbdd&aid=a9a7c5cf-21a7-4421-b562-ca254b705c25",
#   "id": "/subscriptions/4b4ea128-f1cf-47ab-8468-4e9e2ece06e6/resourcegroups/AIB/providers/Microsoft.ManagedIdentity/userAssignedIdentities/VWSaibBuiUserId",
#   "location": "westus2",
#   "name": "VWSaibBuiUserId",
#   "principalId": "eca88ea5-b5b5-4056-80d5-45b35d94dbdd",
#   "resourceGroup": "AIB",
#   "tags": {},
#   "tenantId": "72f988bf-86f1-41af-91ab-2d7cd011db47",
#   "type": "Microsoft.ManagedIdentity/userAssignedIdentities"
# }

# get identity id
imgBuilderCliId=$(az identity show -g $imageResourceGroup -n $idenityName | grep "clientId" | cut -c16- | tr -d '",')

# get the user identity URI, needed for the template
imgBuilderId=/subscriptions/$subscriptionID/resourcegroups/$imageResourceGroup/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$idenityName

# download preconfigured role definition example
curl https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/solutions/12_Creating_AIB_Security_Roles/aibRoleImageCreation.json -o aibRoleImageCreation.json

imageRoleDefName="VWS - Azure Image Builder Image Def"

# update the definition
sed -i -e "s/<subscriptionID>/$subscriptionID/g" aibRoleImageCreation.json
sed -i -e "s/<rgName>/$imageResourceGroup/g" aibRoleImageCreation.json
sed -i -e "s/Azure Image Builder Service Image Creation Role/$imageRoleDefName/g" aibRoleImageCreation.json

# create role definitions
az role definition create --role-definition ./aibRoleImageCreation.json

# grant role definition to the user assigned identity
az role assignment create \
    --assignee $imgBuilderCliId \
    --role $imageRoleDefName \
    --scope /subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup

###################################################################################################################
# Step 2 : Modify HelloImage Example
#############################################################
# download the example and configure it with your vars

curl https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/quickquickstarts/0_Creating_a_Custom_Linux_Managed_Image/helloImageTemplateLinux.json -o helloImageTemplateLinux.json

sed -i -e "s/<subscriptionID>/$subscriptionID/g" helloImageTemplateLinux.json
sed -i -e "s/<rgName>/$imageResourceGroup/g" helloImageTemplateLinux.json
sed -i -e "s/<region>/$location/g" helloImageTemplateLinux.json
sed -i -e "s/<imageName>/$imageName/g" helloImageTemplateLinux.json
sed -i -e "s/<runOutputName>/$runOutputName/g" helloImageTemplateLinux.json

sed -i -e "s%<imgBuilderId>%$imgBuilderId%g" helloImageTemplateLinux.json

###################################################################################################################
# Step 3 : Create the Image
#############################################################
# submit the image confiuration to the VM Image Builder Service

az resource create \
    --resource-group $imageResourceGroup \
    --properties @helloImageTemplateLinux.json \
    --is-full-object \
    --resource-type Microsoft.VirtualMachineImages/imageTemplates \
    -n VWShelloImageTemplateLinux01

# Result:
# NORTHAMERICA+vsantana@VSantana-PC MINGW64 ~/Desktop/temp/ImageBuilder
# $ az resource create \
# >     --resource-group $imageResourceGroup \
# >     --properties @helloImageTemplateLinux.json \
# >     --is-full-object \
# >     --resource-type Microsoft.VirtualMachineImages/imageTemplates \
# >     -n VWShelloImageTemplateLinux01
# {
#   "id": "/subscriptions/4b4ea128-f1cf-47ab-8468-4e9e2ece06e6/resourcegroups/AIB/providers/Microsoft.VirtualMachineImages/imageTemplates/VWShelloImageTemplateLinux01",
#   "identity": {
#     "principalId": null,
#     "tenantId": null,
#     "type": "UserAssigned",
#     "userAssignedIdentities": {
#       "/subscriptions/4b4ea128-f1cf-47ab-8468-4e9e2ece06e6/resourcegroups/AIB/providers/Microsoft.ManagedIdentity/userAssignedIdentities/VWSaibBuiUserId": {
#         "clientId": "a9a7c5cf-21a7-4421-b562-ca254b705c25",
#         "principalId": "eca88ea5-b5b5-4056-80d5-45b35d94dbdd"
#       }
#     }
#   },
#   "kind": null,
#   "location": "westus2",
#   "managedBy": null,
#   "name": "VWShelloImageTemplateLinux01",
#   "plan": null,
#   "properties": {
#     "buildTimeoutInMinutes": 80,
#     "customize": [
#       {
#         "name": "RunScriptFromSource",
#         "scriptUri": "https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/quickquickstarts/customizeScript.sh",
#         "sha256Checksum": "2c6ff6902a4a52deee69e8db26d0036a53388651008aaf31795bb20dabd21fd8",
#         "type": "Shell"
#       },
#       {
#         "name": "CheckSumCompareShellScript",
#         "scriptUri": "https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/quickquickstarts/customizeScript2.sh",
#         "sha256Checksum": "ade4c5214c3c675e92c66e2d067a870c5b81b9844b3de3cc72c49ff36425fc93",
#         "type": "Shell"
#       },
#       {
#         "destination": "/tmp/index.html",
#         "name": "downloadBuildArtifacts",
#         "sha256Checksum": "d9715d72889fb1a0463d06ce9e89d1d2bd33b2c5e5362a736db6f5a25e601a58",
#         "sourceUri": "https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/quickquickstarts/exampleArtifacts/buildArtifacts/index.html",
#         "type": "File"
#       },
#       {
#         "inline": [
#           "sudo mkdir /buildArtifacts",
#           "sudo cp /tmp/index.html /buildArtifacts/index.html"
#         ],
#         "name": "setupBuildPath",
#         "type": "Shell"
#       },
#       {
#         "inline": [
#           "sudo apt install unattended-upgrades"
#         ],
#         "name": "InstallUpgrades",
#         "type": "Shell"
#       }
#     ],
#     "distribute": [
#       {
#         "artifactTags": {
#           "baseosimg": "ubuntu1804",
#           "source": "azVmImageBuilder"
#         },
#         "imageId": "/subscriptions/4b4ea128-f1cf-47ab-8468-4e9e2ece06e6/resourceGroups/AIB/providers/Microsoft.Compute/images/VWSaibCustomLinuxImg01",
#         "location": "WestUS2",
#         "runOutputName": "VWSaibCustLinManImg01ro",
#         "type": "ManagedImage"
#       }
#     ],
#     "provisioningState": "Succeeded",
#     "source": {
#       "offer": "UbuntuServer",
#       "publisher": "Canonical",
#       "sku": "18.04-LTS",
#       "type": "PlatformImage",
#       "version": "latest (18.04.202009220)"
#     },
#     "vmProfile": {
#       "osDiskSizeGB": 30,
#       "vmSize": "Standard_D1_v2"
#     }
#   },
#   "resourceGroup": "AIB",
#   "sku": null,
#   "tags": {
#     "imagebuilderTemplate": "ubuntu1804",
#     "userIdentity": "enabled"
#   },
#   "type": "Microsoft.VirtualMachineImages/imageTemplates"
# }
# 
# NORTHAMERICA+vsantana@VSantana-PC MINGW64 ~/Desktop/temp/ImageBuilder

# wait approx 1-3mins, depending on external links

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
  --resource-group $imageResourceGroup \
  --name aibImgVm0001 \
  --admin-username aibuser \
  --image $imageName \
  --location $location \
  --generate-ssh-keys

# and login...

# ssh aibuser@<pubIp>
# 
# You should see the image was customized with a Message of the Day as soon as your SSH connection is established!
# 
# *******************************************************
# **            This VM was built from the:            **
# ...

###################################################################################################################
# Step 5 : Clean up
#############################################################

az resource delete \
    --resource-group $imageResourceGroup \
    --resource-type Microsoft.VirtualMachineImages/imageTemplates \
    -n helloImageTemplateLinux01

# delete permissions asssignments, roles and identity
az role assignment delete \
    --assignee $imgBuilderCliId \
    --role "$imageRoleDefName" \
    --scope /subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup

az role definition delete --name "$imageRoleDefName"

az identity delete --ids $imgBuilderId


az group delete -n $imageResourceGroup