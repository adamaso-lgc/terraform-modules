#!/usr/bin/env bash
set -e

# Local-only dev credentials — matches .docker/docker-compose.yml
export TF_VAR_pg_host="localhost"
export TF_VAR_pg_port="5432"
export TF_VAR_pg_admin_user="postgres"
export TF_VAR_pg_admin_password="postgres"
export TF_VAR_pg_ssl_mode="disable"

export TF_VAR_orders_db_password="orders_local_secret"
export TF_VAR_inventory_db_password="inventory_local_secret"

# Kafka — Redpanda external listener (host access)
export TF_VAR_kafka_bootstrap_servers="localhost:9092"
export TF_VAR_kafka_connect_url="http://localhost:8083"

# Debezium connects to Postgres FROM inside the Docker network; use the container name
export TF_VAR_pg_cdc_host="postgres_local"

echo "==> Initialising Terraform..."
terraform init

echo "==> Applying..."
terraform apply -auto-approve

echo "==> Done!"
