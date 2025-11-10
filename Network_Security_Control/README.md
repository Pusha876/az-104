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

### Part B — Network Security Groups (Coming Next)
*Additional lab steps will be added as we progress through the exercises*

## 🧹 Cleanup

Remember to clean up resources after completing lab exercises to avoid unnecessary charges:
- Delete virtual networks and associated resources
- Remove resource groups when no longer needed
- Verify all network resources are properly removed