#!/bin/bash

# Storage Account Creation Script
# This script creates a production storage account with advanced features

# Load variables from the variable file
source ./variable

echo "=== Azure Storage Account Creation ==="
echo "Subscription: $SUB_ID"
echo "Resource Group: $RG"
echo "Storage Account: $STORAGE"
echo ""

# Set the subscription context
echo "Setting subscription context..."
az account set --subscription "$SUB_ID"
if [ $? -eq 0 ]; then
    echo "✓ Subscription set to: $SUB_ID"
else
    echo "✗ Failed to set subscription"
    exit 1
fi

# Create resource group if it doesn't exist
echo ""
echo "Creating resource group if it doesn't exist..."
az group create \
    --name "$RG" \
    --location "East US" \
    --tags "Environment=Production" "Purpose=StorageDemo"

if [ $? -eq 0 ]; then
    echo "✓ Resource group '$RG' is ready"
else
    echo "✗ Failed to create resource group"
    exit 1
fi

# Create storage account with advanced features
echo ""
echo "Creating storage account '$STORAGE'..."
az storage account create \
    --name "$STORAGE" \
    --resource-group "$RG" \
    --location "East US" \
    --sku "Standard_LRS" \
    --kind "StorageV2" \
    --access-tier "Hot" \
    --https-only true \
    --min-tls-version "TLS1_2" \
    --allow-blob-public-access false \
    --enable-hierarchical-namespace false \
    --tags "Environment=Production" "Purpose=AppStorage" "Owner=DevTeam"

if [ $? -eq 0 ]; then
    echo "✓ Storage account '$STORAGE' created successfully"
else
    echo "✗ Failed to create storage account"
    exit 1
fi

# Enable blob versioning and soft delete
echo ""
echo "Configuring blob storage security features..."
az storage account blob-service-properties update \
    --account-name "$STORAGE" \
    --resource-group "$RG" \
    --enable-versioning true \
    --enable-delete-retention true \
    --delete-retention-days 7

if [ $? -eq 0 ]; then
    echo "✓ Blob security features enabled"
else
    echo "⚠ Warning: Could not enable all blob security features"
fi

# Create blob container for application logs
echo ""
echo "Creating blob container '$LOG_CONTAINER'..."
az storage container create \
    --name "$LOG_CONTAINER" \
    --account-name "$STORAGE" \
    --resource-group "$RG" \
    --public-access off \
    --auth-mode login

if [ $? -eq 0 ]; then
    echo "✓ Blob container '$LOG_CONTAINER' created"
else
    echo "⚠ Warning: Could not create blob container"
fi

# Create file share for development files
echo ""
echo "Creating file share '$FILE_SHARE'..."
az storage share create \
    --name "$FILE_SHARE" \
    --account-name "$STORAGE" \
    --quota 100 \
    --auth-mode login

if [ $? -eq 0 ]; then
    echo "✓ File share '$FILE_SHARE' created with 100GB quota"
else
    echo "⚠ Warning: Could not create file share"
fi

# Create managed identity for application access
echo ""
echo "Creating managed identity '$APP_MI_NAME'..."
az identity create \
    --name "$APP_MI_NAME" \
    --resource-group "$RG"

if [ $? -eq 0 ]; then
    echo "✓ Managed identity '$APP_MI_NAME' created"
    
    # Get the principal ID of the managed identity
    MI_PRINCIPAL_ID=$(az identity show --name "$APP_MI_NAME" --resource-group "$RG" --query principalId --output tsv)
    echo "Managed Identity Principal ID: $MI_PRINCIPAL_ID"
    
    # Assign Storage Blob Data Contributor role to the managed identity
    echo "Assigning Storage Blob Data Contributor role..."
    az role assignment create \
        --assignee "$MI_PRINCIPAL_ID" \
        --role "Storage Blob Data Contributor" \
        --scope "/subscriptions/$SUB_ID/resourceGroups/$RG/providers/Microsoft.Storage/storageAccounts/$STORAGE"
    
    if [ $? -eq 0 ]; then
        echo "✓ Storage Blob Data Contributor role assigned"
    else
        echo "⚠ Warning: Could not assign role to managed identity"
    fi
    
else
    echo "⚠ Warning: Could not create managed identity"
fi

# Display storage account information
echo ""
echo "=== Storage Account Information ==="
az storage account show \
    --name "$STORAGE" \
    --resource-group "$RG" \
    --query "{Name:name, Location:location, SKU:sku.name, Kind:kind, AccessTier:accessTier, HttpsOnly:enableHttpsTrafficOnly}" \
    --output table

# Display connection string (for reference, but use managed identity in production)
echo ""
echo "=== Connection Information ==="
echo "Storage Account Name: $STORAGE"
echo "Resource Group: $RG"
echo "Primary Endpoints:"
az storage account show \
    --name "$STORAGE" \
    --resource-group "$RG" \
    --query "primaryEndpoints" \
    --output json

echo ""
echo "=== Security Recommendations ==="
echo "✓ HTTPS-only access enabled"
echo "✓ TLS 1.2 minimum version enforced"
echo "✓ Public blob access disabled"
echo "✓ Blob versioning enabled"
echo "✓ Soft delete enabled (7 days)"
echo "✓ Managed identity created for secure access"
echo ""
echo "🔒 For production use, consider:"
echo "   - Enable private endpoints for network isolation"
echo "   - Configure firewall rules to restrict access"
echo "   - Enable diagnostic logging"
echo "   - Set up lifecycle management policies"

echo ""
echo "=== Storage Account Creation Complete! ==="