include infrastructure/make/common.mk
include infrastructure/make/quality.mk
include infrastructure/make/compose.mk
include infrastructure/make/k8s.mk
include infrastructure/make/persistence.mk

.PHONY: help

help:
	@echo "Commands:"
	@echo "  make compose-up [COMPOSE_MODEL_ENV=static]"
	@echo "  make compose-restart [COMPOSE_MODEL_ENV=static]"
	@echo "  make compose-down [COMPOSE_MODEL_ENV=static]"
	@echo "  make compose-logs [COMPOSE_MODEL_ENV=static]"
	@echo "  make compose-smoke [COMPOSE_MODEL_ENV=static]"
	@echo "  make k8s-lint [SERVICE=<service>] [K8S_ENVS='dev test prod']"
	@echo "  make k8s-template [SERVICE=gateway-service] [ENV=dev|test|prod] [IMAGE_TAG=<tag>]"
	@echo "  make k8s-template-postgres [ENV=dev|test|prod]"
	@echo "  make k8s-context [K8S_KUBECONFIG=~/.kube/ai-trust-game-pi.yaml]"
	@echo "  make k8s-build-push SERVICE=gateway-service ENV=dev IMAGE_TAG=<tag>"
	@echo "  make k8s-apply [SERVICE=gateway-service] [ENV=dev|test|prod] [IMAGE_TAG=<tag>]"
	@echo "  make k8s-deploy [SERVICE=gateway-service] [ENV=dev|test|prod]"
	@echo "  make k8s-delete [SERVICE=gateway-service] [ENV=dev|test|prod]"
	@echo "  make k8s-apply-entry [ENV=dev|test|prod]"
	@echo "  make k8s-delete-entry [ENV=dev|test|prod]"
	@echo "  make k8s-status"
	@echo "  make manual-deploy [SERVICE=gateway-service] [ENV=dev|test|prod]"
	@echo "  make manual-deploy-tag"
	@echo "  make migrate-up [POSTGRES_DATABASE_URL=<postgres-url>]"
	@echo "  make migrate-down [POSTGRES_DATABASE_URL=<postgres-url>]"
	@echo "  make test"
	@echo "  make test-go"
	@echo "  make test-flutter"
	@echo "  make lint"
	@echo "  make lint-go"
	@echo "  make lint-flutter"
