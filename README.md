# Openshift3
Terraform and ansible code to spin up OKD/Openshift 3.11 under KVM/Azure
This code was developed so that I could spin up OKD/Openshift resources quickly.
Useful for customer demonstrations and training courses.

## Usage.
1. Clone this Repo.
2. Move into the directoy where you want to provision. i.e. KVM for local libvirtd machines, Azure for Azure cloud
3. Edit the static.tfvars file and edit your values to suit.
4. Run the following
```
make init
make
bash ./configure.bash
```
5. Login to your master node and run the generated script:
```
./install_ocp.bash
``` 
### Notes
For each cloud instance, see the README.md in the relevant directory for specific instructions.

Gary.
26/01/2021
