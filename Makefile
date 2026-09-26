export BUILDKIT_PROGRESS := plain
COMPOSE := docker compose --progress=plain

.PHONY: clone build start start-detach restart down stop logs status

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
# Routes through start/restart scripts so a first run can build with gh auth.
ifeq ($(OS),Windows_NT)
start:
	powershell -NoProfile -ExecutionPolicy Bypass -File start.ps1

restart:
	powershell -NoProfile -ExecutionPolicy Bypass -File restart.ps1
else
start:
	bash start.sh

restart:
	bash restart.sh
endif

start-detach:
	$(COMPOSE) up -d --remove-orphans

down:
	$(COMPOSE) down

# Alias for down (stops this repo's compose project only).
stop: down

logs:
	$(COMPOSE) logs -f --timestamps

status:
	$(COMPOSE) ps
