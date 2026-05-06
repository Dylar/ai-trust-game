include infrastructure/make/common.mk
include infrastructure/make/go.mk
include infrastructure/make/docker.mk
include infrastructure/make/compose.mk
include infrastructure/make/k8s.mk

.PHONY: help

help:
	@echo "Commands:"
	@echo "  make run SERVICE=<name>"
	@echo "  make build SERVICE=<name>"
	@echo "  make docker-build SERVICE=<name>"
	@echo "  make docker-run SERVICE=<name> [PORT=<host-port>]"
	@echo "  make docker-build-run SERVICE=<name> [PORT=<host-port>]"
	@echo "  make docker-logs SERVICE=<name>"
	@echo "  make compose-build [COMPOSE_MODEL_ENV=static]"
	@echo "  make compose-up [COMPOSE_MODEL_ENV=static]"
	@echo "  make compose-up-detached [COMPOSE_MODEL_ENV=static]"
	@echo "  make compose-rebuild [COMPOSE_MODEL_ENV=static]"
	@echo "  make compose-rebuild-detached [COMPOSE_MODEL_ENV=static]"
	@echo "  make compose-restart [COMPOSE_MODEL_ENV=static]"
	@echo "  make compose-down [COMPOSE_MODEL_ENV=static]"
	@echo "  make compose-logs [COMPOSE_MODEL_ENV=static]"
	@echo "  make compose-ps [COMPOSE_MODEL_ENV=static]"
	@echo "  make k8s-lint [K8S_SERVICE=main-service] [K8S_ENVS='dev test prod']"
	@echo "  make k8s-template [K8S_SERVICE=main-service] [TARGET_ENV=dev|test|prod] [K8S_IMAGE_TAG=<tag>]"
	@echo "  make k8s-context [K8S_KUBECONFIG=~/.kube/ai-trust-game-pi.yaml]"
	@echo "  make k8s-build-push K8S_SERVICE=main-service TARGET_ENV=dev K8S_IMAGE_TAG=<tag>"
	@echo "  make k8s-apply [K8S_SERVICE=main-service] [TARGET_ENV=dev|test|prod] [K8S_IMAGE_TAG=<tag>]"
	@echo "  make k8s-apply K8S_SERVICE=frontend-web TARGET_ENV=dev [K8S_IMAGE_TAG=<tag>]"
	@echo "  make k8s-deploy [TARGET_ENV=dev|test|prod] [K8S_IMAGE_TAG=<tag>]"
	@echo "  make k8s-delete [K8S_SERVICE=main-service] [TARGET_ENV=dev|test|prod]"
	@echo "  make k8s-apply-entry [TARGET_ENV=dev|test|prod]"
	@echo "  make k8s-delete-entry [TARGET_ENV=dev|test|prod]"
	@echo "  make k8s-status"
	@echo "  make manual-deploy TARGET_ENV=dev [K8S_IMAGE_TAG=<tag>]"
	@echo "  make manual-deploy-tag"
	@echo "  make test"
	@echo "  make lint"
