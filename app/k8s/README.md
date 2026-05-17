# App Kubernetes Values

This directory owns Kubernetes values for the Flutter web workload and the current app entrypoint.

[General Kubernetes layout](../../docs/deployment/k8s.md)<br>
[Shared Helm charts](../../infrastructure/k8s/README.md)

## Files

```text
values-dev.yaml          frontend-web in atg-dev
values-test.yaml         frontend-web in atg-test
values-prod.yaml         frontend-web in atg-prod

entry-values-dev.yaml    app-entry in atg-dev
entry-values-test.yaml   app-entry in atg-test
entry-values-prod.yaml   app-entry in atg-prod
```

## Frontend Workload

`values-<env>.yaml` deploys `frontend-web` with the shared service chart.

It sets the image, namespace, `APP_ENV`, port `80`, probes, replicas, and resources.

Current image repositories:

```text
dev    ghcr.io/dylar/ai-trust-game-frontend-web-dev
test   ghcr.io/dylar/ai-trust-game-frontend-web-test
prod   ghcr.io/dylar/ai-trust-game-frontend-web-prod
```

These repositories are environment-specific because the Flutter web image is currently built with `APP_ENV` and
`API_BASE_URL` as Docker build arguments.
The same Git SHA can therefore produce different frontend artifacts for different environments.

If API URL configuration becomes runtime config later, this can move toward one image repository for `frontend-web`.

## App Entry

`entry-values-<env>.yaml` deploys `app-entry` with the shared entry chart.

It sets only the namespace, environment, and NodePort:

```text
dev    30080
test   30081
prod   30082
```

`app-entry` is an Nginx reverse proxy.
It routes backend paths to `main-service` and all other traffic to `frontend-web`.

This ownership is temporary.
If a dedicated `gateway-service` is added later, public traffic configuration should move there.
