#!/bin/bash

# Azure Resource Lock Lab Script - Advanced Version
# This script demonstrates creating resources and applying different types of locks

# Load configuration from config file
CONFIG_FILE="../../config.sh"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "❌ Configuration file not found: $CONFIG_FILE"
    echo "Please copy config.template.sh to config.sh and update with your values"
    exit 1
fi

# Variables — using config file values
RG="${LOCK_LAB_RG:-rg-lock-lab}"
LOC="${AZURE_REGION:-eastus}"
SA="${STORAGE_PREFIX:-locklabstorage}$(date +%s)"   # makes name unique

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Azure Resource Lock Lab Script ===${NC}"

# Function to check if command was successful
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $1${NC}"
    else
        echo -e "${RED}✗ $1 failed${NC}"
        exit 1
    fi
}

# Set the subscription
echo -e "${YELLOW}Setting subscription to: $SUB_ID${NC}"
az account set --subscription "$SUB_ID"
check_status "Subscription set"

# Create resource group
echo -e "${YELLOW}Creating resource group: $RG in $LOC${NC}"
az group create --name "$RG" --location "$LOC" --output table
check_status "Resource group created"

# Create storage account
echo -e "${YELLOW}Creating storage account: $SA${NC}"
az storage account create \
    --name "$SA" \
    --resource-group "$RG" \
    --location "$LOC" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --output table
check_status "Storage account created"

# Apply ReadOnly lock at resource group level
echo -e "${YELLOW}Applying ReadOnly lock to resource group${NC}"
az lock create \
    --name "rg-readonly-lock" \
    --lock-type ReadOnly \
    --resource-group "$RG" \
    --notes "Prevents modifications to resources in this RG"
check_status "ReadOnly lock applied to resource group"

# Apply CanNotDelete lock to storage account
echo -e "${YELLOW}Applying CanNotDelete lock to storage account${NC}"
az lock create \
    --name "sa-nodelete-lock" \
    --lock-type CanNotDelete \
    --resource-group "$RG" \
    --resource-name "$SA" \
    --resource-type "Microsoft.Storage/storageAccounts" \
    --notes "Prevents deletion of this storage account"
check_status "CanNotDelete lock applied to storage account"

# List all locks
echo -e "${YELLOW}Listing all resource locks:${NC}"
az lock list --resource-group "$RG" --output table

echo -e "${GREEN}"
echo "========================================="
echo "Resources and locks created successfully!"
echo "========================================="
echo -e "Resource Group: ${YELLOW}$RG${GREEN}"
echo -e "Storage Account: ${YELLOW}$SA${GREEN}"
echo -e "Location: ${YELLOW}$LOC${GREEN}"
echo ""
echo "Locks applied:"
echo "- ReadOnly lock on Resource Group (prevents modifications)"
echo "- CanNotDelete lock on Storage Account (prevents deletion)"
echo -e "${NC}"

echo -e "${YELLOW}To clean up later, you'll need to remove locks first:${NC}"
echo "az lock delete --name 'rg-readonly-lock' --resource-group '$RG'"
echo "az lock delete --name 'sa-nodelete-lock' --resource-group '$RG'"
echo "az group delete --name '$RG' --yes --no-wait"