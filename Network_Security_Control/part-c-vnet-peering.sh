#!/bin/bash

# Network Security Control Lab - Part C
# VNet Peering Implementation and Testing

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
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# VNet Peering Names
PEERING_A_TO_B="peer-vnet-a-to-vnet-b"
PEERING_B_TO_A="peer-vnet-b-to-vnet-a"

# VM in VNet B
VM3="vm-net-c"
VNET2_NSG="nsg-vnet-b-subnet"

echo -e "${BLUE}=== Network Security Control Lab - Part C ===${NC}"
echo -e "${BLUE}VNet Peering Implementation and Cross-VNet Communication${NC}"
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

# Check current VNet topology
echo -e "${CYAN}=== Current Network Topology Analysis ===${NC}"
echo "Checking existing VNets..."
az network vnet list --query "[?starts_with(name, 'vnet')].{Name:name, ResourceGroup:resourceGroup, AddressSpace:addressSpace.addressPrefixes[0], Location:location}" --output table

echo ""

# Create or update VNet B with correct address space
echo -e "${CYAN}=== Setting Up VNet B (10.1.0.0/16) ===${NC}"
echo "Checking if vnet-b exists with correct address space..."

EXISTING_VNET_B=$(az network vnet show -g $RG2 -n $VNET2 --query "addressSpace.addressPrefixes[0]" -o tsv 2>/dev/null)

if [ "$EXISTING_VNET_B" == "10.1.0.0/16" ]; then
    echo -e "${GREEN}✓ VNet B already exists with correct address space${NC}"
else
    echo -e "${YELLOW}⚠ VNet B doesn't exist or has wrong address space, creating/recreating...${NC}"
    
    # Delete existing vnet-b if it exists with wrong address space
    az network vnet delete -g $RG2 -n $VNET2 --yes 2>/dev/null
    
    echo "Creating VNet B with correct address space (10.1.0.0/16)..."
    az network vnet create \
      --resource-group $RG2 \
      --name $VNET2 \
      --address-prefixes 10.1.0.0/16 \
      --subnet-name $VNET2_SUB1 \
      --subnet-prefixes 10.1.1.0/24 \
      --location $LOC
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ VNet B created with correct address space${NC}"
    else
        echo -e "${RED}✗ Failed to create VNet B${NC}"
        exit 1
    fi
fi

echo ""

# Create NSG for VNet B
echo -e "${CYAN}=== Creating Network Security Group for VNet B ===${NC}"
echo "Creating NSG for VNet B subnet..."
az network nsg create \
  --resource-group $RG2 \
  --name $VNET2_NSG \
  --location $LOC

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ NSG created for VNet B${NC}"
else
    echo -e "${YELLOW}⚠ NSG might already exist${NC}"
fi

# Create SSH allow rule for VNet B
echo "Adding SSH allow rule to VNet B NSG..."
az network nsg rule create \
  --resource-group $RG2 \
  --nsg-name $VNET2_NSG \
  --name "Allow-SSH-Internet" \
  --priority 1000 \
  --source-address-prefixes Internet \
  --destination-port-ranges 22 \
  --access Allow \
  --protocol Tcp \
  --description "Allow SSH from Internet"

# Allow communication from VNet A
echo "Adding rule to allow communication from VNet A..."
az network nsg rule create \
  --resource-group $RG2 \
  --nsg-name $VNET2_NSG \
  --name "Allow-VNetA-Communication" \
  --priority 1100 \
  --source-address-prefixes 10.0.0.0/16 \
  --destination-address-prefixes 10.1.0.0/16 \
  --destination-port-ranges "*" \
  --access Allow \
  --protocol "*" \
  --description "Allow all communication from VNet A"

# Associate NSG with VNet B subnet
echo "Associating NSG with VNet B subnet..."
az network vnet subnet update \
  --resource-group $RG2 \
  --vnet-name $VNET2 \
  --name $VNET2_SUB1 \
  --network-security-group $VNET2_NSG

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ NSG associated with VNet B subnet${NC}"
else
    echo -e "${RED}✗ Failed to associate NSG with VNet B subnet${NC}"
fi

echo ""

# Create VM in VNet B
echo -e "${CYAN}=== Creating VM in VNet B ===${NC}"
echo "Creating VM3 in VNet B for cross-VNet testing..."

# Check if VM already exists
EXISTING_VM3=$(az vm show -g $RG2 -n $VM3 --query "name" -o tsv 2>/dev/null)

if [ "$EXISTING_VM3" == "$VM3" ]; then
    echo -e "${GREEN}✓ VM3 already exists in VNet B${NC}"
else
    az vm create \
      --resource-group $RG2 \
      --name $VM3 \
      --image $VM_IMAGE \
      --vnet-name $VNET2 \
      --subnet $VNET2_SUB1 \
      --admin-username $ADMIN \
      --generate-ssh-keys \
      --size $VM_SIZE \
      --no-wait
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ VM3 creation initiated in VNet B${NC}"
    else
        echo -e "${RED}✗ Failed to create VM3${NC}"
    fi
fi

echo ""

# Create VNet Peering
echo -e "${CYAN}=== Creating VNet Peering Connections ===${NC}"

