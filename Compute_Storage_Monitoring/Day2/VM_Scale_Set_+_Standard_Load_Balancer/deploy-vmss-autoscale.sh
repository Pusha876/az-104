#!/bin/bash

# VM Scale Set with Autoscale Deployment Script
# This script creates a VM Scale Set with Standard Load Balancer and configures autoscaling

# Load variables from the variable file
source ./variable

echo "=== Azure VM Scale Set with Autoscale Deployment ==="
echo "Subscription: $SUB_ID"
echo "Resource Group: $RG"
echo "Location: $LOC"
echo "VM Scale Set: $VMSS"
echo "Load Balancer: $LB"
echo "Instance Count: $INSTANCE_COUNT"
echo ""

# Set the subscription context
echo "Setting subscription context..."
az account set --subscription "$SUB_ID"
if [ $? -eq 0 ]; then
    echo "✓ Subscription set successfully"
else
    echo "✗ Failed to set subscription"
    exit 1
fi

# 1) Create resource group
echo ""
echo "Creating resource group..."
az group create --name $RG --location $LOC --subscription $SUB_ID

if [ $? -eq 0 ]; then
    echo "✓ Resource group '$RG' created successfully"
else
    echo "✗ Failed to create resource group"
    exit 1
fi

# 2) Create VM Scale Set with Standard Load Balancer
echo ""
echo "Creating VM Scale Set with Standard Load Balancer..."
az vmss create \
  -g $RG \
  -n $VMSS \
  --image Ubuntu2204 \
  --vm-sku $VM_SIZE \
  --upgrade-policy-mode manual \
  --admin-username $ADMIN \
  --ssh-key-values @$SSH_PUB_KEY_PATH \
  --lb $LB \
  --backend-pool-name bepool-app \
  --instance-count $INSTANCE_COUNT \
  --location $LOC \
  --public-ip-address-allocation static \
  --public-ip-address-dns-name "${VMSS}-dns"

if [ $? -eq 0 ]; then
    echo "✓ VM Scale Set '$VMSS' created successfully"
else
    echo "✗ Failed to create VM Scale Set"
    exit 1
fi

# 3) Configure Network Security Group rules for web traffic
echo ""
echo "Adding NSG rules for web traffic..."
# Allow HTTP traffic
az network nsg rule create \
  -g $RG \
  --nsg-name "${VMSS}NSG" \
  -n Allow-HTTP \
  --priority 1001 \
  --source-address-prefixes '*' \
  --destination-port-ranges 80 \
  --access Allow \
  --protocol Tcp \
  --description "Allow HTTP traffic"

# Allow HTTPS traffic
az network nsg rule create \
  -g $RG \
  --nsg-name "${VMSS}NSG" \
  -n Allow-HTTPS \
  --priority 1002 \
  --source-address-prefixes '*' \
  --destination-port-ranges 443 \
  --access Allow \
  --protocol Tcp \
  --description "Allow HTTPS traffic"

if [ $? -eq 0 ]; then
    echo "✓ NSG rules for web traffic added successfully"
else
    echo "⚠ Warning: Failed to add NSG rules, continuing..."
fi

# 4) Create autoscale configuration
echo ""
echo "Creating autoscale configuration..."
az monitor autoscale create \
  -g $RG \
  -n autoscale-$VMSS \
  --resource $VMSS \
  --resource-group $RG \
  --resource-type Microsoft.Compute/virtualMachineScaleSets \
  --min-count 1 \
  --max-count 5 \
  --count $INSTANCE_COUNT

if [ $? -eq 0 ]; then
    echo "✓ Autoscale configuration created successfully"
else
    echo "✗ Failed to create autoscale configuration"
    exit 1
fi

# 5) Add scale-out rule (CPU > 70%)
echo ""
echo "Adding scale-out rule (CPU > 70%)..."
az monitor autoscale rule create \
  -g $RG \
  --autoscale-name autoscale-$VMSS \
  --scale out 1 \
  --condition "Percentage CPU > 70 avg 5m" \
  --cooldown 5

if [ $? -eq 0 ]; then
    echo "✓ Scale-out rule added successfully"
else
    echo "✗ Failed to add scale-out rule"
    exit 1
fi

# 6) Add scale-in rule (CPU < 30%)
echo ""
echo "Adding scale-in rule (CPU < 30%)..."
az monitor autoscale rule create \
  -g $RG \
  --autoscale-name autoscale-$VMSS \
  --scale in 1 \
  --condition "Percentage CPU < 30 avg 5m" \
  --cooldown 5

