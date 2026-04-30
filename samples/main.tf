# ── Plain database (no CDC) ────────────────────────────────────────────────
# Creates:  database "orders", role "orders_user"

module "orders_db" {
  source = "../modules/postgresql_database"

  database_name = "orders"
  role_password = var.orders_db_password
}

# ── Database with CDC enabled (for Debezium) ───────────────────────────────
# Creates:  database "inventory", role "inventory_user"
#           replication slot "inventory_slot" (pgoutput)
#           publication "inventory_pub" (FOR ALL TABLES)
#
# Prerequisites:
#   - PostgreSQL server must have wal_level=logical
#   - For RDS: set the parameter group before running this module
#   - Locally: use .docker/docker-compose.yml (already configured)

module "inventory_db" {
  source = "../modules/postgresql_database"

  database_name = "inventory"
  role_password = var.inventory_db_password
  enable_cdc    = true
}

# ── Outputs ────────────────────────────────────────────────────────────────

output "orders_database_name" {
  value = module.orders_db.database_name
}

output "inventory_database_name" {
  value = module.inventory_db.database_name
}

output "inventory_replication_slot" {
  description = "Pass this to Debezium connector config as slot.name"
  value       = module.inventory_db.replication_slot_name
}

output "inventory_publication" {
  description = "Pass this to Debezium connector config as publication.name"
  value       = module.inventory_db.publication_name
}
