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

echo "==> Destroying..."
terraform destroy -auto-approve

echo "==> Done!"
