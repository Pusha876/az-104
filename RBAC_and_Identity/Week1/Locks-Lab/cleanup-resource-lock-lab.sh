#!/bin/bash

# Azure Resource Lock Lab Cleanup Script
# This script removes locks and cleans up resources created by the lock lab

# Variables — replace with your values (should match the creation script)
SUB_ID="00000000-0000-0000-0000-000000000000"
RG="rg-lock-lab"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Azure Resource Lock Lab Cleanup Script ===${NC}"

# Function to check if command was successful
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $1${NC}"
    else
        echo -e "${RED}✗ $1 failed${NC}"
    fi
}

# Set the subscription
echo -e "${YELLOW}Setting subscription to: $SUB_ID${NC}"
az account set --subscription "$SUB_ID"
check_status "Subscription set"

# List current locks before removal
echo -e "${YELLOW}Current locks in resource group:${NC}"
az lock list --resource-group "$RG" --output table

# Remove ReadOnly lock from resource group
echo -e "${YELLOW}Removing ReadOnly lock from resource group${NC}"
az lock delete --name "rg-readonly-lock" --resource-group "$RG"
check_status "ReadOnly lock removed from resource group"

# Remove CanNotDelete lock from storage account
echo -e "${YELLOW}Removing CanNotDelete lock from storage account${NC}"
az lock delete --name "sa-nodelete-lock" --resource-group "$RG"
check_status "CanNotDelete lock removed from storage account"

# Verify all locks are removed
echo -e "${YELLOW}Verifying locks are removed:${NC}"
REMAINING_LOCKS=$(az lock list --resource-group "$RG" --query "length(@)")
if [ "$REMAINING_LOCKS" -eq 0 ]; then
    echo -e "${GREEN}✓ All locks successfully removed${NC}"
else
    echo -e "${RED}⚠ Warning: $REMAINING_LOCKS locks still remain${NC}"
    az lock list --resource-group "$RG" --output table
fi

# Delete the resource group and all its resources
echo -e "${YELLOW}Deleting resource group and all resources: $RG${NC}"
read -p "Are you sure you want to delete the resource group '$RG' and all its resources? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    az group delete --name "$RG" --yes --no-wait
    check_status "Resource group deletion initiated"
    echo -e "${GREEN}Resource group deletion started in background${NC}"
else
    echo -e "${YELLOW}Resource group deletion cancelled${NC}"
fi

echo -e "${GREEN}Cleanup script completed!${NC}"