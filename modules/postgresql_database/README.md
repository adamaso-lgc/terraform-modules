# README — postgresql_database

Creates a PostgreSQL database on an **existing** PostgreSQL server (e.g. an RDS cluster or a shared self-hosted instance), together with a dedicated service role. Optionally configures the database for **Change Data Capture (CDC)** by creating a logical replication slot and publication, ready for [Debezium](https://debezium.io/).

> **The module does not provision the PostgreSQL server itself.** That infrastructure is expected to already exist. For local development, a Docker Compose setup is provided under `.docker/`.

---

## Prerequisites

| Requirement | Notes |
|---|---|
| PostgreSQL ≥ 10 | pgoutput logical decoding plugin is built-in from v10 |
| `wal_level = logical` | **Required only when `enable_cdc = true`.** Must be set at the server level (RDS: via Parameter Group; Docker: see `.docker/docker-compose.yml`) |
| Superuser or `CREATEROLE`+`CREATEDB` role | The credentials in the `postgresql` provider must have sufficient privileges to create roles, databases, publications, and replication slots |

---

## Usage

### Basic database

```hcl
module "orders_db" {
  source = "../modules/postgresql_database"

  database_name = "orders"
  role_password = var.orders_db_password
}
```

### With CDC enabled (for Debezium)

```hcl
module "inventory_db" {
  source = "../modules/postgresql_database"

  database_name = "inventory"
  role_password = var.inventory_db_password
  enable_cdc    = true
}
```

The publication is created `FOR ALL TABLES`. Table filtering belongs in the **Debezium connector config**, not the infrastructure layer — this way the publication works immediately without requiring migrations to have run first:

```json
"table.include.list": "public.outbox"
```

Then point Debezium at:
- **slot.name** → `module.inventory_db.replication_slot_name`
- **publication.name** → `module.inventory_db.publication_name`
- **database.server.name** / **database.dbname** → `module.inventory_db.database_name`

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `database_name` | Name of the database to create. **snake_case**. Also drives role, slot, and publication naming. | `string` | — | yes |
| `role_password` | Password for the dedicated service role. Source from a secrets manager. | `string` (sensitive) | — | yes |
| `database_name` | Override for the database name. Defaults to `service_name`. | `string` | `null` | no |
| `enable_cdc` | Enable CDC: grants REPLICATION to the role, creates a `FOR ALL TABLES` publication and replication slot. Requires `wal_level=logical`. Scope tables via `table.include.list` in the Debezium connector. | `bool` | `false` | no |
| `replication_slot_name` | Override for the replication slot name. Defaults to `<service_name>_slot`. | `string` | `null` | no |
| `publication_name` | Override for the publication name. Defaults to `<service_name>_pub`. | `string` | `null` | no |
| `replication_plugin` | Logical decoding plugin (`pgoutput` or `wal2json`). | `string` | `"pgoutput"` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| `database_name` | Name of the created PostgreSQL database. |
| `role_name` | Name of the dedicated service role. |
| `replication_slot_name` | Name of the CDC replication slot. `null` when `enable_cdc = false`. |
| `publication_name` | Name of the CDC publication. `null` when `enable_cdc = false`. |

---

## Naming conventions

Given `database_name = "orders"`:

| Object | Name |
|--------|------|
| Database | `orders` |
| Role | `orders_user` |
| Replication slot | `orders_slot` |
| Publication | `orders_pub` |

---

## Provider configuration

The module requires the `cyrilgdn/postgresql` provider to be configured by the caller:

```hcl
provider "postgresql" {
  host     = var.pg_host
  port     = var.pg_port
  username = var.pg_admin_user
  password = var.pg_admin_password
  sslmode  = var.pg_ssl_mode   # "disable" locally, "require" or "verify-full" in prod
  superuser = false
}
```

> Set `superuser = false` unless your admin user is a true PostgreSQL superuser. The provider uses this flag to decide whether to use `SET ROLE` when managing objects.

---

## Local development

Start a CDC-ready PostgreSQL instance with Docker Compose:

```sh
cd .docker
docker compose up -d
```

The container starts with `wal_level=logical`, `max_replication_slots=10`, and `max_wal_senders=10`, matching what Debezium needs. Configure the Terraform provider to connect to `localhost:5432`.
