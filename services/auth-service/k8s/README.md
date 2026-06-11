# Auth Service Kubernetes Values

This directory owns Kubernetes values for `auth-service`.

[General Kubernetes layout](../../../docs/deployment/k8s.md)<br>
[Shared service chart](../../../infrastructure/k8s/README.md#service-chart)

## Files

```text
values.yaml        shared auth-service defaults across environments
values-dev.yaml    auth-service in atg-dev
values-test.yaml   auth-service in atg-test
values-prod.yaml   auth-service in atg-prod
```

## Workload

The values deploy `auth-service` with the shared service chart.

`values.yaml` sets service-stable workload values such as image defaults, ports, resources, and shared config.
The environment files set namespace, `APP_ENV`, replicas, image tag, and resources.

Current image repository:

```text
ghcr.io/dylar/atg-auth-service
```

## Runtime Config

Current ConfigMap keys:

```text
APP_ENV  environment label used by logs and runtime behavior
PORT     HTTP listen port inside the container
```

Current Secret keys:

```text
DATABASE_URL  PostgreSQL endpoint for user persistence
```
