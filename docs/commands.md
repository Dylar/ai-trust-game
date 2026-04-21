# Development Commands

## Running the Service

- `make run SERVICE=<service-name>`
  starts the specified service (e.g., `make run SERVICE=main-service` for the core HTTP service)

## Development Scripts

- `go run ./services/main-service/scripts/start-session`
  starts a session against the running service

- `go run ./services/main-service/scripts/interaction --session <session-id> --message "<message>"`
  sends one interaction request against the running service

- `go run ./services/main-service/scripts/analysis-request --request <request-id>`
  fetches the stored request analysis for one completed request, including structured signals and an optional
  request-level intent summary

- `go run ./services/main-service/scripts/analysis-session --session <session-id>`
  fetches the stored analyses for all completed requests in one session, plus the aggregated session view and an
  optional session-level intent summary

## Testing and Linting

- `make test`
  runs the full Go test suite

- `make lint`
  runs the configured `golangci-lint` checks across the repository
