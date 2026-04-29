# Infrastructure

This directory contains shared infrastructure assets for building, packaging, and deploying the system.

It is intentionally separate from `tooling/`:

- `tooling/` contains development helpers such as scripts and test support
- `infrastructure/` contains runtime and deployment assets such as Docker and Kubernetes definitions

## Current Structure

- [`docker/`](./docker/)
  shared Docker build definitions for services

## Planned Structure

- `k8s/`
  shared Kubernetes manifests, overlays, or base building blocks

- `terraform/`
  infrastructure provisioning setup when the project reaches that stage

Service-specific deployment assets may still live closer to a service later when that ownership becomes concrete, for
example under `services/<service-name>/k8s/`.
