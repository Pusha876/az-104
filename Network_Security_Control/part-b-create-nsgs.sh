#!/bin/bash

# Network Security Control Lab - Part B
# Create and Configure Network Security Groups (NSGs)

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
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# NSG Names
NSG_SUBNET_A1="nsg-subnet-a1"
NSG_SUBNET_A2="nsg-subnet-a2"
NSG_VM_A="nsg-vm-a"
NSG_VM_B="nsg-vm-b"

echo -e "${BLUE}=== Network Security Control Lab - Part B ===${NC}"
echo -e "${BLUE}Creating and Configuring Network Security Groups${NC}"
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

# Create NSGs
echo -e "${CYAN}=== Creating Network Security Groups ===${NC}"

echo "Creating NSG for subnet-a1: $NSG_SUBNET_A1"
az network nsg create \
  --resource-group $RG1 \
  --name $NSG_SUBNET_A1 \
  --location $LOC

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ NSG $NSG_SUBNET_A1 created${NC}"
else
    echo -e "${RED}✗ Failed to create NSG $NSG_SUBNET_A1${NC}"
fi

echo "Creating NSG for subnet-a2: $NSG_SUBNET_A2"
az network nsg create \
  --resource-group $RG1 \
  --name $NSG_SUBNET_A2 \
  --location $LOC

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ NSG $NSG_SUBNET_A2 created${NC}"
else
    echo -e "${RED}✗ Failed to create NSG $NSG_SUBNET_A2${NC}"
fi

echo ""

# Create custom security rules
echo -e "${CYAN}=== Creating Custom Security Rules ===${NC}"

# Rule 1: Allow SSH from internet to subnet-a1 (higher priority than default)
echo "Creating SSH allow rule for subnet-a1..."
az network nsg rule create \
  --resource-group $RG1 \
  --nsg-name $NSG_SUBNET_A1 \
  --name "Allow-SSH-Internet" \
  --priority 1000 \
  --source-address-prefixes Internet \
  --destination-port-ranges 22 \
  --access Allow \
  --protocol Tcp \
  --description "Allow SSH from Internet"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ SSH allow rule created for $NSG_SUBNET_A1${NC}"
else
    echo -e "${RED}✗ Failed to create SSH rule for $NSG_SUBNET_A1${NC}"
fi

# Rule 2: Allow ICMP between subnets for ping testing
echo "Creating ICMP allow rule between subnets..."
az network nsg rule create \
  --resource-group $RG1 \
  --nsg-name $NSG_SUBNET_A1 \
  --name "Allow-ICMP-Internal" \
  --priority 1100 \
  --source-address-prefixes 10.0.0.0/16 \
  --destination-address-prefixes 10.0.0.0/16 \
  --destination-port-ranges "*" \
  --access Allow \
  --protocol Icmp \
  --description "Allow ICMP within VNet"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ ICMP allow rule created${NC}"
else
    echo -e "${RED}✗ Failed to create ICMP rule${NC}"
fi

# Rule 3: Block HTTP traffic from subnet-a1 to subnet-a2 (demonstration rule)
echo "Creating HTTP block rule from subnet-a1 to subnet-a2..."
az network nsg rule create \
  --resource-group $RG1 \
  --nsg-name $NSG_SUBNET_A1 \
  --name "Block-HTTP-To-SubnetA2" \
  --priority 1200 \
  --source-address-prefixes 10.0.1.0/24 \
  --destination-address-prefixes 10.0.2.0/24 \
  --destination-port-ranges 80 \
  --access Deny \
  --protocol Tcp \
  --description "Block HTTP from subnet-a1 to subnet-a2"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ HTTP block rule created${NC}"
else
    echo -e "${RED}✗ Failed to create HTTP block rule${NC}"
fi

# Rule 4: Allow SSH from subnet-a1 to subnet-a2
echo "Creating SSH allow rule from subnet-a1 to subnet-a2..."
az network nsg rule create \
  --resource-group $RG1 \
  --nsg-name $NSG_SUBNET_A2 \
  --name "Allow-SSH-From-SubnetA1" \
  --priority 1000 \
  --source-address-prefixes 10.0.1.0/24 \
  --destination-address-prefixes 10.0.2.0/24 \
  --destination-port-ranges 22 \
  --access Allow \
  --protocol Tcp \
  --description "Allow SSH from subnet-a1 to subnet-a2"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ SSH inter-subnet rule created${NC}"
