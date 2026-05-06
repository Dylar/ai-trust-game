# AGENT Notes

This file holds temporary notes, discussed decisions, open questions, and follow-up items from repository work.
Keep stable project documentation in the focused docs such as `k8s.md` and `commands.md`.

## Phase 11 Notes

## Current Cluster State

- First real target cluster: Raspberry Pi running k3s.
- Workstation uses a dedicated kubeconfig at `~/.kube/ai-trust-game-pi.yaml`.
- First namespace: `atg-dev`.
- `main-service` deploys through Helm.
- `app-entry` is the temporary explicit per-environment NodePort entry under `app/k8s/entry-<env>.yaml`.
- Long-term ingress ownership should move to a future `gateway-service`.

## Cloudflare Tunnel Setup

Use this when the k3s cluster should serve HTTP traffic from the Internet without opening inbound router ports.
The tunnel should point to Traefik on the Raspberry Pi, not directly to a Pod.

Target shape:

```text
Internet
  -> Cloudflare
  -> cloudflared on the Raspberry Pi
  -> Traefik on port 80
  -> Kubernetes Ingress
  -> main-service
```

Prerequisites:

- a Cloudflare account
- a domain managed by Cloudflare
- SSH access to the Raspberry Pi
- Traefik running in k3s
- the `atg-dev` namespace and main-service deployment are already applied

Check Traefik on the workstation:

```sh
KUBECONFIG=~/.kube/ai-trust-game-pi.yaml kubectl get svc -n kube-system traefik
KUBECONFIG=~/.kube/ai-trust-game-pi.yaml kubectl get ingressclass
```

The expected Ingress class is `traefik`.

Create the explicit dev app entry:

```sh
make k8s-apply-entry TARGET_ENV=dev
KUBECONFIG=~/.kube/ai-trust-game-pi.yaml kubectl get svc app-entry -n atg-dev
```

Choose a public hostname, for example:

```text
atg-dev.example.com
```

In the Cloudflare dashboard:

1. Open Zero Trust or Cloudflare One.
2. Go to Networks, then Tunnels.
3. Create a Cloudflare Tunnel.
4. Choose `cloudflared`.
5. Name the tunnel, for example `atg-pi-dev`.
6. Select the Raspberry Pi operating system and architecture.
7. Copy the generated install/run command from Cloudflare.
8. Run that command on the Raspberry Pi over SSH.

Cloudflare's dashboard command installs `cloudflared` with a tunnel token and runs it as a connector.
This is the preferred setup for a remotely managed tunnel because the token and service command come from Cloudflare.

After the connector is healthy in Cloudflare, add a published application route:

```text
Hostname: atg-dev.example.com
Service:  http://localhost:80
```

Use `localhost:80` because `cloudflared` runs on the Raspberry Pi and Traefik exposes HTTP on the Pi's port 80.

Then test from outside the Tailnet:

```sh
curl https://atg-dev.example.com/healthz
```

If the request does not route, check the future Ingress or gateway resources plus the tunnel service:

```sh
KUBECONFIG=~/.kube/ai-trust-game-pi.yaml kubectl get svc app-entry -n atg-dev
KUBECONFIG=~/.kube/ai-trust-game-pi.yaml kubectl get pods -n atg-dev -l app.kubernetes.io/name=app-entry
sudo systemctl status cloudflared
sudo journalctl -u cloudflared -n 100 --no-pager
```

For a later Ingress-based setup, set the public hostname explicitly on the Ingress rule:

```yaml
rules:
  - host: atg-dev.example.com
    http:
      paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: main-service
              port:
                number: 8080
```

The current Tailscale setup uses NodePorts instead of Ingress host rules.
Using an explicit host is clearer once the public hostname is stable.

To protect the dev application, add a Cloudflare Access self-hosted application for the same hostname and allow only
trusted users.
Do not expose the Kubernetes API through the tunnel.

## Follow-Ups

- Move the public cluster entry point from `main-service` to `gateway-service` in Phase 12.
- Revisit public hosting with real hostnames, TLS, and access protection after the Tailscale-only setup.
- Review and simplify documentation after Phase 11 is finished.

## GitHub Actions Deploy Strategy

Do not use a self-hosted GitHub Actions runner on the Raspberry Pi while the repository is public.
GitHub warns that forks of public repositories can potentially run dangerous code on self-hosted runners through pull requests.
That makes a home-network runner too risky as the default Phase 11 solution.

Current safe baseline:

- deploy from the workstation with `make k8s-deploy`
- keep GitHub Actions deploy on GitHub-hosted runners
- require a securely reachable Kubernetes API and `KUBE_CONFIG_B64` before using the GitHub Actions deploy workflow

Possible later options:

- make the repository private and revisit a locked-down self-hosted runner
- expose only the Kubernetes API through a hardened private network path
- use a deployment pull agent such as Argo CD or Flux inside the cluster
