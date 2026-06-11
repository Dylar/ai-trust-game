SERVICE ?=
SERVICES ?= gateway-service auth-service game-service logging-service audit-service frontend-web
K8S_SELECTED_SERVICE := $(if $(strip $(SERVICE)),$(SERVICE),gateway-service)
K8S_DEPLOY_SERVICES := $(if $(strip $(SERVICE)),$(SERVICE),$(SERVICES))
K8S_RELEASE ?= $(K8S_SELECTED_SERVICE)
K8S_CHART ?= ./infrastructure/k8s/service-chart
K8S_CONFIG_DIR ?= $(if $(filter frontend-web,$(K8S_SELECTED_SERVICE)),./apps/trust-game-app/k8s,./services/$(K8S_SELECTED_SERVICE)/k8s)
K8S_BASE_VALUES ?= $(K8S_CONFIG_DIR)/values.yaml
K8S_VALUES ?= $(K8S_CONFIG_DIR)/values-$(ENV).yaml
K8S_VALUES_ARGS := $(if $(wildcard $(K8S_BASE_VALUES)),-f $(K8S_BASE_VALUES),) -f $(K8S_VALUES)
K8S_NAMESPACE ?= atg-$(ENV)
K8S_ENTRY_RELEASE ?= app-entry
K8S_ENTRY_CHART ?= ./infrastructure/k8s/entry-chart
K8S_ENTRY_VALUES ?= ./apps/trust-game-app/k8s/entry-values-$(ENV).yaml
K8S_RABBITMQ_RELEASE ?= rabbitmq
K8S_RABBITMQ_CHART ?= ./infrastructure/k8s/rabbitmq-chart
K8S_RABBITMQ_CONFIG_DIR ?= ./infrastructure/k8s/rabbitmq
K8S_RABBITMQ_BASE_VALUES ?= $(K8S_RABBITMQ_CONFIG_DIR)/values.yaml
K8S_RABBITMQ_VALUES ?= $(K8S_RABBITMQ_CONFIG_DIR)/values-$(ENV).yaml
K8S_RABBITMQ_VALUES_ARGS := $(if $(wildcard $(K8S_RABBITMQ_BASE_VALUES)),-f $(K8S_RABBITMQ_BASE_VALUES),) -f $(K8S_RABBITMQ_VALUES)
K8S_POSTGRES_RELEASE ?= postgres
K8S_POSTGRES_CHART ?= ./infrastructure/k8s/postgres-chart
K8S_POSTGRES_CONFIG_DIR ?= ./infrastructure/k8s/postgres
K8S_POSTGRES_BASE_VALUES ?= $(K8S_POSTGRES_CONFIG_DIR)/values.yaml
K8S_POSTGRES_VALUES ?= $(K8S_POSTGRES_CONFIG_DIR)/values-$(ENV).yaml
K8S_POSTGRES_VALUES_ARGS := $(if $(wildcard $(K8S_POSTGRES_BASE_VALUES)),-f $(K8S_POSTGRES_BASE_VALUES),) -f $(K8S_POSTGRES_VALUES)
K8S_ENVS ?= dev test prod
IMAGE_TAG ?=
K8S_DEPLOY_IMAGE_TAG ?=
K8S_MANUAL_TAG_PREFIX ?= manual-deploy
K8S_KUBECONFIG ?= $(HOME)/.kube/ai-trust-game-pi.yaml
K8S_KUBECTL ?= kubectl --kubeconfig $(K8S_KUBECONFIG)
K8S_HELM ?= helm --kubeconfig $(K8S_KUBECONFIG)
K8S_DOCKER_PLATFORM ?= linux/arm64
K8S_SET_ARGS :=
ifneq ($(strip $(IMAGE_TAG)),)
K8S_SET_ARGS += --set image.tag=$(IMAGE_TAG)
endif

.PHONY: k8s-lint k8s-template k8s-template-rabbitmq k8s-template-postgres k8s-check-kubeconfig k8s-context k8s-build-push k8s-apply k8s-apply-rabbitmq k8s-apply-postgres k8s-deploy k8s-delete k8s-delete-rabbitmq k8s-delete-postgres k8s-apply-entry k8s-delete-entry k8s-status manual-deploy-tag manual-deploy

