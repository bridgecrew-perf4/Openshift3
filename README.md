# Openshift3
Terraform and ansible code to spin up OKD/Openshift 3.11 under KVM/Azure
This code was developed so that I could spin up Openshift resources quickly.
Useful for customer demonstrations and training courses.

## Usage.
1. Clone this Repo.
2. Move into the directoy where you want to provision. i.e. KVM for local libvirtd machines, Azure for Azure cloud etc.
3. ```make init ; make```
4. bash configure.bash
5. Your OKD cluster should provision and be available after around 30 minutes.

###Ron,
At the moment, the code in KVM provisions a single machine nicely into libvirtd on my home system.
I need to provision 3 machines of course.  I thought I'd have the value sin the variables as an array then count through them?

Struggling with that at the moment.
 

