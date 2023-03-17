terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.0"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "15.9.0"
    }
  }
}


provider "gitlab" {
  token = var.gitlab_token
  base_url  = "http://10.0.2.4"
}

# Configure the AZURE Provider
provider "azurerm" {
  features {}
}

# Recover resource group name
data "azurerm_resource_group" "rg" {
  name = "GR_LABS"
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.prefix}-virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet_internal" {
  name                 = "${var.prefix}-subnet-internal"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "gateway-subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.0.3.0/27"]
}

resource "azurerm_network_security_group" "nsg" {
    name                = "${var.prefix}-nsg"
    location            = data.azurerm_resource_group.rg.location
    resource_group_name = data.azurerm_resource_group.rg.name

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
        name                       = "HTTP"
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
        name                       = "HTTPS"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "onprem"
    }
}

resource "azurerm_subnet_network_security_group_association" "subnet_internal-nsg-association" {
    subnet_id                 = azurerm_subnet.subnet_internal.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "vpn-gateway1-pip" {
  name                = "${var.prefix}-vpn-gateway1-pip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "onprem-vpn-gateway" {
    name                = "${var.prefix}-onprem-vpn-gateway1"
    location            = data.azurerm_resource_group.rg.location
    resource_group_name = data.azurerm_resource_group.rg.name

    type     = "Vpn"
    vpn_type = "RouteBased"

    active_active = false
    enable_bgp    = false
    sku           = "VpnGw1"

    ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn-gateway1-pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway-subnet.id
    }

    vpn_client_configuration {
    address_space = ["10.2.0.0/24"]

    root_certificate {
      name = "DigiCert-Federated-ID-Root-CA"

      public_cert_data = <<EOF
MIIC5zCCAc+gAwIBAgIQerVuW5lnuqRDVY3v5WouVjANBgkqhkiG9w0BAQsFADAW
MRQwEgYDVQQDDAtQMlNSb290Q2VydDAeFw0yMzAzMTUyMjE1MzNaFw0yNDAzMTUy
MjM1MzNaMBYxFDASBgNVBAMMC1AyU1Jvb3RDZXJ0MIIBIjANBgkqhkiG9w0BAQEF
AAOCAQ8AMIIBCgKCAQEAqBAbqtyoSQ4lG0fE+O/D6vfupIaFwGgUYEi96vSJ6R9B
6z7uEVbbj1CBzxV3dO/oB6GD8QxqHwP61q/T+J5He6zLXVVnlaYGCQyHjVOSDx/3
2wApg22e4T8puAYGfzkQFWsjAuaGMYOtt2Y88331xy/mxnBaJ/HkK6oyfbQnhYry
w2Vkh4waE+h9Jm80olpY/6Owm6Cy0/YGsfdjEdxUB3RTxsnYXsYVhCUJaYukDz6j
QUN/w5ni1TzB1WgvrRwjgFUvuiiJz2hDTI+qt09ZYss0Ig5x5LBHmdvo515FT9KU
QMMyhxQOavP/ZuCff0EKQJBwQhLRgdTH07P6nQvW6QIDAQABozEwLzAOBgNVHQ8B
Af8EBAMCAgQwHQYDVR0OBBYEFLvXp2djZC1tuZkjMsXqbttI1xqxMA0GCSqGSIb3
DQEBCwUAA4IBAQCNpEJbeJzBG6TG8MWN6PRIwy/LTeVvXuddgiRg94t+C261Ox9w
nfwaVjjaKjDa6vL4icgnPKF50wrO657UskIv4xrj0mAkf6VwKayDUyE1CLTBwqEC
M4LpwTy/+JmiDpdyHGf/tbT8SCqSmogeDGzITi1bbJvpJjD+4Idxy7wOAKC4iNj2
WRsSKj8rYl91l83SknV4mmRCGanCRfTFnzs7U+qt8bJnVNFh4FHp9yLPPYBTpJS/
HeWCG9hZxx8Pz4xxIGgeLqeYTm6l0ovsDtyMrBm149+TKE9nSfxrG+3nrLftJXfD
ATsHyeJ4hF9Pafvr9hPfSD3qcFG6pVO2Bk51
EOF

    }

  }
    depends_on = [azurerm_public_ip.vpn-gateway1-pip]

}

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic-internal"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_marketplace_agreement" "gitlabee" {
  publisher = "gitlabinc1586447921813"
  offer     = "gitlabee"
  plan      = "default"
}

resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                = "${var.prefix}-linux-vm"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "gitlabinc1586447921813"
    offer     = "gitlabee"
    sku       = "default"
    version   = "15.4.2112733204"
  }

  plan {
    publisher = "gitlabinc1586447921813"
    product   = "gitlabee"
    name      = "default"
  }

  depends_on = [azurerm_marketplace_agreement.gitlabee]
}

resource "gitlab_project" "example" {
  name        = "example"
  description = "My awesome codebase"

  visibility_level = "public"
}