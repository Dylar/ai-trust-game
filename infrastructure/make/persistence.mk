POSTGRES_DATABASE_URL ?= $(DATABASE_URL)
POSTGRES_MIGRATIONS_PATH ?= ./infrastructure/persistence/postgres/migrations
MIGRATE_VERSION ?= v4.18.3
MIGRATE := go run github.com/golang-migrate/migrate/v4/cmd/migrate@$(MIGRATE_VERSION)

.PHONY: migrate-check-env migrate-up migrate-down

migrate-check-env:
	@if [ -z "$(POSTGRES_DATABASE_URL)" ]; then \
		echo "Warning: POSTGRES_DATABASE_URL is empty."; \
		echo "Set DATABASE_URL or POSTGRES_DATABASE_URL before running migrations."; \
		exit 1; \
	fi

migrate-up: migrate-check-env
	$(MIGRATE) -path "$(POSTGRES_MIGRATIONS_PATH)" -database "$(POSTGRES_DATABASE_URL)" up

migrate-down: migrate-check-env
	$(MIGRATE) -path "$(POSTGRES_MIGRATIONS_PATH)" -database "$(POSTGRES_DATABASE_URL)" down 1
