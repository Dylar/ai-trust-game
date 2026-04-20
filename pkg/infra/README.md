# Infra Package

This package contains shared service bootstrap and runtime helpers.

Its responsibility is technical foundation, not business behavior.

## What Lives Here

- [`config.go`](./config.go)
  shared runtime configuration objects for server startup

- [`http.go`](./http.go)
  HTTP server construction, startup, and graceful shutdown handling

- [`service.go`](./service.go)
  higher-level server orchestration across one or more configured HTTP servers

- [`common.go`](./common.go)
  small shared runtime helpers such as environment lookup

## Why This Package Exists

The project keeps service bootstrap separate from feature code.

That means:

- handlers and processors do not own process lifecycle concerns
- services can compose shared runtime behavior without duplicating startup code
- shutdown behavior stays explicit and testable at the application edge

## Current Runtime Model

[`Server`](./service.go) is the top-level runtime wrapper.

It currently:

- starts all configured HTTP servers
- waits for either a server error or a shutdown signal
- creates a shutdown timeout window
- shuts down HTTP servers and optional extra cleanup hooks

[`HTTPServer`](./http.go) is the lower-level HTTP wrapper.

It currently:

- creates a `http.ServeMux`
- lets the service register routes
- applies a read-header timeout
- exposes `Run()` and `Shutdown()` behind a small project-local abstraction

## Configuration Shape

[`Config`](./config.go) currently supports:

- one or more `HTTPConfig` entries
- an optional top-level shutdown hook

Each `HTTPConfig` contains:

- `Name`
  descriptive server name

- `Port`
  listen port

- `Register`
  route registration callback

- `Shutdown`
  optional server-specific cleanup hook

## Current Usage

The main service uses this package in:

- [`services/main-service/cmd/main.go`](../../services/main-service/cmd/main.go)

That composition root builds handlers and processors first, then hands route registration to `pkg/infra`.
