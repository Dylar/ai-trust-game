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

- [`../.github/workflows/ci.yml`](../.github/workflows/ci.yml)
  continuous integration checks for Go, Flutter, and Docker image builds

The `env/` directory is the intentionally lightweight Phase 11 starting point.
Right now it keeps environment selection simple while the project still runs as one main service plus one frontend
stack.
Later, once multiple services and Kubernetes-specific environment differences become concrete, this may evolve into a
more environment-centered structure such as dedicated `dev/`, `test/`, and `prod/` deployment areas.

## Planned Structure

- `k8s/`
  shared Kubernetes manifests, overlays, or base building blocks

- `terraform/`
  infrastructure provisioning setup when the project reaches that stage

Service-specific deployment assets may still live closer to a service later when that ownership becomes concrete, for
example under `services/<service-name>/k8s/`.
