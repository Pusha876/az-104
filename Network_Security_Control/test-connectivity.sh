#!/bin/bash

# Network Security Control Lab - Connectivity Testing Script
# Test SSH connections and network connectivity between VMs

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

echo -e "${BLUE}=== Network Security Control Lab - Connectivity Testing ===${NC}"
echo ""

# Get VM IP addresses
VM1_PUBLIC_IP=$(az vm list-ip-addresses -g $RG1 -n $VM1 --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)
VM1_PRIVATE_IP=$(az vm list-ip-addresses -g $RG1 -n $VM1 --query "[0].virtualMachine.network.privateIpAddresses[0]" -o tsv)
VM2_PUBLIC_IP=$(az vm list-ip-addresses -g $RG1 -n $VM2 --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)
VM2_PRIVATE_IP=$(az vm list-ip-addresses -g $RG1 -n $VM2 --query "[0].virtualMachine.network.privateIpAddresses[0]" -o tsv)

echo -e "${CYAN}=== VM Information ===${NC}"
echo -e "${YELLOW}VM1 ($VM1):${NC}"
echo "  Public IP:  $VM1_PUBLIC_IP"
echo "  Private IP: $VM1_PRIVATE_IP"
echo "  Subnet:     $VNET1_SUB1 (10.0.1.0/24)"

echo ""
echo -e "${YELLOW}VM2 ($VM2):${NC}"
echo "  Public IP:  $VM2_PUBLIC_IP"
echo "  Private IP: $VM2_PRIVATE_IP"
echo "  Subnet:     $VNET1_SUB2 (10.0.2.0/24)"

echo ""
echo -e "${CYAN}=== SSH Connection Commands ===${NC}"
echo -e "${GREEN}Connect to VM1:${NC}"
echo "ssh -i ~/.ssh/id_rsa $ADMIN@$VM1_PUBLIC_IP"

echo ""
echo -e "${GREEN}Connect to VM2:${NC}"
echo "ssh -i ~/.ssh/id_rsa $ADMIN@$VM2_PUBLIC_IP"

echo ""
echo -e "${CYAN}=== Network Connectivity Tests ===${NC}"
echo -e "${YELLOW}From VM1, test connectivity to VM2:${NC}"
echo "1. Ping test: ping -c 4 $VM2_PRIVATE_IP"
echo "2. SSH test:  ssh $ADMIN@$VM2_PRIVATE_IP"
echo "3. Port test: nc -zv $VM2_PRIVATE_IP 22"

echo ""
echo -e "${CYAN}=== Quick SSH Test ===${NC}"
echo "Testing SSH connectivity to VM1..."

# Test SSH connectivity with timeout
timeout 10 ssh -i ~/.ssh/id_rsa -o ConnectTimeout=5 -o BatchMode=yes $ADMIN@$VM1_PUBLIC_IP "echo 'SSH connection successful!'" 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ SSH to VM1 is working!${NC}"
else
    echo -e "${YELLOW}⚠ SSH to VM1 timed out or failed (this might be normal if VM is still initializing)${NC}"
fi

echo ""
echo "Testing SSH connectivity to VM2..."
timeout 10 ssh -i ~/.ssh/id_rsa -o ConnectTimeout=5 -o BatchMode=yes $ADMIN@$VM2_PUBLIC_IP "echo 'SSH connection successful!'" 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ SSH to VM2 is working!${NC}"
else
    echo -e "${YELLOW}⚠ SSH to VM2 timed out or failed (this might be normal if VM is still initializing)${NC}"
fi

echo ""
echo -e "${CYAN}=== Interactive SSH Connection ===${NC}"
echo "To connect interactively to VM1, run:"
echo -e "${GREEN}ssh -i ~/.ssh/id_rsa $ADMIN@$VM1_PUBLIC_IP${NC}"
echo ""
echo "If connection is unstable, try:"
echo -e "${GREEN}ssh -i ~/.ssh/id_rsa -o ServerAliveInterval=60 -o ServerAliveCountMax=3 $ADMIN@$VM1_PUBLIC_IP${NC}"

echo ""
echo -e "${YELLOW}Note: If you get disconnected, it's normal for new VMs. Wait a minute and try again.${NC}"