# RabbitMQ Messaging

This package contains generic RabbitMQ publisher and consumer helpers for backend services.

It owns broker mechanics such as durable exchange declaration, durable queue binding, persistent messages, manual
acknowledgement, retry publishing, and dead-letter routing for rejected messages.

Retryable processing errors are republished to the configured retry exchange as persistent messages, then acknowledged
from the main queue. The retry queue dead-letters back to the main exchange after its TTL.

Rejected messages, such as invalid payloads wrapped with `messaging.Reject`, are nacked without requeue so RabbitMQ
routes them to the configured dead-letter exchange.

Project-specific event contracts, routing names, and payload serialization belong outside this package.
