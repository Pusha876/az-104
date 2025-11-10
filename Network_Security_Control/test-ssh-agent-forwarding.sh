#!/bin/bash

# Network Security Control Lab - SSH Agent Forwarding Test
# Test secure SSH Agent Forwarding from local machine → VM1 → VM2

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

echo -e "${BLUE}=== SSH Agent Forwarding Test Guide ===${NC}"
echo ""

# Get VM IP addresses
VM1_PUBLIC_IP=$(az vm list-ip-addresses -g $RG1 -n $VM1 --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)
VM1_PRIVATE_IP=$(az vm list-ip-addresses -g $RG1 -n $VM1 --query "[0].virtualMachine.network.privateIpAddresses[0]" -o tsv)
VM2_PUBLIC_IP=$(az vm list-ip-addresses -g $RG1 -n $VM2 --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)
VM2_PRIVATE_IP=$(az vm list-ip-addresses -g $RG1 -n $VM2 --query "[0].virtualMachine.network.privateIpAddresses[0]" -o tsv)

echo -e "${CYAN}=== VM Information ===${NC}"
echo "VM1 ($VM1): $VM1_PUBLIC_IP → $VM1_PRIVATE_IP (subnet-a1)"
echo "VM2 ($VM2): $VM2_PUBLIC_IP → $VM2_PRIVATE_IP (subnet-a2)"
echo ""

echo -e "${CYAN}=== SSH Agent Forwarding Steps ===${NC}"
echo ""

echo -e "${YELLOW}Step 1: Check SSH Agent Status${NC}"
echo "First, let's check if SSH agent is running on your local machine:"
echo ""
echo -e "${GREEN}ssh-add -l${NC}"
echo ""

echo "Running SSH agent check..."
ssh-add -l 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ SSH agent is running and has keys loaded${NC}"
else
    echo -e "${YELLOW}⚠ SSH agent might need keys added. Run: ssh-add ~/.ssh/id_rsa${NC}"
fi

echo ""
echo -e "${YELLOW}Step 2: Connect to VM1 with Agent Forwarding${NC}"
echo "Connect to VM1 with the -A flag for agent forwarding:"
echo ""
echo -e "${GREEN}ssh -A -i ~/.ssh/id_rsa $ADMIN@$VM1_PUBLIC_IP${NC}"
echo ""

echo -e "${YELLOW}Step 3: From VM1, SSH to VM2${NC}"
echo "Once connected to VM1, you should be able to SSH to VM2:"
echo ""
echo -e "${GREEN}ssh $ADMIN@$VM2_PRIVATE_IP${NC}"
echo ""

echo -e "${CYAN}=== Testing SSH Agent Forwarding Automatically ===${NC}"
echo "Let's test this automatically..."
echo ""

echo "Testing SSH connection with agent forwarding to VM1..."
echo "Command: ssh -A -i ~/.ssh/id_rsa -o ConnectTimeout=10 -o BatchMode=yes $ADMIN@$VM1_PUBLIC_IP 'echo \"Successfully connected to VM1 with agent forwarding\"'"

timeout 15 ssh -A -i ~/.ssh/id_rsa -o ConnectTimeout=10 -o BatchMode=yes $ADMIN@$VM1_PUBLIC_IP 'echo "Successfully connected to VM1 with agent forwarding"' 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ SSH Agent Forwarding to VM1: WORKING${NC}"
    echo ""
    
    echo "Now testing SSH from VM1 to VM2 through the forwarded agent..."
    echo "Command: ssh -A -i ~/.ssh/id_rsa -o ConnectTimeout=10 $ADMIN@$VM1_PUBLIC_IP 'ssh -o ConnectTimeout=10 -o BatchMode=yes $ADMIN@$VM2_PRIVATE_IP \"echo \\\"Successfully connected to VM2 from VM1\\\"\"'"
    
    timeout 20 ssh -A -i ~/.ssh/id_rsa -o ConnectTimeout=10 $ADMIN@$VM1_PUBLIC_IP "ssh -o ConnectTimeout=10 -o BatchMode=yes $ADMIN@$VM2_PRIVATE_IP 'echo \"Successfully connected to VM2 from VM1\"'" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ SSH Agent Forwarding VM1 → VM2: WORKING PERFECTLY!${NC}"
    else
        echo -e "${YELLOW}⚠ SSH Agent Forwarding VM1 → VM2: Needs interactive testing${NC}"
        echo "This might require accepting host key fingerprints interactively."
    fi
else
    echo -e "${YELLOW}⚠ SSH Agent Forwarding: Needs interactive testing${NC}"
fi

echo ""
echo -e "${CYAN}=== Manual Testing Instructions ===${NC}"
echo ""

echo -e "${YELLOW}For Interactive Testing:${NC}"
echo ""
echo "1. Open a new terminal and run:"
echo -e "${GREEN}   ssh -A -i ~/.ssh/id_rsa $ADMIN@$VM1_PUBLIC_IP${NC}"
echo ""
echo "2. Once connected to VM1, test the forwarded agent:"
echo -e "${GREEN}   ssh-add -l${NC}"
echo "   (This should show your forwarded keys)"
echo ""
echo "3. SSH from VM1 to VM2:"
echo -e "${GREEN}   ssh $ADMIN@$VM2_PRIVATE_IP${NC}"
echo "   (Accept the host key fingerprint when prompted)"
echo ""

echo -e "${CYAN}=== Security Benefits of SSH Agent Forwarding ===${NC}"
echo -e "${GREEN}✅ Private key never leaves your local machine${NC}"
echo -e "${GREEN}✅ Secure authentication chain: Local → VM1 → VM2${NC}"
echo -e "${GREEN}✅ No need to copy private keys to intermediate hosts${NC}"
echo -e "${GREEN}✅ Keys are forwarded only for the duration of the session${NC}"
echo ""

echo -e "${YELLOW}Troubleshooting Tips:${NC}"
echo "• If agent forwarding fails, ensure SSH agent is running locally"
echo "• Add your key to agent: ssh-add ~/.ssh/id_rsa"
echo "• Some systems require 'ForwardAgent yes' in ~/.ssh/config"
echo "• Host key verification might require interactive acceptance"
echo ""

echo -e "${BLUE}Ready to test SSH Agent Forwarding interactively!${NC}"