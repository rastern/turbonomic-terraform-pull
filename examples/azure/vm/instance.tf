variable "image_map" {
  type = map
}
variable "location" {
  type    = string
  default = "eastus"
}
variable "vm_size" {
  type    = string
  default = "Standard_DS1_v2"
}

provider "azurerm" {
  version = "~>2.0"
  features {}
}

resource "azurerm_resource_group" "demogroup" {
    name     = "demoResourceGroup"
    location = var.location
}

resource "azurerm_virtual_network" "demonetwork" {
    name                = "demoVnet"
    address_space       = ["10.0.0.0/16"]
    location            = var.locaiton
    resource_group_name = azurerm_resource_group.demogroup.name
}

resource "azurerm_subnet" "demosubnet" {
    name                 = "demoSubnet"
    resource_group_name  = azurerm_resource_group.demogroup.name
    virtual_network_name = azurerm_virtual_network.demonetwork.name
    address_prefixes       = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "demopublicip" {
    name                         = "demoPublicIP"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.demogroup.name
    allocation_method            = "Dynamic"
}

resource "azurerm_network_security_group" "demonsg" {
    name                = "demoNetworkSecurityGroup"
    location            = var.location
    resource_group_name = azurerm_resource_group.demogroup.name

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
}

resource "azurerm_network_interface" "demonic" {
    name                        = "demoNIC"
    location                    = var.location
    resource_group_name         = azurerm_resource_group.demogroup.name

    ip_configuration {
        name                          = "demoNicConfiguration"
        subnet_id                     = azurerm_subnet.demosubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.demopublicip.id
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.demonic.id
    network_security_group_id = azurerm_network_security_group.demonsg.id
}

resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.demogroup.name
    }

    byte_length = 8
}

resource "azurerm_storage_account" "demostorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.demogroup.name
    location                    = var.location
    account_replication_type    = "LRS"
    account_tier                = "Standard"
}

resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

output "tls_private_key" { value = "tls_private_key.example_ssh.private_key_pem" }

resource "azurerm_linux_virtual_machine" "demovm" {
    name                  = "demoVM"
    location              = var.location
    resource_group_name   = azurerm_resource_group.demogroup.name
    network_interface_ids = [azurerm_network_interface.demonic.id]
    size                  = var.vm_size

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference = var.image_map

    computer_name  = "demovm"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.example_ssh.public_key_openssh
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.demostorageaccount.primary_blob_endpoint
    }
}
