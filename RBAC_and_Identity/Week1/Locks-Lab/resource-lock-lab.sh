#!/bin/bash

# Azure Resource Lock Lab - Basic Version
# This script demonstrates basic resource lock functionality

# Variables (modify these as needed)
SUB_ID="fdb4cfb7-d1ff-4de8-866a-b6c3ae961a7b"
RG="ResourceLockLabRG"
LOC="East US"
SA="resourcelocksa$(date +%s)"

echo "Starting Azure Resource Lock Lab..."

# Set subscription context
az account set --subscription $SUB_ID

# Create resource group
echo "Creating resource group: $RG"
az group create --name $RG --location "$LOC"

# Create storage account
echo "Creating storage account: $SA"
az storage account create \
    --name $SA \
    --resource-group $RG \
    --location "$LOC" \
    --sku Standard_LRS

# Apply ReadOnly lock to storage account
echo "Applying ReadOnly lock to storage account..."
az lock create \
    --name "ReadOnlyLock" \
    --lock-type ReadOnly \
    --resource-group $RG \
    --resource-name $SA \
    --resource-type Microsoft.Storage/storageAccounts

# Display current locks
echo "Current resource locks:"
az lock list --resource-group $RG --output table

echo "Lab setup complete!"
echo "Try to delete the storage account to see the lock in action:"
echo "az storage account delete --name $SA --resource-group $RG"