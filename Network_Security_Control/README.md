# Network Security Control Lab

This lab focuses on implementing and managing Azure network security controls, including virtual networks, subnets, network security groups (NSGs), and network connectivity scenarios.

## 📁 Lab Structure

### Configuration Files

- **`variable`** - Template file with network configuration variables (safe for git)
- **`config`** - Personal configuration file with actual subscription ID (ignored by git)
- **Scripts** - Various lab scripts for network security scenarios

## 🔧 Configuration Setup

**IMPORTANT**: Before running any scripts in this lab, set up your configuration:

1. The `config` file contains your actual subscription ID and network settings
2. The `variable` file serves as a template reference
3. The `config` file is automatically ignored by git for security

## 🌐 Network Architecture

This lab creates the following network topology:

### Virtual Networks
- **vnet-a** (10.0.0.0/16) in Resource Group `rg-net-a`
  - subnet-a1 (10.0.1.0/24)
  - subnet-a2 (10.0.2.0/24)
- **vnet-b** (10.1.0.0/16) in Resource Group `rg-net-b`
  - subnet-b1 (10.1.1.0/24)

### Network Security Scenarios
This lab covers:
- Virtual Network creation and configuration
- Subnet segmentation and addressing
- Network Security Groups (NSGs) implementation
- Virtual Network Peering
- Network connectivity and routing
- Security rules and access control

## 🎯 Learning Objectives

- Understand Azure virtual networking concepts
- Implement network segmentation strategies
- Configure network security groups and rules
- Establish secure network connectivity
- Troubleshoot network connectivity issues
- Apply network security best practices

## 📋 Prerequisites

- Azure CLI installed and configured
- Valid Azure subscription with network permissions
- Understanding of IP addressing and subnetting
- Basic knowledge of network security concepts

## 🔒 Security Notes

- The `config` file contains sensitive subscription information
- Never commit the `config` file to version control
- Use the `variable` file as a reference template
- Follow principle of least privilege for network access

## 🚀 Getting Started

1. Ensure your `config` file is properly set up with your subscription ID
2. Review the network topology and addressing scheme
3. Run lab scripts in the recommended order
4. Monitor resources and costs during lab exercises

## 📚 Lab Walkthrough

Follow these steps to work through the Network Security Control lab properly:

### Part A — Create Resource Groups & Virtual Networks

#### Option 1: Azure Portal (Quick Setup)

**Step 1: Create Resource Groups**
1. Navigate to Azure Portal → Resource Groups
2. Create first resource group:
   - Name: `rg-net-a`
   - Region: `East US`
3. Create second resource group:
   - Name: `rg-net-b`
   - Region: `East US`

**Step 2: Create Virtual Network A**
In resource group `rg-net-a`, create VNet `vnet-a`:
- **Name**: `vnet-a`
- **Address range**: `10.0.0.0/16`
- **Subnets**:
  - **subnet-a1**: `10.0.1.0/24`
  - **subnet-a2**: `10.0.2.0/24`

**Step 3: Create Virtual Network B**
In resource group `rg-net-b`, create VNet `vnet-b` (for peering later):
- **Name**: `vnet-b`
- **Address range**: `10.1.0.0/16`
- **Subnets**:
  - **subnet-b1**: `10.1.1.0/24`

#### Option 2: Azure CLI (Automated)

```bash
# Load configuration
source config

# Create resource groups
az group create --name $RG1 --location $LOC
az group create --name $RG2 --location $LOC

# Create VNet A with two subnets
az network vnet create \
  --resource-group $RG1 \
  --name $VNET1 \
  --address-prefixes 10.0.0.0/16 \
  --subnet-name $VNET1_SUB1 \
  --subnet-prefixes 10.0.1.0/24

az network vnet subnet create \
  --resource-group $RG1 \
  --vnet-name $VNET1 \
  --name $VNET1_SUB2 \
  --address-prefixes 10.0.2.0/24

# Create VNet B with one subnet
az network vnet create \
  --resource-group $RG2 \
  --name $VNET2 \
  --address-prefixes 10.1.0.0/16 \
  --subnet-name $VNET2_SUB1 \
  --subnet-prefixes 10.1.1.0/24
```

**Verification Commands:**
```bash
# List all resource groups
az group list --query "[?starts_with(name, 'rg-net')].{Name:name, Location:location}" --output table

# Verify VNet A
az network vnet show --resource-group $RG1 --name $VNET1 --query "{Name:name, AddressSpace:addressSpace.addressPrefixes}" --output table
az network vnet subnet list --resource-group $RG1 --vnet-name $VNET1 --query "[].{Name:name, AddressPrefix:addressPrefix}" --output table

# Verify VNet B
az network vnet show --resource-group $RG2 --name $VNET2 --query "{Name:name, AddressSpace:addressSpace.addressPrefixes}" --output table
az network vnet subnet list --resource-group $RG2 --vnet-name $VNET2 --query "[].{Name:name, AddressPrefix:addressPrefix}" --output table
```

### Part B — Network Security Groups (NSGs)

Configure Network Security Groups to control traffic between VMs and subnets.

#### Prerequisites for Part B
- Part A completed (resource groups, VNets, and VMs created)
- Both VMs (vm-net-a and vm-net-b) are running

#### NSG Configuration Steps

**Step 1: Create Network Security Groups**
Create separate NSGs for each subnet to demonstrate granular control:
- **nsg-subnet-a1** - For subnet-a1 (where vm-net-a resides)
- **nsg-subnet-a2** - For subnet-a2 (where vm-net-b resides)

