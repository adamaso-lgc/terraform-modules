DOCKER_COMPOSE := docker compose -f .docker/docker-compose.yml
DB_URL         ?= postgres://inventory_user:inventory_local_secret@localhost:5432/inventory?sslmode=disable
MIGRATE_PATH   ?= samples/go-outbox/migrations

.PHONY: up down down-v local-apply local-destroy local-reset migrate-up run-outbox help

## up           Start the local Postgres container and wait until healthy.
up:
	docker network create terraformresources_default 2>/dev/null || true
	$(DOCKER_COMPOSE) up -d --wait

## down         Stop and remove the local Postgres container.
down:
	$(DOCKER_COMPOSE) down

## down-v       Stop and remove the local Postgres container and its volumes.
down-v:
	$(DOCKER_COMPOSE) down -v

## local-apply  Init and apply the sample config against local Docker Postgres.
local-apply:
	cd samples/terraform && bash localapply.sh

## local-destroy  Destroy all Terraform-managed resources against local Docker Postgres.
local-destroy:
	cd samples/terraform && bash localdestroy.sh

## local-reset  Destroy then re-apply (useful after config changes).
local-reset: local-destroy local-apply

## migrate-create  Create a new migration file with the given name (e.g., `make migrate-create name=add_users_table`).
migrate-create:
	migrate create -ext sql -dir $(MIGRATE_PATH) -seq $(name)

## migrate-up       Apply all pending migrations to the local Postgres database.
migrate-up:
	migrate -path $(MIGRATE_PATH) -database "$(DB_URL)" -verbose up

## run-outbox   Run the Go sample to insert an event into inventory.public.outbox.
run-outbox:
	cd samples/go-outbox && go run .

## help         Show available targets.
help:
	@grep -E '^##' Makefile | sed 's/^## //'
