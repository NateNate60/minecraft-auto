#!/bin/bash

if ! test -f "$HOME/.aws/credentials"; 
then 
    echo "Could not find AWS credentials."
    echo "Please put credentials in ~/.aws/credentials."
    exit
fi

if ! command -v aws &> /dev/null 
then 
    echo "The AWS CLI isn't installed."
    echo "Please install Terraform and make sure it's in the PATH."
    echo "The easiest way to do so is using Snap."
    echo "    snap install aws-cli"
fi

if ! command -v terraform &> /dev/null 
then 
    echo "Terraform isn't installed."
    echo "Please install Terraform and make sure it's in the PATH."
    echo "The easiest way to do so is using Snap."
    echo "    snap install terraform"
fi

touch tf-key-pair

terraform init
terraform validate

echo "Applying Terraform configuration..."
echo "This WILL result in charges to your AWS account as infrastructure is created."
echo "Press CTRL + C to cancel"

for i in {5..1} 
do
    printf "Applying in $i...\r"
    sleep 1
done 

terraform apply -auto-approve

echo ""
echo ""

echo "Please wait a few minutes for the server to download and start the Minecraft server software."
echo "If you are unable to connect, please wait a few minutes and try again because the process"
echo "might not be complete yet."

echo ""
echo "Your server's IP address is:"
cat server_ip

echo ""
echo "Try connecting in five minutes, which is $(date -d "now + 5 minutes")"

