.PHONY: run build test lint

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

test:
	go test ./...

lint:
	$(GOLANGCI_LINT) run ./...
