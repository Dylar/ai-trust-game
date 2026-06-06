# Shared Foundation Code

This directory contains generic backend foundation packages used by services.

Current packages:

- [`infra/`](./infra/)
  service bootstrap, HTTP server lifecycle, and runtime config

- [`logging/`](./logging/)
  structured logging abstraction and HTTP request logging

- [`messaging/`](./messaging/)
  provider-neutral messaging contracts

- [`messaging/rabbitmq/`](./messaging/rabbitmq/)
  generic RabbitMQ publisher and consumer helpers

- [`network/`](./network/)
  request metadata, transport helpers, CORS, and JSON response utilities

- [`persistence/`](./persistence/)
  provider-neutral persistence support

- [`persistence/postgres/`](./persistence/postgres/)
  generic PostgreSQL connection, health, and migration helpers

Foundation code should stay technical and broadly reusable.
Project-specific workflows and business behavior belong in service-owned packages or `services/shared/project/`.
