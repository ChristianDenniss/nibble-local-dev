COMPOSE := docker compose

.PHONY: clone build up down logs status

ifeq ($(OS),Windows_NT)
clone:
	powershell -NoProfile -ExecutionPolicy Bypass -File clone.ps1
else
clone:
	bash clone.sh
endif

build:
	$(COMPOSE) pull
ifeq ($(OS),Windows_NT)
	powershell -NoProfile -ExecutionPolicy Bypass -File with-github-auth.ps1 build
else
	bash with-github-auth.sh $(COMPOSE) build
endif

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f

status:
	$(COMPOSE) ps
