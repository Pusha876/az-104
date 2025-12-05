# Day 1: Virtual Machines & Compute Essentials

## Ì≥Å Lab Structure

```
Day1/
‚îî‚îÄ‚îÄ VM_with_Managed_Identity_+_Custom_NSG/
    ‚îú‚îÄ‚îÄ deploy-vm.sh      # Automated VM deployment script
    ‚îî‚îÄ‚îÄ variable          # Configuration variables (gitignored)
```

## ÌæØ Learning Objectives

By the end of Day 1, you will be able to:

- Deploy Azure VMs with security best practices
- Configure Network Security Groups (NSGs) with custom rules
- Enable system-assigned managed identities
- Implement SSH key authentication
- Understand VM SKUs and sizing decisions

## Ì∑™ Hands-On Lab: Secure VM with Managed Identity

### Lab Overview
Deploy a Linux VM with:
- ‚úÖ SSH key authentication (no passwords)
- ‚úÖ System-assigned managed identity
- ‚úÖ Custom NSG restricting SSH to your IP only
- ‚úÖ Standard static public IP
- ‚úÖ Ubuntu LTS with minimal B1s size

## Ì∫Ä Quick Start

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

## Ì≥ã What Gets Created

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

## Ì¥ß Key Concepts

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

## Ì¥ç Validation Steps

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

## Ì∫® Troubleshooting

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

## Ì≥ö Additional Learning

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

**Ìæì AZ-104 Exam Focus**: VM deployment, NSG configuration, managed identities, and SSH authentication are heavily tested topics.
