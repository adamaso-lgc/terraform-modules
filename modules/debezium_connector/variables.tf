variable "connector_name" {
  description = "Unique name for the Debezium connector within this Kafka Connect cluster."
  type        = string
}

variable "pg_host" {
  description = "Hostname of the PostgreSQL server as seen FROM the Kafka Connect container. When running locally with Docker, use the container name (e.g. 'postgres_local'), not 'localhost'."
  type        = string
}

variable "pg_port" {
  description = "Port of the PostgreSQL server."
  type        = number
  default     = 5432
}

variable "pg_user" {
  description = "PostgreSQL user for the connector. Must have REPLICATION privilege. Pass the role created by the postgresql_database module."
  type        = string
}

variable "pg_password" {
  description = "Password for the PostgreSQL connector user."
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "Name of the PostgreSQL database to stream changes from. Use the postgresql_database module's database_name output."
  type        = string
}

variable "replication_slot" {
  description = "Name of the logical replication slot. Use the postgresql_database module's replication_slot_name output."
  type        = string
}

variable "publication_name" {
  description = "Name of the PostgreSQL publication. Use the postgresql_database module's publication_name output."
  type        = string
}

variable "table_include_list" {
  description = "List of tables to capture in 'schema.table' format (e.g. ['public.outbox']). Scopes CDC to specific tables rather than capturing the entire database."
  type        = list(string)
}

variable "topic_prefix" {
  description = "Prefix for all Kafka topics emitted by this connector. Debezium produces topics as '<prefix>.<schema>.<table>'. Typically matches the database name."
  type        = string
}

variable "plugin_name" {
  description = "Logical decoding plugin. pgoutput is built into PostgreSQL 10+ and preferred for Debezium. Use wal2json only if you need the wal2json extension."
  type        = string
  default     = "pgoutput"

  validation {
    condition     = contains(["pgoutput", "wal2json"], var.plugin_name)
    error_message = "plugin_name must be one of: pgoutput, wal2json."
  }
}

variable "override_config" {
  description = "Additional Debezium connector configuration to merge with the defaults. Keys/values follow the Debezium PostgreSQL connector configuration reference."
  type        = map(string)
  default     = {}
}
