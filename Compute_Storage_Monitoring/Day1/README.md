# Day 1: Virtual Machines & Compute Essentials

## ��� Lab Structure

```
Day1/
└── VM_with_Managed_Identity_+_Custom_NSG/
    ├── deploy-vm.sh      # Automated VM deployment script
    └── variable          # Configuration variables (gitignored)
```

## ��� Learning Objectives

By the end of Day 1, you will be able to:

- Deploy Azure VMs with security best practices
- Configure Network Security Groups (NSGs) with custom rules
- Enable system-assigned managed identities
- Implement SSH key authentication
- Understand VM SKUs and sizing decisions

## ��� Hands-On Lab: Secure VM with Managed Identity

### Lab Overview
Deploy a Linux VM with:
- ✅ SSH key authentication (no passwords)
- ✅ System-assigned managed identity
- ✅ Custom NSG restricting SSH to your IP only
- ✅ Standard static public IP
- ✅ Ubuntu LTS with minimal B1s size

## ��� Quick Start

### Prerequisites
```bash
# Get your public IP first
curl ifconfig.me
# Record this IP for the variable file
```

### 1. Configure Variables
Navigate to the lab directory and set up your configuration:
```bash
cd VM_with_Managed_Identity_+_Custom_NSG/
# Edit the variable file with your settings
```

### 2. Run Deployment
```bash
# Deploy the entire infrastructure
./deploy-vm.sh

# Connect to your VM (command shown in script output)
ssh -i ~/.ssh/id_rsa azureuser@[VM-PUBLIC-IP]
```

### 3. Clean Up Resources
```bash
# Delete the resource group and all resources
az group delete --name [resource-group] --yes --no-wait
```

## ��� What Gets Created

### Infrastructure Components
1. **Resource Group** - Container for all resources
2. **Virtual Network** - 10.0.0.0/16 address space
3. **Subnet** - 10.0.0.0/24 for VM placement
4. **Network Security Group** - Custom firewall rules
5. **Public IP** - Static Standard SKU
6. **Network Interface** - Connects VM to network
7. **Virtual Machine** - Ubuntu LTS with B1s size

### Security Configuration
- **SSH Access**: Restricted to your public IP only
- **Explicit Deny**: All other inbound traffic blocked
- **Managed Identity**: System-assigned for Azure service access
- **SSH Keys**: Password authentication disabled

## ��� Key Concepts

### VM SKUs Quick Reference
| SKU Series | Purpose | Example Use Cases |
|------------|---------|-------------------|
| B-series | Burstable, low-cost | Dev/test, small applications |
| D-series | General purpose | Web servers, app servers |
| E-series | Memory optimized | Databases, Redis, caching |
| F-series | Compute optimized | Batch processing, analytics |

### Availability Options
- **Availability Sets**: 99.95% SLA, fault/update domains
- **Availability Zones**: 99.99% SLA, physical datacenters
- **Single VM**: 99.9% SLA with premium storage

### Managed Identity Benefits
- No credential management in code
- Automatic Azure AD token handling
- Access to Key Vault, Storage, SQL Database
- Eliminates secret rotation requirements

## ��� Validation Steps

### 1. Verify VM Status
```bash
az vm show -g [resource-group] -n [vm-name] --query "provisioningState"
```

### 2. Check Managed Identity
```bash
az vm identity show -g [resource-group] -n [vm-name]
```

### 3. Review NSG Rules
```bash
az network nsg rule list -g [resource-group] --nsg-name [nsg-name] -o table
```

### 4. Test SSH Connection
```bash
ssh -i ~/.ssh/id_rsa azureuser@[vm-public-ip]
```

## 🔍 Get VM Public IP Address
```bash
# Get the public IP of your VM
az vm list-ip-addresses --resource-group rg-vm-app01 --output table

# Or get just the IP address
az vm list-ip-addresses --resource-group rg-vm-app01 --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" --output tsv
```

## 🔐 SSH Connection Commands

### Method 1: Using your PEM key
```bash
# Set correct permissions for the key file
chmod 600 rg-vm-app01_key.pem

# SSH to the VM (replace [PUBLIC-IP] with actual IP)
ssh -i rg-vm-app01_key.pem azureuser@[PUBLIC-IP]
```

### Method 2: One-liner with automatic IP lookup
```bash
# Get IP and connect in one command
PUBLIC_IP=$(az vm list-ip-addresses --resource-group rg-vm-app01 --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" --output tsv) && ssh -i rg-vm-app01_key.pem azureuser@$PUBLIC_IP
```

## 🚨 Troubleshooting

### If connection fails:
```bash
# Check if VM is running
az vm get-instance-view --resource-group rg-vm-app01 --name [VM-NAME] --query instanceView.statuses[1] --output table

# Verify NSG rules allow your current IP
curl ifconfig.me  # Check your current public IP
az network nsg rule show --resource-group rg-vm-app01 --nsg-name [NSG-NAME] --name Allow-SSH-From-MyIP
```

**Note**: Make sure your `rg-vm-app01_key.pem` file is in the current directory, or provide the full path to the key file.

### Common Issues
- **SSH Connection Refused**: Check NSG rules and your current public IP
- **Key Permission Denied**: Ensure SSH key has correct permissions (600)
- **VM Creation Failed**: Verify quota availability in the region
- **IP Address Changed**: Update NSG rule if your public IP changed

### Useful Commands
```bash
# Get your current public IP
curl ifconfig.me

# Check VM power state
az vm get-instance-view -g [rg] -n [vm] --query "instanceView.statuses[1].displayStatus"

# View effective NSG rules
az network nic list-effective-nsg -g [rg] -n [nic-name]

# Monitor VM metrics
az monitor metrics list --resource [vm-resource-id] --metric "Percentage CPU"
```

## ��� Additional Learning

### Related Azure Services
- **Azure Bastion**: Secure RDP/SSH without public IPs
- **VM Scale Sets**: Auto-scaling VM groups
- **Azure Security Center**: Security posture management
- **Log Analytics**: Centralized logging and monitoring

### Next Steps
- Explore VM extensions for automated configuration
- Learn about custom VM images and templates
- Practice with different VM sizes and configurations
- Implement VM backup and disaster recovery

---

**��� AZ-104 Exam Focus**: VM deployment, NSG configuration, managed identities, and SSH authentication are heavily tested topics.
