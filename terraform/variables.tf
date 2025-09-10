variable "subscription_id" {
  description = "Azure subscription ID"
  default     = "23fb7416-3883-4129-8707-4c05f8a2c325"
}

variable "location" {
  description = "Azure region"
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "microservice-rg"
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  default     = "microservice-aks"
}

variable "node_count" {
  description = "Number of AKS nodes"
  default     = 1
}

variable "vm_size" {
  description = "VM size for AKS nodes"
  default     = "Standard_B2s"
}

