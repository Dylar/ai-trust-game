# RabbitMQ Kubernetes Values

This directory owns Kubernetes values for the RabbitMQ broker used by async service messaging.

```text
values.yaml        shared RabbitMQ defaults across environments
values-dev.yaml    RabbitMQ in atg-dev
values-test.yaml   RabbitMQ in atg-test
values-prod.yaml   RabbitMQ in atg-prod
```

This broker deployment does not configure persistent volumes.
Queued messages are not guaranteed to survive Pod rescheduling or volume loss.
