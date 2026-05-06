# Development Commands

The repository root `Makefile` is a small entrypoint that includes focused files under
[`../infrastructure/make`](../infrastructure/make/):

- `common.mk` for shared defaults
- `go.mk` for local Go commands
- `docker.mk` for single-service Docker commands
- `compose.mk` for the optional local compose stack
- `k8s.mk` for Kubernetes deployment commands

## Local Service Run

- `make run SERVICE=<service-name>`
  starts the specified service (e.g., `make run SERVICE=main-service` for the core HTTP service)

## Single Service Docker

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

## Compose Stack

The compose stack is optional local development tooling. It is not part of the Kubernetes deployment path.

Compose values are read from `COMPOSE_ENV_FILE`, which defaults to `infrastructure/env/<TARGET_ENV>.env`.
The compose file intentionally does not define fallback defaults for required runtime values; missing values are reported
by `make compose-check-env` before Docker Compose starts.

- `make compose-build [TARGET_ENV=dev|test]`
  builds the current compose stack images without starting the containers

- `make compose-up [TARGET_ENV=dev|test]`
  builds and starts the local stack from `compose.yml` using the selected env file under `infrastructure/env/`
  (e.g., `make compose-up TARGET_ENV=test`)

- `make compose-up-detached [TARGET_ENV=dev|test]`
  builds and starts the local stack in the background

- `make compose-rebuild [TARGET_ENV=dev|test]`
  rebuilds and recreates the current compose stack in one step

- `make compose-rebuild-detached [TARGET_ENV=dev|test]`
  rebuilds and recreates the current compose stack in the background

- `make compose-restart [TARGET_ENV=dev|test]`
  restarts the current compose containers without rebuilding the images

- `make compose-down`
  stops and removes the local stack started through `compose.yml`

- `make compose-logs`
  follows the combined logs of the current compose stack

- `make compose-ps`
  shows the current compose containers and their status, including health state when available

- `make compose-check-env [TARGET_ENV=dev|test]`
  validates that the selected compose env file exists and contains the required compose variables

## Kubernetes

- `make k8s-lint [K8S_SERVICE=main-service] [K8S_ENVS='dev test prod']`
  lints the Helm chart and renders each selected environment without applying it

- `make k8s-template [K8S_SERVICE=main-service] [TARGET_ENV=dev|test|prod] [K8S_IMAGE_TAG=<tag>]`
  renders the Kubernetes manifests for the selected service and environment through Helm

- `make k8s-context [K8S_KUBECONFIG=~/.kube/ai-trust-game-pi.yaml]`
  shows the Kubernetes context and nodes from the project kubeconfig

- `make k8s-build-push K8S_SERVICE=main-service TARGET_ENV=dev K8S_IMAGE_TAG=<tag>`
  builds the selected service image from the local working tree and pushes it to the image repository from the
  selected Kubernetes values file

- `make k8s-apply [K8S_SERVICE=main-service] [TARGET_ENV=dev|test|prod] [K8S_IMAGE_TAG=<tag>]`
  installs or upgrades the selected service and environment through Helm.
  If `K8S_IMAGE_TAG` is omitted, the current Git commit SHA is used as the image tag

- `make k8s-apply K8S_SERVICE=frontend-web TARGET_ENV=dev [K8S_IMAGE_TAG=<tag>]`
  installs or upgrades the Flutter web frontend using values from `app/k8s`

- `make k8s-deploy [TARGET_ENV=dev|test|prod] [K8S_IMAGE_TAG=<tag>]`
  deploys the prepared services for the selected environment and applies the environment app entry when a matching
  manifest exists.
  If `K8S_IMAGE_TAG` is omitted, the current Git commit SHA is used as the image tag

- `make k8s-delete [K8S_SERVICE=main-service] [TARGET_ENV=dev|test|prod]`
  uninstalls the selected Helm release from the selected environment namespace

- `make k8s-apply-entry [TARGET_ENV=dev|test|prod]`
  applies the explicit app entry manifest for the selected environment when one exists

- `make k8s-delete-entry [TARGET_ENV=dev|test|prod]`
  deletes the explicit app entry manifest for the selected environment when one exists

- `make k8s-status`
  shows the deployed Kubernetes workloads and services labeled as part of `ai-trust-game` across all namespaces

- `make manual-deploy-tag`
  prints the automatic manual deploy tag format without triggering a workflow

- `make manual-deploy TARGET_ENV=dev [K8S_IMAGE_TAG=<tag>]`
  builds the prepared service images from the local working tree, pushes them to GHCR, and deploys the selected
  environment with that tag.
  If `K8S_IMAGE_TAG` is omitted, the target generates `manual-deploy-<short-sha>[-dirty]-<yyyy-mm-dd-hh-mm>`

Manual image publishing is also available through the `Publish Images` GitHub Actions workflow.

## Service Scripts

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

## Quality Checks

- `make test`
  runs the full Go test suite

- `make lint`
  runs the configured `golangci-lint` checks across the repository
