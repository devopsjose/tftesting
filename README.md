# Azure DevOps build agent from Azure ScaleSet
This repo creates a new Azure DevOps (ADO) Windows build agent.
The steps can be broken down into the followings sequence:
1. Packer creates a virtual machine in Azure and installs the specified packages
2. Packer creates generalises the VM and creates an Azure Image. It also destroys all previously created resources, apart from the new Image
4. The newly created AMI ID is added to a parameter store
5. Terraform pulls the AMI ID from the parameter store and deploy an ec2 instance based on it
6. User-data is used at the point the ec2 instance starts to initiate the agent 

## Bootstrapping Azure
In order to prep the Azure Subscription for deploying resources via Terraform, the following resources will need to be created:
- A resource group to hold the resources for the state file
- A storage account for the state file
- A container which is where the state file exists

Here are a series of az cli commands which can be run to deploy those resources.
```
az group create --name terraform-state --location eastus
az storage account create --resource-group terraform-state --name edmentumtfstate --sku Standard_LRS --encryption-services blob
az storage container create --name infra-adoagent-azss --account-name edmentumtfstate
```

## Prerequisites
* The agent that the pipeline is run against will only require docker is preinstalled.
* The pipeline also requires access to an ADO library which contains the AWS access key and the secret key. In this repo that library is called Cross-Account-DeploymentUser and is defined on line 24 of aws-linux64-container.yaml.
* A method for authenticating
  * We are currently using a password and username to authenticate which is set as a secret variable at the point the pipeline is run. A user is able to pass their own credentials through at the point of running the pipleine using this method but we will be using a service account with permissions to add the agent to the specified pool (information on checking on whether the user has the correct permissions can be found here https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-windows?view=azure-devops#permissions).

<br />

> **_NOTE:_** The preferred method for authenticating would be using a PAT. However, we are not able to use this method until we move to Azure DevOps Services or add HTTPS functionality to our ADO servers (information on how to do that here https://docs.microsoft.com/en-us/azure/devops/server/admin/websitesettings?view=azure-devops-2020). Details on how to create this PAT can be found here https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-windows?view=azure-devops#permissions under "Authenticate with a personal access token (PAT)". The PAT token should be added to the Secret Manager of the account you are planning to deploy the agent to. It should have a name of az-devops-agent-pat and a key of the same name.

<br />

This has been tested and used with a previously built self-hosted agent in an ADO pipeline. However, theoretically it should be executable on a Microsoft hosted agent in future. To do this, you would need to update the agent pool in the yaml file, for example:
```
pool: ubuntu-latest
```
> **_NOTE:_** We will not be able to use Microsoft hosted agents until we have moved to Azure DevOps services.



## Build & Deploy
There are several activities that the pipeline performs which have been explained above. Once the pipeline has been added to ADO using the yaml file included at the root of the repo, it is ready to run. When you select Run in ADO, you will notice a radio button to select Build or Deploy. Selecting Build performs steps 1 to 4, selecting Deploy performs steps 5 & 6, as described above.

### Variables
* Packer
  * terraform version - line 4 of azdo-agent-linux-arm64.pkr.hcl
  * terragrunt version - line 8 of azdo-agent-linux-arm64.pkr.hcl
  * powershell version - line 12 of azdo-agent-linux-arm64.pkr.hcl
  * python version - line 16 of azdo-agent-linux-arm64.pkr.hcl
  * agent count - line 20 of azdo-agent-linux-arm64.pkr.hcl
  * agent pool - line 24 of azdo-agent-linux-arm64.pkr.hcl
* Terraform
  * subnet_id - line 1 of global.auto.tfvars
  * vpc_id - line 2 of global.auto.tfvars
* Both
  * region - line 18 of aws-linux64-container.yaml

## Common Issues
### Agent Authentication
If you are building the AMI and see an error like this in Packer:<br>
<span style="color:red">You are not authorized to access https://dev.azure.com</span><br>
This is likely caused by an expired PAT, refer to prerequisites in this document for information on recreating this.

