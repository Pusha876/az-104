#!/bin/bash

# VM Scale Set Autoscale Testing Script
# This script generates load to test the autoscaling functionality

# Load variables from the variable file
source ./variable

echo "=== VM Scale Set Autoscale Testing ==="
echo "Resource Group: $RG"
echo "VM Scale Set: $VMSS"
echo ""

# Get load balancer public IP
echo "Getting load balancer public IP..."
PUBLIC_IP=$(az network public-ip show -g $RG -n "${LB}PublicIP" --query "ipAddress" -o tsv 2>/dev/null)

if [ -z "$PUBLIC_IP" ]; then
    echo "✗ Could not find load balancer public IP"
    echo "Make sure the VM Scale Set is deployed first by running: ./deploy-vmss-autoscale.sh"
    exit 1
fi

echo "✓ Load Balancer Public IP: $PUBLIC_IP"
echo ""

# Function to check current instance count
check_instances() {
    CURRENT_COUNT=$(az vmss list-instances -g $RG -n $VMSS --query "length(@)" -o tsv)
    echo "Current instance count: $CURRENT_COUNT"
}

# Function to monitor CPU usage
monitor_cpu() {
    echo "Average CPU usage across all instances:"
    az monitor metrics list \
        --resource "/subscriptions/$SUB_ID/resourceGroups/$RG/providers/Microsoft.Compute/virtualMachineScaleSets/$VMSS" \
        --metric "Percentage CPU" \
        --interval PT1M \
        --query "value[0].timeseries[0].data[-1].average" \
        -o tsv 2>/dev/null || echo "CPU metrics not available yet"
}

# Function to show autoscale activity
show_autoscale_activity() {
    echo ""
    echo "Recent autoscale activities:"
    az monitor activity-log list \
        --resource-group $RG \
        --start-time $(date -d '10 minutes ago' -u +"%Y-%m-%dT%H:%M:%SZ") \
        --query "[?contains(operationName.value, 'autoscale')].{Time:eventTimestamp, Operation:operationName.localizedValue, Status:status.localizedValue}" \
        -o table 2>/dev/null || echo "No recent autoscale activities"
}

echo "Current status before load testing:"
check_instances
monitor_cpu

echo ""
echo "=== Starting Load Test ==="
echo "This will generate HTTP requests to trigger CPU load and autoscaling"
echo "Press Ctrl+C to stop the load test"
echo ""

# Generate load using multiple background processes
echo "Generating load on $PUBLIC_IP..."
for i in {1..50}; do
    (
        while true; do
            curl -s "http://$PUBLIC_IP" > /dev/null
            sleep 0.1
        done
    ) &
done

# Store PIDs for cleanup
LOAD_PIDS=$!

echo "✓ Load generation started (50 concurrent processes)"
echo "✓ Each process makes requests every 0.1 seconds"
echo ""
echo "Monitoring scaling activity (updates every 30 seconds)..."
echo "Watch for instance count to increase when CPU > 70%"
echo ""

# Monitor for 10 minutes or until interrupted
COUNTER=0
while [ $COUNTER -lt 20 ]; do
    sleep 30
    COUNTER=$((COUNTER + 1))
    
    echo "=== Update $COUNTER ($(date)) ==="
    check_instances
    monitor_cpu
    show_autoscale_activity
    echo ""
done

echo ""
echo "=== Stopping Load Test ==="
# Kill all background curl processes
jobs -p | xargs kill 2>/dev/null
echo "✓ Load generation stopped"

echo ""
echo "=== Final Status ==="
check_instances
monitor_cpu

echo ""
echo "🔍 Monitoring Commands:"
echo "Watch instances: watch 'az vmss list-instances -g $RG -n $VMSS --output table'"
echo "Check autoscale settings: az monitor autoscale show -g $RG -n autoscale-$VMSS"
echo "View scaling history: az monitor autoscale show -g $RG -n autoscale-$VMSS --query profiles[0].rules"
echo ""
echo "⚠️  Note: Scaling actions may take 5-10 minutes due to cooldown periods"
echo "Scale-in will occur when CPU drops below 30% for 5 minutes"