**Step 2: Configure Security Rules**
- **Allow SSH** from Internet to subnet-a1 (management access)
- **Allow ICMP** within VNet (for ping testing)
- **Block HTTP** from subnet-a1 to subnet-a2 (demonstration rule)
- **Allow SSH** between subnets (for inter-VM management)

**Step 3: Associate NSGs with Subnets**
Link each NSG to its respective subnet to enforce the rules.

#### Option 1: Automated Script
```bash
# Run the automated Part B script
./part-b-create-nsgs.sh
```

#### Option 2: Manual Azure CLI Commands
```bash
# Load configuration
source config

# Create NSGs
az network nsg create --resource-group $RG1 --name nsg-subnet-a1 --location $LOC
az network nsg create --resource-group $RG1 --name nsg-subnet-a2 --location $LOC

# Create security rules (examples)
az network nsg rule create \
  --resource-group $RG1 \
  --nsg-name nsg-subnet-a1 \
  --name "Allow-SSH-Internet" \
  --priority 1000 \
  --source-address-prefixes Internet \
  --destination-port-ranges 22 \
  --access Allow \
  --protocol Tcp

# Associate NSGs with subnets
az network vnet subnet update \
  --resource-group $RG1 \
  --vnet-name $VNET1 \
  --name $VNET1_SUB1 \
  --network-security-group nsg-subnet-a1
```

#### Testing Network Security
After Part B completion, test the following connectivity scenarios:

1. **SSH to VM1** (should work - SSH allowed from Internet)
2. **Ping between VMs** (should work - ICMP allowed within VNet)  
3. **SSH from VM1 to VM2** (should work - SSH allowed between subnets)
4. **HTTP from VM1 to VM2** (should be blocked - HTTP denied by custom rule)

### Part C — VNet Peering 

Implement Virtual Network Peering to enable communication between separate VNets.

#### Prerequisites for Part C
- Parts A and B completed (VNet A with VMs and NSGs configured)
- Understanding of VNet address spaces and routing

#### VNet Peering Architecture

**Before Part C:**
- VNet A (10.0.0.0/16) with 2 VMs in different subnets
- VNet B exists but may need reconfiguration

**After Part C:**
- VNet A (10.0.0.0/16) ←→ VNet B (10.1.0.0/16)
- Bidirectional peering connection
- VM3 deployed in VNet B for cross-VNet testing
- NSG rules updated for inter-VNet communication

#### Implementation Steps

**Step 1: VNet B Configuration**
- Ensure VNet B has correct address space (10.1.0.0/16)
- Create subnet-b1 (10.1.1.0/24)
- Deploy VM3 for testing cross-VNet connectivity

**Step 2: Network Security Groups**
- Create NSG for VNet B subnet
- Configure rules to allow communication from VNet A
- Maintain security while enabling cross-VNet traffic

**Step 3: VNet Peering Setup**
- Create bidirectional peering: VNet A ←→ VNet B
- Configure peering settings (allow VNet access, forwarded traffic)
- Verify peering state is "Connected"

#### Option 1: Automated Script
```bash
# Run the automated Part C script
./part-c-vnet-peering.sh
```

#### Option 2: Manual Azure CLI Commands
```bash
# Load configuration
source config

# Create VNet peering from A to B
az network vnet peering create \
  --name peer-vnet-a-to-vnet-b \
  --resource-group $RG1 \
  --vnet-name $VNET1 \
  --remote-vnet $VNET2 \
  --allow-vnet-access \
  --allow-forwarded-traffic

# Create VNet peering from B to A
az network vnet peering create \
  --name peer-vnet-b-to-vnet-a \
  --resource-group $RG2 \
  --vnet-name $VNET2 \
  --remote-vnet "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG1/providers/Microsoft.Network/virtualNetworks/$VNET1" \
  --allow-vnet-access \
  --allow-forwarded-traffic
```

#### Testing Cross-VNet Connectivity

After Part C completion, test these scenarios:

1. **Cross-VNet Ping** - VM1/VM2 → VM3 (should work with peering)
2. **Cross-VNet SSH** - SSH from VNet A VMs to VNet B VM using private IPs
3. **Route Verification** - Check effective routes show peered network paths
4. **NSG Rule Testing** - Verify traffic flows through configured security rules

#### Network Topology After Part C
```
┌─────────────────┐    Peering    ┌─────────────────┐
│ VNet A          │ ←─────────→   │ VNet B          │
│ 10.0.0.0/16     │               │ 10.1.0.0/16     │
│                 │               │                 │
│ ┌─────────────┐ │               │ ┌─────────────┐ │
│ │ subnet-a1   │ │               │ │ subnet-b1   │ │
│ │ 10.0.1.0/24 │ │               │ │ 10.1.1.0/24 │ │
│ │   vm-net-a  │ │               │ │   vm-net-c  │ │
│ └─────────────┘ │               │ └─────────────┘ │
│                 │               │                 │
│ ┌─────────────┐ │               │                 │
│ │ subnet-a2   │ │               │                 │
│ │ 10.0.2.0/24 │ │               │                 │
│ │   vm-net-b  │ │               │                 │
│ └─────────────┘ │               │                 │
└─────────────────┘               └─────────────────┘
```

### Part D — Advanced Scenarios (Future)
*Traffic analysis, custom routing, and network monitoring*

## 🧹 Cleanup

Remember to clean up resources after completing lab exercises to avoid unnecessary charges:
- Delete virtual networks and associated resources
- Remove resource groups when no longer needed
- Verify all network resources are properly removed