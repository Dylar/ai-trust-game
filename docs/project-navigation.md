# Project Navigation

This document works as a table of contents.

Use it to find your way around the project documentation, from high-level architecture to code-near explanations.

Also, you can find the development roadmap and commands reference here.

## Project

- [Project Description and Goals](project-description.md)
- [Agent working contract and documentation map for AI-assisted development](AGENT.md)

## Architecture

- [Architecture Guidelines](architecture-guidelines.md)
- [Backend Architecture](architecture-backend.md)
- [Frontend Architecture](architecture-frontend.md)

## Code-Near Documentation

### Backend

#### Services
- [Main HTTP service, routes, metadata headers, and runtime wiring](../services/main-service/README.md)

#### Core / Foundation
- [Shared service bootstrap, HTTP server lifecycle, and runtime config](../pkg/infra/README.md)
- [Request metadata, transport helpers, and JSON response utilities](../pkg/network/README.md)
- [Structured logging abstraction and HTTP request logging](../pkg/logging/README.md)


- [Core domain types and trust-sensitive business vocabulary](../internal/domain/README.md)
- [Authoritative session repository boundary and in-memory storage](../internal/session/README.md)
- [LLM provider abstraction and runtime configuration](../internal/llm/README.md)
- [Audit events, sinks, request analysis, session aggregation, and intent summaries](../pkg/audit/README.md)

#### Features
- [Interaction pipeline and processor architecture](../internal/interaction/README.md)
- [Capability calculation across easy, medium, and hard modes](../internal/interaction/capability/README.md)

### Frontend
- [Flutter web app bootstrap and frontend entrypoint](../app/README.md)

## Development

- [Development Phases](dev-roadmap.md)
- [Commands](commands.md)
