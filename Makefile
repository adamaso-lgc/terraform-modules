DOCKER_COMPOSE := docker compose -f .docker/docker-compose.yml

.PHONY: up down down-v local-apply local-destroy local-reset help

## up           Start the local Postgres container and wait until healthy.
up:
	$(DOCKER_COMPOSE) up -d --wait

## down         Stop and remove the local Postgres container.
down:
	$(DOCKER_COMPOSE) down

## down-v       Stop and remove the local Postgres container and its volumes.
down-v:
	$(DOCKER_COMPOSE) down -v

## local-apply  Init and apply the sample config against local Docker Postgres.
local-apply:
	cd samples && bash localapply.sh

## local-destroy  Destroy all Terraform-managed resources against local Docker Postgres.
local-destroy:
	cd samples && bash localdestroy.sh

## local-reset  Destroy then re-apply (useful after config changes).
local-reset: local-destroy local-apply

## help         Show available targets.
help:
	@grep -E '^##' Makefile | sed 's/^## //'
