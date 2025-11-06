#!/bin/bash

# Azure Configuration Template
# Copy this file to config.sh and update with your own values
# The config.sh file will be ignored by git to protect sensitive information

# Azure Subscription ID - Replace with your subscription ID
export SUB_ID="YOUR-SUBSCRIPTION-ID-HERE"

# Default Resource Group Names
export LOCK_LAB_RG="rg-lock-lab"
export RBAC_LAB_RG="rg-rbac-lab"

# Default Azure Region
export AZURE_REGION="eastus"

# Storage Account Prefix (will be made unique with timestamp)
export STORAGE_PREFIX="locklabstorage"

# Management Group (if using management group labs)
export MANAGEMENT_GROUP_NAME="az104-mg"

# Default User Principal Name (for RBAC labs)
export TEST_USER_UPN="testuser@yourdomain.com"

echo "Configuration loaded for subscription: $SUB_ID"