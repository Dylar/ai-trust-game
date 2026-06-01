# GitHub Actions Workflows

This directory contains CI, image publishing, and deploy workflows.

## Workflows

```text
ci-test.yml      checks pull requests targeting test
publish.yml      checks and publishes images
deploy.yml       deploys an existing image tag
```

Reusable workflow files provide the shared Go, Flutter, Helm, and Docker steps.

## Kubernetes Checks

The service chart is checked with backend and frontend values.
The entry chart is checked separately with app-owned entry values.

```text
infrastructure/k8s/service-chart
infrastructure/k8s/entry-chart
```

[Shared Kubernetes charts](../../infrastructure/k8s/README.md)

## Image Publishing

`publish.yml` builds and pushes images to GHCR.

Backend service images:

```text
atg-gateway-service
atg-game-service
atg-logging-service
```

Published image tags:

```text
<full commit sha>
latest
<optional manual workflow input>
```

Images are built for `linux/amd64` and `linux/arm64`.

Frontend image publishing currently uses environment-specific build args:

```text
DEV_API_BASE_URL
TEST_API_BASE_URL
PROD_API_BASE_URL
```

[App Kubernetes values](../../apps/trust-game-app/k8s/README.md#frontend-workload)

## Deploy

`deploy.yml` does not build images.
It deploys an already published `image-tag` to one selected service, or to all prepared services, for one environment.

It needs `KUBE_CONFIG_B64` for a securely reachable Kubernetes API.
For the current Raspberry Pi dev cluster, prefer workstation-local deploys through Make.

[Kubernetes commands](../../docs/development/commands.md#kubernetes)
