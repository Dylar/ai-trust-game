# Game Service Kubernetes Values

This directory owns Kubernetes values for `game-service`.

[General Kubernetes layout](../../../docs/deployment/k8s.md)<br>
[Shared service chart](../../../infrastructure/k8s/README.md#service-chart)

## Files

```text
values.yaml        shared game-service defaults across environments
values-dev.yaml    game-service in atg-dev
values-test.yaml   game-service in atg-test
values-prod.yaml   game-service in atg-prod
```

## Workload

The values deploy `game-service` with the shared service chart.

`values.yaml` sets service-stable workload values such as image defaults, ports, internal URLs, and shared config.
The environment files set namespace, `APP_ENV`, replicas, image tag, and resources.
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
RABBITMQ_URL              RabbitMQ endpoint for async audit events
AUDIT_EVENTS_EXCHANGE     exchange used for audit event publishing
AUDIT_EVENTS_ROUTING_KEY  routing key used for audit event publishing
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