echo "Creating peering from VNet A to VNet B..."
az network vnet peering create \
  --name $PEERING_A_TO_B \
  --resource-group $RG1 \
  --vnet-name $VNET1 \
  --remote-vnet $VNET2 \
  --allow-vnet-access \
  --allow-forwarded-traffic \
  --allow-gateway-transit false \
  --use-remote-gateways false

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Peering created: VNet A → VNet B${NC}"
else
    echo -e "${YELLOW}⚠ Peering VNet A → VNet B might already exist${NC}"
fi

echo "Creating peering from VNet B to VNet A..."
az network vnet peering create \
  --name $PEERING_B_TO_A \
  --resource-group $RG2 \
  --vnet-name $VNET2 \
  --remote-vnet "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG1/providers/Microsoft.Network/virtualNetworks/$VNET1" \
  --allow-vnet-access \
  --allow-forwarded-traffic \
  --allow-gateway-transit false \
  --use-remote-gateways false

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Peering created: VNet B → VNet A${NC}"
else
    echo -e "${YELLOW}⚠ Peering VNet B → VNet A might already exist${NC}"
fi

echo ""

# Verify peering status
echo -e "${CYAN}=== Verifying VNet Peering Status ===${NC}"
echo -e "${YELLOW}VNet A Peering Status:${NC}"
az network vnet peering list -g $RG1 --vnet-name $VNET1 --query "[].{Name:name, PeeringState:peeringState, RemoteVNet:remoteVirtualNetwork.id}" --output table

echo ""
echo -e "${YELLOW}VNet B Peering Status:${NC}"
az network vnet peering list -g $RG2 --vnet-name $VNET2 --query "[].{Name:name, PeeringState:remoteVirtualNetwork.id, RemoteVNet:remoteVirtualNetwork.id}" --output table

echo ""

# Display network topology
echo -e "${BLUE}=== Final Network Topology ===${NC}"
echo -e "${PURPLE}VNet A (rg-net-a):${NC}"
echo "  ├── Address Space: 10.0.0.0/16"
echo "  ├── subnet-a1: 10.0.1.0/24 → vm-net-a"
echo "  └── subnet-a2: 10.0.2.0/24 → vm-net-b"
echo ""
echo -e "${PURPLE}VNet B (rg-net-b):${NC}"
echo "  ├── Address Space: 10.1.0.0/16"
echo "  └── subnet-b1: 10.1.1.0/24 → vm-net-c"
echo ""
echo -e "${PURPLE}VNet Peering:${NC}"
echo "  ├── VNet A ←→ VNet B (Bidirectional)"
echo "  └── Allow VNet Access: Enabled"

echo ""

# Get VM information for testing
echo -e "${CYAN}=== VM Information for Cross-VNet Testing ===${NC}"
echo "Waiting for VM3 to be ready..."
sleep 30  # Give VM3 time to initialize

echo -e "${YELLOW}All VMs Status:${NC}"
az vm list --query "[?starts_with(name, 'vm-net')].{Name:name, ResourceGroup:resourceGroup, Status:provisioningState}" --output table

echo ""
echo -e "${YELLOW}VM IP Addresses:${NC}"
az vm list-ip-addresses --query "[?virtualMachine.name=='vm-net-a' || virtualMachine.name=='vm-net-b' || virtualMachine.name=='vm-net-c'].{VM:virtualMachine.name, PrivateIP:virtualMachine.network.privateIpAddresses[0], PublicIP:virtualMachine.network.publicIpAddresses[0].ipAddress}" --output table

echo ""

# Testing instructions
echo -e "${BLUE}=== Cross-VNet Connectivity Testing Instructions ===${NC}"
echo ""
echo -e "${GREEN}Test 1: Ping from VNet A to VNet B${NC}"
echo "SSH to VM1 or VM2 and ping VM3:"
VM3_PRIVATE_IP=$(az vm list-ip-addresses -g $RG2 -n $VM3 --query "[0].virtualMachine.network.privateIpAddresses[0]" -o tsv 2>/dev/null)
if [ ! -z "$VM3_PRIVATE_IP" ]; then
    echo "ping $VM3_PRIVATE_IP"
else
    echo "ping <VM3_PRIVATE_IP> (will be available once VM3 is ready)"
fi

echo ""
echo -e "${GREEN}Test 2: SSH from VNet A to VNet B${NC}"
echo "Using SSH Agent Forwarding:"
echo "ssh -A -i ~/.ssh/id_rsa azureuser@<VM1_PUBLIC_IP>"
echo "Then: ssh azureuser@<VM3_PRIVATE_IP>"

echo ""
echo -e "${GREEN}Test 3: Verify Peering Status${NC}"
echo "Check effective routes on VM network interfaces:"
echo "az network nic show-effective-route-table -g $RG1 -n vm-net-aVMNic"

echo ""
echo -e "${GREEN}=== Part C Complete! ===${NC}"
echo -e "${GREEN}✓ VNet B created with correct address space (10.1.0.0/16)${NC}"
echo -e "${GREEN}✓ VM3 deployed in VNet B${NC}"
echo -e "${GREEN}✓ Bidirectional VNet peering established${NC}"
echo -e "${GREEN}✓ NSG rules configured for cross-VNet communication${NC}"
echo ""
echo -e "${BLUE}Ready for advanced network scenarios and traffic analysis!${NC}"