PORT ?= 8080
APP_ENV ?= $(TARGET_ENV)

.PHONY: docker-build docker-run docker-build-run docker-logs

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
