variable "system" {
    type = string
    description = "Name of the system or environment"
}

variable "servername" {
    type = string
    description = "Server name of the virtual machine"
}

variable "location" {
    type = string
    description = "Azure location of terraform server environment"
    default = "westus2"

}

variable "admin_username" {
    type = string
    default= "admin"
    description = "Administrator username for server"
}

variable "admin_password" {
    type = string
    default= "admin1234!!"
    description = "Administrator password for server"
}

variable "vnet_address_space" { 
    type = list
    description = "Address space for Virtual Network"
    default = ["10.0.0.0/16"]
}

variable "managed_disk_type" { 
    type = map
    description = "Disk type Premium in Primary location Standard in DR location"

    default = {
        westus2 = "Premium_LRS"
        eastus = "Standard_LRS"
    }
}

variable "vm_size" {
    type = string
    description = "Size of VM"
    default = "Standard_B1s"
}

variable "os" {
    description = "OS image to deploy"
    type = object({
        publisher = string
        offer = string
        sku = string
        version = string
  })
} 

# Locate the existing custom/golden image
data "azurerm_image" "search" {
  name                = "vmterraform-image-20201113120041"
  resource_group_name = "rg-terraexample"
}

output "image_id" {
  value = "/subscriptions/cf0bcec9-631e-4dc9-8d08-807fa41bbe6e/resourceGroups/rg-terraexample/providers/Microsoft.Compute/images/vmterraform-image-20201113120041"
}
