COMPOSE := docker compose

.PHONY: bootstrap up down logs status

bootstrap:
	$(COMPOSE) pull
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f

status:
	$(COMPOSE) ps
