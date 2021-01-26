# Openshift3
Terraform and ansible code to spin up OKD/Openshift 3.11 under KVM/Azure
This code was developed so that I could spin up Openshift resources quickly.
Useful for customer demonstrations and training courses.

## Usage.
1. Clone this Repo.
2. Move into the directoy where you want to provision. i.e. KVM for local libvirtd machines, Azure for Azure cloud
3. Edit the static.tfvars file and edit your values to suit.
4. Run the following
```
make init
make
```
4. bash ./configure.bash
5. Your OKD cluster should provision and be available after around 30 minutes.

### Note for Ron
At the moment, the code in KVM provisions the three machines correctly. I got tired and gave up.
Outstanding:
1.  Code to process the CPU & Memory from an array (tuple) as I want to be able to set those seperately per machine.
2. Write the ansible code! (I have most of that)

Gary.
26/01/2021
