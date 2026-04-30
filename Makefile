SERVICE ?=
PORT ?= 8080
BACKEND_PORT ?= 8080
FRONTEND_PORT ?= 3000
APP_FLAVOR ?= dev
API_BASE_URL ?= http://localhost:8080
GOLANGCI_LINT ?= $(shell go env GOPATH)/bin/golangci-lint

.PHONY: help run build test lint docker-build docker-run docker-build-run docker-logs compose-up compose-down compose-logs

help:
	@echo "Commands:"
	@echo "  make run SERVICE=<name>"
	@echo "  make build SERVICE=<name>"
	@echo "  make docker-build SERVICE=<name>"
	@echo "  make docker-run SERVICE=<name> [PORT=<host-port>]"
	@echo "  make docker-build-run SERVICE=<name> [PORT=<host-port>]"
	@echo "  make docker-logs SERVICE=<name>"
	@echo "  make compose-up"
	@echo "  make compose-down"
	@echo "  make compose-logs"
	@echo "  make test"
	@echo "  make lint"

run:
	@if [ -z "$(SERVICE)" ]; then \
		echo "Error: SERVICE missing"; \
		echo "Example: make run SERVICE=main-service"; \
		exit 1; \
	fi
	go run ./services/$(SERVICE)/cmd

build:
	@if [ -z "$(SERVICE)" ]; then \
		echo "Error: SERVICE missing"; \
		echo "Example: make build SERVICE=main-service"; \
		exit 1; \
	fi
	mkdir -p bin
	go build -o ./bin/$(SERVICE) ./services/$(SERVICE)/cmd

docker-build:
	@if [ -z "$(SERVICE)" ]; then \
		echo "Error: SERVICE missing"; \
		echo "Example: make docker-build SERVICE=main-service"; \
		exit 1; \
	fi
	docker build --build-arg SERVICE=$(SERVICE) -f ./infrastructure/docker/go-service.Dockerfile -t $(SERVICE):local .

docker-run:
	@if [ -z "$(SERVICE)" ]; then \
		echo "Error: SERVICE missing"; \
		echo "Example: make docker-run SERVICE=main-service"; \
		exit 1; \
	fi
	docker run --rm -p $(PORT):8080 -e PORT=8080 $(SERVICE):local

docker-build-run: docker-build docker-run

docker-logs:
	@if [ -z "$(SERVICE)" ]; then \
		echo "Error: SERVICE missing"; \
		echo "Example: make docker-logs SERVICE=main-service"; \
		exit 1; \
	fi
	docker logs -f $$(docker ps -q --filter ancestor=$(SERVICE):local | head -n 1)

compose-up:
	BACKEND_PORT=$(BACKEND_PORT) FRONTEND_PORT=$(FRONTEND_PORT) APP_FLAVOR=$(APP_FLAVOR) API_BASE_URL=$(API_BASE_URL) docker compose up --build

compose-down:
	docker compose down

compose-logs:
	docker compose logs -f

test:
	go test ./...

lint:
	$(GOLANGCI_LINT) run ./...
