# RabbitMQ Messaging

This package contains generic RabbitMQ publisher and consumer helpers for backend services.

It owns broker mechanics such as durable exchange declaration, durable queue binding, persistent messages, manual
acknowledgement, and nack-on-processing-error behavior.

Project-specific event contracts, routing names, and payload serialization belong outside this package.
