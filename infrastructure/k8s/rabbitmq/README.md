# RabbitMQ Kubernetes Values

This directory owns Kubernetes values for the RabbitMQ broker used by async service messaging.

```text
values.yaml        shared RabbitMQ defaults across environments
values-dev.yaml    RabbitMQ in atg-dev
values-test.yaml   RabbitMQ in atg-test
values-prod.yaml   RabbitMQ in atg-prod
```

The Phase 12 broker deployment is intentionally ephemeral.
It makes the async audit path runnable in Kubernetes, but it does not persist queued messages across Pod rescheduling or
volume loss.

RabbitMQ persistence, broker credentials through Secrets, dead-letter handling, and retry policy hardening belong to
Phase 13.
