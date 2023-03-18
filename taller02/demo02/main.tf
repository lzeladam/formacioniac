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

# Configure the GitLab Provider
provider "gitlab" {
  token = var.gitlab_token
  base_url  = "http://10.0.2.4"
}

# Configure the AZURE Provider
provider "azurerm" {
  features {}
}

# Retrieves the Azure Resource Group information
data "azurerm_resource_group" "rg" {
  name = "GR_LABS"
}

# Creates  a virtual network in Azure
resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.prefix}-virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Creates a subnet within the virtual network for internal use
resource "azurerm_subnet" "internal_subnet" {
  name                 = "${var.prefix}-internal-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Creates a subnet for gateway use within the virtual network 
resource "azurerm_subnet" "gateway-subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.0.3.0/27"]
}

# Creates a network security group to internal subnet to allow certain network traffic
resource "azurerm_network_security_group" "internal_nsg" {
    name                = "${var.prefix}-internal-nsg"
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

    security_rule {
        name                       = "RDP"
        priority                   = 1004
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "ICMP"
        priority                   = 1005
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Icmp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "onprem"
    }
}

# Associates the internal subnet with the created network security group 
resource "azurerm_subnet_network_security_group_association" "internal_subnet_nsg_association" {
    subnet_id                 = azurerm_subnet.internal_subnet.id
    network_security_group_id = azurerm_network_security_group.internal_nsg.id
}

# Creates a public IP address for the virtual network gateway
resource "azurerm_public_ip" "vpn-gateway-pip" {
  name                = "${var.prefix}-vpn-gateway-pip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  allocation_method = "Dynamic"
}

# Creates a virtual network gateway
resource "azurerm_virtual_network_gateway" "vpn-gateway" {
    name                = "${var.prefix}-vpn-gateway"
    location            = data.azurerm_resource_group.rg.location
    resource_group_name = data.azurerm_resource_group.rg.name

    type     = "Vpn"
    vpn_type = "RouteBased"

    active_active = false
    enable_bgp    = false
    sku           = "VpnGw1"

    ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn-gateway-pip.id
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
    depends_on = [azurerm_public_ip.vpn-gateway-pip]

}

# Creates a network interface to then associate it with a Linux virtual machine.
resource "azurerm_network_interface" "nic_linux_vm" {
  name                = "${var.prefix}-nic-linux-vm"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Creates a marketplace agreement to download a GitLab Bitnami image. It specifies the publisher, offer, and plan parameters.
resource "azurerm_marketplace_agreement" "gitlabee" {
  publisher = "gitlabinc1586447921813"
  offer     = "gitlabee"
  plan      = "default"
}

# Creates a Linux virtual machine using the GitLab Bitnami image from the marketplace
resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                = "${var.prefix}-linux-vm"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic_linux_vm.id,
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

# Creates a GitLab project named "example" with a visibility level set to "public".
# resource "gitlab_project" "example" {
#  name        = "example"
#  description = "My awesome codebase"

#  visibility_level = "public"
#}

# Creates a network interface named to then associates it with a Windows virtual machine
resource "azurerm_network_interface" "nic_windows" {
  name                =  "${var.prefix}-nic-internal-windows"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Creates a Windows virtual machine using the Windows Server image from the marketplace
resource "azurerm_windows_virtual_machine" "windows_vm" {
  name                = "${var.prefix}-win-vm"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic_windows.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

# Creates an Azure container registry
resource "azurerm_container_registry" "acr" {
  name                = "${var.prefix}containerRegistry"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Premium"
  admin_enabled       = false
  georeplications {
    location                = "WEST US 2"
    zone_redundancy_enabled = true
    tags                    = {}
  }
  georeplications {
    location                = "North Europe"
    zone_redundancy_enabled = true
    tags                    = {}
  }
}