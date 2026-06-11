# Audit Service Kubernetes Values

This directory owns Kubernetes values for `audit-service`.

[General Kubernetes layout](../../../docs/deployment/k8s.md)<br>
[Shared service chart](../../../infrastructure/k8s/README.md#service-chart)

## Files

```text
values.yaml        shared audit-service defaults across environments
values-dev.yaml    audit-service in atg-dev
values-test.yaml   audit-service in atg-test
values-prod.yaml   audit-service in atg-prod
```

## Workload

The values deploy `audit-service` with the shared service chart.

`values.yaml` sets service-stable workload values such as image defaults, ports, resources, and shared config.
The environment files set namespace, `APP_ENV`, and replicas.

Current image repository:

```text
ghcr.io/dylar/atg-audit-service
```

## Runtime Config

Current ConfigMap keys:

```text
APP_ENV       environment label used by logs and runtime behavior
PORT          HTTP listen port inside the container
LLM_PROVIDER  model provider selection, for example static or groq
GROQ_MODEL    optional Groq model name when Groq is used
AUDIT_EVENTS_EXCHANGE                   exchange used for audit event publishing
AUDIT_EVENTS_QUEUE                      queue consumed by audit-service
AUDIT_EVENTS_ROUTING_KEY                routing key used for audit event publishing
AUDIT_EVENTS_RETRY_EXCHANGE             exchange used for retry publishing
AUDIT_EVENTS_RETRY_QUEUE                queue used for delayed audit retries
AUDIT_EVENTS_RETRY_DELAY_MILLIS         retry delay in milliseconds
AUDIT_EVENTS_DEAD_LETTER_EXCHANGE       exchange used for rejected audit events
AUDIT_EVENTS_DEAD_LETTER_QUEUE          queue used for rejected audit events
```

Secrets:

```text
audit-service-secret
```

`GROQ_API_KEY` is required when `LLM_PROVIDER=groq`.
`RABBITMQ_URL` is the RabbitMQ endpoint for async audit events.

## Traffic

`audit-service` receives audit events from `game-service` and serves analysis reads through `gateway-service`.