if [ $? -eq 0 ]; then
    echo "✓ Scale-in rule added successfully"
else
    echo "✗ Failed to add scale-in rule"
    exit 1
fi

# 7) Add load balancer probe and rule for HTTP traffic
echo ""
echo "Configuring load balancer for web traffic..."
# Create health probe
az network lb probe create \
  -g $RG \
  --lb-name $LB \
  -n http-probe \
  --protocol Http \
  --port 80 \
  --path "/"

# Create load balancing rule
az network lb rule create \
  -g $RG \
  --lb-name $LB \
  -n http-rule \
  --protocol Tcp \
  --frontend-port 80 \
  --backend-port 80 \
  --frontend-ip-name LoadBalancerFrontEnd \
  --backend-pool-name bepool-app \
  --probe-name http-probe

if [ $? -eq 0 ]; then
    echo "✓ Load balancer configured for HTTP traffic"
else
    echo "⚠ Warning: Failed to configure load balancer rules, continuing..."
fi

# 8) Install web server on instances (via custom script extension)
echo ""
echo "Installing web server on VM instances..."
az vmss extension set \
  -g $RG \
  --vmss-name $VMSS \
  -n customScript \
  --publisher Microsoft.Azure.Extensions \
  --version 2.0 \
  --settings '{
    "commandToExecute": "sudo apt-get update && sudo apt-get install -y nginx && sudo systemctl start nginx && sudo systemctl enable nginx && echo \"<h1>VM Scale Set Instance: $(hostname)</h1><p>Server: $(hostname -I)</p>\" | sudo tee /var/www/html/index.html"
  }'

if [ $? -eq 0 ]; then
    echo "✓ Web server installed on VM instances"
else
    echo "⚠ Warning: Failed to install web server, continuing..."
fi

# 9) Get deployment summary
echo ""
echo "=== Deployment Summary ==="

# Get public IP
PUBLIC_IP=$(az network public-ip show -g $RG -n "${LB}PublicIP" --query "ipAddress" -o tsv 2>/dev/null)
DNS_NAME=$(az network public-ip show -g $RG -n "${LB}PublicIP" --query "dnsSettings.fqdn" -o tsv 2>/dev/null)

echo "Load Balancer Public IP: $PUBLIC_IP"
echo "DNS Name: $DNS_NAME"

# Get autoscale settings
echo ""
echo "Autoscale Configuration:"
az monitor autoscale show -g $RG -n autoscale-$VMSS --query "{Enabled:enabled, MinCount:profiles[0].capacity.minimum, MaxCount:profiles[0].capacity.maximum, DefaultCount:profiles[0].capacity.default, Rules:length(profiles[0].rules)}" -o table

echo ""
echo "Scaling Rules:"
az monitor autoscale rule list -g $RG --autoscale-name autoscale-$VMSS --query "[].{Direction:scaleAction.direction, Threshold:metricTrigger.threshold, Operator:metricTrigger.operator, Metric:metricTrigger.metricName, TimeWindow:metricTrigger.timeWindow, Cooldown:scaleAction.cooldown}" -o table

# Get current instances
echo ""
echo "Current VM Instances:"
az vmss list-instances -g $RG -n $VMSS --output table

echo ""
echo "=== Deployment Complete! ==="
echo "✓ Resource Group: $RG"
echo "✓ VM Scale Set: $VMSS"
echo "✓ Load Balancer: $LB"
echo "✓ Autoscale: autoscale-$VMSS"
echo "✓ Instance Range: 1-5 VMs (currently $INSTANCE_COUNT)"
echo "✓ Web Server: Nginx installed on all instances"
echo ""
echo "🌐 Test URLs:"
echo "HTTP: http://$PUBLIC_IP"
if [ ! -z "$DNS_NAME" ]; then
    echo "DNS:  http://$DNS_NAME"
fi
echo ""
echo "🔥 Generate Load (to test autoscaling):"
echo "for i in {1..100}; do curl -s http://$PUBLIC_IP > /dev/null & done"
echo ""
echo "📊 Monitor Scaling:"
echo "watch 'az vmss list-instances -g $RG -n $VMSS --output table'"
echo ""
echo "🧹 Cleanup Command:"
echo "az group delete --name $RG --yes --no-wait"