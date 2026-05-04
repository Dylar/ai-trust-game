# Kubernetes Deployment Guide

The project uses Helm for Kubernetes manifests.

Helm keeps shared Kubernetes structure in one chart while services provide environment-specific values.

The chart templates are intentionally close to regular Kubernetes YAML. They only use placeholders for values that vary
between services or environments.

This avoids copying the same deployment shape for each service while still keeping `dev`, `test`, and `prod` separate.

## Current Layout

The shared chart lives under infrastructure:

```text
infrastructure/k8s/helm/http-service/
  Chart.yaml
  values.yaml
  templates/
    config-map.yaml
    deployment.yaml
    service.yaml
```

Service values live next to the service:

```text
services/main-service/k8s/
  values-dev.yaml
  values-test.yaml
  values-prod.yaml
```

The chart is the shared deployment shape.
The service values define identity, image, target namespace, replicas, resources, ports, probes, and runtime configuration.
The chart also includes `values.schema.json`, which Helm uses to validate values during `helm lint`, `helm template`,
and installs.
Namespaces are managed outside the chart. This avoids Helm ownership conflicts when a namespace already exists.

## Commands

These commands require the Helm CLI to be installed locally.

Render an environment without applying it:

```sh
make k8s-template TARGET_ENV=dev
```

`make k8s-template` writes rendered Kubernetes YAML to stdout. Redirect it when you want a local review artifact:

```sh
make k8s-template TARGET_ENV=dev > /tmp/main-service-dev.yaml
```

Lint and render all prepared environments:

```sh
make k8s-lint
```

Apply an environment:

```sh
make k8s-apply TARGET_ENV=dev
```

If `K8S_IMAGE_TAG` is omitted, `make k8s-apply` deploys the image tagged with the current Git commit SHA.
That commit must already have been published to GHCR.

Override only the image tag at render or deploy time:

```sh
make k8s-template TARGET_ENV=prod K8S_IMAGE_TAG=<commit-sha>
make k8s-apply TARGET_ENV=prod K8S_IMAGE_TAG=manual-deploy-2026-05-02-11-21
```

Remove an environment:

```sh
make k8s-delete TARGET_ENV=dev
```

Check deployed resources:

```sh
make k8s-status
```

The status command searches all namespaces for resources labeled as part of `ai-trust-game`.
Cluster-mutating Make targets use a project kubeconfig instead of the default global Kubernetes context.
The default path is `~/.kube/ai-trust-game-pi.yaml`.
Override it with `K8S_KUBECONFIG=<path>` when needed.

Check which cluster the project commands will use:

```sh
make k8s-context
```

CI runs the same type of Helm validation through `.github/workflows/reusable-helm.yml`.
It lints the shared chart and renders the `main-service` `dev`, `test`, and `prod` values files.

The publish workflow tags images with the full source commit SHA and `latest`.
It can also be started manually with an extra tag such as `manual-deploy-<short-sha>-2026-05-02-11-21`.
Published images are built for `linux/amd64` and `linux/arm64` so the Raspberry Pi can pull the same GHCR image.

Normal publish runs tag images with the Git commit SHA and `latest`.
Manual publish runs can add one extra human-readable tag through the `image-tag` workflow input.
Use that input for tags such as `manual-deploy-<short-sha>-2026-05-02-11-21`.

Manual deployments are prepared through `.github/workflows/deploy.yml`.
The local `manual-deploy` Make target only triggers that GitHub Actions workflow; it does not run `helm upgrade` against
the current local Kubernetes context.
If `K8S_IMAGE_TAG` is omitted, the Make target generates `manual-deploy-<short-sha>-<yyyy-mm-dd-hh-mm>`.
Use `make manual-deploy-tag` to preview the automatic tag without triggering a workflow.
The selected tag must already exist in the registry before the deploy workflow can roll it out.

```sh
make manual-deploy K8S_SERVICE=main-service TARGET_ENV=dev
make manual-deploy K8S_SERVICE=main-service TARGET_ENV=dev K8S_IMAGE_TAG=manual-deploy-<short-sha>-2026-05-02-11-21
```

The deploy workflow requires a GitHub environment secret named `KUBE_CONFIG_B64`.
That secret should contain a base64-encoded kubeconfig for the target cluster.
Until that secret points to a project-owned cluster, the workflow is expected to fail before deploying.

## Raspberry Pi k3s Plan

The intended first real cluster target is a project-owned Raspberry Pi running k3s.
Do not deploy from a workstation that is connected to an unrelated work cluster.

Suggested setup steps:

1. Install or reset Raspberry Pi OS Lite 64-bit.
2. Enable SSH and set a strong user password or SSH key.
3. Update packages:

   ```sh
   sudo apt update
   sudo apt upgrade -y
   ```

4. Install k3s:

   ```sh
   curl -sfL https://get.k3s.io | sh -
   ```

5. Check the cluster locally on the Pi:

   ```sh
   sudo k3s kubectl get nodes
   ```

