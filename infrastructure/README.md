# Infrastructure

This directory contains shared infrastructure assets for building, packaging, and deploying the system.

It is intentionally separate from `tooling/`:

- `tooling/` contains development helpers such as scripts and test support
- `infrastructure/` contains runtime and deployment assets such as Docker and Kubernetes definitions

## Current Structure

- [`docker/`](./docker/)
  shared Docker build definitions for services

- [`../compose.yml`](../compose.yml)
  local multi-container stack definition for the current development setup

- [`env/`](./env/)
  shared environment variable files for local stack variants such as `dev` and `test`

- [`.github/workflows/`](../.github/workflows/)
  reusable GitHub Actions building blocks plus small caller workflows for `PR -> test` and `push -> master`

- [`k8s/`](./k8s/)
  reserved for shared Kubernetes infrastructure once common patterns become concrete

The `env/` and `k8s/` directories are intentionally lightweight Phase 11 starting points.
Right now they keep environment selection simple while the project still runs as one main service plus one frontend
stack.
Later, once multiple services and Kubernetes-specific environment differences become concrete, this may evolve into a
more environment-centered structure such as dedicated `dev/`, `test/`, and `prod/` deployment areas.

## Planned Structure

- `terraform/`
  infrastructure provisioning setup when the project reaches that stage

Service-specific deployment assets live close to the owning module, for example under `services/<service-name>/k8s/`.
