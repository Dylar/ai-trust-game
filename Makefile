include infrastructure/make/common.mk
include infrastructure/make/quality.mk
include infrastructure/make/compose.mk
include infrastructure/make/k8s.mk

.PHONY: help

help:
	@echo "Commands:"
	@echo "  make compose-up [COMPOSE_MODEL_ENV=static]"
	@echo "  make compose-restart [COMPOSE_MODEL_ENV=static]"
	@echo "  make compose-down [COMPOSE_MODEL_ENV=static]"
	@echo "  make compose-logs [COMPOSE_MODEL_ENV=static]"
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
	@echo "  make test-go"
	@echo "  make test-flutter"
	@echo "  make lint"
	@echo "  make lint-go"
	@echo "  make lint-flutter"
