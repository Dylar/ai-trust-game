# Kubernetes Deployment

Kubernetes in this project is split into three parts:

```text
shared chart -> workload values -> environment
```

The chart describes the Kubernetes shape.
The values describe one deployable workload.
The environment decides where and with which values it runs.

## Shared Charts

Shared Helm charts live under `infrastructure/k8s/`.
They describe reusable Kubernetes objects such as deployments, services, config maps, and the current app entrypoint
shape.

[Shared Kubernetes charts](../../infrastructure/k8s/README.md)

## Workload Values

Workload values live next to the thing they deploy.
Backend service values stay under `services/<service-name>/k8s/`.
Frontend and current app-entry values stay under `apps/trust-game-app/k8s/`.

[Gateway service Kubernetes values](../../services/gateway-service/k8s/README.md)<br>
[Game service Kubernetes values](../../services/game-service/k8s/README.md)<br>
[App Kubernetes values](../../apps/trust-game-app/k8s/README.md)

## Environments

The project uses `dev`, `test`, and `prod`.
Namespaces use the matching `atg-<env>` shape, for example `atg-dev`.
Values files use the same suffix: `values-dev.yaml` and `entry-values-dev.yaml`.

This keeps Make targets, Helm values, and cluster resources easy to line up.

## Config And Secrets

Normal runtime config belongs in values files and is rendered into a ConfigMap.
Secret runtime config belongs in Kubernetes Secrets and must not be stored in this repository without encryption.

The shared service chart uses this naming convention:

```text
<serviceName>-config-map
<serviceName>-secret
```

Each service owns the meaning of its own secret keys.
For concrete keys, read the service-owned Kubernetes README.

[Gateway service Kubernetes values](../../services/gateway-service/k8s/README.md#runtime-config)<br>
[Game service Kubernetes values](../../services/game-service/k8s/README.md#runtime-config)

## Images

Values files choose the image repository with `image.repository`.
Deploy commands and workflows choose the version with `image.tag`.

The preferred direction is one image repository per deployable workload, with environments selecting tags at different
times.
If a workload is built differently per environment, that exception belongs in the workload-owned README.

[App image setup](../../apps/trust-game-app/k8s/README.md#frontend-workload)<br>
[Gateway service image setup](../../services/gateway-service/k8s/README.md#workload)<br>
[Game service image setup](../../services/game-service/k8s/README.md#workload)

## Local, Deploy, And Check

Use Docker Compose for local development.
Use Kubernetes commands when you want to build, deploy, inspect, or validate the cluster path.

The command reference is split into `Local`, `Deploy`, `Lint / Check`, and `Cleanup`.

[Kubernetes commands](../development/commands.md#kubernetes)

## Current Entry Point

`app-entry` is the current temporary entrypoint for the deployed app environment.
It belongs to `apps/trust-game-app/k8s/` for now.
It routes public backend traffic to `gateway-service` and frontend traffic to `frontend-web`.

[App entry values](../../apps/trust-game-app/k8s/README.md#app-entry)
