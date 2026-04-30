# terraform-modules

Shared Terraform modules for personal projects. Each module targets a specific infrastructure concern at the **application layer** — it connects to existing platform-level infrastructure rather than provisioning it from scratch.

---

## Modules

| Module | Description |
|--------|-------------|
| [`postgresql_database`](modules/postgresql_database/README.md) | Creates a database and dedicated service role on an existing PostgreSQL server. Optionally configures CDC (replication slot + publication) for Debezium. |
| [`kafka_topic`](modules/kafka_topic) | Creates a Kafka topic on an existing broker using the `Mongey/kafka` provider. |
| [`debezium_connector`](modules/debezium_connector) | Registers a Debezium PostgreSQL source connector via the Kafka Connect REST API. Wires a CDC-enabled database to a Kafka topic. |

---

## Local development

A full local stack (PostgreSQL, Redpanda, Kafka Connect, Redpanda Console) is provided via Docker Compose in `.docker/`.

### Prerequisites

- Docker with Compose v2
- Terraform ≥ 1.5.6
- Go ≥ 1.26 (for the Go sample)
- [`migrate`](https://github.com/golang-migrate/migrate) CLI (to run DB migrations manually)

### Makefile targets

| Target | Description |
|--------|-------------|
| `make up` | Start all containers and wait until healthy |
| `make down` | Stop and remove containers |
| `make down-v` | Stop and remove containers **and volumes** |
| `make local-apply` | `terraform init` + `apply` against the local stack |
| `make local-destroy` | `terraform destroy` against the local stack |
| `make local-reset` | Destroy then re-apply |
| `make run-outbox` | Run the Go sample to insert an outbox event |

```sh
make up
make local-apply
make run-outbox        # inserts a sample event into inventory.public.outbox
```

Open **http://localhost:8080** (Redpanda Console) to inspect topics and CDC events.

---

## Samples

The `samples/` directory contains working examples.

### `samples/terraform/`

Terraform configuration that exercises all three modules against the local Docker stack:

- `orders` database (no CDC)
- `inventory` database with CDC enabled
- Kafka topic `inventory.public.outbox`
- Debezium connector wiring Postgres → Kafka

Run via `make local-apply` / `make local-destroy`.

### `samples/go-outbox/`

Minimal Go application that connects to the `inventory` database as `inventory_user` and inserts an event into `public.outbox`.

**Before first run**, apply the migration to create the table:

```sh
migrate -path samples/go-outbox/migrations \
        -database "postgres://inventory_user:inventory_local_secret@localhost:5432/inventory?sslmode=disable" \
        up
```

Then run the app:

```sh
make run-outbox
# or directly:
cd samples/go-outbox && go run .
```

Environment variables (all optional, defaults match the local Docker stack):

| Variable | Default |
|----------|---------|
| `OUTBOX_DB_HOST` | `localhost` |
| `OUTBOX_DB_PORT` | `5432` |
| `OUTBOX_DB_NAME` | `inventory` |
| `OUTBOX_DB_USER` | `inventory_user` |
| `OUTBOX_DB_PASSWORD` | `inventory_local_secret` |

