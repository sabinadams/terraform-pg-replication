# Overview
This repository includes the [Terraform](https://www.terraform.io/) configurations required to deploy an RDS instance that is configured to work with [Pulse](https://www.prisma.io/data-platform/pulse).

# Requirements (3)

## 1. Terraform installed on your machine
You need Terraform installed on your machine so you can run CLI commands that initialize and deploy your infrastructure.
To install Terraform, follow the steps below:

#### Mac
```sh
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

#### Windows
Download the binary under the **Windows** tab [here](https://developer.hashicorp.com/terraform/downloads).

#### Linux
```sh
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

## 2. An AWS account
If you do not already have an AWS account, you can create one [here](https://portal.aws.amazon.com/billing/signup#/start/email).

## 3. AWS CLI set up locally on your machine
The AWS CLI is used automatically within the Terraform configuration to restart
your database after configuring a few custom settings Pulse relies on that require a reboot after changing.

### Install the CLI
If you do not already have the AWS CLI installed, you can install it by following the instructions [here](https://awscli.amazonaws.com/AWSCLIV2.pkg).
### Authenticate locally
Once installed, run the following command in your terminal and follow the prompts to authenticate with AWS.
```sh
aws configure
```

# Deploying the infrastructure
To deploy this infrastructure, navigate into the project in your terminal and run:
```sh
terraform init
terraform apply 
```
You will be asked to confirm the deployment. Type `'yes'` and hit `Enter`. 

> **Warning**
> The deployment will take a few minutes.

When the deployment is complete, you will see some output in the terminal containing the connection string to your new database. It should look something like:
```
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:

connection_string = "postgresql://postgres:postgres@pg-pulse.cghbgyrueus2.us-east-1.rds.amazonaws.com:5432/pulsedb"
```

That connection string is what you will provide when setting up Pulse within your Cloud Project.

# Cleaning Up
When you are done testing, be sure to run the following command to remove all resources created by Terraform if you no longer need them:

```sh
terraform destroy
```

> **Warning**
> Leaving these resources running on your account may incur cost.