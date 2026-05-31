# Project Navigation

This document works as a table of contents.

Use it to find your way around the project documentation, from high-level architecture to code-near explanations.

Also, you can find the broad development plan and commands reference here.

## Project

- [Project Description and Goals](project/description.md)
- [Agent working contract and documentation map for AI-assisted development](AGENT.md)

## Architecture

- [Architecture Guidelines](architecture/guidelines.md)
- [Backend Architecture](architecture/backend.md)
- [Frontend Architecture](architecture/frontend.md)

## Code-Near Documentation

### Backend

#### Services
- [Game HTTP service, routes, metadata headers, and runtime wiring](../services/game-service/README.md)
- [Game service Kubernetes deployment values](../services/game-service/k8s/README.md)

#### Core / Foundation
- [Shared service bootstrap, HTTP server lifecycle, and runtime config](../pkg/infra/README.md)
- [Request metadata, transport helpers, and JSON response utilities](../pkg/network/README.md)
- [Structured logging abstraction and HTTP request logging](../pkg/logging/README.md)

- [Core domain types and trust-sensitive business vocabulary](../services/game-service/service/domain/README.md)
- [Authoritative session repository boundary and in-memory storage](../services/game-service/service/session/README.md)
- [LLM provider abstraction and runtime configuration](../services/game-service/service/llm/README.md)
- [Audit events, sinks, request analysis, session aggregation, and intent summaries](../services/game-service/service/audit/README.md)

#### Features
- [Interaction pipeline and processor architecture](../services/game-service/service/interaction/README.md)
- [Capability calculation across easy, medium, and hard modes](../services/game-service/service/interaction/capability/README.md)

### Frontend
- [Flutter web app bootstrap and frontend entrypoint](../apps/trust-game-app/README.md)
- [Frontend workload and app entrypoint Kubernetes values](../apps/trust-game-app/k8s/README.md)

### Infrastructure
- [Shared Docker, Compose, Kubernetes, and Make infrastructure](../infrastructure/README.md)
- [Kubernetes chart and deployment structure](../infrastructure/k8s/README.md)
- [GitHub Actions CI, image publishing, and deploy workflows](../.github/workflows/README.md)

## Development

- [Development Plan](development/roadmap.md)
- [Commands](development/commands.md)
- [Kubernetes deployment overview](deployment/k8s.md)
- [Frontend flow diagrams](diagrams/frontend-uml.md)
- [AGENT phase planning notes](development/AGENT-notes.md)
