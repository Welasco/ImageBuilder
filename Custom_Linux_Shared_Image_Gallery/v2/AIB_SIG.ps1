# Variables

sigResourceGroup=AIBSIG
location=westus2
subscriptionID=$(az account show | grep id | tr -d '",' | cut -c7-)
sigName=VWSSIG
imageDefName=CentOS_82_images
runOutputName=cent82SigRo
imageTemplateName=CentOS82ImageTemplatev2

###################################################################################################################
# Step 6 : Create the Image
#############################################################
# submit the image confiuration to the VM Image Builder Service

az resource create \
    --resource-group $sigResourceGroup \
    --properties @helloImageTemplateforSIGv2.json \
    --is-full-object \
    --resource-type Microsoft.VirtualMachineImages/imageTemplates \
    -n $imageTemplateName

# Delete 
az resource Delete \
    --resource-group $sigResourceGroup \
    --resource-type Microsoft.VirtualMachineImages/imageTemplates \
    -n $imageTemplateName 

# Get resource details
az resource show \
    --ids "/subscriptions/$subscriptionId/resourcegroups/$sigResourceGroup/providers/Microsoft.VirtualMachineImages/imageTemplates/$imageTemplateName/runOutputs/$runOutputName"  | grep artifactUri
az resource show \
    --ids "/subscriptions/$subscriptionId/resourcegroups/$sigResourceGroup/providers/Microsoft.VirtualMachineImages/imageTemplates/$imageTemplateName/runOutputs/$runOutputName"
az resource show \
    --ids "/subscriptions/$subscriptionId/resourcegroups/$sigResourceGroup/providers/Microsoft.VirtualMachineImages/imageTemplates/$imageTemplateName"
az resource show --ids /subscriptions/4b4ea128-f1cf-47ab-8468-4e9e2ece06e6/resourceGroups/AIBSIG/providers/Microsoft.VirtualMachineImages/imageTemplates/CentOS82ImageTemplate
# start the image build

az resource invoke-action \
     --resource-group $sigResourceGroup \
     --resource-type  Microsoft.VirtualMachineImages/imageTemplates \
     -n $imageTemplateName \
     --action Run 

# wait minimum of 15mins (this includes replication time to both regions)

###################################################################################################################
# Step 7 : Create the VM
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