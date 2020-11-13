locals {
  system = "CSkillsApp"
}


provider "azurerm" {
  version = "1.38.0"
}

#create resource group
resource "azurerm_resource_group" "rg" {
    name     = "image"
    location = "South Central US"
    tags      = {
      Environment = local.system
    }
}

# Locate the existing custom/golden image
data "azurerm_image" "search" {
  name                = "image"
  resource_group_name = "image"
}

output "image_id" {
  value = "/subscriptions/cf0bcec9-631e-4dc9-8d08-807fa41bbe6e/resourceGroups/image/providers/Microsoft.Compute/images/image"
}


#Create virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = "vnet-${local.system}-westus2-001"
    address_space       = ["10.0.0.0/16"]
    location            = "South Central US"
    resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "snet-${local.system}-westus2-001 "
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.0.0/24"
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
  name                = "pip-${local.system}-dev-westus2-001"
  location            = "South Central US"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}


# Create network security group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-sshallow-001 "
  location            = "South Central US"
  resource_group_name = azurerm_resource_group.rg.name

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

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                      = "nic-01-${local.system}-dev-001 "
  location                  = "South Central US"
  resource_group_name       = azurerm_resource_group.rg.name
  network_security_group_id = azurerm_network_security_group.nsg.id

  ip_configuration {
    name                          = "niccfg-${local.system}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

# Create virtual machine
resource "azurerm_virtual_machine" "vm" {
  name                  = "image"
  location              = "South Central US"
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_DS2_v2"

  storage_os_disk {
    name              = "stvmpmvmterraformos"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    id = "${data.azurerm_image.search.id}"
  }

  os_profile {
    computer_name  = "image"
    admin_username = "terrauser"
    admin_password = "Password1234!"
  }

os_profile_windows_config {
  }
}