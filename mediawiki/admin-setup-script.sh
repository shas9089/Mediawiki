#!/bin/bash

#Update the packages 
sudo apt-get update 
sudo apt-get -y upgrade
sudo apt-get install python3-pip -y


#install terraform 
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt install terraform


#install aws-cli
sudo apt-get install awscli -y

#install Ansible
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update
sudo apt install ansible -y