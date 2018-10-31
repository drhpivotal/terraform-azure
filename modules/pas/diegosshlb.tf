resource "azurerm_public_ip" "diego-ssh-lb-public-ip" {
  name                         = "ssh-lb-public-ip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "static"
  sku                          = "Standard"
}

resource "azurerm_lb" "diego-ssh" {
  name                = "${var.env_name}-ssh-lb"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  sku                 = "Standard"

  frontend_ip_configuration = {
    name                 = "frontendip"
    public_ip_address_id = "${azurerm_public_ip.diego-ssh-lb-public-ip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "diego-ssh-backend-pool" {
  name                = "ssh-backend-pool"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.diego-ssh.id}"
}

resource "azurerm_lb_probe" "diego-ssh-probe" {
  name                = "ssh-probe"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.diego-ssh.id}"
  protocol            = "TCP"
  port                = 2222
}

resource "azurerm_lb_rule" "ssh-rule" {
  name                = "diego-ssh-rule"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.diego-ssh.id}"

  frontend_ip_configuration_name = "frontendip"
  protocol                       = "TCP"
  frontend_port                  = 2222
  backend_port                   = 2222

  backend_address_pool_id = "${azurerm_lb_backend_address_pool.diego-ssh-backend-pool.id}"
  probe_id                = "${azurerm_lb_probe.diego-ssh-probe.id}"
}
