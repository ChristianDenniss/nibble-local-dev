export BUILDKIT_PROGRESS := plain
COMPOSE := docker compose --progress=plain

.PHONY: clone build start start-detach restart down logs status

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
	powershell -NoProfile -ExecutionPolicy Bypass -File with-github-auth.ps1 --progress=plain build
else
	bash with-github-auth.sh $(COMPOSE) build
endif

# Foreground: postgres init, migrations, and every service stream into this terminal.
start:
	$(COMPOSE) up --remove-orphans --timestamps

start-detach:
	$(COMPOSE) up -d --remove-orphans

restart:
	$(COMPOSE) down
	$(COMPOSE) up --remove-orphans --timestamps

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f --timestamps

status:
	$(COMPOSE) ps
