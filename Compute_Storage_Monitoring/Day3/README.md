# Day 3: Monitoring and Alerts Lab

This lab demonstrates Azure VM monitoring and alerting capabilities using Azure Monitor and Log Analytics.

## 📋 Lab Overview

- **VM Setup**: Deploy VM with web server for monitoring
- **Custom Script Extension**: Install and configure Nginx
- **Network Configuration**: Configure NSG rules for web traffic
- **Monitoring Setup**: Azure Monitor and alerting configuration

## 🚀 Initial VM Setup and Configuration

### 1. Configure Variables
First, set up your environment variables by editing the `variable` file in the `Monitoring_and_Alerts` directory:

```bash
cd Monitoring_and_Alerts/
# Edit the variable file with your specific values
source ./variable
```

### 2. Install Web Server via Custom Script Extension

Remove any existing custom script extensions and install a fresh one:

```bash
# Remove existing extension (if any)
az vm extension delete --resource-group $RG --vm-name $VM_NAME --name customScript

# Install nginx via custom script extension
az vm extension set \
  --resource-group $RG \
  --vm-name $VM_NAME \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --version 2.1 \
  --settings '{"commandToExecute":"sudo apt update -y && sudo apt install nginx -y && sudo systemctl enable nginx && sudo systemctl start nginx && echo \"<h1>VM: vm-week3day1</h1><p>Nginx is running on $(hostname)</p>\" | sudo tee /var/www/html/index.html"}'
```

### 3. Configure Network Security Group (NSG)

Allow HTTP traffic to access the web server:

```bash
# Find the NSG associated with your VM
NSG_NAME=$(az network nsg list -g $RG --query "[0].name" -o tsv)
echo "Found NSG: $NSG_NAME"

# Add HTTP rule to allow web traffic
az network nsg rule create \
  -g $RG \
  --nsg-name $NSG_NAME \
  -n Allow-HTTP \
  --priority 1001 \
  --source-address-prefixes '*' \
  --destination-port-ranges 80 \
  --access Allow \
  --protocol Tcp \
  --description "Allow HTTP traffic"
```

### 4. Test Web Server Access

Verify the web server is accessible:

```bash
# Get VM public IP
VM_PUBLIC_IP=$(az vm show -d -g $RG -n $VM_NAME --query "publicIps" -o tsv)
echo "VM Public IP: $VM_PUBLIC_IP"

# Test web server
curl -s http://$VM_PUBLIC_IP
```

Expected output:
```html
<h1>VM: vm-week3day1</h1><p>Nginx is running on vm-week3day1</p>
```

### 5. SSH Access to VM

Connect to your VM using the SSH key:

```bash
# Navigate to the key directory
cd Monitoring_and_Alerts/

# Set proper permissions on SSH key
chmod 600 vm-week3day1_key.pem

# SSH to the VM
ssh -i vm-week3day1_key.pem azureuser@$VM_PUBLIC_IP
```

## 🔧 Troubleshooting

### Custom Script Extension Issues
- **Conflict Error**: If you get a configuration conflict, delete the existing extension first
- **Provisioning Failed**: Check the extension status with:
  ```bash
  az vm extension show --resource-group $RG --vm-name $VM_NAME --name customScript
  ```

### Network Connectivity Issues
- **Web Server Not Accessible**: Ensure NSG rules allow HTTP traffic on port 80
- **SSH Connection Timeout**: Check your internet connection and NSG rules for SSH (port 22)

### Variable File Errors
- **Syntax Errors**: Ensure all variables have valid values without angle brackets `< >`
- **Missing Variables**: Make sure to source the variable file: `source ./variable`

## 📊 Next Steps

Once the basic VM setup is complete, proceed to:
1. Configure Azure Monitor for VM insights
2. Set up Log Analytics workspace
3. Create custom alerts and action groups
4. Monitor VM performance and availability

## 🧹 Cleanup

When finished with the lab:
```bash
az group delete --name $RG --yes --no-wait
```