k8s-lint:
	@for service in $(K8S_DEPLOY_SERVICES); do \
		for env in $(K8S_ENVS); do \
			if [ "$$service" = "frontend-web" ]; then \
				base_values_file=./apps/trust-game-app/k8s/values.yaml; \
				values_file=./apps/trust-game-app/k8s/values-$$env.yaml; \
			else \
				base_values_file=./services/$$service/k8s/values.yaml; \
				values_file=./services/$$service/k8s/values-$$env.yaml; \
			fi; \
			values_args="-f $$values_file"; \
			if [ -f "$$base_values_file" ]; then \
				values_args="-f $$base_values_file -f $$values_file"; \
			fi; \
			echo "Linting $$service $$env"; \
			helm lint $(K8S_CHART) $$values_args; \
			echo "Rendering $$service $$env"; \
			helm template $$service $(K8S_CHART) $$values_args >/dev/null; \
		done; \
	done
	@if [ -z "$(strip $(SERVICE))" ]; then \
		for env in $(K8S_ENVS); do \
			echo "Linting postgres $$env"; \
			helm lint $(K8S_POSTGRES_CHART) -f $(K8S_POSTGRES_BASE_VALUES) -f $(K8S_POSTGRES_CONFIG_DIR)/values-$$env.yaml; \
			echo "Rendering postgres $$env"; \
			helm template $(K8S_POSTGRES_RELEASE) $(K8S_POSTGRES_CHART) -f $(K8S_POSTGRES_BASE_VALUES) -f $(K8S_POSTGRES_CONFIG_DIR)/values-$$env.yaml >/dev/null; \
			echo "Linting rabbitmq $$env"; \
			helm lint $(K8S_RABBITMQ_CHART) -f $(K8S_RABBITMQ_BASE_VALUES) -f $(K8S_RABBITMQ_CONFIG_DIR)/values-$$env.yaml; \
			echo "Rendering rabbitmq $$env"; \
			helm template $(K8S_RABBITMQ_RELEASE) $(K8S_RABBITMQ_CHART) -f $(K8S_RABBITMQ_BASE_VALUES) -f $(K8S_RABBITMQ_CONFIG_DIR)/values-$$env.yaml >/dev/null; \
		done; \
	fi

k8s-template:
	helm template $(K8S_RELEASE) $(K8S_CHART) $(K8S_VALUES_ARGS) $(K8S_SET_ARGS)

k8s-template-rabbitmq:
	helm template $(K8S_RABBITMQ_RELEASE) $(K8S_RABBITMQ_CHART) $(K8S_RABBITMQ_VALUES_ARGS)

k8s-template-postgres:
	helm template $(K8S_POSTGRES_RELEASE) $(K8S_POSTGRES_CHART) $(K8S_POSTGRES_VALUES_ARGS)

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

k8s-build-push:
	@if [ -z "$(IMAGE_TAG)" ]; then \
		echo "Error: IMAGE_TAG missing"; \
		exit 1; \
	fi
	@image_repo=$$(yq eval -r '.image.repository // ""' "$(K8S_VALUES)"); \
	if [ -z "$$image_repo" ] || [ "$$image_repo" = "null" ]; then \
		if [ -f "$(K8S_BASE_VALUES)" ]; then \
			image_repo=$$(yq eval -r '.image.repository // ""' "$(K8S_BASE_VALUES)"); \
		fi; \
	fi; \
	if [ -z "$$image_repo" ] || [ "$$image_repo" = "null" ]; then \
		echo "Error: image.repository missing in $(K8S_BASE_VALUES) and $(K8S_VALUES)"; \
		exit 1; \
	fi; \
	echo "Building and pushing $(K8S_SELECTED_SERVICE) for $(ENV) as $$image_repo:$(IMAGE_TAG)"; \
	case "$(K8S_SELECTED_SERVICE)" in \
		gateway-service|auth-service|game-service|logging-service|audit-service) \
			docker buildx build \
				--platform $(K8S_DOCKER_PLATFORM) \
				--build-arg SERVICE=$(K8S_SELECTED_SERVICE) \
				-f ./infrastructure/docker/go-service.Dockerfile \
				-t "$$image_repo:$(IMAGE_TAG)" \
				--push . ;; \
		frontend-web) \
			docker buildx build \
				--platform $(K8S_DOCKER_PLATFORM) \
				--build-arg APP_ENV=$(ENV) \
				--build-arg API_BASE_URL="$(API_BASE_URL)" \
				-f ./infrastructure/docker/flutter-web.Dockerfile \
				-t "$$image_repo:$(IMAGE_TAG)" \
				--push . ;; \
		*) \
			echo "Error: unsupported SERVICE for k8s-build-push: $(K8S_SELECTED_SERVICE)"; \
			exit 1 ;; \
	esac

k8s-apply: k8s-check-kubeconfig
	@image_tag="$(IMAGE_TAG)"; \
	if [ -z "$$image_tag" ]; then \
		image_tag=$$(git rev-parse HEAD); \
	fi; \
	echo "Deploying $(K8S_RELEASE) to $(K8S_NAMESPACE) with image tag $$image_tag"; \
	$(K8S_HELM) upgrade --install $(K8S_RELEASE) $(K8S_CHART) $(K8S_VALUES_ARGS) --set image.tag=$$image_tag --namespace $(K8S_NAMESPACE) --create-namespace

k8s-apply-rabbitmq: k8s-check-kubeconfig
	@if [ ! -f "$(K8S_RABBITMQ_VALUES)" ]; then \
		echo "Error: K8S_RABBITMQ_VALUES not found: $(K8S_RABBITMQ_VALUES)"; \
		exit 1; \
	fi
	$(K8S_HELM) upgrade --install $(K8S_RABBITMQ_RELEASE) $(K8S_RABBITMQ_CHART) $(K8S_RABBITMQ_VALUES_ARGS) --namespace $(K8S_NAMESPACE) --create-namespace

