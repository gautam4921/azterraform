# Create a resource group
resource "azurerm_resource_group" "azrg" {
  name     = var.resource_group_name
  location = var.location
}
# Storage account for Boot diagnostics
resource "azurerm_storage_account" "azbootdiag" {
  name                     = "azeus2bootdiag"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_replication_type = "LRS"
  account_tier             = "Standard"
}
# Public IP creation for vm
resource "azurerm_public_ip" "azpip01" {
  name                = "${var.prefix}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
  }
#Create a network security group 
resource "azurerm_network_security_group" "NSG" {
  name                = "Nsg-prod-rg-hcs-eus"
  location            = azurerm_resource_group.azrg.location
  resource_group_name = azurerm_resource_group.azrg.name
  security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = "vnet-HCS-EUS"
    address_space       = ["10.0.0.0/16"]
    location            = var.location
    dns_servers         = ["192.168.1.6"] 
    resource_group_name = azurerm_resource_group.azrg.name
}
# Create a virtual subnetwork #1
resource "azurerm_subnet" "subnet" {
  name                 = "vnet-HCS-EUS-Prod"
  resource_group_name  = azurerm_resource_group.azrg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]  
}
# Associate subnet and network security group 
resource "azurerm_subnet_network_security_group_association" "asnsga-01" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.NSG.id
}

# Create a virtual subnetwork #2
resource "azurerm_subnet" "subnet2" {
  name                 = "vnet-HCS-EUS-Dev"
  resource_group_name  = azurerm_resource_group.azrg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
# Create a virtual subnetwork #3
resource "azurerm_subnet" "subnet3" {
  name                 = "vnet-HCS-EUS-Test"
  resource_group_name  = azurerm_resource_group.azrg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}
# Crete network interface for vm 
resource "azurerm_network_interface" "vmnic" {
  name                = "win2k19vm01-vmnic"
  location            =  var.location
  resource_group_name = azurerm_resource_group.azrg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
# create windows virtual machine 
resource "azurerm_windows_virtual_machine" "azwinvm" {
  name                = "${var.prefix}-vm"
  resource_group_name = azurerm_resource_group.azrg.name
  location            = azurerm_resource_group.azrg.location
  size                = "Standard_B2s"
  admin_username      = "gautam"
  admin_password      = "Welcome@12345"
  enable_automatic_updates   = "true"  
  network_interface_ids = [azurerm_network_interface.vmnic.id,]
   
#Create  os disk for virtual machine 
  os_disk {
    name                 = "win2k19vm01-osdisk" 
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"            
  }
  #Take windows Image from image gallery in azure 

#windows server 2019 image to be taken from Market place
    source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
 }
    boot_diagnostics {
    storage_account_uri = azurerm_storage_account.azbootdiag.primary_blob_endpoint
  }
# Tags are optional 
   tags = {
     Environment = "IAAC"
     Team        = "DevOps"
   }
  
}
#End of script.