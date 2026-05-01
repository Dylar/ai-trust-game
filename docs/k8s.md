# Kubernetes Deployment Guide

The project uses Kustomize for Kubernetes manifests.

Kustomize keeps the YAML readable:

- `base/` contains complete Kubernetes resources for one service
- `overlays/<env>/` contains only environment-specific changes

This avoids templating while still keeping `dev`, `test`, and `prod` separate.

## Current Layout

The current Kubernetes starting point is service-local:

```text
services/main-service/k8s/
  base/
    config-map.yaml
    deployment.yaml
    kustomization.yaml
    secret.example.yaml
    service.yaml
  overlays/
    dev/
    test/
    prod/
```

The base is complete and can be read as the default deployment shape.
Each overlay references the base and patches only the values that differ for that environment.

## Commands

Render an environment without applying it:

```sh
kubectl kustomize services/main-service/k8s/overlays/dev
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

## Adding A New Service

When adding a new backend service, create a service-owned Kubernetes directory:

```text
services/<service-name>/k8s/
  base/
    config-map.yaml
    deployment.yaml
    kustomization.yaml
    secret.example.yaml
    service.yaml
  overlays/
    dev/
      config-map.patch.yaml
      deployment.patch.yaml
      kustomization.yaml
      namespace.yaml
    test/
      config-map.patch.yaml
      deployment.patch.yaml
      kustomization.yaml
      namespace.yaml
    prod/
      config-map.patch.yaml
      deployment.patch.yaml
      kustomization.yaml
      namespace.yaml
```

The easiest starting point is to copy `services/main-service/k8s/` and then rename the service-specific values.

## Values To Rename

Replace these values everywhere they appear:

- `main-service`
  Kubernetes resource name, container name, image name, and `app.kubernetes.io/name`

- `main-service-config-map`
  ConfigMap name referenced by the deployment

- `main-service-secret`
  optional Secret name referenced by the deployment

- `ai-trust-game-<env>`
  namespace names if the service should use a different namespace strategy

- `ghcr.io/dylar/ai-trust-game-main-service`
  production image repository

Keep labels consistent between:

- `Deployment.spec.selector.matchLabels`
- `Deployment.spec.template.metadata.labels`
- `Service.spec.selector`

If these do not match, Pods may run but Services will not route traffic to them.

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

- `ConfigMap.data`
  Non-secret runtime environment variables.

- `Secret`
  Secret values such as API keys. Keep only examples in Git.

## Environment Overlays

Use overlays for values that differ between environments:

- `APP_ENV`
- replicas
- image repository and tag
- CPU and memory
- provider settings such as `LLM_PROVIDER` and `GROQ_MODEL`
- namespace

Avoid changing the service shape in overlays unless the environment really requires it.
If every environment needs the same change, update the base instead.
