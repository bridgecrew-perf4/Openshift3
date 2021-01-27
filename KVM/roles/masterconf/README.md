Role Name
=========

Creates the bind server on the bastion host and prepares for Openshift install

Requirements
------------

Ansible itself

Role Variables
--------------

The default variable files should ve copied from defaults to the vars directory

Dependencies
------------

None

Example Playbook
----------------

    - hosts: bastion
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------

gary.crowe (gary.crowe@computacenter.com)

