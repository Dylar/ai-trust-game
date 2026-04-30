# Development Commands

## Running the Service

- `make run SERVICE=<service-name>`
  starts the specified service (e.g., `make run SERVICE=main-service` for the core HTTP service)

- `make docker-build SERVICE=<service-name>`
  builds the local Docker image for the specified Go service through the shared Dockerfile
  (e.g., `make docker-build SERVICE=main-service`)

- `make docker-run SERVICE=<service-name> [PORT=<host-port>]`
  runs the previously built local Docker image and publishes container port `8080` to the selected host port
  (e.g., `make docker-run SERVICE=main-service`)

- `make docker-build-run SERVICE=<service-name> [PORT=<host-port>]`
  rebuilds the local Docker image and then starts it immediately
  (e.g., `make docker-build-run SERVICE=main-service`)

- `make docker-logs SERVICE=<service-name>`
  follows the logs of the currently running local container for that image
  (e.g., `make docker-logs SERVICE=main-service`)

- `make compose-up [TARGET_ENV=dev|test]`
  builds and starts the local stack from `compose.yml` using the selected env file under `infrastructure/env/`
  (e.g., `make compose-up TARGET_ENV=test`)

- `make compose-down`
  stops and removes the local stack started through `compose.yml`

- `make compose-logs`
  follows the combined logs of the current compose stack

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
