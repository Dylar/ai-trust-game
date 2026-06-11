# RabbitMQ Kubernetes Values

This directory owns Kubernetes values for the RabbitMQ broker used by async service messaging.

```text
values.yaml        shared RabbitMQ defaults across environments
values-dev.yaml    RabbitMQ in atg-dev
values-test.yaml   RabbitMQ in atg-test
values-prod.yaml   RabbitMQ in atg-prod
```

The broker chart renders a Secret for the default broker user and a PersistentVolumeClaim for RabbitMQ data.

Current Secret keys:

```text
RABBITMQ_DEFAULT_USER  default broker username
RABBITMQ_DEFAULT_PASS  default broker password
```

Current persistence values:

```text
persistence.enabled           enables the RabbitMQ data PVC
persistence.size              requested PVC size
persistence.storageClassName  optional storage class name
```
