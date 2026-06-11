# Kubernetes

This directory contains the shared Helm charts.

The charts describe reusable Kubernetes shapes.
Workload-specific values live lower in the tree:

[Gateway service values](../../services/gateway-service/k8s/README.md)<br>
[Auth service values](../../services/auth-service/k8s/README.md)<br>
[Game service values](../../services/game-service/k8s/README.md)<br>
[Audit service values](../../services/audit-service/k8s/README.md)<br>
[App values](../../apps/trust-game-app/k8s/README.md)<br>
[General Kubernetes layout](../../docs/deployment/k8s.md)

## Service Chart

`service-chart/` is the shared chart for normal HTTP workloads.
It renders a `Deployment`, `Service`, `ConfigMap`, and an optional `Secret` when `secretConfig` is set.

Use it for backend services and for the Flutter web workload when the default HTTP workload shape is enough.

[service-chart](./service-chart/)

Expected value areas:

```text
identity    serviceName, namespace, environment, component, partOf
image       repository, tag, pullPolicy, optional imagePullSecrets
network     containerPort, servicePort
health      readiness and liveness probes
resources   requests and limits
config       string values rendered into <serviceName>-config-map
secretConfig string values rendered into <serviceName>-secret when present
```

The chart references `<serviceName>-secret` as optional.
The workload README owns the expected secret keys.

## PostgreSQL Chart

`postgres-chart/` is the dedicated chart for the current backend persistence database.
It renders a PostgreSQL `Deployment`, `Service`, credential `Secret`, and optional data `PersistentVolumeClaim`.

[postgres-chart](./postgres-chart/)

PostgreSQL values live under `postgres/`.

[PostgreSQL values](./postgres/)

## RabbitMQ Chart

`rabbitmq-chart/` is the dedicated chart for the current async messaging broker.
It renders a RabbitMQ `Deployment`, `Service`, and broker config.

[rabbitmq-chart](./rabbitmq-chart/)

RabbitMQ values live under `rabbitmq/`.

[RabbitMQ values](./rabbitmq/)

## Entry Chart

`entry-chart/` is the shared chart for the current app entrypoint.
It renders an Nginx reverse proxy as a `Deployment`, `Service`, and `ConfigMap`.

[entry-chart](./entry-chart/)

The chart routes backend path prefixes to `gateway-service` and all other traffic to `frontend-web`.
The app owns the current environment-specific entry values.

[App entry values](../../apps/trust-game-app/k8s/README.md#app-entry)

## Check Changes

For normal service-chart checks, use the Make targets:

```sh
make k8s-lint
make k8s-lint SERVICE=frontend-web K8S_ENVS='dev test prod'
```

For entry-chart changes, use Helm directly:

```sh
helm lint ./infrastructure/k8s/entry-chart -f ./apps/trust-game-app/k8s/entry-values-dev.yaml
helm template app-entry ./infrastructure/k8s/entry-chart -f ./apps/trust-game-app/k8s/entry-values-dev.yaml
```

For PostgreSQL and RabbitMQ chart changes, use the Make wrappers or Helm directly:

```sh
make k8s-template-postgres ENV=dev
helm lint ./infrastructure/k8s/postgres-chart -f ./infrastructure/k8s/postgres/values.yaml -f ./infrastructure/k8s/postgres/values-dev.yaml
make k8s-template-rabbitmq ENV=dev
helm lint ./infrastructure/k8s/rabbitmq-chart -f ./infrastructure/k8s/rabbitmq/values.yaml -f ./infrastructure/k8s/rabbitmq/values-dev.yaml
```
