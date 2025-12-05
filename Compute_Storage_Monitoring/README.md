# Compute Storage Monitoring Lab

## Ì≥ä 7-Day Learning Path

This lab provides hands-on experience with Azure compute resources, storage solutions, and monitoring best practices across a structured 7-day curriculum.

## Ì≥Å Lab Structure

```
Compute_Storage_Monitoring/
‚îú‚îÄ‚îÄ Day1/     # Virtual Machines & Compute Essentials
‚îú‚îÄ‚îÄ Day2/     # VM Scale Sets & Load Balancing  
‚îú‚îÄ‚îÄ Day3/     # Azure Storage Accounts & Blob Storage
‚îú‚îÄ‚îÄ Day4/     # File Shares & Storage Security
‚îú‚îÄ‚îÄ Day5/     # Azure Monitor & Application Insights
‚îú‚îÄ‚îÄ Day6/     # Log Analytics & Alerting
‚îî‚îÄ‚îÄ Day7/     # Backup & Disaster Recovery
```

## ÌæØ Learning Objectives

By the end of this 7-day lab, you will be able to:

- Deploy and manage Azure Virtual Machines with security best practices
- Configure VM Scale Sets and load balancing for high availability
- Implement secure Azure Storage solutions with proper access controls
- Set up comprehensive monitoring and alerting for Azure resources
- Design backup and disaster recovery strategies

## Ì∫Ä Getting Started

### Prerequisites
- Azure subscription with Contributor access
- Azure CLI installed and configured
- Basic understanding of cloud computing concepts

### Daily Lab Approach
Each day focuses on specific Azure services:

1. **Ì≥ñ Theory Review** - Key concepts and AZ-104 exam topics
2. **Ì∑™ Hands-on Lab** - Practical implementation exercises  
3. **‚úÖ Validation** - Testing and verification steps
4. **Ì≥ù Best Practices** - Production-ready configurations

## Ì≥ã Daily Overview

### Day 1: Virtual Machines & Compute Essentials
- VM SKUs and sizing guidance
- Availability Sets vs Availability Zones
- Managed Identity configuration
- Network Security Groups (NSGs)
- SSH key authentication

### Day 2: VM Scale Sets & Load Balancing
- Auto-scaling configuration
- Load balancer deployment
- Health probes and backend pools
- Custom script extensions

### Day 3: Azure Storage Accounts & Blob Storage
- Storage account types and replication
- Blob storage tiers and lifecycle management
- Access keys vs SAS tokens
- Storage security best practices

### Day 4: File Shares & Storage Security
- Azure Files configuration
- SMB and NFS protocols
- Private endpoints for storage
- Azure AD authentication

### Day 5: Azure Monitor & Application Insights
- Metrics and diagnostic settings
- Application performance monitoring
- Custom dashboards and workbooks
- Performance counters

### Day 6: Log Analytics & Alerting
- Log Analytics workspace setup
- KQL (Kusto Query Language) basics
- Alert rules and action groups
- Notification channels

### Day 7: Backup & Disaster Recovery
- Azure Backup configuration
- Recovery Services Vault
- VM backup policies
- Cross-region replication

## Ì¥ß Common Tools & Commands

### Essential Azure CLI Commands
```bash
# Resource management
az group create --name <rg-name> --location <region>
az resource list --resource-group <rg-name>

# VM operations
az vm create --resource-group <rg> --name <vm-name>
az vm start/stop/restart --resource-group <rg> --name <vm>

# Storage operations
az storage account create --resource-group <rg> --name <storage-account>
az storage blob upload --account-name <account> --container-name <container>

# Monitoring
az monitor metrics list --resource <resource-id>
az monitor log-analytics workspace create --resource-group <rg>
```

## Ì≥ö Additional Resources

- [Azure Documentation](https://docs.microsoft.com/azure/)
- [AZ-104 Exam Guide](https://docs.microsoft.com/learn/certifications/exams/az-104)
- [Azure CLI Reference](https://docs.microsoft.com/cli/azure/)
- [Azure PowerShell Documentation](https://docs.microsoft.com/powershell/azure/)

## Ì≤° Tips for Success

1. **Practice Daily** - Consistent hands-on experience builds muscle memory
2. **Document Your Work** - Keep notes of configurations and troubleshooting
3. **Test Everything** - Always validate your implementations
4. **Clean Up Resources** - Delete resources after labs to avoid charges
5. **Read Error Messages** - Azure provides detailed error information

---

**Start with Day1/** to begin your Azure compute and storage monitoring journey!
