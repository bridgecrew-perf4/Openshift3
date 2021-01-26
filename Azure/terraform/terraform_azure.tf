# Configure the Microsoft Azure Provider
provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you're using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "ocp3grp" {
    name     = "OCP3Group"
    location = "uksouth"

    tags = {
        environment = "OCP3 Demo"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "ocp3network" {
    name                = "OCP3Vnet"
    address_space       = ["10.0.0.0/16"]
    location            = "uksouth"
    resource_group_name = azurerm_resource_group.ocp3grp.name

    tags = {
        environment = "OCP3 Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "OCP3Subnet"
    resource_group_name  = azurerm_resource_group.ocp3grp.name
    virtual_network_name = azurerm_virtual_network.ocp3network.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "OCP3publicip" {
    name                         = "OCP3PublicIP"
    location                     = "uksouth"
    resource_group_name          = azurerm_resource_group.ocp3grp.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "OCP3 Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "OCP3sg" {
    name                = "OCP3NSG"
    location            = "uksouth"
    resource_group_name = azurerm_resource_group.ocp3grp.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTPD"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "PROXY"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "OCP3 Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "OCP3NIC" {
    name                      = "myNIC"
    location                  = "uksouth"
    resource_group_name       = azurerm_resource_group.ocp3grp.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.OCP3publicip.id
    }

    tags = {
        environment = "PodMan Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "OCP3" {
    network_interface_id      = azurerm_network_interface.OCP3NIC.id
    network_security_group_id = azurerm_network_security_group.OCP3sg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.ocp3grp.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.ocp3grp.name
    location                    = "uksouth"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "OCP3 Demo"
    }
}

# Create (and display) an SSH key
resource "tls_private_key" "OCP3_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" { value = tls_private_key.OCP3_ssh.private_key_pem }

# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
    name                  = "oshiftmaster"
    location              = "uksouth"
    resource_group_name   = azurerm_resource_group.ocp3grp.name
    network_interface_ids = [azurerm_network_interface.OCP3NIC.id]
    #size                 = "Standard_DS1_v2"
    size                  = "Standard_D2s_v3"

    os_disk {
        name              = "OCP3OsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
#       storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "RedHat"
        offer     = "RHEL"
        sku       = "8.2"
        version   = "8.2.2020050811"
    }

    computer_name  = "oshiftmaster"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.OCP3_ssh.public_key_openssh
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "OCP3 Demo"
    }
}
