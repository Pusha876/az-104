# Azure Resource Lock Lab

This lab demonstrates how to create and manage Azure resource locks to prevent accidental deletion or modification of critical resources.

## Scripts Overview

### 1. `resource-lock-lab.sh` (Basic)
- Creates resource group and storage account
- Basic script with the variables you requested

### 2. `resource-lock-lab-advanced.sh` (Recommended)
- Creates resource group and storage account
- Applies ReadOnly lock to resource group
- Applies CanNotDelete lock to storage account
- Includes error checking and colored output
- Lists all applied locks

### 3. `cleanup-resource-lock-lab.sh`
- Removes all applied locks
- Safely deletes the resource group and resources
- Includes confirmation prompt

## Prerequisites

- Azure CLI installed and configured
- Valid Azure subscription
- Appropriate permissions to create resources and locks

## Usage

### Step 1: Update Variables
Edit the scripts and replace the placeholder values:

```bash
SUB_ID="your-subscription-id-here"
RG="rg-lock-lab"
LOC="eastus"
SA="locklabstorage$(date +%s)"
```

### Step 2: Make Scripts Executable
```bash
chmod +x resource-lock-lab.sh
chmod +x resource-lock-lab-advanced.sh
chmod +x cleanup-resource-lock-lab.sh
```

### Step 3: Run the Lab
```bash
# Run the advanced version (recommended)
./resource-lock-lab-advanced.sh

# Or run the basic version
./resource-lock-lab.sh
```

### Step 4: Experiment with Locks
Try to:
- Modify resources (should be blocked by ReadOnly lock)
- Delete the storage account (should be blocked by CanNotDelete lock)
- Delete the resource group (should be blocked by locks)

### Step 5: Clean Up
```bash
./cleanup-resource-lock-lab.sh
```

## Lock Types

### ReadOnly Lock
- Prevents users from modifying resources
- Users can still read resources
- Applied at resource group level affects all resources within

### CanNotDelete Lock
- Prevents users from deleting resources
- Users can still modify resources
- Applied at resource level affects only that specific resource

## Key Learning Points

1. **Lock Inheritance**: Locks applied at higher scopes (resource group) affect all resources within
2. **Lock Removal**: Locks must be removed before resources can be deleted
3. **Lock Hierarchy**: You need appropriate permissions to create/remove locks
4. **Best Practices**: Use locks on critical production resources to prevent accidental changes

## Troubleshooting

If you encounter permission issues:
- Ensure you have `Owner` or `User Access Administrator` role 
- Check that your account has lock management permissions

If cleanup fails:
- Manually remove locks in Azure Portal
- Try running cleanup script again

## Related Azure CLI Commands

```bash
# List all locks in a resource group
az lock list --resource-group <resource-group-name>

# Create a ReadOnly lock
az lock create --name <lock-name> --lock-type ReadOnly --resource-group <rg-name>

# Create a CanNotDelete lock on specific resource
az lock create --name <lock-name> --lock-type CanNotDelete --resource-group <rg-name> --resource-name <resource-name> --resource-type <resource-type>

# Delete a lock
az lock delete --name <lock-name> --resource-group <rg-name>
```