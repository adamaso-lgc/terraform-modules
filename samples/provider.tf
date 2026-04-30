terraform {
  required_version = ">= 1.5.6"

  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.22"
    }
    kafka = {
      source  = "Mongey/kafka"
      version = ">= 0.7"
    }
    kafka-connect = {
      source  = "Mongey/kafka-connect"
      version = ">= 0.2"
    }
  }
}

provider "postgresql" {
  host      = var.pg_host
  port      = var.pg_port
  username  = var.pg_admin_user
  password  = var.pg_admin_password
  sslmode   = var.pg_ssl_mode
  superuser = false
}

provider "kafka" {
  bootstrap_servers = [var.kafka_bootstrap_servers]
  tls_enabled       = false
}

provider "kafka-connect" {
  url = var.kafka_connect_url
}
