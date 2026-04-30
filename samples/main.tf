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

# ── Kafka topic for CDC events ─────────────────────────────────────────────
# Debezium emits events to: <topic_prefix>.<schema>.<table>
# With topic_prefix="inventory", table "public.outbox" → "inventory.public.outbox"

module "inventory_cdc_topic" {
  source = "../modules/kafka_topic"

  topic_name = "inventory.public.outbox"
  partitions = 1 # increase in production
}

# ── Debezium connector ─────────────────────────────────────────────────────
# Wires the inventory Postgres replication slot → Kafka topic.
# pg_host must be reachable FROM the Kafka Connect container
# (container name locally, RDS endpoint in production).

module "inventory_debezium" {
  source = "../modules/debezium_connector"

  connector_name     = "inventory-cdc"
  pg_host            = var.pg_cdc_host
  pg_port            = var.pg_port
  pg_user            = module.inventory_db.role_name
  pg_password        = var.inventory_db_password
  database_name      = module.inventory_db.database_name
  replication_slot   = module.inventory_db.replication_slot_name
  publication_name   = module.inventory_db.publication_name
  table_include_list = ["public.outbox"]
  topic_prefix       = "inventory"
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

output "inventory_cdc_topic" {
  description = "Kafka topic where Debezium publishes inventory CDC events"
  value       = module.inventory_cdc_topic.topic_name
}

output "inventory_connector_name" {
  description = "Debezium connector name — use to query connector status via Kafka Connect REST API"
  value       = module.inventory_debezium.connector_name
}
