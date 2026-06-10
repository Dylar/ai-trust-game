# Audit Service

This service owns audit event ingestion, audit analysis, and audit read models.

It currently owns:

- local audit-service health checks
- RabbitMQ audit event consumption
- `POST /audit/events` as an internal HTTP fallback/debug ingestion endpoint
- request-level analysis reads at `GET /analysis/request/{requestId}`
- session-level analysis reads at `GET /analysis/session/{sessionId}`
- raw audit event storage
- request analysis storage backed by PostgreSQL when configured, otherwise in-memory storage

The audit service does not own game state transitions, public routing, or generic app logging.

## Structure

- [`cmd/`](./cmd/)
  runtime wiring and server startup

- [`service/`](./service/)
  HTTP handlers and route registration

- [`service/audit/`](./service/audit/)
  audit analysis, repositories, sinks, and intent summarization

- [`k8s/`](./k8s/)
  Helm values for deploying this service

## HTTP Surface

Current routes:

- `GET /healthz`
  returns local audit-service health for container and Kubernetes probes

- `POST /audit/events`
  accepts audit events from internal services as a fallback/debug path

- `GET /analysis/request/{requestId}`
  returns one stored request analysis

- `GET /analysis/session/{sessionId}`
  returns the aggregated session analysis plus ordered request analyses

## Runtime Behavior

`game-service` publishes audit events to RabbitMQ.
`audit-service` consumes the audit event queue and processes events through the same analyzing sink used by the HTTP
fallback endpoint.
The audit service stores each consumed audit event, keeps request events in memory until the request is complete, then
creates and stores a request analysis.

When `DATABASE_URL` is configured, raw events and request analyses are stored in PostgreSQL. When `DATABASE_URL` is not
configured, the service uses in-memory repositories for lightweight local runs and focused tests.

Request and session analysis responses include `user_id` when audit events provide it. Session analysis remains derived
from the stored request analyses for that session, preserving the current read contract while making the read model
survive service restarts.

## Environment Variables

- `PORT`
  HTTP port, defaults through [`services/shared/foundation/infra`](../../services/shared/foundation/infra/)

- `DATABASE_URL`
  optional PostgreSQL connection string used for persistent audit events and request analyses

- `RABBITMQ_URL`
  RabbitMQ endpoint used for async audit event consumption

- `AUDIT_EVENTS_EXCHANGE`
  exchange used for audit event consumption

- `AUDIT_EVENTS_QUEUE`
  queue used for audit event consumption

- `AUDIT_EVENTS_ROUTING_KEY`
  routing key used for audit event consumption

- `LLM_PROVIDER`, `GROQ_API_KEY`, `GROQ_MODEL`
  optional model-backed intent summarization configuration
