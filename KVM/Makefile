THISDIR := $(notdir $(CURDIR))
IPmaster := 192.168.200.70
IPworker1:= 192.168.200.80
IPworker2:= 192.168.200.90

apply:
	terraform apply -auto-approve -var-file=vars.tfvars

init:
	terraform init

plan:
	terraform plan

## recreate terraform resources
rebuild: destroy apply

destroy:
	terraform destroy -auto-approve

## ssh into VM, unique after each rebuild so refresh known_hosts
ssh:
	ssh-keygen -f ~/.ssh/known_hosts -R $(IPmaster)
	ssh-keyscan "$(IPmaster)" >> ~/.ssh/known_hosts
	ssh-keygen -f ~/.ssh/known_hosts -R $(IPworker1)
	ssh-keyscan "$(IPworker1)" >> ~/.ssh/known_hosts
	ssh-keygen -f ~/.ssh/known_hosts -R $(IPworker2)
	ssh-keyscan "$(IPworker2)" >> ~/.ssh/known_hosts

## create public/private keypair for ssh
create-keypair:
	@echo "THISDIR=$(THISDIR)"
	ssh-keygen -t rsa -b 4096 -f id_rsa -C $(PROJECT) -N "" -q

metadata:
	terraform refresh && terraform output

## validate syntax of cloud_init
validate-cloud-config:
	cloud-init devel schema --config-file cloud_init.cfg
