# terraform code
This directory contains terraform code to create a satellite server machine under KVM. It assumes you already have KVM installed on your local machine. Edit the provider section to point it at a remote KVM resource.

## Running the terraform code
1. The terraform code uses static IP addressing.  Edit the static.tfvars file for your values
2. I'm using "Make" here , so now run the following:
```
make init
make apply

The image is a standard rhel7.9 kvm qcow2 obtained from Redhat.
As the size of root is limited, I created a new custom image from that using the following:
```
cp rhel-server-7.8-x86_64-kvm.qcow2 rhel-server-7.8-big-x86_64-kvm.qcow2
qemu-img resize rhel-server-7.8-big-x86_64-kvm.qcow2 +20G
```
## Configure the Cluster
Once the machine is created (literally seconds) you now do the bulk of the work from ansible.

### Running the ansible code
The ansible play will require a pool ID & RHN login details.  You will also need to generate a manifest file @ access.redhat.com

1. Edit the deployment file for your details specifying your login details etc.
3. Run "Configure.bash"

The process will take an hour or more to download your content.  
4. Edit Makefile and change the IP address to your satellite server
5. Login to your satellite instance:
```
make ssh
```
