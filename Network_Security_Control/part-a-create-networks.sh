#!/bin/bash

# Network Security Control Lab - Part A
# Create Resource Groups and Virtual Networks

# Load configuration
CONFIG_FILE="config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "❌ Configuration file not found: $CONFIG_FILE"
    echo "Please ensure the config file exists with your subscription ID"
    exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Network Security Control Lab - Part A ===${NC}"
echo -e "${BLUE}Creating Resource Groups and Virtual Networks${NC}"
echo ""

# Set subscription context
echo -e "${YELLOW}Setting subscription context...${NC}"
az account set --subscription $SUBSCRIPTION_ID
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Subscription set to: $SUBSCRIPTION_ID${NC}"
else
    echo -e "${RED}✗ Failed to set subscription${NC}"
    exit 1
fi

echo ""

# Create Resource Groups
echo -e "${YELLOW}Creating resource groups...${NC}"

echo "Creating resource group: $RG1"
az group create --name $RG1 --location $LOC --output table
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Resource group $RG1 created${NC}"
else
    echo -e "${RED}✗ Failed to create resource group $RG1${NC}"
fi

echo "Creating resource group: $RG2"
az group create --name $RG2 --location $LOC --output table
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Resource group $RG2 created${NC}"
else
    echo -e "${RED}✗ Failed to create resource group $RG2${NC}"
fi

echo ""

# Create Virtual Network A with first subnet
echo -e "${YELLOW}Creating VNet A with subnets...${NC}"
echo "Creating $VNET1 with address space 10.0.0.0/16"
az network vnet create \
  --resource-group $RG1 \
  --name $VNET1 \
  --address-prefixes 10.0.0.0/16 \
  --subnet-name $VNET1_SUB1 \
  --subnet-prefixes 10.0.1.0/24 \
  --output table

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ VNet $VNET1 created with subnet $VNET1_SUB1${NC}"
else
    echo -e "${RED}✗ Failed to create VNet $VNET1${NC}"
fi

# Add second subnet to VNet A
echo "Adding second subnet to $VNET1"
az network vnet subnet create \
  --resource-group $RG1 \
  --vnet-name $VNET1 \
  --name $VNET1_SUB2 \
  --address-prefixes 10.0.2.0/24 \
  --output table

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Subnet $VNET1_SUB2 added to $VNET1${NC}"
else
    echo -e "${RED}✗ Failed to create subnet $VNET1_SUB2${NC}"
fi

echo ""

# Create Virtual Network B
echo -e "${YELLOW}Creating VNet B...${NC}"
echo "Creating $VNET2 with address space 10.1.0.0/16"
az network vnet create \
  --resource-group $RG2 \
  --name $VNET2 \
  --address-prefixes 10.1.0.0/16 \
  --subnet-name $VNET2_SUB1 \
  --subnet-prefixes 10.1.1.0/24 \
  --output table

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ VNet $VNET2 created with subnet $VNET2_SUB1${NC}"
else
    echo -e "${RED}✗ Failed to create VNet $VNET2${NC}"
fi

echo ""

# Verification
echo -e "${BLUE}=== Verification ===${NC}"
echo -e "${YELLOW}Resource Groups:${NC}"
az group list --query "[?starts_with(name, 'rg-net')].{Name:name, Location:location}" --output table

echo ""
echo -e "${YELLOW}VNet A Details:${NC}"
az network vnet show --resource-group $RG1 --name $VNET1 --query "{Name:name, AddressSpace:addressSpace.addressPrefixes}" --output table
az network vnet subnet list --resource-group $RG1 --vnet-name $VNET1 --query "[].{Name:name, AddressPrefix:addressPrefix}" --output table

echo ""
echo -e "${YELLOW}VNet B Details:${NC}"
az network vnet show --resource-group $RG2 --name $VNET2 --query "{Name:name, AddressSpace:addressSpace.addressPrefixes}" --output table
az network vnet subnet list --resource-group $RG2 --vnet-name $VNET2 --query "[].{Name:name, AddressPrefix:addressPrefix}" --output table

echo ""
echo -e "${GREEN}=== Part A Complete! ===${NC}"
echo -e "${GREEN}✓ Created resource groups: $RG1, $RG2${NC}"
echo -e "${GREEN}✓ Created VNet A ($VNET1) with 2 subnets${NC}"
echo -e "${GREEN}✓ Created VNet B ($VNET2) with 1 subnet${NC}"
echo ""
echo -e "${BLUE}Ready for Part B - Network Security Groups!${NC}"