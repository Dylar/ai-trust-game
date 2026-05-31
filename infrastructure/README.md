# Infrastructure

This directory contains shared infrastructure assets for building, packaging, and deploying the system.

It is intentionally separate from `tooling/`:

- `tooling/` contains development helpers such as scripts and test support
- `infrastructure/` contains runtime and deployment assets such as Docker and Kubernetes definitions

## Current Structure

- [`docker/`](./docker/)
  shared Docker build definitions for services

- [`make/`](./make/)
  focused Makefile fragments included by the repository root `Makefile`

- [`docker/compose/`](./docker/compose/)
  optional local Docker Compose stack split into a root include file plus backend, web, and model environment files

- [`.github/workflows/`](../.github/workflows/)
  reusable GitHub Actions building blocks plus caller workflows for CI, image publishing, and deploys
  See [workflow documentation](../.github/workflows/README.md).

- [`k8s/`](./k8s/)
  shared Kubernetes Helm charts and deployment assets

The Docker Compose and Kubernetes directories intentionally keep shared infrastructure separate from service-owned
configuration.
Compose owns the optional local container stack.
Kubernetes shared chart logic lives under [`k8s/`](./k8s/), while workload values live close to the owning module.

## Planned Structure

- `terraform/`
  infrastructure provisioning setup when the project reaches that stage

Service-specific deployment values live close to the owning module, for example under `services/<service-name>/k8s/`.
Frontend workload and app entrypoint values live under `apps/trust-game-app/k8s/`.
