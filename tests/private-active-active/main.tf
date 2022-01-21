resource "random_string" "friendly_name" {
  length  = 4
  upper   = false
  number  = false
  special = false
}

module "private_active_active" {
  source = "../../"

  location             = var.location
  friendly_name_prefix = local.friendly_name_prefix

  resource_group_name_dns = var.resource_group_name_dns
  domain_name             = var.domain_name
  iact_subnet_list        = ["${azurerm_linux_virtual_machine.vm_bastion.private_ip_address}/32"]

  # Bootstrapping resources
  load_balancer_certificate   = data.azurerm_key_vault_certificate.load_balancer
  tfe_license_secret          = data.azurerm_key_vault_secret.tfe_license
  vm_certificate_secret       = data.azurerm_key_vault_secret.vm_certificate
  vm_key_secret               = data.azurerm_key_vault_secret.vm_key
  tls_bootstrap_cert_pathname = "/var/lib/terraform-enterprise/certificate.pem"
  tls_bootstrap_key_pathname  = "/var/lib/terraform-enterprise/key.pem"

  # Behind proxy information
  proxy_ip   = azurerm_linux_virtual_machine.proxy.private_ip_address
  proxy_port = local.proxy_port

  # Private Active / Active Scenario
  vm_node_count             = 2
  vm_sku                    = "Standard_D16as_v4"
  vm_image_id               = "rhel"
  load_balancer_public      = false
  load_balancer_type        = "application_gateway"
  load_balancer_sku_name    = "WAF_v2"
  load_balancer_sku_tier    = "WAF_v2"
  redis_enable_non_ssl_port = true
  redis_use_password_auth   = true
  redis_use_tls             = false
  installation_type         = "production"
  production_type           = "external"

  create_bastion = false
  tags           = local.common_tags
}
