# 1. The Private Network Interfaces
resource "azurerm_network_interface" "cluster_nic" {
  count               = 2
  name                = "nic-cluster-node-${count.index + 1}"
  location            = azurerm_resource_group.acumen.location
  resource_group_name = azurerm_resource_group.acumen.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
    # No Public IP attached here!
  }
}

# 2. The Private Cluster Virtual Machines
resource "azurerm_linux_virtual_machine" "cluster_vm" {
  count               = 2
  name                = "vm-acumen-node-${count.index + 1}"
  resource_group_name = azurerm_resource_group.acumen.name
  location            = azurerm_resource_group.acumen.location
  size                = "Standard_E2s_v4"
  admin_username      = "acumenadmin"

  network_interface_ids = [
    azurerm_network_interface.cluster_nic[count.index].id,
  ]

  admin_ssh_key {
    username   = "acumenadmin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  disable_password_authentication = true
}

# 3. Output the Private IPs
output "cluster_private_ips" {
  value       = azurerm_linux_virtual_machine.cluster_vm[*].private_ip_address
  description = "The private IP addresses of the Cluster Nodes"
}
