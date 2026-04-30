terraform {
  required_version = ">= 1.5.6"

  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.22"
    }
  }
}

provider "postgresql" {
  host     = var.pg_host
  port     = var.pg_port
  username = var.pg_admin_user
  password = var.pg_admin_password
  sslmode  = var.pg_ssl_mode

  # Set to true only if the admin user is a real PostgreSQL superuser.
  # When false the provider uses SET ROLE instead of direct object ownership.
  superuser = false
}
