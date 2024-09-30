#!/bin/bash

# Get the IP address from Terraform output
INSTANCE_IP=$(terraform output -raw instance_ip)

# Define the hostname you want to use
HOSTNAME="ec2-instance"

# Update the hosts file
echo "$INSTANCE_IP $HOSTNAME" | sudo tee -a /etc/hosts
