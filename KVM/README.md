# terraform code
This directory contains terraform code to create a satellite server machine under KVM. It assumes you already have KVM installed on your local machine.  There is also a shell script ( kvm_install_sat.bash) that will create a machine that has LVM partitioning. Use whichever matches your needs.

## Running the terraform code
1. The terraform code uses a static IP address.  Edit the static.tfvars file for your values
2. I'm using "Make" here , so now run the following:
a. Run "Make init"
b. Run "Make apply"

The image is a standard rhel7.9 kvm qcow2 obtained from Redhat.
As the size of root is limited, I created a new custom image from that using the following:
```
cp rhel-server-7.8-x86_64-kvm.qcow2 rhel-server-7.8-big-x86_64-kvm.qcow2
qemu-img resize rhel-server-7.8-big-x86_64-kvm.qcow2 +20G
```
## Configure the satellite
Once the machine is created (literally seconds) you now do the bulk of the work from ansible.

### Running the ansible code
The ansible play will require a pool ID & RHN login details.  You will also need to generate a manifest file @ access.redhat.com

1. Edit the deployment file for your details specifying your login details etc.
2. Copy your downloaded manifest file to: ~/ansible/roles/ansible-roles/files/manifest.zip
3. Run "Configure.bash"

The process will take an hour or more to download your content.  
4. Edit Makefile and change the IP address to your satellite server
5. Login to your satellite instance:
```
make ssh
```
6. Run the script /root/satellite/maintenance_scripts/finalise.bash

### Using the shell script to create the virtual machine.
You may use the supplied script ```kvm_install_sat.bash``` to install the virtusl mschine intrad of using terraform.  The advantage is that the image will be using LVM partitioning for pulp/mongodb - better suited to Production environments.
The script uses a kickstart file: ```rhel.cfg``` Edit this file for appropriate values.
