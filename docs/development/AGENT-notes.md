# AGENT Notes

This file holds temporary phase planning notes, discussed decisions, open questions, and follow-up items from repository
work.

Use this file to turn the broad development plan into a concrete phase definition before implementation starts.
Once a phase is implemented, move durable decisions into the focused project documentation and remove obsolete working
notes.

The notes are not the project source of truth. They are a planning area for discussion and decision-making until the
relevant decisions are implemented and reflected in stable documentation.

## Phase 12 Notes

Phase 12 focuses on service ownership and repository structure.
Do not add gRPC or Proto contracts in this phase. They would add code generation, contract-versioning, and tooling
overhead without a clear project need yet.

### Target State

By the end of Phase 12:

- Public cluster traffic enters through `gateway-service`.
- The former `main-service` has been renamed to `game-service`.
- `game-service`, `logging-service`, and `audit-service` have explicit service ownership and runtime structure.
- The Flutter app lives under `apps/trust-game-app/`.
- Service-owned backend code is no longer mixed into root-level `internal/` or `pkg/` folders.
- Shared backend code lives only under explicit `services/shared/...` folders.
- Backend tooling lives under `services/shared/tooling/`.
- Documentation reflects the new service boundaries and repository structure.

### Architecture Rules

- Public API communication uses HTTP/JSON through `gateway-service`.
- Internal service communication uses HTTP/JSON by default for now.
- Async messaging for logging and audit delivery is part of Phase 12.
- The concrete async messaging technology must be chosen during Phase 12 before implementation.
- Services must not import directly from another `services/<service-name>/...` folder.
- Shared code must move through `services/shared/...`.
- Use `services/shared/project/` for project-specific shared Go code that multiple services need.
- Use `services/shared/foundation/` only for generic, project-independent infrastructure-style packages.
- Use `services/shared/tooling/` for backend test helpers, service scripts support, mocks, and other service-focused
  development tooling.
- Keep root-level directories focused on repository-wide concerns such as documentation, infrastructure, tooling, and
  top-level orchestration.

### Work Plan

1. Define the final service boundaries. (Done)
   - `gateway-service` owns the public backend entry point for external access into the cluster.
   - `gateway-service` can later own cross-cutting public-edge concerns such as auth, CORS, rate limiting, request
     shaping, and routing.
   - `game-service` owns the core product logic such as sessions, interactions, modes, policies, and the current game
     flow.
   - `logging-service` owns log ingestion from the app through the gateway and, later, service or cluster-internal logs.
   - `audit-service` owns audit event ingestion, audit analysis, audit read models, and later audit persistence.

   Boundary details:

   - `gateway-service`
     - Owns public HTTP routing for backend API paths.
     - Receives external app/client requests.
     - Preserves and forwards request metadata such as request ID, session ID, and user ID where needed.
     - Routes synchronous public requests to the owning internal service.
     - Does not own game rules, session state, audit analysis, log storage, or persistence.
     - Can later add auth, CORS, rate limiting, public request shaping, and routing policies.

   - `game-service`
     - Owns trust-game domain behavior.
     - Owns session start, authoritative session state, interaction processing, modes, policies, planning, execution,
       response building, and LLM-backed game flow behavior.
     - Emits log and audit events to the appropriate service boundary instead of storing or analyzing them directly once
       those services exist.
     - Does not own public edge routing, client log ingestion, audit read models, or cross-service log collection.

   - `logging-service`
     - Owns log ingestion APIs for app/client logs routed through the gateway.
     - Owns service log event ingestion once internal delivery is introduced.
     - Owns log normalization and log-oriented read models when needed.
     - Does not own audit semantics, game rules, session state, or public API routing.

   - `audit-service`
     - Owns audit event ingestion and audit-specific event semantics.
     - Owns request analysis, session analysis, audit read models, and intent summaries.
     - Receives audit events from `game-service` and possibly public-edge audit events from `gateway-service`.
     - Does not own generic logging, game state transitions, public routing, or persistence setup before Phase 13.

   Cross-service ownership rules:

   - A service may expose HTTP endpoints or async event subjects/queues as its boundary.
   - Other services call or publish to those boundaries instead of importing the service's code directly.
   - Shared event envelopes, DTOs, and project concepts used by multiple services belong under
     `services/shared/project/`.
   - Generic service runtime helpers belong under `services/shared/foundation/`.
   - Backend test and script helpers belong under `services/shared/tooling/`.

