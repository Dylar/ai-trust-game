# Kubernetes Deployment Guide

The project uses Helm for Kubernetes manifests.

Helm keeps shared Kubernetes structure in one chart while services provide environment-specific values.

The chart templates are intentionally close to regular Kubernetes YAML. They only use placeholders for values that vary
between services or environments.

This avoids copying the same deployment shape for each service while still keeping `dev`, `test`, and `prod` separate.

## Current Layout

The shared chart lives under infrastructure:

```text
infrastructure/k8s/helm/http-service/
  Chart.yaml
  values.yaml
  templates/
    config-map.yaml
    deployment.yaml
    namespace.yaml
    service.yaml
```

Service values live next to the service:

```text
services/main-service/k8s/
  values-dev.yaml
  values-test.yaml
  values-prod.yaml
```

The chart is the shared deployment shape.
The service values define identity, image, namespace, replicas, resources, ports, probes, and runtime configuration.

## Commands

These commands require the Helm CLI to be installed locally.

Render an environment without applying it:

```sh
make k8s-template TARGET_ENV=dev
```

Lint and render all prepared environments:

```sh
make k8s-lint
```

Apply an environment:

```sh
make k8s-apply TARGET_ENV=dev
```

Remove an environment:

```sh
make k8s-delete TARGET_ENV=dev
```

Check deployed resources:

```sh
make k8s-status
```

The status command searches all namespaces for resources labeled as part of `ai-trust-game`.

CI runs the same type of Helm validation through `.github/workflows/reusable-helm.yml`.
It lints the shared chart and renders the `main-service` `dev`, `test`, and `prod` values files.

## Adding A New Service

When adding a new backend service, create a service-owned values directory:

```text
services/<service-name>/k8s/
  values-dev.yaml
  values-test.yaml
  values-prod.yaml
```

The easiest starting point is to copy the `main-service` values files and then rename the service-specific values.

## Values To Rename

Replace these values everywhere they appear:

- `main-service`
  Helm release name, Kubernetes resource name, container name, image name, and `app.kubernetes.io/name`

- `ai-trust-game-<env>`
  namespace names if the service should use a different namespace strategy

- `ghcr.io/dylar/ai-trust-game-main-service`
  production image repository

The chart derives ConfigMap and Secret names from `serviceName`:

- `<serviceName>-config-map`
- `<serviceName>-secret`

The Secret reference is optional, so static-provider local deployments do not need a Secret.

## Service Settings To Review

Review these settings for every new service:

- `replicas`
  How many Pods should run in each environment.

- `image`
  Local image names are useful for `dev`; registry images should be used for remote environments.

- `imagePullPolicy`
  `IfNotPresent` is convenient for local development. Remote environments may need `Always` depending on image tagging.

- `containerPort`
  The port the container listens on.

- `Service.spec.ports`
  The cluster-internal service port and target port.

- `readinessProbe`
  The endpoint Kubernetes uses to decide whether the Pod can receive traffic.

- `livenessProbe`
  The endpoint Kubernetes uses to decide whether the Pod should be restarted.

- `resources.requests`
  CPU and memory Kubernetes should reserve for the container.

- `resources.limits`
  CPU and memory the container is allowed to use.

- `config`
  Non-secret runtime environment variables.

- `Secret`
  Secret values such as API keys. Keep only examples in Git.

## Environment Values

Use values files for values that differ between environments:

- `APP_ENV`
- replicas
- image repository and tag
- CPU and memory
- provider settings such as `LLM_PROVIDER` and `GROQ_MODEL`
- namespace

Avoid changing the chart for service-specific values.
If one service needs a different deployment shape, first consider whether that service needs a separate chart.
