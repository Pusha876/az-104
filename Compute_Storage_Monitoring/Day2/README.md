# VM Scale Set with Autoscale Lab

This lab demonstrates how to create and configure an Azure VM Scale Set with automatic scaling based on CPU utilization.

## 📋 Lab Overview

- **VM Scale Set**: 2-5 Ubuntu instances with Standard Load Balancer
- **Autoscaling**: Scale out when CPU > 70%, scale in when CPU < 30%
- **Web Server**: Nginx installed on all instances for testing
- **Load Testing**: Automated script to generate load and trigger scaling

## 🚀 Quick Start

### 1. Configure Variables
Copy and edit the variable template:
```bash
cp variable.template variable
# Edit variable file with your subscription ID and IP address
```

### 2. Deploy VM Scale Set
Run the main deployment script:
```bash
./deploy-vmss-autoscale.sh
```

This will create:
- Resource Group
- VM Scale Set (2 instances initially)
- Standard Load Balancer with public IP
- Autoscale configuration with CPU-based rules
- Network Security Group with web traffic rules
- Nginx web server on all instances

### 3. Test Autoscaling
Generate load to trigger scaling:
```bash
./test-autoscale.sh
```

This script will:
- Generate HTTP load to increase CPU usage
- Monitor instance count changes
- Show autoscale activities
- Display CPU metrics

## 🔧 Manual Commands

### Check Current Status
```bash
# View current instances
az vmss list-instances -g rg-vmss-lb01 -n vmss-web01 --output table

# Check autoscale configuration
az monitor autoscale show -g rg-vmss-lb01 -n autoscale-vmss-web01

# View scaling rules
az monitor autoscale rule list -g rg-vmss-lb01 --autoscale-name autoscale-vmss-web01 --output table
```

### Monitor Scaling Activity
```bash
# Watch instances (auto-refresh every 2 seconds)
watch 'az vmss list-instances -g rg-vmss-lb01 -n vmss-web01 --output table'

# Check CPU metrics
az monitor metrics list --resource-group rg-vmss-lb01 --resource vmss-web01 --resource-type Microsoft.Compute/virtualMachineScaleSets --metric "Percentage CPU" --interval PT1M
```

### Generate Manual Load
```bash
# Get load balancer IP
LB_IP=$(az network public-ip show -g rg-vmss-lb01 -n lb-standard01PublicIP --query "ipAddress" -o tsv)

# Generate load (run in multiple terminals)
for i in {1..100}; do curl -s http://$LB_IP > /dev/null & done

# Install stress tool on instances
az vmss run-command invoke -g rg-vmss-lb01 -n vmss-web01 --command-id RunShellScript --scripts "sudo apt-get install -y stress" --instance-id "*"

# Run CPU stress test
az vmss run-command invoke -g rg-vmss-lab01 -n vmss-web01 --command-id RunShellScript --scripts "stress --cpu 2 --timeout 300s" --instance-id "*"
```

## 📊 Expected Behavior

1. **Initial State**: 2 VM instances running
2. **Load Applied**: CPU usage increases above 70%
3. **Scale Out**: After 5 minutes, new instances are added (up to 5 total)
4. **Load Removed**: CPU usage drops below 30%
5. **Scale In**: After 5 minutes, excess instances are removed (minimum 1)

## 🔍 Troubleshooting

### Scaling Not Working
- Check autoscale is enabled: `az monitor autoscale show -g rg-vmss-lb01 -n autoscale-vmss-web01 --query "enabled"`
- Verify CPU metrics are available: Can take 10-15 minutes after deployment
- Check cooldown periods: Default 5 minutes between scaling actions

### Load Balancer Not Responding
- Verify NSG rules allow HTTP traffic (port 80)
- Check health probe status: `az network lb probe show -g rg-vmss-lb01 --lb-name lb-standard01 -n http-probe`
- Ensure Nginx is running on instances

### SSH Access to Instances
```bash
# Get instance connection info
az vmss list-instance-connection-info -g rg-vmss-lb01 -n vmss-web01

# SSH using the generated keys
ssh -i vm_key.pem azureuser@<instance-public-ip>
```

## 🧹 Cleanup

Remove all resources:
```bash
az group delete --name rg-vmss-lb01 --yes --no-wait
```

## 📈 Scaling Configuration

- **Minimum Instances**: 1
- **Maximum Instances**: 5
- **Default Instances**: 2
- **Scale-Out Trigger**: CPU > 70% (average over 5 minutes)
- **Scale-In Trigger**: CPU < 30% (average over 5 minutes)
- **Cooldown Period**: 5 minutes between scaling actions
- **Scaling Increment**: 1 instance per action

## 🌐 Access Points

After deployment:
- **Load Balancer IP**: Shown in deployment output
- **Web Interface**: `http://<load-balancer-ip>`
- **Health Check**: `http://<load-balancer-ip>/` (returns instance hostname)

## 📚 Learning Objectives

This lab demonstrates:
- ✅ VM Scale Set creation and configuration
- ✅ Standard Load Balancer with backend pool
- ✅ Autoscale configuration with CPU metrics
- ✅ Network Security Group rules
- ✅ Custom Script Extensions for VM initialization
- ✅ Load testing and monitoring
- ✅ Azure CLI automation scripting