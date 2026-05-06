# Kubernetes

The project uses Helm for shared Kubernetes structure.
Services provide environment-specific values next to their code.

## Layout

Shared chart:

```text
infrastructure/k8s/chart/
  Chart.yaml
  values.yaml
  values.schema.json
  templates/
    config-map.yaml
    deployment.yaml
    service.yaml
```

Main-service values and explicit manifests:

```text
services/main-service/k8s/
  values-dev.yaml
  values-test.yaml
  values-prod.yaml
```

Frontend values and the temporary dev entry Ingress:

```text
app/k8s/
  values-dev.yaml
  values-test.yaml
  values-prod.yaml
  ingress-dev.yaml
```

The shared chart renders the common `Deployment`, `Service`, and `ConfigMap`.
Namespaces and Ingress resources are intentionally outside the shared chart.

## Namespaces

Environment namespaces use the short `atg-<env>` form:

```text
atg-dev
atg-test
atg-prod
```

Create the dev namespace:

```sh
KUBECONFIG=~/.kube/ai-trust-game-pi.yaml kubectl create namespace atg-dev
KUBECONFIG=~/.kube/ai-trust-game-pi.yaml kubectl label namespace atg-dev \
  app.kubernetes.io/part-of=ai-trust-game \
  app.kubernetes.io/environment=dev
```

## Kubeconfig

Project Kubernetes commands use a dedicated kubeconfig:

```text
~/.kube/ai-trust-game-pi.yaml
```

This avoids accidentally using another workstation cluster context.

Fetch the k3s kubeconfig from the Raspberry Pi:

```sh
mkdir -p ~/.kube
ssh <pi-user>@<pi-lan-ip> 'sudo cat /etc/rancher/k3s/k3s.yaml' > ~/.kube/ai-trust-game-pi.yaml
chmod 600 ~/.kube/ai-trust-game-pi.yaml
perl -pi -e 's#https://127.0.0.1:6443#https://<pi-lan-ip>:6443#' ~/.kube/ai-trust-game-pi.yaml
```

Check the selected cluster:

```sh
make k8s-context
```

## Commands

Render without applying:

```sh
make k8s-template TARGET_ENV=dev
```

Lint and render all prepared environments:

```sh
make k8s-lint
```

Deploy an environment:

```sh
make k8s-apply TARGET_ENV=dev
make k8s-apply K8S_SERVICE=frontend-web TARGET_ENV=dev
```

If `K8S_IMAGE_TAG` is omitted, the current Git commit SHA is used as the image tag.
That tag must already exist in GHCR.

Override the image tag:

```sh
make k8s-apply TARGET_ENV=dev K8S_IMAGE_TAG=<tag>
```

Remove a release:

```sh
make k8s-delete TARGET_ENV=dev
```

Apply or remove the explicit dev Ingress:

```sh
make k8s-apply-ingress TARGET_ENV=dev
make k8s-delete-ingress TARGET_ENV=dev
```

Check deployed resources:

```sh
make k8s-status
KUBECONFIG=~/.kube/ai-trust-game-pi.yaml kubectl get ingress -n atg-dev
```

## Images

The main-service image repository is:

```text
ghcr.io/dylar/ai-trust-game-main-service
```

Frontend images are environment-specific because their Flutter build uses environment-specific `--dart-define` values:

```text
ghcr.io/dylar/ai-trust-game-frontend-web-dev
ghcr.io/dylar/ai-trust-game-frontend-web-test
ghcr.io/dylar/ai-trust-game-frontend-web-prod
```

The publish workflow creates:

- a full commit-SHA tag
- `latest`
- an optional manual tag from the workflow input

Published images are built for:

- `linux/amd64`
- `linux/arm64`

Set these GitHub repository variables before publishing frontend images for real environments:

- `DEV_API_BASE_URL`
- `TEST_API_BASE_URL`
- `PROD_API_BASE_URL`

For Tailscale dev, `DEV_API_BASE_URL` should point to the MagicDNS HTTP origin:

```text
http://raspberrypi.tail164eef.ts.net
```

## Ingress

The shared Helm chart does not create generic Ingress resources.
Ingress resources are explicit service-owned manifests.

The current temporary dev entry point is:

```text
app/k8s/ingress-dev.yaml
```

It routes backend paths such as `/session`, `/interaction`, `/analysis`, and `/healthz` to `main-service:8080`.
It routes `/` to `frontend-web:80`.
The long-term public entry point should move to a future `gateway-service`.

## Secrets

GitHub Actions deployment expects:

- `KUBE_CONFIG_B64`
  base64-encoded kubeconfig for the target environment

The chart optionally references:

- `main-service-secret`
  runtime secrets for the main service

If GHCR is private, create an image pull secret in each namespace:

```sh
KUBECONFIG=~/.kube/ai-trust-game-pi.yaml kubectl create secret docker-registry ghcr-pull-secret \
  --namespace atg-dev \
  --docker-server=ghcr.io \
  --docker-username=<github-user> \
  --docker-password=<github-token-with-read-packages>
```

Then reference it from the service values:

```yaml
imagePullSecrets:
  - ghcr-pull-secret
```

## Adding A Service

For a new backend service:

1. Copy the `main-service` values files.
2. Replace `serviceName`.
3. Set the namespace.
4. Set the image repository.
5. Review replicas, resources, ports, probes, config, and secrets.
6. Add explicit Ingress only when the service is meant to be an entry point.
