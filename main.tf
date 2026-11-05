resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_prefix}-001"
  location = var.location

  tags = local.common_tags
}

resource "azurerm_virtual_network" "main" {
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  name                = "vnet-${local.name_prefix}-001"
  address_space       = ["10.40.0.0/16"]

  tags = azurerm_resource_group.main.tags
}

resource "azurerm_subnet" "main" {
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  name                 = "snet-${local.name_prefix}-001"
  address_prefixes     = ["10.40.1.0/24"]
}

resource "azurerm_public_ip" "main" {
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  name                = "pip-${local.name_prefix}-001"
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = azurerm_resource_group.main.tags
}

resource "tls_private_key" "main" {
  algorithm = "ED25519"
}

resource "random_password" "tpot_web" {
  length           = 24
  special          = true
  override_special = "_-+=@#"
}

resource "azurerm_ssh_public_key" "main" {
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  public_key          = tls_private_key.main.public_key_openssh
  name                = "ssh-${local.name_prefix}-001"

  tags = azurerm_resource_group.main.tags
}

resource "azurerm_network_security_group" "main" {
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  name                = "nsg-${local.name_prefix}-001"

  security_rule {
    name                       = "AllowTpotManagementInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["64294", "64295", "64297"]
    source_address_prefixes    = local.management_source_address_prefixes
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyTpotManagementInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["64294", "64295", "64297"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHoneypotInbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "1-64000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAnyOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = azurerm_resource_group.main.tags
}

resource "azurerm_network_interface" "main" {
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  name                = "nic-${local.name_prefix}-001"

  ip_configuration {
    subnet_id                     = azurerm_subnet.main.id
    public_ip_address_id          = azurerm_public_ip.main.id
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
  }

  tags = azurerm_resource_group.main.tags
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_linux_virtual_machine" "main" {
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  computer_name       = local.computer_name
  name                = "vm-${local.name_prefix}-001"
  admin_username      = var.admin_username
  size                = var.vm_size

  custom_data = base64encode(templatefile("${path.module}/cloud-init.yaml.tftpl", {
    admin_username           = var.admin_username
    tpot_branch              = var.tpot_branch
    tpot_repo_url            = var.tpot_repo_url
    tpot_web_user            = var.tpot_web_user
    tpot_web_password_base64 = base64encode(local.tpot_web_password)
  }))

  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.main.id]

  admin_ssh_key {
    public_key = azurerm_ssh_public_key.main.public_key
    username   = var.admin_username
  }

  os_disk {
    disk_size_gb         = var.os_disk_size_gb
    name                 = "osdisk-${local.name_prefix}-001"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = var.ubuntu_offer
    sku       = var.ubuntu_sku
    version   = var.ubuntu_version
  }

  tags = azurerm_resource_group.main.tags

  depends_on = [azurerm_network_interface_security_group_association.main]
}
