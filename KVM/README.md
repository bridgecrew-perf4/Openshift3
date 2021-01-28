# terraform code
This directory contains terraform code to create the infrastructure for OKD 3.11 under KVM. It assumes you already have KVM installed on your local machine. Edit the provider section to point it at a remote KVM resource.

## Step 1 : Running the terraform code
1. The terraform code uses static IP addressing.  Edit the static.tfvars file for your values
2. I'm using "Make" here , so now run the following:
```
make init
make apply
```

The image is a Centos 7 kvm qcow2 obtained from the Centos website.
As the size of root is limited, I created a new custom image from that using the following:
```
cp /var/lib/libvirt/images/CentOS-7-x86_64-GenericCloud.qcow2 /var/lib/libvirt/images/CentOS-7-big-x86_64-GenericCloud.qcow2
qemu-img resize CentOS-7-big-x86_64-GenericCloud.qcow2 +20G
```

### Step 2 : Running the ansible code
Once the machines are created (literally seconds) you now do the bulk of the work from ansible.
The ansible play will use your private key for access to the master machine.  My user is "pi" as I'm running from a raspberry pi.
Edit the ```cloud_init.cfg``` file and change the ```pi``` user for your own user.

Now your set to install.  Run the following:
```
./configure.bash
```
The process will take 10 minutes or so to set-up your machines ready to deploy the cluster.  

## Step 3. : Deply the cluster
Finally, your ready to deploy.   Login to the master server, su to root and run the supplied script.
```
ssh master
sudo -i
./install_ocp.bash
```
The install takes about 50 minutes on my 4 core, 64Mib machine.

Good luck.
Gary Crowe 28/01/2021
