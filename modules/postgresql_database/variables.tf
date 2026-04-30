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
  description = "When true, configures the database for Change Data Capture: grants REPLICATION to the service role and creates a publication FOR ALL TABLES. Requires the PostgreSQL server to have wal_level=logical. The replication slot is managed by Debezium, not Terraform."
  type        = bool
  default     = false
}

variable "replication_slot_name" {
  description = "Name for the replication slot. Defaults to <database_name>_slot. This name is passed to the Debezium connector as slot.name — Debezium creates the slot itself. Only used when enable_cdc is true."
  type        = string
  default     = null
}

variable "publication_name" {
  description = "Override for the publication name. Defaults to <database_name>_pub. Only used when enable_cdc is true."
  type        = string
  default     = null
}