else
    echo -e "${RED}✗ Failed to create SSH inter-subnet rule${NC}"
fi

echo ""

# Associate NSGs with subnets
echo -e "${CYAN}=== Associating NSGs with Subnets ===${NC}"

echo "Associating $NSG_SUBNET_A1 with $VNET1_SUB1..."
az network vnet subnet update \
  --resource-group $RG1 \
  --vnet-name $VNET1 \
  --name $VNET1_SUB1 \
  --network-security-group $NSG_SUBNET_A1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ NSG associated with $VNET1_SUB1${NC}"
else
    echo -e "${RED}✗ Failed to associate NSG with $VNET1_SUB1${NC}"
fi

echo "Associating $NSG_SUBNET_A2 with $VNET1_SUB2..."
az network vnet subnet update \
  --resource-group $RG1 \
  --vnet-name $VNET1 \
  --name $VNET1_SUB2 \
  --network-security-group $NSG_SUBNET_A2

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ NSG associated with $VNET1_SUB2${NC}"
else
    echo -e "${RED}✗ Failed to associate NSG with $VNET1_SUB2${NC}"
fi

echo ""

# Display NSG information
echo -e "${BLUE}=== NSG Configuration Summary ===${NC}"
echo -e "${YELLOW}Network Security Groups:${NC}"
az network nsg list --resource-group $RG1 --query "[].{Name:name, Location:location, Subnets:subnets[0].name}" --output table

echo ""
echo -e "${YELLOW}Security Rules for $NSG_SUBNET_A1:${NC}"
az network nsg rule list --resource-group $RG1 --nsg-name $NSG_SUBNET_A1 --query "[].{Name:name, Priority:priority, Access:access, Protocol:protocol, Direction:direction, SourceAddressPrefix:sourceAddressPrefix, DestinationPortRange:destinationPortRange}" --output table

echo ""
echo -e "${YELLOW}Security Rules for $NSG_SUBNET_A2:${NC}"
az network nsg rule list --resource-group $RG1 --nsg-name $NSG_SUBNET_A2 --query "[].{Name:name, Priority:priority, Access:access, Protocol:protocol, Direction:direction, SourceAddressPrefix:sourceAddressPrefix, DestinationPortRange:destinationPortRange}" --output table

echo ""

# Test connectivity instructions
echo -e "${BLUE}=== Testing Instructions ===${NC}"
echo -e "${CYAN}VM Information:${NC}"
az vm list-ip-addresses -g $RG1 --query "[].{VM:virtualMachine.name, PrivateIP:virtualMachine.network.privateIpAddresses[0], PublicIP:virtualMachine.network.publicIpAddresses[0].ipAddress}" --output table

echo ""
echo -e "${YELLOW}Connectivity Tests to Perform:${NC}"
echo -e "${GREEN}1. SSH to VM1 (should work):${NC}"
VM1_PUBLIC_IP=$(az vm list-ip-addresses -g $RG1 -n $VM1 --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)
echo "   ssh $ADMIN@$VM1_PUBLIC_IP"

echo ""
echo -e "${GREEN}2. From VM1, ping VM2 (should work - ICMP allowed):${NC}"
VM2_PRIVATE_IP=$(az vm list-ip-addresses -g $RG1 -n $VM2 --query "[0].virtualMachine.network.privateIpAddresses[0]" -o tsv)
echo "   ping $VM2_PRIVATE_IP"

echo ""
echo -e "${GREEN}3. From VM1, SSH to VM2 (should work - SSH allowed):${NC}"
echo "   ssh $ADMIN@$VM2_PRIVATE_IP"

echo ""
echo -e "${RED}4. HTTP traffic from VM1 to VM2 on port 80 (should be blocked):${NC}"
echo "   # Install and test with netcat or curl if needed"
echo "   # This rule demonstrates selective traffic blocking"

echo ""
echo -e "${GREEN}=== Part B Complete! ===${NC}"
echo -e "${GREEN}✓ Created NSGs for both subnets${NC}"
echo -e "${GREEN}✓ Configured custom security rules${NC}"
echo -e "${GREEN}✓ Associated NSGs with subnets${NC}"
echo -e "${GREEN}✓ SSH, ICMP allowed; HTTP blocked between specific subnets${NC}"
echo ""
echo -e "${BLUE}Ready for Part C - VNet Peering and Advanced Scenarios!${NC}"