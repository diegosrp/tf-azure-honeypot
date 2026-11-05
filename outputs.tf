output "management_source_address_prefixes" {
  description = "CIDR ranges allowed to access T-Pot administrative ports. Defaults to the public IP detected during apply."
  value       = local.management_source_address_prefixes
}

output "ssh_private_key_pem" {
  description = "Generated private key for SSH access. Store it locally with chmod 600 before connecting."
  value       = tls_private_key.main.private_key_openssh
  sensitive   = true
}

output "ssh_public_key_id" {
  description = "ID of the Azure SSH Public Key resource used by the VM."
  value       = azurerm_ssh_public_key.main.id
}

output "ssh_command" {
  description = "SSH command for the T-Pot VM after the installer moves SSH to port 64295."
  value       = "ssh -i ./tpot_ssh_key.pem -p 64295 ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
}

output "tpot_install_log_command" {
  description = "Command to follow the T-Pot cloud-init installation log over SSH."
  value       = "sudo tail -f /var/log/tpot-install.log"
}

output "tpot_web_password" {
  description = "Generated or supplied T-Pot WebUI password."
  value       = local.tpot_web_password
  sensitive   = true
}

output "tpot_web_username" {
  description = "T-Pot WebUI username."
  value       = var.tpot_web_user
}

output "tpot_web_url" {
  description = "T-Pot WebUI URL. The service becomes available after cloud-init installs T-Pot and the VM reboots."
  value       = "https://${azurerm_public_ip.main.ip_address}:64297"
}