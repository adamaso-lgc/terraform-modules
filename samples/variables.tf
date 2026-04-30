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
