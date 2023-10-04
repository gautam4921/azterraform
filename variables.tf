variable "resource_group_name" {
default = "Rg-HCS-EUS"  
}
variable "location" {
default = "East US 2"    
}
variable "spn-client-id" {
default = "442c3a03-6b98-4704-bb6e-c719b6e533c6"    
}
variable "spn-client-secret" {
default = "ObI8Q~AqbF_L6Zb.B0RTa39kmTdba2aSEjuedaoH"    
}
variable "spn-tenant-id" {
default = "90f4dd64-b8a4-40a8-898f-a777acc25b9a"    
}
variable "subscription_id" {
default = "b2ceda44-2b61-42fb-a4bc-3dae69cbab50"
} 

variable "azurerm_windows_virtual_machine" {
default = "win2k19vm01"
} 
variable "prefix" {
default = "win2k19vm01"    
}