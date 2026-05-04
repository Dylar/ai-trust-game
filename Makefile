TARGET_ENV ?= dev
SERVICE ?=
PORT ?= 8080
BACKEND_PORT ?= 8080
FRONTEND_PORT ?= 3000
APP_ENV ?= $(TARGET_ENV)
API_BASE_URL ?= http://localhost:8080
COMPOSE_ENV_FILE ?= ./infrastructure/env/$(TARGET_ENV).env
GOLANGCI_LINT ?= $(shell go env GOPATH)/bin/golangci-lint
K8S_SERVICE ?= main-service
K8S_RELEASE ?= $(K8S_SERVICE)
K8S_CHART ?= ./infrastructure/k8s/helm/http-service
K8S_VALUES ?= ./services/$(K8S_SERVICE)/k8s/values-$(TARGET_ENV).yaml
K8S_NAMESPACE ?= atg-$(TARGET_ENV)
K8S_ENVS ?= dev test prod
K8S_IMAGE_TAG ?=
K8S_MANUAL_TAG_PREFIX ?= manual-deploy
K8S_KUBECONFIG ?= $(HOME)/.kube/ai-trust-game-pi.yaml
K8S_KUBECTL ?= kubectl --kubeconfig $(K8S_KUBECONFIG)
K8S_HELM ?= helm --kubeconfig $(K8S_KUBECONFIG)
MANUAL_DEPLOY_WORKFLOW ?= deploy.yml
K8S_SET_ARGS :=
ifneq ($(strip $(K8S_IMAGE_TAG)),)
K8S_SET_ARGS += --set image.tag=$(K8S_IMAGE_TAG)
endif

.PHONY: help run build test lint docker-build docker-run docker-build-run docker-logs compose-build compose-up compose-up-detached compose-down compose-logs compose-ps compose-rebuild compose-rebuild-detached compose-restart k8s-lint k8s-template k8s-check-kubeconfig k8s-context k8s-apply k8s-delete k8s-status manual-deploy-tag manual-deploy manuel-deploy

help:
	@echo "Commands:"
	@echo "  make run SERVICE=<name>"
	@echo "  make build SERVICE=<name>"
	@echo "  make docker-build SERVICE=<name>"
	@echo "  make docker-run SERVICE=<name> [PORT=<host-port>]"
	@echo "  make docker-build-run SERVICE=<name> [PORT=<host-port>]"
	@echo "  make docker-logs SERVICE=<name>"
	@echo "  make compose-build [TARGET_ENV=dev|test]"
	@echo "  make compose-up [TARGET_ENV=dev|test]"
	@echo "  make compose-up-detached [TARGET_ENV=dev|test]"
	@echo "  make compose-rebuild [TARGET_ENV=dev|test]"
	@echo "  make compose-rebuild-detached [TARGET_ENV=dev|test]"
	@echo "  make compose-restart [TARGET_ENV=dev|test]"
	@echo "  make compose-down"
	@echo "  make compose-logs"
	@echo "  make compose-ps"
	@echo "  make k8s-lint [K8S_SERVICE=main-service] [K8S_ENVS='dev test prod']"
	@echo "  make k8s-template [K8S_SERVICE=main-service] [TARGET_ENV=dev|test|prod] [K8S_IMAGE_TAG=<tag>]"
	@echo "  make k8s-context [K8S_KUBECONFIG=~/.kube/ai-trust-game-pi.yaml]"
	@echo "  make k8s-apply [K8S_SERVICE=main-service] [TARGET_ENV=dev|test|prod] [K8S_IMAGE_TAG=<tag>]"
	@echo "  make k8s-delete [K8S_SERVICE=main-service] [TARGET_ENV=dev|test|prod]"
	@echo "  make k8s-status"
	@echo "  make manual-deploy K8S_SERVICE=main-service TARGET_ENV=dev [K8S_IMAGE_TAG=<tag>]"
	@echo "  make manual-deploy-tag"
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
	docker run --rm -p $(PORT):8080 -e PORT=8080 -e APP_ENV=$(APP_ENV) $(SERVICE):local

docker-build-run: docker-build docker-run

docker-logs:
	@if [ -z "$(SERVICE)" ]; then \
		echo "Error: SERVICE missing"; \
		echo "Example: make docker-logs SERVICE=main-service"; \
		exit 1; \
	fi
	docker logs -f $$(docker ps -q --filter ancestor=$(SERVICE):local | head -n 1)

compose-up:
	BACKEND_PORT=$(BACKEND_PORT) FRONTEND_PORT=$(FRONTEND_PORT) APP_ENV=$(APP_ENV) API_BASE_URL=$(API_BASE_URL) docker compose --env-file $(COMPOSE_ENV_FILE) up --build

