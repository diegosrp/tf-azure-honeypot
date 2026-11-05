locals {
  location_code = lookup(
    {
      australiaeast   = "aue"
      brazilsouth     = "brs"
      eastus          = "eus"
      newzealandnorth = "nzn"
    },
    replace(lower(var.location), " ", ""),
    substr(replace(lower(var.location), " ", ""), 0, 6)
  )

  name_prefix   = lower("${var.workload_name}-${var.environment}-${local.location_code}")
  computer_name = substr(replace(local.name_prefix, "-", ""), 0, 15)

  current_public_ip                  = chomp(data.http.current_public_ip.response_body)
  management_source_address_prefixes = coalesce(var.management_source_address_prefixes, ["${local.current_public_ip}/32"])
  tpot_web_password                  = coalesce(var.tpot_web_password, random_password.tpot_web.result)

  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Workload    = var.workload_name
  }
}