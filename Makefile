COMPOSE := docker compose

.PHONY: clone bootstrap up down logs status

ifeq ($(OS),Windows_NT)
clone:
	powershell -NoProfile -ExecutionPolicy Bypass -File clone.ps1
else
clone:
	bash clone.sh
endif

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
