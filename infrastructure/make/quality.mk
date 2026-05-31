GOLANGCI_LINT ?= $(shell go env GOPATH)/bin/golangci-lint

.PHONY: test test-go test-flutter lint lint-go lint-flutter

test: test-go test-flutter

test-go:
	go test ./...

test-flutter:
	cd apps/trust-game-app && flutter test

lint: lint-go lint-flutter

lint-go:
	$(GOLANGCI_LINT) run ./...

lint-flutter:
	cd apps/trust-game-app && flutter analyze
