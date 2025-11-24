# Storage, Networking & Identity Integration Lab

## Overview
This lab demonstrates Azure storage security hardening with VNet integration, private endpoints, and identity-based access control.

## Ì≥Å Lab Structure
```
Storage_Networking_&_Identity_Integration/
‚îú‚îÄ‚îÄ variable                     # Configuration variables (gitignored)
‚îú‚îÄ‚îÄ create-storage-account.sh    # Creates secure storage account
‚îú‚îÄ‚îÄ create-vnet.sh              # Creates VNet-App01 with private endpoint subnet
‚îî‚îÄ‚îÄ images/                     # Lab documentation images
```

## Ì∫Ä Quick Start

### 1. Configure Variables
Edit the `variable` file with your subscription and resource details:
```bash
# Example values (update with your info)
SUB_ID="your-subscription-id"
RG="rg-prod-storage" 
STORAGE="prodsa001354"
VNET="VNet-App01"
SUBNET_PE="pe-subnet"
```

### 2. Create Infrastructure
```bash
# Create VNet with private endpoint subnet
./create-vnet.sh

# Create secure storage account
./create-storage-account.sh
```

## ÌæØ Lab Objectives

### Phase 1: Network Foundation
- ‚úÖ Create VNet-App01 (10.100.0.0/16)
- ‚úÖ Create private endpoint subnet
- ‚úÖ Deploy production storage account

### Phase 2: Storage Security Hardening
- Ì¥í Disable public blob access
- Ì¥í Enforce HTTPS and TLS 1.2
- Ì¥í Enable blob versioning and soft delete
- Ì¥í Configure Microsoft Defender for Storage

### Phase 3: Private Connectivity
- Ì¥ó Create private endpoint for blob storage
- Ì¥ó Configure private DNS zone
- Ì¥ó Validate private connectivity

### Phase 4: Identity Integration
- Ì±§ Configure managed identity access
- Ì±§ Set up Azure AD authentication for file shares
- Ì±§ Implement RBAC for developers

## Ì≥ã Manual Configuration Steps

### Storage Account Hardening
1. **Portal ‚Üí Storage Account ‚Üí Networking**
   - Set public access to "Selected networks"
   - Add VNet-App01 to allowed networks

2. **Portal ‚Üí Storage Account ‚Üí Configuration**
   - Minimum TLS version: TLS 1.2
   - Secure transfer required: Enabled
   - Allow shared key access: Disabled (if using Azure AD only)

3. **Portal ‚Üí Storage Account ‚Üí Security**
   - Enable Microsoft Defender for Storage

### Private Endpoint Setup
1. **Portal ‚Üí Storage Account ‚Üí Networking ‚Üí Private endpoints**
   - Create new private endpoint
   - Target subresource: blob
   - VNet: VNet-App01, Subnet: pe-subnet
   - Private DNS integration: Yes

2. **Verify DNS Resolution**
   ```bash
   nslookup [storageaccount].blob.core.windows.net
   # Should resolve to private IP (10.100.x.x)
   ```

### Identity Access Control
1. **Portal ‚Üí Storage Account ‚Üí Containers ‚Üí app-logs ‚Üí Access Control (IAM)**
   - Add role assignment
   - Role: Storage Blob Data Contributor
   - Assign to: Managed Identity (app-service-mi)

2. **Portal ‚Üí Storage Account ‚Üí File shares ‚Üí dev-files ‚Üí Access Control (IAM)**
   - Add role assignment
   - Role: Storage File Data SMB Share Contributor
   - Assign to: Developer group

## ‚úÖ Verification Checklist

### Network Connectivity
- [ ] VNet-App01 created with correct address space
- [ ] Private endpoint subnet configured
- [ ] Private endpoint created and approved
- [ ] DNS resolves storage account to private IP

### Storage Security
- [ ] Public blob access disabled
- [ ] HTTPS-only access enforced
- [ ] TLS 1.2 minimum version set
- [ ] Blob versioning enabled
- [ ] Soft delete configured (7 days)
- [ ] Microsoft Defender enabled

### Identity & Access
- [ ] Managed identity has storage access
- [ ] Azure AD authentication enabled for file shares
- [ ] Developer group has SMB access
- [ ] Account key access disabled/restricted

### Testing
- [ ] Application can write to app-logs container using managed identity
- [ ] Developers can access dev-files share with Azure AD credentials
- [ ] Storage account inaccessible from public internet
- [ ] Private endpoint connectivity working

## Ì¥ß Troubleshooting

### Common Issues
- **DNS not resolving to private IP**: Check private DNS zone linking
- **Access denied errors**: Verify RBAC role assignments
- **Connection timeouts**: Check NSG rules and firewall settings
- **Authentication failures**: Ensure managed identity is configured

### Useful Commands
```bash
# Test DNS resolution
nslookup [storageaccount].blob.core.windows.net

# Check private endpoint status
az network private-endpoint list --resource-group [rg-name]

# Verify role assignments
az role assignment list --assignee [identity-object-id]
```

## Ì≥ö Additional Resources
- [Azure Storage security guide](https://docs.microsoft.com/azure/storage/common/storage-security-guide)
- [Private endpoints for Azure Storage](https://docs.microsoft.com/azure/storage/common/storage-private-endpoints)
- [Azure Storage access control](https://docs.microsoft.com/azure/storage/common/storage-auth)

---
**Lab Goal**: Implement zero-trust storage architecture with private connectivity and identity-based access control.
