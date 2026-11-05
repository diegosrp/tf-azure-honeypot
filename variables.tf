variable "admin_username" {
  description = "Linux administrator username for SSH access to the honeypot VM"
  type        = string
  default     = "azureuser"
}

variable "environment" {
  description = "Deployment environment name used in Azure resource naming and tags"
  type        = string
  default     = "lab"

  validation {
    condition     = can(regex("^[a-z0-9-]{2,12}$", var.environment))
    error_message = "Environment must be 2-12 lowercase letters, numbers, or hyphens"
  }
}

variable "location" {
  description = "Azure region where the honeypot resources will be deployed"
  type        = string
  default     = "newzealandnorth"
}

variable "management_source_address_prefixes" {
  description = "Optional source CIDR ranges allowed to access T-Pot administrative ports 64294, 64295, and 64297. When null, Terraform detects the current public IP and allows it as /32"
  type        = list(string)
  default     = null
  nullable    = true

  validation {
    condition     = var.management_source_address_prefixes == null || length(var.management_source_address_prefixes) > 0
    error_message = "Management source address prefixes must be null or contain at least one CIDR range"
  }
}

variable "os_disk_size_gb" {
  description = "Managed OS disk size in GB. T-Pot requires at least 128 GB for a sensor and more for hive workloads"
  type        = number
  default     = 256

  validation {
    condition     = var.os_disk_size_gb >= 128
    error_message = "OS disk size must be at least 128 GB for T-Pot"
  }
}

variable "tpot_branch" {
  description = "T-Pot Git branch, tag, or commit used by the installer"
  type        = string
  default     = "master"
}

variable "tpot_repo_url" {
  description = "HTTPS URL of the T-Pot repository to clone during VM bootstrap"
  type        = string
  default     = "https://github.com/telekom-security/tpotce.git"
}

variable "tpot_web_password" {
  description = "Optional password for the T-Pot WebUI basic authentication account. When null, Terraform generates one. This value is sensitive and will be stored in Terraform state through VM custom data"
  type        = string
  default     = null
  nullable    = true
  sensitive   = true

  validation {
    condition     = var.tpot_web_password == null || length(var.tpot_web_password) >= 12
    error_message = "T-Pot WebUI password must contain at least 12 characters"
  }
}

variable "tpot_web_user" {
  description = "Username for the T-Pot WebUI basic authentication account"
  type        = string
  default     = "azhoneypot"
}

variable "ubuntu_offer" {
  description = "Canonical Ubuntu marketplace offer for the VM image"
  type        = string
  default     = "ubuntu-26_04-lts"
}

variable "ubuntu_sku" {
  description = "Canonical Ubuntu marketplace SKU for the VM image"
  type        = string
  default     = "server"
}

variable "ubuntu_version" {
  description = "Canonical Ubuntu marketplace image version. Use latest to deploy the newest image for the selected offer and SKU"
  type        = string
  default     = "latest"
}

variable "vm_size" {
  description = "Azure VM SKU. The default provides 16 GB RAM, matching the T-Pot hive recommendation"
  type        = string
  default     = "Standard_D4s_v5"
}

variable "workload_name" {
  description = "Short workload identifier used in Azure resource naming and tags"
  type        = string
  default     = "tpot"

  validation {
    condition     = can(regex("^[a-z0-9]{2,10}$", var.workload_name))
    error_message = "Workload name must be 2-10 lowercase letters or numbers"
  }
}