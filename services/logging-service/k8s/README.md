# Logging Service Kubernetes Values

This directory owns Kubernetes values for `logging-service`.

[General Kubernetes layout](../../../docs/deployment/k8s.md)<br>
[Shared service chart](../../../infrastructure/k8s/README.md#service-chart)

## Files

```text
values-dev.yaml    logging-service in atg-dev
values-test.yaml   logging-service in atg-test
values-prod.yaml   logging-service in atg-prod
```

## Workload

The values deploy `logging-service` with the shared service chart.

They set the image, namespace, `APP_ENV`, port `8080`, replicas, resources, and probes.

Current image repository:

```text
ghcr.io/dylar/atg-logging-service
```

## Runtime Config

Current ConfigMap keys:

```text
APP_ENV  environment label used by logs and runtime behavior
PORT     HTTP listen port inside the container
```

## Traffic

`logging-service` is reached through `gateway-service` for public app log ingestion.
Cluster-internal service log delivery will be added when async messaging is introduced in Phase 12.
