# Kubernetes

The project uses Helm for shared Kubernetes structure.
Services provide environment-specific values next to their code.

## Layout

Shared service chart:

```text
infrastructure/k8s/service-chart/
  Chart.yaml
  values.yaml
  values.schema.json
  templates/
    config-map.yaml
    deployment.yaml
    service.yaml
```

Shared app entry chart:

```text
infrastructure/k8s/entry-chart/
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

Frontend values and app entry chart:

```text
app/k8s/
  values-dev.yaml
  values-test.yaml
  values-prod.yaml
  entry-values-dev.yaml
  entry-values-test.yaml
  entry-values-prod.yaml
```

The shared chart renders the common `Deployment`, `Service`, and `ConfigMap`.
The app entry chart renders the Nginx entrypoint that routes frontend and backend traffic through one NodePort service.

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
make k8s-template ENV=dev
```

Lint and render all prepared environments:

```sh
make k8s-lint
```

Deploy an environment:

```sh
make k8s-deploy ENV=dev
```

This deploys all prepared services using the current Git commit SHA as the image tag.
That tag must already exist in GHCR.

Deploy one service from an already published commit-SHA image:

```sh
make k8s-deploy SERVICE=main-service ENV=dev
```

Build the current local working tree, push images with a generated `manual-deploy-<sha>-<date>-<time>` tag, and deploy
them:

```sh
make manual-deploy ENV=dev
```

Build and deploy only one service from the local working tree:

```sh
make manual-deploy SERVICE=main-service ENV=dev
```

Remove a release:

```sh
make k8s-delete SERVICE=main-service ENV=dev
```

Apply or remove the app entry Helm release:

```sh
make k8s-apply-entry ENV=dev
make k8s-delete-entry ENV=dev
```

Check deployed resources:

```sh
make k8s-status
KUBECONFIG=~/.kube/ai-trust-game-pi.yaml kubectl get svc app-entry -n atg-dev
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
http://raspberrypi.tail164eef.ts.net:30080
```

For the current Tailscale setup, the environment ports are:

```text
dev   http://raspberrypi.tail164eef.ts.net:30080
test  http://raspberrypi.tail164eef.ts.net:30081
prod  http://raspberrypi.tail164eef.ts.net:30082
```

## App Entry

The shared Helm chart does not create generic public entry points.
The current Tailscale entry points are rendered from `infrastructure/k8s/entry-chart` with values from
`app/k8s/entry-values-<env>.yaml`.

Each app entry creates a small Nginx reverse proxy and exposes it as a `NodePort`.
It routes backend paths such as `/session`, `/interaction`, `/analysis`, and `/healthz` to `main-service:8080`.
It routes `/` to `frontend-web:80`.
The long-term public entry point should move to a future `gateway-service`.

## GitHub Actions Deploy

The deploy workflow runs on GitHub-hosted runners and expects `KUBE_CONFIG_B64` to contain a kubeconfig
for a securely reachable Kubernetes API.

Do not use a self-hosted GitHub Actions runner for this public repository unless the repository becomes private
or the runner is explicitly hardened for public-repository risk.
For the current Raspberry Pi dev cluster, prefer workstation-local deploys with `make k8s-deploy ENV=dev`.

## Secrets

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
