# Mediawiki repository

This repository for installation of Mediawiki on AWS EC2 instances using Terraforma, AWS cli and Ansible.

Terraform is responsible for provisioning infrastructure on AWS. 
Ansible helps to install Mediawiki on EC2 instances.

# Architecute workflow.

Users traffic arrives on load balancer and get routed to webservers in public subnet
Web servers can only make calls to DB server in private subnet.

# How to execute the terraform scripts.

# Create the admin machine from where you run the terraform scripts.

Give the execute permission to the 

chmod 700 admin-setup-script.sh


./admin-setup-script.sh

# Plan

terrform plan

# Apply

terraform apply

# Destroy

terraform destroy
