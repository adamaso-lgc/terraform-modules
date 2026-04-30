# terraform-modules

Shared Terraform modules for personal projects. Each module targets a specific infrastructure concern at the **application layer** — it connects to existing platform-level infrastructure rather than provisioning it from scratch.

---

## Modules

| Module | Description |
|--------|-------------|
| [`postgresql_database`](modules/postgresql_database/README.md) | Creates a database and dedicated service role on an existing PostgreSQL server. Optionally configures CDC (replication slot + publication) for Debezium. |

---

## Local development

A Docker Compose setup is provided in `.docker/` to run dependencies locally:

```sh
cd .docker
docker compose up -d
```

See `.docker/.env` for configurable versions and ports.

---

## Samples

The `samples/` directory contains example Terraform configurations showing how to use each module.
