variable "database_name" {
  description = "Name of the PostgreSQL database to create. Must be snake_case. Also used to derive the role, slot, and publication names."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9_]*$", var.database_name))
    error_message = "database_name must be snake_case: lowercase letters, digits, and underscores only, starting with a letter."
  }
}

variable "role_password" {
  description = "Password for the dedicated service role. Should be sourced from a secrets manager rather than hardcoded."
  type        = string
  sensitive   = true
}

variable "enable_cdc" {
  description = "When true, configures the database for Change Data Capture: grants REPLICATION to the service role, creates a publication FOR ALL TABLES and a logical replication slot. Requires the PostgreSQL server to have wal_level=logical. Use table.include.list in your Debezium connector to scope which tables are actually captured."
  type        = bool
  default     = false
}

variable "replication_slot_name" {
  description = "Override for the replication slot name. Defaults to <database_name>_slot. Only used when enable_cdc is true."
  type        = string
  default     = null
}

variable "publication_name" {
  description = "Override for the publication name. Defaults to <database_name>_pub. Only used when enable_cdc is true."
  type        = string
  default     = null
}

variable "replication_plugin" {
  description = "Logical decoding plugin for the replication slot. pgoutput is built into PostgreSQL 10+ and is the default for Debezium. Use wal2json if you need the wal2json extension instead."
  type        = string
  default     = "pgoutput"

  validation {
    condition     = contains(["pgoutput", "wal2json"], var.replication_plugin)
    error_message = "replication_plugin must be one of: pgoutput, wal2json."
  }
}
