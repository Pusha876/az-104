# RBAC and Identity Management

This directory contains resources and documentation for Azure Role-Based Access Control (RBAC) and Identity management exercises and troubleshooting.

## Common Tasks

### Creating Role Assignments

Use the Azure CLI to assign roles to users, groups, or service principals:

```bash
az role assignment create --assignee <user-email> --role "<role-name>" --scope <scope>
```

## Troubleshooting

### Issue: MissingSubscription Error with Role Assignments

**Problem:**
When attempting to create role assignments using `az role assignment create`, you may encounter the following error:

```
(MissingSubscription) The request did not have a subscription or a valid tenant level resource provider.
Code: MissingSubscription
Message: The request did not have a subscription or a valid tenant level resource provider.
```

**Symptoms:**
- Azure CLI is properly authenticated (`az account show` works)
- Subscription is active and accessible
- Other Azure operations work normally
- Role assignment commands consistently fail with MissingSubscription error
- Issue occurs at subscription, resource group, and management group levels

**Root Cause:**
This appears to be a known issue with certain Azure CLI versions or specific tenant/subscription configurations where the role assignment commands don't properly inherit the subscription context.

**Workaround:**
Use the Azure REST API directly via the `az rest` command:

1. **Get the user's principal ID:**
   ```bash
   az ad user show --id user@domain.com --query id --output tsv
   ```

2. **Get the role definition ID (optional - you can use role name):**
   ```bash
   az role definition list --name "Role Name" --query "[0].name" --output tsv
   ```

3. **Generate a unique UUID for the role assignment:**
   ```bash
   python -c "import uuid; print(uuid.uuid4())"
   ```
   
   Or use PowerShell:
   ```powershell
   [System.Guid]::NewGuid()
   ```

4. **Create the role assignment using REST API:**
   ```bash
   az rest --method PUT \
     --uri "https://management.azure.com/subscriptions/<subscription-id>/providers/Microsoft.Authorization/roleAssignments/<assignment-uuid>?api-version=2022-04-01" \
     --body "{\"properties\":{\"roleDefinitionId\":\"/subscriptions/<subscription-id>/providers/Microsoft.Authorization/roleDefinitions/<role-definition-id>\",\"principalId\":\"<principal-id>\"}}" \
     --headers "Content-Type=application/json"
   ```

**Examples:**

**Subscription Level Assignment:**
```bash
# Variables
SUBSCRIPTION_ID="b2dd5abd-3642-48b8-929e-2cafb8b4257d"
USER_EMAIL="labuser2@djpusha876gmail.onmicrosoft.com"
ROLE_NAME="Reader and Data Access"

# Get user principal ID
PRINCIPAL_ID=$(az ad user show --id $USER_EMAIL --query id --output tsv)

# Get role definition ID
ROLE_ID=$(az role definition list --name "$ROLE_NAME" --query "[0].name" --output tsv)

# Generate assignment ID
ASSIGNMENT_ID=$(python -c "import uuid; print(uuid.uuid4())")

# Create role assignment at subscription level
az rest --method PUT \
  --uri "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.Authorization/roleAssignments/$ASSIGNMENT_ID?api-version=2022-04-01" \
  --body "{\"properties\":{\"roleDefinitionId\":\"/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.Authorization/roleDefinitions/$ROLE_ID\",\"principalId\":\"$PRINCIPAL_ID\"}}" \
  --headers "Content-Type=application/json"
```

**Resource Group Level Assignment:**
```bash
# Variables
SUBSCRIPTION_ID="b2dd5abd-3642-48b8-929e-2cafb8b4257d"
RESOURCE_GROUP="rg-lab-rbac"
USER_EMAIL="labuser2@djpusha876gmail.onmicrosoft.com"
ROLE_NAME="Virtual Machine Contributor"

# Get user principal ID
PRINCIPAL_ID=$(az ad user show --id $USER_EMAIL --query id --output tsv)

# Get role definition ID
ROLE_ID=$(az role definition list --name "$ROLE_NAME" --query "[0].name" --output tsv)

# Generate assignment ID
ASSIGNMENT_ID=$(python -c "import uuid; print(uuid.uuid4())")

# Create role assignment at resource group level
az rest --method PUT \
  --uri "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Authorization/roleAssignments/$ASSIGNMENT_ID?api-version=2022-04-01" \
  --body "{\"properties\":{\"roleDefinitionId\":\"/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.Authorization/roleDefinitions/$ROLE_ID\",\"principalId\":\"$PRINCIPAL_ID\"}}" \
  --headers "Content-Type=application/json"
```

