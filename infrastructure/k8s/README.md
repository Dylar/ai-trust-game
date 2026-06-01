# Kubernetes

This directory contains the shared Helm charts.

The charts describe reusable Kubernetes shapes.
Workload-specific values live lower in the tree:

[Gateway service values](../../services/gateway-service/k8s/README.md)<br>
[Game service values](../../services/game-service/k8s/README.md)<br>
[App values](../../apps/trust-game-app/k8s/README.md)<br>
[General Kubernetes layout](../../docs/deployment/k8s.md)

## Service Chart

`service-chart/` is the shared chart for normal HTTP workloads.
It renders a `Deployment`, `Service`, and `ConfigMap`.

Use it for backend services and for the Flutter web workload when the default HTTP workload shape is enough.

[service-chart](./service-chart/)

Expected value areas:

```text
identity    serviceName, namespace, environment, component, partOf
image       repository, tag, pullPolicy, optional imagePullSecrets
network     containerPort, servicePort
health      readiness and liveness probes
resources   requests and limits
config      string values rendered into <serviceName>-config-map
secrets     optional <serviceName>-secret reference
```

The chart references `<serviceName>-secret` as optional.
The workload README owns the expected secret keys.

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
