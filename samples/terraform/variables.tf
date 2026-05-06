variable "pg_host" {
  description = "Hostname or IP of the PostgreSQL server."
  type        = string
}

variable "pg_port" {
  description = "Port the PostgreSQL server is listening on."
  type        = number
  default     = 5432
}

variable "pg_admin_user" {
  description = "Admin username with CREATEROLE and CREATEDB privileges."
  type        = string
}

variable "pg_admin_password" {
  description = "Password for the PostgreSQL admin user."
  type        = string
  sensitive   = true
}

variable "pg_ssl_mode" {
  description = "PostgreSQL SSL mode. Use 'disable' locally and 'require' or 'verify-full' in production."
  type        = string
  default     = "require"

  validation {
    condition     = contains(["disable", "require", "verify-ca", "verify-full"], var.pg_ssl_mode)
    error_message = "pg_ssl_mode must be one of: disable, require, verify-ca, verify-full."
  }
}

variable "orders_db_password" {
  description = "Password for the orders-service database role."
  type        = string
  sensitive   = true
}

variable "inventory_db_password" {
  description = "Password for the inventory-service database role."
  type        = string
  sensitive   = true
}

# ── Kafka ──────────────────────────────────────────────────────────────────

variable "kafka_bootstrap_servers" {
  description = "Kafka bootstrap server address. Locally: localhost:9092 (external Confluent broker listener)."
  type        = string
}

variable "kafka_connect_url" {
  description = "Base URL for the Kafka Connect REST API. Locally: http://localhost:8083."
  type        = string
}

variable "pg_cdc_host" {
  description = "PostgreSQL hostname as seen FROM the Kafka Connect container. Locally: the Postgres container name (postgres_local). In production: the RDS endpoint."
  type        = string
}

