resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "microservice"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Dev"
  }

  depends_on = [azurerm_resource_group.rg]
}