k8s-apply-postgres: k8s-check-kubeconfig
	@if [ ! -f "$(K8S_POSTGRES_VALUES)" ]; then \
		echo "Error: K8S_POSTGRES_VALUES not found: $(K8S_POSTGRES_VALUES)"; \
		exit 1; \
	fi
	$(K8S_HELM) upgrade --install $(K8S_POSTGRES_RELEASE) $(K8S_POSTGRES_CHART) $(K8S_POSTGRES_VALUES_ARGS) --namespace $(K8S_NAMESPACE) --create-namespace

k8s-deploy:
	@if [ -n "$(IMAGE_TAG)" ]; then \
		echo "Error: k8s-deploy uses the current commit SHA as image tag. Do not pass IMAGE_TAG."; \
		echo "Use k8s-apply for an already published custom tag, or manual-deploy for local builds."; \
		exit 1; \
	fi; \
	$(MAKE) k8s-check-kubeconfig || exit $$?; \
	image_tag="$(K8S_DEPLOY_IMAGE_TAG)"; \
	if [ -z "$$image_tag" ]; then \
		image_tag=$$(git rev-parse HEAD); \
	fi; \
	if [ -z "$(strip $(SERVICE))" ]; then \
		$(MAKE) k8s-apply-postgres ENV=$(ENV) || exit $$?; \
		$(MAKE) k8s-apply-rabbitmq ENV=$(ENV) || exit $$?; \
	fi; \
	for service in $(K8S_DEPLOY_SERVICES); do \
		$(MAKE) k8s-apply SERVICE=$$service ENV=$(ENV) IMAGE_TAG=$$image_tag || exit $$?; \
	done; \
	if [ -z "$(strip $(SERVICE))" ]; then \
		if [ -f "$(K8S_ENTRY_VALUES)" ]; then \
			$(MAKE) k8s-apply-entry ENV=$(ENV); \
		else \
			echo "No app entry values for $(ENV), skipping app entry."; \
		fi; \
	fi

k8s-delete: k8s-check-kubeconfig
	$(K8S_HELM) uninstall $(K8S_RELEASE) --namespace $(K8S_NAMESPACE)

k8s-delete-rabbitmq: k8s-check-kubeconfig
	$(K8S_HELM) uninstall $(K8S_RABBITMQ_RELEASE) --namespace $(K8S_NAMESPACE) --ignore-not-found

k8s-delete-postgres: k8s-check-kubeconfig
	$(K8S_HELM) uninstall $(K8S_POSTGRES_RELEASE) --namespace $(K8S_NAMESPACE) --ignore-not-found

k8s-apply-entry: k8s-check-kubeconfig
	@if [ ! -f "$(K8S_ENTRY_VALUES)" ]; then \
		echo "Error: K8S_ENTRY_VALUES not found: $(K8S_ENTRY_VALUES)"; \
		exit 1; \
	fi
	$(K8S_HELM) upgrade --install $(K8S_ENTRY_RELEASE) $(K8S_ENTRY_CHART) -f $(K8S_ENTRY_VALUES) --namespace $(K8S_NAMESPACE) --create-namespace

k8s-delete-entry: k8s-check-kubeconfig
	$(K8S_HELM) uninstall $(K8S_ENTRY_RELEASE) --namespace $(K8S_NAMESPACE) --ignore-not-found

k8s-status: k8s-check-kubeconfig
	$(K8S_KUBECTL) get deploy,svc,pods -A -l app.kubernetes.io/part-of=ai-trust-game

manual-deploy-tag:
	@commit_sha=$$(git rev-parse --short=12 HEAD); \
	timestamp=$$(date +%Y-%m-%d-%H-%M); \
	echo "$(K8S_MANUAL_TAG_PREFIX)-$$commit_sha-$$timestamp"

manual-deploy:
	@if [ -n "$(IMAGE_TAG)" ]; then \
		echo "Error: manual-deploy always generates its own image tag. Do not pass IMAGE_TAG."; \
		exit 1; \
	fi; \
	commit_sha=$$(git rev-parse --short=12 HEAD); \
	timestamp=$$(date +%Y-%m-%d-%H-%M); \
	image_tag="$(K8S_MANUAL_TAG_PREFIX)-$$commit_sha-$$timestamp"; \
	for service in $(K8S_DEPLOY_SERVICES); do \
		$(MAKE) k8s-build-push SERVICE=$$service ENV=$(ENV) IMAGE_TAG=$$image_tag API_BASE_URL="$(API_BASE_URL)" || exit $$?; \
	done; \
	$(MAKE) k8s-deploy SERVICE="$(SERVICE)" ENV=$(ENV) K8S_DEPLOY_IMAGE_TAG=$$image_tag