compose-up-detached:
	BACKEND_PORT=$(BACKEND_PORT) FRONTEND_PORT=$(FRONTEND_PORT) APP_ENV=$(APP_ENV) API_BASE_URL=$(API_BASE_URL) docker compose --env-file $(COMPOSE_ENV_FILE) up --build -d

compose-build:
	BACKEND_PORT=$(BACKEND_PORT) FRONTEND_PORT=$(FRONTEND_PORT) APP_ENV=$(APP_ENV) API_BASE_URL=$(API_BASE_URL) docker compose --env-file $(COMPOSE_ENV_FILE) build

compose-rebuild:
	BACKEND_PORT=$(BACKEND_PORT) FRONTEND_PORT=$(FRONTEND_PORT) APP_ENV=$(APP_ENV) API_BASE_URL=$(API_BASE_URL) docker compose --env-file $(COMPOSE_ENV_FILE) up --build --force-recreate

compose-rebuild-detached:
	BACKEND_PORT=$(BACKEND_PORT) FRONTEND_PORT=$(FRONTEND_PORT) APP_ENV=$(APP_ENV) API_BASE_URL=$(API_BASE_URL) docker compose --env-file $(COMPOSE_ENV_FILE) up --build --force-recreate -d

compose-restart:
	docker compose --env-file $(COMPOSE_ENV_FILE) restart

compose-down:
	docker compose --env-file $(COMPOSE_ENV_FILE) down

compose-logs:
	docker compose --env-file $(COMPOSE_ENV_FILE) logs -f

compose-ps:
	docker compose --env-file $(COMPOSE_ENV_FILE) ps

k8s-lint:
	@for env in $(K8S_ENVS); do \
		values_file=./services/$(K8S_SERVICE)/k8s/values-$$env.yaml; \
		echo "Linting $(K8S_SERVICE) $$env"; \
		helm lint $(K8S_CHART) -f $$values_file; \
		echo "Rendering $(K8S_SERVICE) $$env"; \
		helm template $(K8S_RELEASE) $(K8S_CHART) -f $$values_file >/dev/null; \
	done

k8s-template:
	helm template $(K8S_RELEASE) $(K8S_CHART) -f $(K8S_VALUES) $(K8S_SET_ARGS)

k8s-check-kubeconfig:
	@if [ ! -f "$(K8S_KUBECONFIG)" ]; then \
		echo "Error: K8S_KUBECONFIG not found: $(K8S_KUBECONFIG)"; \
		echo "Create the project kubeconfig first or pass K8S_KUBECONFIG=<path>."; \
		exit 1; \
	fi

k8s-context: k8s-check-kubeconfig
	@echo "Using kubeconfig: $(K8S_KUBECONFIG)"
	@$(K8S_KUBECTL) config current-context
	@$(K8S_KUBECTL) get nodes

k8s-apply: k8s-check-kubeconfig
	@image_tag="$(K8S_IMAGE_TAG)"; \
	if [ -z "$$image_tag" ]; then \
		image_tag=$$(git rev-parse HEAD); \
	fi; \
	echo "Deploying $(K8S_RELEASE) to $(K8S_NAMESPACE) with image tag $$image_tag"; \
	$(K8S_HELM) upgrade --install $(K8S_RELEASE) $(K8S_CHART) -f $(K8S_VALUES) --set image.tag=$$image_tag --namespace $(K8S_NAMESPACE) --create-namespace

k8s-delete: k8s-check-kubeconfig
	$(K8S_HELM) uninstall $(K8S_RELEASE) --namespace $(K8S_NAMESPACE)

k8s-status: k8s-check-kubeconfig
	$(K8S_KUBECTL) get deploy,svc,pods -A -l app.kubernetes.io/part-of=ai-trust-game

manual-deploy-tag:
	@commit_sha=$$(git rev-parse --short=12 HEAD); \
	timestamp=$$(date +%Y-%m-%d-%H-%M); \
	echo "$(K8S_MANUAL_TAG_PREFIX)-$$commit_sha-$$timestamp"

manual-deploy:
	@image_tag="$(K8S_IMAGE_TAG)"; \
	if [ -z "$$image_tag" ]; then \
		commit_sha=$$(git rev-parse --short=12 HEAD); \
		timestamp=$$(date +%Y-%m-%d-%H-%M); \
		image_tag="$(K8S_MANUAL_TAG_PREFIX)-$$commit_sha-$$timestamp"; \
	fi; \
	echo "Triggering $(MANUAL_DEPLOY_WORKFLOW) for $(K8S_SERVICE) $(TARGET_ENV) with image tag $$image_tag"; \
	gh workflow run $(MANUAL_DEPLOY_WORKFLOW) \
		-f service=$(K8S_SERVICE) \
		-f environment=$(TARGET_ENV) \
		-f image-tag=$$image_tag

manuel-deploy: manual-deploy

test:
	go test ./...

lint:
	$(GOLANGCI_LINT) run ./...
