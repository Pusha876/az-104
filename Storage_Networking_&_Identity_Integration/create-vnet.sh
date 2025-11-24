#!/bin/bash

# VNet Creation Script
# Creates VNet-App01 using variables from the variable file

# Load variables from the variable file
source ./variable

echo "=== Creating VNet: $VNET ==="
echo "Subscription: $SUB_ID"
echo "Resource Group: $RG"
echo "VNet Name: $VNET"
echo ""

# Set the subscription context
echo "Setting subscription context..."
az account set --subscription "$SUB_ID"
if [ $? -eq 0 ]; then
    echo "✓ Subscription set successfully"
else
    echo "✗ Failed to set subscription"
    exit 1
fi

# Create the virtual network
echo ""
echo "Creating virtual network '$VNET'..."
az network vnet create \
    --name "$VNET" \
    --resource-group "$RG" \
    --location "East US" \
    --address-prefix "10.100.0.0/16" \
    --subnet-name "$SUBNET_PE" \
    --subnet-prefix "10.100.1.0/24"

if [ $? -eq 0 ]; then
    echo "✓ VNet '$VNET' created successfully"
    echo "✓ Subnet '$SUBNET_PE' created (10.100.1.0/24)"
else
    echo "✗ Failed to create VNet"
    exit 1
fi

# Display VNet information
echo ""
echo "=== VNet Information ==="
az network vnet show \
    --name "$VNET" \
    --resource-group "$RG" \
    --query "{Name:name, Location:location, AddressSpace:addressSpace.addressPrefixes[0]}" \
    --output table

echo ""
echo "=== VNet Creation Complete! ==="