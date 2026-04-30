terraform {
  required_providers {
    kafka-connect = {
      source = "Mongey/kafka-connect"
    }
  }
}

resource "kafka-connect_connector" "debezium" {
  name = var.connector_name

  config = merge(
    {
      "name"               = var.connector_name
      "connector.class"    = "io.debezium.connector.postgresql.PostgresConnector"
      "plugin.name"        = var.plugin_name
      "tasks.max"          = "1"
      "database.hostname"  = var.pg_host
      "database.port"      = tostring(var.pg_port)
      "database.user"      = var.pg_user
      "database.password"  = var.pg_password
      "database.dbname"    = var.database_name
      "topic.prefix"       = var.topic_prefix
      "slot.name"          = var.replication_slot
      "publication.name"   = var.publication_name
      "table.include.list" = join(",", var.table_include_list)
    },
    var.override_config
  )
}

output "connector_name" {
  description = "Name of the created Debezium connector."
  value       = kafka-connect_connector.debezium.name
}
