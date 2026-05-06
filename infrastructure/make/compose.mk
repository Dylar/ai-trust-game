COMPOSE_FILE ?= ./infrastructure/docker/compose/compose.yml
COMPOSE_ENV_FILE ?= ./infrastructure/docker/compose/env/$(TARGET_ENV).env
COMPOSE_REQUIRED_VARS ?= APP_ENV API_BASE_URL BACKEND_PORT FRONTEND_PORT LLM_PROVIDER
COMPOSE := docker compose --file $(COMPOSE_FILE) --env-file $(COMPOSE_ENV_FILE)

.PHONY: compose-check-env compose-build compose-up-run compose-up compose-up-detached compose-down compose-logs compose-ps compose-rebuild compose-rebuild-detached compose-restart

compose-check-env:
	@if [ ! -f "$(COMPOSE_FILE)" ]; then \
		echo "Warning: COMPOSE_FILE not found: $(COMPOSE_FILE)"; \
		echo "Pass COMPOSE_FILE=<path> or restore the local Docker Compose file."; \
		exit 1; \
	fi; \
	if [ ! -f "$(COMPOSE_ENV_FILE)" ]; then \
		echo "Warning: COMPOSE_ENV_FILE not found: $(COMPOSE_ENV_FILE)"; \
		echo "Set TARGET_ENV to an existing env file or pass COMPOSE_ENV_FILE=<path>."; \
		exit 1; \
	fi; \
	missing=0; \
	for name in $(COMPOSE_REQUIRED_VARS); do \
		if ! grep -Eq "^$$name=" "$(COMPOSE_ENV_FILE)"; then \
			echo "Warning: $$name is missing in $(COMPOSE_ENV_FILE)"; \
			missing=1; \
		fi; \
	done; \
	exit $$missing

compose-up-run: compose-check-env
	$(COMPOSE) up $(COMPOSE_UP_ARGS)

compose-up: COMPOSE_UP_ARGS = --build
compose-up: compose-up-run

compose-up-detached: COMPOSE_UP_ARGS = --build -d
compose-up-detached: compose-up-run

compose-rebuild: COMPOSE_UP_ARGS = --build --force-recreate
compose-rebuild: compose-up-run

compose-rebuild-detached: COMPOSE_UP_ARGS = --build --force-recreate -d
compose-rebuild-detached: compose-up-run

compose-build: compose-check-env
	$(COMPOSE) build

compose-restart: compose-check-env
	$(COMPOSE) restart

compose-down: compose-check-env
	$(COMPOSE) down

compose-logs: compose-check-env
	$(COMPOSE) logs -f

compose-ps: compose-check-env
	$(COMPOSE) ps
