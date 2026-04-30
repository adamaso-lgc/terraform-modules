terraform {
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
  }
}

locals {
  role_name        = "${var.database_name}_user"
  slot_name        = coalesce(var.replication_slot_name, "${var.database_name}_slot")
  publication_name = coalesce(var.publication_name, "${var.database_name}_pub")
}

resource "postgresql_role" "service_role" {
  name        = local.role_name
  login       = true
  password    = var.role_password
  replication = var.enable_cdc
}

resource "postgresql_database" "db" {
  name  = var.database_name
  owner = postgresql_role.service_role.name

  depends_on = [postgresql_role.service_role]
}

# CDC resources — only provisioned when enable_cdc = true
resource "postgresql_publication" "cdc" {
  count      = var.enable_cdc ? 1 : 0
  name       = local.publication_name
  database   = postgresql_database.db.name
  all_tables = true

  depends_on = [postgresql_database.db]
}

resource "postgresql_replication_slot" "cdc" {
  count  = var.enable_cdc ? 1 : 0
  name   = local.slot_name
  plugin = var.replication_plugin

  depends_on = [postgresql_database.db]
}

output "database_name" {
  description = "Name of the created PostgreSQL database."
  value       = postgresql_database.db.name
}

output "role_name" {
  description = "Name of the dedicated service role created for this database."
  value       = postgresql_role.service_role.name
}

output "replication_slot_name" {
  description = "Name of the CDC replication slot. Null when enable_cdc is false."
  value       = var.enable_cdc ? postgresql_replication_slot.cdc[0].name : null
}

output "publication_name" {
  description = "Name of the CDC publication. Null when enable_cdc is false."
  value       = var.enable_cdc ? postgresql_publication.cdc[0].name : null
}
