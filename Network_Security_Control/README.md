# Network Security Control Lab

This lab focuses on implementing and managing Azure network security controls, including virtual networks, subnets, network security groups (NSGs), and network connectivity scenarios.

## 📁 Lab Structure

### Configuration Files

- **`variable`** - Template file with network configuration variables (safe for git)
- **`config`** - Personal configuration file with actual subscription ID (ignored by git)
- **Scripts** - Various lab scripts for network security scenarios

## 🔧 Configuration Setup

**IMPORTANT**: Before running any scripts in this lab, set up your configuration:

1. The `config` file contains your actual subscription ID and network settings
2. The `variable` file serves as a template reference
3. The `config` file is automatically ignored by git for security

## 🌐 Network Architecture

This lab creates the following network topology:

### Virtual Networks
- **vnet-a** (10.1.0.0/16) in Resource Group `rg-net-a`
  - subnet-a1 (10.1.1.0/24)
  - subnet-a2 (10.1.2.0/24)
- **vnet-b** (10.2.0.0/16) in Resource Group `rg-net-b`
  - subnet-b1 (10.2.1.0/24)

### Network Security Scenarios
This lab covers:
- Virtual Network creation and configuration
- Subnet segmentation and addressing
- Network Security Groups (NSGs) implementation
- Virtual Network Peering
- Network connectivity and routing
- Security rules and access control

## 🎯 Learning Objectives

- Understand Azure virtual networking concepts
- Implement network segmentation strategies
- Configure network security groups and rules
- Establish secure network connectivity
- Troubleshoot network connectivity issues
- Apply network security best practices

## 📋 Prerequisites

- Azure CLI installed and configured
- Valid Azure subscription with network permissions
- Understanding of IP addressing and subnetting
- Basic knowledge of network security concepts

## 🔒 Security Notes

- The `config` file contains sensitive subscription information
- Never commit the `config` file to version control
- Use the `variable` file as a reference template
- Follow principle of least privilege for network access

## 🚀 Getting Started

1. Ensure your `config` file is properly set up with your subscription ID
2. Review the network topology and addressing scheme
3. Run lab scripts in the recommended order
4. Monitor resources and costs during lab exercises

## 🧹 Cleanup

Remember to clean up resources after completing lab exercises to avoid unnecessary charges:
- Delete virtual networks and associated resources
- Remove resource groups when no longer needed
- Verify all network resources are properly removed