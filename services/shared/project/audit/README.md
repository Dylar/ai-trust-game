# Shared Audit Contracts

This package contains project-specific audit event contracts and producer helpers shared by services.

It is intentionally limited to the event and sink boundary needed by event producers, including RabbitMQ delivery for
the async audit path and an HTTP sink for fallback/debug delivery to `audit-service`.
Generic RabbitMQ broker mechanics live in `services/shared/foundation/messaging/rabbitmq/`.
Audit analysis, repositories, read models, and summarization belong to `services/audit-service/`.
