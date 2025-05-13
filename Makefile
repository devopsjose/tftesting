SHELL := /bin/bash
.SILENT:

PURP = \e[0;35m

DOCKER=docker run --rm
DOCKER_COMPOSE=docker-compose run --rm -w
PACKER_WORKING_DIR=/workspace/src
TF_WORKING_DIR=/workspace/terraform
TF_LINT_WORKING_DIR=/data/terraform

export AWS_DEFAULT_REGION ?= us-east-2

# RUN_PACKER=$(DOCKER) \
# 	-v `pwd`:/workspace \
# 	-v ~/.ssh:/root/.ssh \
# 	-w $(PACKER_WORKING_DIR) \
# 	-e ARM_SUBSCRIPTION_ID=$(ARM_SUBSCRIPTION_ID) \
# 	-e ARM_TENANT_ID=$(ARM_TENANT_ID) \
# 	-e ARM_CLIENT_ID=$(ARM_CLIENT_ID) \
# 	-e ARM_CLIENT_SECRET=$(ARM_CLIENT_SECRET) \
# 	-e PACKER_PLUGIN_PATH=$(PACKER_WORKING_DIR)/.packer.d/plugins \
# 	hashicorp/packer:1.8

RUN_PACKER=docker-compose run --rm -w /workspace/src packer

# RUN_TF=$(DOCKER) \
# 	-v `pwd`:/workspace \
# 	-w $(TF_WORKING_DIR) \
# 	-u 1001:1001 \
# 	-e ARM_SUBSCRIPTION_ID=$(ARM_SUBSCRIPTION_ID) \
# 	-e ARM_TENANT_ID=$(ARM_TENANT_ID) \
# 	-e ARM_CLIENT_ID=$(ARM_CLIENT_ID) \
# 	-e ARM_CLIENT_SECRET=$(ARM_CLIENT_SECRET) \
# 	zenika/terraform-azure-cli:release-6.1_terraform-0.15.5_azcli-2.28.1

# RUN_TF=docker compose run --rm -w /workspace/terraform az login --service-principal -u $(ARM_CLIENT_ID) -p $(ARM_CLIENT_SECRET) --tenant $(ARM_TENANT_ID) && terraform
# RUN_TF=docker compose run --rm -w /workspace/terraform az login --identity && terraform
# RUN_TF=docker compose run --rm -w /workspace/terraform az login --identity --client-id $(ARM_CLIENT_ID) && terraform
RUN_TF=docker compose run --rm -w /workspace/terraform terraform

TF_SHELL=$(DOCKER) \
	--entrypoint="/bin/sh" \
	-v `pwd`:/workspace \
	-w $(TF_WORKING_DIR) \
	hashicorp/terraform:1.1.6

TF_PLAN=plan.out

RUN_AWS_CLI=docker run --rm \
	--entrypoint "/bin/sh" \
	-v `pwd`:/workspace \
	-w $(PACKER_WORKING_DIR) \
	-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
	-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
	-e AWS_SESSION_TOKEN=$(AWS_SESSION_TOKEN) \
	-e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
	mikesir87/aws-cli:2.1.6

RUN_TFLINT=docker run

SHELL := /bin/bash
.SILENT:

RUN_CHECKOV = @docker run --rm -t -v=${PWD}:/tf -w=/tf bridgecrew/checkov:2

RUN_TERRASCAN=docker run --rm -t -v ${PWD}:/workspace -w $(TF_WORKING_DIR) accurics/terrascan:1.13.2

RUN_TFSEC=docker run --rm -t -v ${PWD}:/workspace -w $(TF_WORKING_DIR) aquasec/tfsec:v1.6

.PHONY: packer-1
packer-1:
	@echo -e "$(PURP)Running task: $@"
	$(RUN_PACKER) build -force windows2022Edmentum1.pkr.hcl
	@echo -e "$(PURP)Done: $@"

.PHONY: packer-2
packer-2:
	@echo -e "$(PURP)Running task: $@"
	$(RUN_PACKER) build -force windows2022Edmentum2.pkr.hcl
	@echo -e "$(PURP)Done: $@"

.PHONY: packer-3
packer-3:
	@echo -e "$(PURP)Running task: $@"
	$(RUN_PACKER) build -force windows2022Edmentum3.pkr.hcl
	@echo -e "$(PURP)Done: $@"

.PHONY: packer-4
packer-4:
	@echo -e "$(PURP)Running task: $@"
	$(RUN_PACKER) build -force windows2022Edmentum4.pkr.hcl
	@echo -e "$(PURP)Done: $@"

.PHONY: packer-5
packer-5:
	@echo -e "$(PURP)Running task: $@"
	$(RUN_PACKER) build -force windows2022Edmentum5.pkr.hcl
	@echo -e "$(PURP)Done: $@"

.PHONY: packer
packer:
	@echo -e "$(PURP)Running task: $@"
	$(RUN_PACKER) build -force Windows2022.pkr.hcl
	@echo -e "$(PURP)Done: $@"

.PHONY: packer-fmt
packer-fmt:
	@echo -e "$(PURP)Running task: $@"
	$(RUN_PACKER) fmt .
	@echo -e "$(PURP)Done: $@"

.PHONY: packer-tools
packer-tools:
	@echo -e "$(PURP)Running task: $@"
	$(RUN_PACKER) build -force .
	@echo -e "$(PURP)Done: $@"

.PHONY: terraform-init
terraform-init:
	@echo -e "$(PURP)Running task: $@"
	# @echo "ARM_SUBSCRIPTION_ID: $(ARM_SUBSCRIPTION_ID)"
	# @echo "ARM_TENANT_ID: $(ARM_TENANT_ID)"
	# $(RUN_TF) az version
	# $(RUN_TF) which az
	$(RUN_TF) terraform init -input=false
	@echo -e "$(PURP)Done: $@"

.PHONY: terraform-plan
terraform-plan: terraform-init
	@echo -e "$(PURP)Running task: $@"
	$(RUN_TF) terraform plan -out out.terraform
	@echo -e "$(PURP)Done: $@"

.PHONY: terraform-apply
terraform-apply: terraform-init 
	@echo -e "$(PURP)Running task: $@"
	$(RUN_TF) terraform apply -input=false out.terraform
	@echo -e "$(PURP)Done: $@"

.PHONY: terraform-fmt
terraform-fmt: terraform-fmt
	@echo -e "$(PURP)Running task: $@"
	$(RUN_TF) terraform fmt
	@echo -e "$(PURP)Done: $@"

.PHONY: terraform-clean
terraform-clean:
	@echo -e "$(PURP)Running task: $@, removing terraform directory and purging docker networks ..."
	$(TF_SHELL) -c "rm -rf .terraform"
	@echo -e "$(PURP)Done: $@"

.PHONY: terraform-import
terraform-import: terraform-import
	@echo -e "$(PURP)Running task: $@"
	$(RUN_TF) terraform import -input=false azurerm_virtual_machine_scale_set_extension.performance-diagnostics /subscriptions/9447ad8c-388a-4ea6-9e40-f3fdace6ef02/resourceGroups/VMSS-BUILD-AGENT/providers/Microsoft.Compute/virtualMachineScaleSets/ELFMaster/extensions/AzurePerformanceDiagnostics
	@echo -e "$(PURP)Done: $@"

.PHONY: terraform-taint
terraform-taint: terraform-taint
	@echo -e "$(PURP)Running task: $@"
	$(RUN_TF) terraform taint azurerm_virtual_machine_scale_set_extension.performance-diagnostics
	@echo -e "$(PURP)Done: $@"

.PHONY: terraform-bootstrap
terraform-bootstrap: terraform-bootstrap
	@echo -e "$(PURP)Running task: $@"
	$(RUN_TF) terraform init
	$(RUN_TF) terraform import azurerm_resource_group.vmss-tfstate-build-agent /subscriptions/$(ARM_SUBSCRIPTION_ID)/resourceGroups/terraform-state
	$(RUN_TF) terraform import azurerm_storage_account.vmss-tfstate-build-agent /subscriptions/$(ARM_SUBSCRIPTION_ID)/resourceGroups/terraform-state/providers/Microsoft.Storage/storageAccounts/edmentumtfstate
	$(RUN_TF) terraform import azurerm_storage_container.vmss-tfstate-build-agent https://example.blob.core.windows.net/container
	@echo -e "$(PURP)Done: $@"

.PHONY: checkov
checkov:
	@echo -e "$(PURP)Running task: $@"
	$(RUN_CHECKOV) --directory /tf -s
	@echo -e "$(PURP)Done: $@"

.PHONY: terrascan
terrascan:
	@echo -e "$(PURP)Running task: $@"
	$(RUN_TERRASCAN) scan -o json 2>/dev/null
	@echo -e "$(PURP)Done: $@"

.PHONY: tfsec
tfsec:
	@echo -e "$(PURP)Running task: $@"
	$(RUN_TFSEC) . -s
	@echo -e "$(PURP)Done: $@"

.PHONY: tflint
tflint:
	@echo -e "$(PURP)Running task: $@"
	docker run --rm -t -v `pwd`:/data -w $(TF_LINT_WORKING_DIR) ghcr.io/terraform-linters/tflint-bundle:latest --force
	@echo -e "$(PURP)Done: $@"