**Management Group Level Assignment:**
```bash
# Variables
MANAGEMENT_GROUP="Dev-MG-CLI"
USER_EMAIL="labuser2@djpusha876gmail.onmicrosoft.com"
ROLE_NAME="Reader"

# Get user principal ID
PRINCIPAL_ID=$(az ad user show --id $USER_EMAIL --query id --output tsv)

# Get role definition ID
ROLE_ID=$(az role definition list --name "$ROLE_NAME" --query "[0].name" --output tsv)

# Generate assignment ID
ASSIGNMENT_ID=$(python -c "import uuid; print(uuid.uuid4())")

# Create role assignment at management group level
az rest --method PUT \
  --uri "https://management.azure.com/providers/Microsoft.Management/managementGroups/$MANAGEMENT_GROUP/providers/Microsoft.Authorization/roleAssignments/$ASSIGNMENT_ID?api-version=2022-04-01" \
  --body "{\"properties\":{\"roleDefinitionId\":\"/providers/Microsoft.Authorization/roleDefinitions/$ROLE_ID\",\"principalId\":\"$PRINCIPAL_ID\"}}" \
  --headers "Content-Type=application/json"
```

**Multiple Role Assignments (Each role requires a separate command):**
```bash
# Variables
SUBSCRIPTION_ID="b2dd5abd-3642-48b8-929e-2cafb8b4257d"
RESOURCE_GROUP="rg-lab-rbac"
USER_EMAIL="labuser2@djpusha876gmail.onmicrosoft.com"

# Get user principal ID (only needed once)
PRINCIPAL_ID=$(az ad user show --id $USER_EMAIL --query id --output tsv)

# Role 1: Network Contributor
ROLE_1="Network Contributor"
ROLE_ID_1=$(az role definition list --name "$ROLE_1" --query "[0].name" --output tsv)
ASSIGNMENT_ID_1=$(python -c "import uuid; print(uuid.uuid4())")

az rest --method PUT \
  --uri "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Authorization/roleAssignments/$ASSIGNMENT_ID_1?api-version=2022-04-01" \
  --body "{\"properties\":{\"roleDefinitionId\":\"/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.Authorization/roleDefinitions/$ROLE_ID_1\",\"principalId\":\"$PRINCIPAL_ID\"}}" \
  --headers "Content-Type=application/json"

# Role 2: Storage Account Contributor
ROLE_2="Storage Account Contributor"
ROLE_ID_2=$(az role definition list --name "$ROLE_2" --query "[0].name" --output tsv)
ASSIGNMENT_ID_2=$(python -c "import uuid; print(uuid.uuid4())")

az rest --method PUT \
  --uri "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Authorization/roleAssignments/$ASSIGNMENT_ID_2?api-version=2022-04-01" \
  --body "{\"properties\":{\"roleDefinitionId\":\"/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.Authorization/roleDefinitions/$ROLE_ID_2\",\"principalId\":\"$PRINCIPAL_ID\"}}" \
  --headers "Content-Type=application/json"
```

**Verification:**
After creating the role assignment, verify it was successful:

```bash
# List role assignments for the user at subscription level
az rest --method GET \
  --uri "https://management.azure.com/subscriptions/<subscription-id>/providers/Microsoft.Authorization/roleAssignments?api-version=2022-04-01&\$filter=principalId eq '<principal-id>'"

# List role assignments for the user at resource group level
az rest --method GET \
  --uri "https://management.azure.com/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Authorization/roleAssignments?api-version=2022-04-01&\$filter=principalId eq '<principal-id>'"

# List role assignments for the user at management group level
az rest --method GET \
  --uri "https://management.azure.com/providers/Microsoft.Management/managementGroups/<management-group>/providers/Microsoft.Authorization/roleAssignments?api-version=2022-04-01&\$filter=principalId eq '<principal-id>'"
```

**Alternative Solutions to Try First:**
1. Clear Azure CLI cache and re-authenticate:
   ```bash
   az account clear && az login
   ```

2. Explicitly specify the subscription:
   ```bash
   az role assignment create --assignee <user> --role "<role>" --scope <scope> --subscription <subscription-id>
   ```

3. Use the role definition ID instead of role name:
   ```bash
   az role assignment create --assignee <user> --role <role-definition-id> --scope <scope>
   ```

## Notes

- The REST API workaround is reliable and works consistently when the standard CLI commands fail
- Always use unique UUIDs for role assignment IDs to avoid conflicts
- The role assignment takes effect immediately after creation
- Document any custom role assignments for future reference and compliance auditing
- **Multiple Role Assignments**: Azure CLI does not support assigning multiple roles in a single command (comma-separated roles don't work). You must create separate role assignments for each role
- **Common Syntax Errors**: 
  - Remove extra `$` symbols from command lines
  - Ensure role names are spelled correctly (e.g., "Network Contributor" not "Network Contibutor")
  - Each role requires a separate `az role assignment create` command or REST API call

## Resources

- [Azure RBAC Documentation](https://docs.microsoft.com/en-us/azure/role-based-access-control/)
- [Azure CLI Role Assignment Reference](https://docs.microsoft.com/en-us/cli/azure/role/assignment)
- [Azure REST API - Role Assignments](https://docs.microsoft.com/en-us/rest/api/authorization/role-assignments)