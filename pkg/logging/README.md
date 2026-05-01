# Logging Package

This package contains the shared logging abstraction and the current console implementation.

Its job is to make logging consistent at meaningful boundaries without coupling the rest of the codebase to one
specific logging backend.

## What Lives Here

- [`logger.go`](./logger.go)
  the shared `Logger` interface plus structured field helpers

- [`logger_console.go`](./logger_console.go)
  the current console logger implementation

- [`logger_noop.go`](./logger_noop.go)
  a no-op implementation for tests or disabled logging paths

- [`http.go`](./http.go)
  HTTP logging middleware with status-based log levels

## Design Intent

The abstraction is intentionally small.

It supports:

- `Debug`
- `Info`
- `Warn`
- `Error`

plus structured `Field` values.

This keeps logging:

- easy to stub in tests
- consistent across packages
- replaceable if the project adopts another backend later

## Structured Fields

[`WithField`](./logger.go) and [`WithError`](./logger.go) make stable log context explicit.

[`WithFields`](./logger.go) wraps a logger with shared fields, which is useful for process-wide context such as:

- service name
- environment
- provider configuration

The main service uses that pattern in its composition root before wiring handlers and processors.

## HTTP Logging

[`HttpLogging`](./http.go) wraps an `http.Handler` and logs:

- method
- path
- status
- duration in milliseconds

The log level depends on the response status:

- `Info` for success
- `Warn` for client errors
- `Error` for server errors

This keeps request lifecycle logging at the transport boundary instead of spreading it across handlers.
