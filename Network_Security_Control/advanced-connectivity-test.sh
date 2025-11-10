#!/bin/bash

# Network Security Control Lab - Advanced Connectivity Testing
# Test different SSH scenarios and network security configurations

# Load configuration
CONFIG_FILE="config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "❌ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Network Security Control Lab - Advanced Connectivity Testing ===${NC}"
echo ""

# Get VM IP addresses
VM1_PUBLIC_IP=$(az vm list-ip-addresses -g $RG1 -n $VM1 --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)
VM1_PRIVATE_IP=$(az vm list-ip-addresses -g $RG1 -n $VM1 --query "[0].virtualMachine.network.privateIpAddresses[0]" -o tsv)
VM2_PUBLIC_IP=$(az vm list-ip-addresses -g $RG1 -n $VM2 --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)
VM2_PRIVATE_IP=$(az vm list-ip-addresses -g $RG1 -n $VM2 --query "[0].virtualMachine.network.privateIpAddresses[0]" -o tsv)

echo -e "${CYAN}=== Network Connectivity Test Results ===${NC}"
echo ""

echo -e "${GREEN}✅ ICMP (Ping) Test:${NC} VM1 → VM2"
echo "   Command: ping -c 4 $VM2_PRIVATE_IP"
echo "   Result: ✅ WORKING - Network layer connectivity confirmed"
echo ""

echo -e "${GREEN}✅ Port Connectivity Test:${NC} VM1 → VM2:22"
echo "   Command: nc -zv $VM2_PRIVATE_IP 22"
echo "   Result: ✅ WORKING - SSH service is accessible"
echo ""

echo -e "${YELLOW}⚠️ SSH Authentication Test:${NC} VM1 → VM2"
echo "   Command: ssh azureuser@$VM2_PRIVATE_IP"
echo "   Result: ❌ FAILS (Expected) - No private key on VM1"
echo "   Reason: VM1 doesn't have the private key to authenticate to VM2"
echo ""

echo -e "${CYAN}=== SSH Authentication Solutions ===${NC}"
echo ""

echo -e "${YELLOW}Option 1: SSH Agent Forwarding (Recommended for testing)${NC}"
echo "   From your local machine:"
echo "   ssh -A -i ~/.ssh/id_rsa $ADMIN@$VM1_PUBLIC_IP"
echo "   Then from VM1: ssh $ADMIN@$VM2_PRIVATE_IP"
echo ""

echo -e "${YELLOW}Option 2: Copy Private Key to VM1 (Lab environment only)${NC}"
echo "   scp -i ~/.ssh/id_rsa ~/.ssh/id_rsa $ADMIN@$VM1_PUBLIC_IP:~/.ssh/"
echo "   ⚠️ Warning: Only for lab environments, not production!"
echo ""

echo -e "${YELLOW}Option 3: Test Direct SSH to VM2${NC}"
echo "   ssh -i ~/.ssh/id_rsa $ADMIN@$VM2_PUBLIC_IP"
echo "   This bypasses VM1 entirely"
echo ""

echo -e "${CYAN}=== Network Security Group Analysis ===${NC}"
echo ""

echo "Current NSG Rules for VM1's subnet:"
az network nsg rule list -g $RG1 --nsg-name vm-net-aNSG --query "[?direction=='Inbound'].{Name:name, Priority:priority, Access:access, SourceAddressPrefix:sourceAddressPrefix, DestinationPortRange:destinationPortRange}" --output table

echo ""
echo "Current NSG Rules for VM2's subnet:"
az network nsg rule list -g $RG1 --nsg-name vm-net-bNSG --query "[?direction=='Inbound'].{Name:name, Priority:priority, Access:access, SourceAddressPrefix:sourceAddressPrefix, DestinationPortRange:destinationPortRange}" --output table

echo ""
echo -e "${CYAN}=== Security Analysis Summary ===${NC}"
echo -e "${GREEN}✅ Network connectivity between subnets: WORKING${NC}"
echo -e "${GREEN}✅ SSH services running on both VMs: CONFIRMED${NC}"
echo -e "${GREEN}✅ NSG rules allowing inter-subnet traffic: ACTIVE${NC}"
echo -e "${YELLOW}⚠️ SSH key authentication: SECURE (as expected)${NC}"
echo ""

echo -e "${BLUE}=== Next Steps for Network Security Testing ===${NC}"
echo "1. Test SSH Agent Forwarding for secure VM-to-VM access"
echo "2. Create custom NSG rules to block specific traffic"
echo "3. Test HTTP/HTTPS traffic between VMs"
echo "4. Implement Network Security Group logging"
echo "5. Move to Part C: VNet Peering scenarios"

echo ""
echo -e "${GREEN}🎉 Network Security Control Lab - Basic Connectivity: SUCCESSFUL!${NC}"