2. Move the app into the new app hierarchy. (Done)
   - Move `app/` to `apps/trust-game-app/`.
   - Update Make targets, Dockerfiles, Compose files, Kubernetes values, and documentation links that reference `app/`.
   - Verify Flutter tests and build commands still work from the new path.

   Completion notes:

   - The Flutter app now lives under `apps/trust-game-app/`.
   - Make quality targets run Flutter checks from the new app path.
   - The Flutter web Dockerfile copies the app from the new app path.
   - GitHub Actions Flutter, Helm, deploy, and publish workflows reference the new app path.
   - Frontend Kubernetes values and app-entry values are read from `apps/trust-game-app/k8s/`.
   - App and deployment documentation links point to the new app path.

3. Rename `main-service` to `game-service`. (Done)
   - Move `services/main-service/` to `services/game-service/`.
   - Update Go package paths, scripts, Compose services, image names, Kubernetes values, Make targets, and docs.
   - Keep behavior unchanged during the rename.
   - Verify Go tests still pass after the rename.

   Completion notes:

   - The backend service folder now lives under `services/game-service/`.
   - Service runtime name, logs, Compose service, Kubernetes service name, and image repository use `game-service`.
   - Go imports and service scripts reference `services/game-service/...`.
   - Documentation and workflow references point to `game-service`.

4. Move service-owned backend code into the owning service. (Done)
   - Move game-specific domain, session, interaction, LLM, and audit usage code into `services/game-service/service/`
     where ownership belongs.
   - Move reusable code only when there is a clear owner or shared need.
   - Avoid behavior changes while moving code.

   Completion notes:

   - Game-owned domain, session, interaction, and LLM packages now live under `services/game-service/service/`.
   - The existing audit module moved from root-level `pkg/audit` to `services/game-service/service/audit` because it
     currently owns game-service audit events, analysis, read models, and intent summarization.
   - Root-level `internal/` was removed.
   - The shared Go service Dockerfile now builds from `pkg/` and `services/` without copying a root-level `internal/`.
   - Code-near documentation links now point to the new service-owned package locations.

5. Create the shared service code areas.
   - Create `services/shared/project/` for project-specific shared code.
   - Create `services/shared/foundation/` for generic service foundations such as logging, HTTP/network helpers, and
     runtime bootstrap if they are needed by multiple services.
   - Create `services/shared/tooling/` for backend test helpers, service script helpers, mocks, assertions, and other
     service-focused development tooling.
   - Move existing root-level `pkg/` code into the appropriate shared location only after deciding whether each package
     is project-specific or generic foundation code.
   - Move existing root-level backend `tooling/` code into `services/shared/tooling/` when it supports services rather
     than repository-wide orchestration.

6. Add `gateway-service`.
   - Create the service structure under `services/gateway-service/`.
   - Add health checks and minimal HTTP routing/proxy behavior.
   - Route public API paths through the gateway to the appropriate internal service.
   - Update local Compose and Kubernetes so external backend traffic targets the gateway.

7. Add `logging-service`.
   - Create the service structure under `services/logging-service/`.
   - Move client log ingestion responsibility out of the game service.
   - Update gateway routing and app/backend clients as needed.

8. Add `audit-service`.
   - Create the service structure under `services/audit-service/`.
   - Move audit event ingestion, analysis, read models, and intent summaries out of the game service.
   - Keep persistence out of scope until Phase 13.
   - Update game service calls and gateway routing as needed.

9. Choose and implement async messaging.
   - Choose the async messaging technology for service-to-service log and audit delivery.
   - Add local Compose support for the selected broker or event system.
   - Add Kubernetes runtime configuration for the selected broker or event system if needed in Phase 12 deployments.
   - Define shared event envelope conventions under `services/shared/project/` when events are project-specific.
   - Route log and audit events asynchronously where that is the intended service boundary.
   - Keep public client communication synchronous through `gateway-service`.

10. Update runtime and deployment wiring.
   - Ensure Docker Compose starts the app, gateway, game, logging, and audit services.
   - Add or update Kubernetes values for each service.
   - Ensure public cluster entry routes to `gateway-service`.
   - Keep service-specific deployment values close to each service.

11. Update stable documentation.
    - Update backend architecture documentation for the new service boundaries.
    - Update service READMEs for each new or renamed service.
    - Update app, infrastructure, deployment, and command documentation for the new paths.
    - Update project navigation and root README links where needed.

12. Verify the phase.
    - Run Go tests.
    - Run Flutter tests.
    - Run formatting and linting checks.
    - Run Compose checks for the local stack.
    - Render or lint Kubernetes manifests for the changed services.
    - Remove obsolete working notes once stable documentation reflects the implemented decisions.
