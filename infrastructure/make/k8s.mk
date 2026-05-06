K8S_SERVICE ?= main-service
K8S_RELEASE ?= $(K8S_SERVICE)
K8S_CHART ?= ./infrastructure/k8s/chart
K8S_CONFIG_DIR ?= $(if $(filter frontend-web,$(K8S_SERVICE)),./app/k8s,./services/$(K8S_SERVICE)/k8s)
K8S_VALUES ?= $(K8S_CONFIG_DIR)/values-$(TARGET_ENV).yaml
K8S_NAMESPACE ?= atg-$(TARGET_ENV)
K8S_ENTRY ?= ./app/k8s/entry-$(TARGET_ENV).yaml
K8S_ENVS ?= dev test prod
K8S_SERVICES ?= main-service frontend-web
K8S_IMAGE_TAG ?=
K8S_MANUAL_TAG_PREFIX ?= manual-deploy
K8S_KUBECONFIG ?= $(HOME)/.kube/ai-trust-game-pi.yaml
K8S_KUBECTL ?= kubectl --kubeconfig $(K8S_KUBECONFIG)
K8S_HELM ?= helm --kubeconfig $(K8S_KUBECONFIG)
K8S_DOCKER_PLATFORM ?= linux/arm64
K8S_SET_ARGS :=
ifneq ($(strip $(K8S_IMAGE_TAG)),)
K8S_SET_ARGS += --set image.tag=$(K8S_IMAGE_TAG)
endif

.PHONY: k8s-lint k8s-template k8s-check-kubeconfig k8s-context k8s-build-push k8s-apply k8s-deploy k8s-delete k8s-apply-entry k8s-delete-entry k8s-status manual-deploy-tag manual-deploy

k8s-lint:
	@for env in $(K8S_ENVS); do \
		values_file=$(K8S_CONFIG_DIR)/values-$$env.yaml; \
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

k8s-build-push:
	@if [ -z "$(K8S_IMAGE_TAG)" ]; then \
		echo "Error: K8S_IMAGE_TAG missing"; \
		exit 1; \
	fi
	@image_repo=$$(yq eval -r '.image.repository' "$(K8S_VALUES)"); \
	if [ -z "$$image_repo" ] || [ "$$image_repo" = "null" ]; then \
		echo "Error: image.repository missing in $(K8S_VALUES)"; \
		exit 1; \
	fi; \
	echo "Building and pushing $(K8S_SERVICE) for $(TARGET_ENV) as $$image_repo:$(K8S_IMAGE_TAG)"; \
	case "$(K8S_SERVICE)" in \
		main-service) \
			docker buildx build \
				--platform $(K8S_DOCKER_PLATFORM) \
				--build-arg SERVICE=main-service \
				-f ./infrastructure/docker/go-service.Dockerfile \
				-t "$$image_repo:$(K8S_IMAGE_TAG)" \
				--push . ;; \
		frontend-web) \
			docker buildx build \
				--platform $(K8S_DOCKER_PLATFORM) \
				--build-arg APP_ENV=$(TARGET_ENV) \
				--build-arg API_BASE_URL="$(API_BASE_URL)" \
				-f ./infrastructure/docker/flutter-web.Dockerfile \
				-t "$$image_repo:$(K8S_IMAGE_TAG)" \
				--push . ;; \
		*) \
			echo "Error: unsupported K8S_SERVICE for k8s-build-push: $(K8S_SERVICE)"; \
			exit 1 ;; \
	esac

k8s-apply: k8s-check-kubeconfig
	@image_tag="$(K8S_IMAGE_TAG)"; \
	if [ -z "$$image_tag" ]; then \
		image_tag=$$(git rev-parse HEAD); \
	fi; \
	echo "Deploying $(K8S_RELEASE) to $(K8S_NAMESPACE) with image tag $$image_tag"; \
	$(K8S_HELM) upgrade --install $(K8S_RELEASE) $(K8S_CHART) -f $(K8S_VALUES) --set image.tag=$$image_tag --namespace $(K8S_NAMESPACE) --create-namespace

k8s-deploy: k8s-check-kubeconfig
	@image_tag="$(K8S_IMAGE_TAG)"; \
	if [ -z "$$image_tag" ]; then \
		image_tag=$$(git rev-parse HEAD); \
	fi; \
	for service in $(K8S_SERVICES); do \
		$(MAKE) k8s-apply K8S_SERVICE=$$service TARGET_ENV=$(TARGET_ENV) K8S_IMAGE_TAG=$$image_tag || exit $$?; \
	done; \
	if [ -f "$(K8S_ENTRY)" ]; then \
		$(MAKE) k8s-apply-entry TARGET_ENV=$(TARGET_ENV); \
	else \
		echo "No app entry manifest for $(TARGET_ENV), skipping app entry."; \
	fi

k8s-delete: k8s-check-kubeconfig
	$(K8S_HELM) uninstall $(K8S_RELEASE) --namespace $(K8S_NAMESPACE)

k8s-apply-entry: k8s-check-kubeconfig
	@if [ ! -f "$(K8S_ENTRY)" ]; then \
		echo "Error: K8S_ENTRY not found: $(K8S_ENTRY)"; \
		exit 1; \
	fi
	$(K8S_KUBECTL) apply -f $(K8S_ENTRY)

k8s-delete-entry: k8s-check-kubeconfig
	@if [ ! -f "$(K8S_ENTRY)" ]; then \
		echo "Error: K8S_ENTRY not found: $(K8S_ENTRY)"; \
		exit 1; \
	fi
	$(K8S_KUBECTL) delete -f $(K8S_ENTRY) --ignore-not-found

k8s-status: k8s-check-kubeconfig
	$(K8S_KUBECTL) get deploy,svc,pods -A -l app.kubernetes.io/part-of=ai-trust-game

manual-deploy-tag:
	@commit_sha=$$(git rev-parse --short=12 HEAD); \
	dirty_suffix=""; \
	if ! git diff --quiet || ! git diff --cached --quiet; then \
		dirty_suffix="-dirty"; \
	fi; \
	timestamp=$$(date +%Y-%m-%d-%H-%M); \
	echo "$(K8S_MANUAL_TAG_PREFIX)-$$commit_sha$$dirty_suffix-$$timestamp"

manual-deploy:
	@image_tag="$(K8S_IMAGE_TAG)"; \
	if [ -z "$$image_tag" ]; then \
		commit_sha=$$(git rev-parse --short=12 HEAD); \
		dirty_suffix=""; \
		if ! git diff --quiet || ! git diff --cached --quiet; then \
			dirty_suffix="-dirty"; \
		fi; \
		timestamp=$$(date +%Y-%m-%d-%H-%M); \
		image_tag="$(K8S_MANUAL_TAG_PREFIX)-$$commit_sha$$dirty_suffix-$$timestamp"; \
	fi; \
	for service in $(K8S_SERVICES); do \
		$(MAKE) k8s-build-push K8S_SERVICE=$$service TARGET_ENV=$(TARGET_ENV) K8S_IMAGE_TAG=$$image_tag API_BASE_URL="$(API_BASE_URL)" || exit $$?; \
	done; \
	$(MAKE) k8s-deploy TARGET_ENV=$(TARGET_ENV) K8S_IMAGE_TAG=$$image_tag
