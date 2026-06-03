# Game Service Kubernetes Values

This directory owns Kubernetes values for `game-service`.

[General Kubernetes layout](../../../docs/deployment/k8s.md)<br>
[Shared service chart](../../../infrastructure/k8s/README.md#service-chart)

## Files

```text
values-dev.yaml    game-service in atg-dev
values-test.yaml   game-service in atg-test
values-prod.yaml   game-service in atg-prod
```

## Workload

The values deploy `game-service` with the shared service chart.

They set the image, namespace, `APP_ENV`, port `8080`, replicas, resources, and runtime config.
The shared service chart supplies the default `/healthz` probes.

Current image repository:

```text
ghcr.io/dylar/atg-game-service
```

`game-service` is currently environment-neutral as a container image.
Environment behavior comes from values, ConfigMaps, and Secrets.

## Runtime Config

Current ConfigMap keys:

```text
APP_ENV       environment label used by logs and runtime behavior
PORT          HTTP listen port inside the container
LLM_PROVIDER  model provider selection, for example static or groq
GROQ_MODEL    optional Groq model name when Groq is used
AUDIT_SERVICE_URL  internal URL for audit event ingestion
```

The shared service chart also references this optional runtime secret:

```text
game-service-secret
```

`GROQ_API_KEY` is required when `LLM_PROVIDER=groq`.

## Traffic

`game-service` is not exposed directly outside the cluster.
External app traffic reaches it through `app-entry`.

[App entry values](../../../apps/trust-game-app/k8s/README.md#app-entry)