6. Copy the kubeconfig to the workstation without merging it into the global default kubeconfig:

   ```sh
   mkdir -p ~/.kube
   ssh <pi-user>@<pi-lan-ip> 'sudo cat /etc/rancher/k3s/k3s.yaml' > ~/.kube/ai-trust-game-pi.yaml
   chmod 600 ~/.kube/ai-trust-game-pi.yaml
   ```

7. Replace the local server address in that kubeconfig with the Pi LAN address:

   ```sh
   perl -pi -e 's#https://127.0.0.1:6443#https://<pi-lan-ip>:6443#' ~/.kube/ai-trust-game-pi.yaml
   ```

8. Verify the project kubeconfig from the workstation:

   ```sh
   make k8s-context
   ```

9. Create the first namespace:

   ```sh
   KUBECONFIG=~/.kube/ai-trust-game-pi.yaml kubectl create namespace atg-dev
   KUBECONFIG=~/.kube/ai-trust-game-pi.yaml kubectl label namespace atg-dev \
     app.kubernetes.io/part-of=ai-trust-game \
     app.kubernetes.io/environment=dev
   ```

10. Base64-encode the final kubeconfig and store it as the GitHub environment secret `KUBE_CONFIG_B64`.

   ```sh
   base64 -i ~/.kube/ai-trust-game-pi.yaml | pbcopy
   ```

## External Access

For application traffic, a Cloudflare Tunnel is a good free starting point.
It avoids opening inbound router ports and can put Cloudflare Access in front of private routes.

The rough shape is:

- run `cloudflared` on the Raspberry Pi
- route a hostname to the in-cluster service or ingress
- protect sensitive routes with Cloudflare Access
- keep the Kubernetes API private unless there is a strong reason to expose it

For GitHub Actions deployment access, prefer one of these approaches:

- GitHub Actions reaches the Kubernetes API through a tightly scoped, protected endpoint.
- A later self-hosted GitHub runner runs inside the home network and deploys locally.

The second option avoids exposing the Kubernetes API publicly and is likely the safer long-term setup.

## Secrets

Expected GitHub secrets:

- `KUBE_CONFIG_B64`
  base64-encoded kubeconfig for the target environment

Expected Kubernetes secrets:

- `main-service-secret`
  optional secret referenced by the chart

Potential future keys:

- `GROQ_API_KEY`
- Cloudflare Tunnel token
- TLS or issuer-related secrets if ingress moves beyond Cloudflare-managed TLS

If the GHCR package is private, create a Kubernetes image pull secret in each environment namespace:

```sh
KUBECONFIG=~/.kube/ai-trust-game-pi.yaml kubectl create secret docker-registry ghcr-pull-secret \
  --namespace atg-dev \
  --docker-server=ghcr.io \
  --docker-username=<github-user> \
  --docker-password=<github-token-with-read-packages>
```

Then add it to the service values:

```yaml
imagePullSecrets:
  - ghcr-pull-secret
```

If the GHCR package is public, no image pull secret is needed.

## Adding A New Service

When adding a new backend service, create a service-owned values directory:

```text
services/<service-name>/k8s/
  values-dev.yaml
  values-test.yaml
  values-prod.yaml
```

The easiest starting point is to copy the `main-service` values files and then rename the service-specific values.

## Values To Rename

Replace these values everywhere they appear:

- `main-service`
  Helm release name, Kubernetes resource name, container name, image name, and `app.kubernetes.io/name`

- `ai-trust-game-<env>`
  namespace names if the service should use a different namespace strategy

- `ghcr.io/dylar/ai-trust-game-main-service`
  GHCR image repository

The chart derives ConfigMap and Secret names from `serviceName`:

- `<serviceName>-config-map`
- `<serviceName>-secret`

The Secret reference is optional, so static-provider local deployments do not need a Secret.

## Service Settings To Review

Review these settings for every new service:

- `replicas`
  How many Pods should run in each environment.

- `image`
  Registry images should be used for remote environments.
  CI-published images get a commit-SHA tag, and manual workflow runs can add a human-readable manual deploy tag.

- `imagePullSecrets`
  Optional Kubernetes Secret names used when pulling private registry images.

- `imagePullPolicy`
  `IfNotPresent` is convenient for local development. Remote environments may need `Always` depending on image tagging.

- `containerPort`
  The port the container listens on.

- `Service.spec.ports`
  The cluster-internal service port and target port.

- `readinessProbe`
  The endpoint Kubernetes uses to decide whether the Pod can receive traffic.

- `livenessProbe`
  The endpoint Kubernetes uses to decide whether the Pod should be restarted.

- `resources.requests`
  CPU and memory Kubernetes should reserve for the container.

- `resources.limits`
  CPU and memory the container is allowed to use.

- `config`
  Non-secret runtime environment variables.

- `Secret`
  Secret values such as API keys. Keep only examples in Git.

## Environment Values

Use values files for values that differ between environments:

- `APP_ENV`
- replicas
- image repository and tag
- CPU and memory
- provider settings such as `LLM_PROVIDER` and `GROQ_MODEL`
- namespace

Avoid changing the chart for service-specific values.
If one service needs a different deployment shape, first consider whether that service needs a separate chart.
