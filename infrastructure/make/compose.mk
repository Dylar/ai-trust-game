COMPOSE_FILE ?= ./infrastructure/docker/compose/compose.yml
COMPOSE_MODEL_ENV ?= static
COMPOSE_ENV_FILE ?= ./infrastructure/docker/compose/env/$(COMPOSE_MODEL_ENV).env
COMPOSE_REQUIRED_VARS ?= LLM_PROVIDER
COMPOSE := docker compose --file $(COMPOSE_FILE) --env-file $(COMPOSE_ENV_FILE)

.PHONY: compose-check-env compose-up compose-down compose-logs compose-restart compose-smoke

compose-check-env:
	@if [ ! -f "$(COMPOSE_FILE)" ]; then \
		echo "Warning: COMPOSE_FILE not found: $(COMPOSE_FILE)"; \
		echo "Pass COMPOSE_FILE=<path> or restore the local Docker Compose file."; \
		exit 1; \
	fi; \
	if [ ! -f "$(COMPOSE_ENV_FILE)" ]; then \
		echo "Warning: COMPOSE_ENV_FILE not found: $(COMPOSE_ENV_FILE)"; \
		echo "Set COMPOSE_MODEL_ENV to an existing model env file or pass COMPOSE_ENV_FILE=<path>."; \
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

compose-up: compose-check-env
	$(COMPOSE) up --build

compose-restart: compose-check-env
	$(COMPOSE) restart

compose-down: compose-check-env
	$(COMPOSE) down

compose-logs: compose-check-env
	$(COMPOSE) logs -f

compose-smoke: compose-check-env
	$(COMPOSE) up -d --build --force-recreate
	$(COMPOSE) exec -T postgres sh -c 'pg_isready -U "$$POSTGRES_USER" -d "$$POSTGRES_DB"'
	$(COMPOSE) exec -T gateway-service wget -qO- http://127.0.0.1:8080/healthz
	$(COMPOSE) exec -T gateway-service wget -qO- http://127.0.0.1:8080/auth/users
