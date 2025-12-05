#!/bin/bash

# VM with Managed Identity and Custom NSG Deployment Script
# This script creates a secure VM with system-assigned managed identity and custom NSG rules

# Load variables from the variable file
source ./variable

echo "=== Azure VM Deployment with Managed Identity & Custom NSG ==="
echo "Subscription: $SUBSCRIPTION_ID"
echo "Resource Group: $RG"
echo "Location: $LOC"
echo "VM Name: $VM"
echo ""

# Set the subscription context
echo "Setting subscription context..."
az account set --subscription "$SUBSCRIPTION_ID"
if [ $? -eq 0 ]; then
    echo "✓ Subscription set successfully"
else
    echo "✗ Failed to set subscription"
    exit 1
fi

# 1) Create resource group
echo ""
echo "Creating resource group..."
az group create --name $RG --location $LOC --subscription $SUBSCRIPTION_ID

if [ $? -eq 0 ]; then
    echo "✓ Resource group '$RG' created successfully"
else
    echo "✗ Failed to create resource group"
    exit 1
fi

# 2) Create vnet + subnet
echo ""
echo "Creating virtual network and subnet..."
az network vnet create -g $RG -n $VNET --address-prefix 10.0.0.0/16 \
  --subnet-name $SUBNET --subnet-prefix 10.0.0.0/24

if [ $? -eq 0 ]; then
    echo "✓ VNet '$VNET' and subnet '$SUBNET' created successfully"
else
    echo "✗ Failed to create VNet and subnet"
    exit 1
fi

# 3) Create NSG
echo ""
echo "Creating Network Security Group..."
az network nsg create -g $RG -n $NSG

if [ $? -eq 0 ]; then
    echo "✓ NSG '$NSG' created successfully"
else
    echo "✗ Failed to create NSG"
    exit 1
fi

# 4) Allow SSH from YOUR IP only (priority 100)
echo ""
echo "Adding SSH allow rule for your IP ($MYIP)..."
az network nsg rule create -g $RG --nsg-name $NSG -n Allow-SSH-From-MyIP \
  --priority 100 --direction Inbound --access Allow --protocol Tcp \
  --source-address-prefixes ${MYIP}/32 --destination-port-ranges 22 --description "Allow SSH from my IP"

if [ $? -eq 0 ]; then
    echo "✓ SSH allow rule created for IP $MYIP"
else
    echo "✗ Failed to create SSH allow rule"
    exit 1
fi

# 5) Explicit deny all inbound (priority 200)
echo ""
echo "Adding explicit deny all inbound rule..."
az network nsg rule create -g $RG --nsg-name $NSG -n Deny-All-Inbound \
  --priority 200 --direction Inbound --access Deny --protocol '*' \
  --source-address-prefixes '*' --destination-port-ranges '*' --description "Deny all inbound"

if [ $? -eq 0 ]; then
    echo "✓ Deny all inbound rule created"
else
    echo "✗ Failed to create deny all rule"
    exit 1
fi

# 6) Associate NSG to subnet
echo ""
echo "Associating NSG to subnet..."
az network vnet subnet update -g $RG --vnet-name $VNET -n $SUBNET --network-security-group $NSG

if [ $? -eq 0 ]; then
    echo "✓ NSG associated to subnet successfully"
else
    echo "✗ Failed to associate NSG to subnet"
    exit 1
fi

# 7) Create Standard static public IP
echo ""
echo "Creating static public IP..."
az network public-ip create -g $RG -n $PIP --sku Standard --allocation-method Static

if [ $? -eq 0 ]; then
    echo "✓ Static public IP '$PIP' created successfully"
else
    echo "✗ Failed to create public IP"
    exit 1
fi

# 8) Create NIC attached to subnet and public IP
echo ""
echo "Creating network interface..."
az network nic create -g $RG -n $NIC --vnet-name $VNET --subnet $SUBNET --public-ip-address $PIP

if [ $? -eq 0 ]; then
    echo "✓ Network interface '$NIC' created successfully"
else
    echo "✗ Failed to create network interface"
    exit 1
fi

# 9) Create VM using SSH key and no inline NSG (we used subnet NSG)
echo ""
echo "Creating virtual machine with SSH key authentication..."
az vm create -g $RG -n $VM --nics $NIC --image UbuntuLTS --admin-username $ADMIN \
  --ssh-key-values @$SSH_PUB_KEY_PATH --size Standard_B1s --subscription $SUBSCRIPTION_ID

if [ $? -eq 0 ]; then
    echo "✓ Virtual machine '$VM' created successfully"
else
    echo "✗ Failed to create virtual machine"
    exit 1
fi

# 10) Assign system-assigned managed identity (if az vm create didn't create it)
echo ""
echo "Assigning system-assigned managed identity..."
az vm identity assign -g $RG -n $VM

if [ $? -eq 0 ]; then
    echo "✓ System-assigned managed identity enabled"
else
    echo "✗ Failed to assign managed identity"
    exit 1
fi

# 11) Show identity and public IP
echo ""
echo "=== Deployment Summary ==="
echo "VM Identity Information:"
az vm show -g $RG -n $VM --query identity -o json

echo ""
echo "VM IP Addresses:"
az vm list-ip-addresses -g $RG -n $VM -o table

echo ""
echo "=== NSG Rules Summary ==="
az network nsg rule list -g $RG --nsg-name $NSG --query "[].{Name:name, Priority:priority, Direction:direction, Access:access, Protocol:protocol, SourceAddressPrefix:sourceAddressPrefix, DestinationPortRange:destinationPortRange}" -o table

echo ""
echo "=== Deployment Complete! ==="
echo "✓ Resource Group: $RG"
echo "✓ Virtual Machine: $VM"
echo "✓ Admin User: $ADMIN"
echo "✓ NSG Rules: SSH from $MYIP only, deny all others"
echo "✓ Managed Identity: System-assigned enabled"
echo ""
echo "🔐 SSH Connection Command:"
PUBLIC_IP=$(az vm list-ip-addresses -g $RG -n $VM --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)
echo "ssh -i $SSH_PRIV_KEY_PATH $ADMIN@$PUBLIC_IP"
echo ""
echo "🧹 Cleanup Command:"
echo "az group delete --name $RG --yes --no-wait"