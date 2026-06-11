# Gateway Service Kubernetes Values

This directory owns Kubernetes values for `gateway-service`.

[General Kubernetes layout](../../../docs/deployment/k8s.md)<br>
[Shared service chart](../../../infrastructure/k8s/README.md#service-chart)

## Files

```text
values.yaml        shared gateway-service defaults across environments
values-dev.yaml    gateway-service in atg-dev
values-test.yaml   gateway-service in atg-test
values-prod.yaml   gateway-service in atg-prod
```

## Workload

The values deploy `gateway-service` with the shared service chart.

`values.yaml` sets service-stable workload values such as image defaults, ports, upstream URLs, and shared config.
The environment files set namespace, `APP_ENV`, replicas, image tag, and resources.

Current image repository:

```text
ghcr.io/dylar/atg-gateway-service
```

## Runtime Config

Current ConfigMap keys:

```text
APP_ENV              environment label used by logs and runtime behavior
PORT                 HTTP listen port inside the container
GAME_SERVICE_URL     internal URL for routing public game requests to game-service
LOGGING_SERVICE_URL  internal URL for routing public log requests to logging-service
AUDIT_SERVICE_URL    internal URL for routing public analysis requests to audit-service
AUTH_SERVICE_URL     internal URL for routing public auth requests to auth-service
```

## Traffic

`gateway-service` is the public backend target behind the current `app-entry` reverse proxy.
Cluster-internal services should still call the owning service boundary directly when public routing is not needed.
