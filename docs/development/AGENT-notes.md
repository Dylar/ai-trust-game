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
- The current `main-service` is renamed to `game-service`.
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

1. Define the final service boundaries.
   - `gateway-service` owns the public backend entry point for external access into the cluster.
   - `gateway-service` can later own cross-cutting public-edge concerns such as auth, CORS, rate limiting, request
     shaping, and routing.
   - `game-service` owns the core product logic such as sessions, interactions, modes, policies, and the current game
     flow.
   - `logging-service` owns log ingestion from the app through the gateway and, later, service or cluster-internal logs.
   - `audit-service` owns audit event ingestion, audit analysis, audit read models, and later audit persistence.

2. Move the app into the new app hierarchy.
   - Move `app/` to `apps/trust-game-app/`.
   - Update Make targets, Dockerfiles, Compose files, Kubernetes values, and documentation links that reference `app/`.
   - Verify Flutter tests and build commands still work from the new path.

3. Rename `main-service` to `game-service`.
   - Move `services/main-service/` to `services/game-service/`.
   - Update Go package paths, scripts, Compose services, image names, Kubernetes values, Make targets, and docs.
   - Keep behavior unchanged during the rename.
   - Verify Go tests still pass after the rename.

4. Move service-owned backend code into the owning service.
   - Move game-specific domain, session, interaction, LLM, and audit usage code into `services/game-service/service/`
     where ownership belongs.
   - Move reusable code only when there is a clear owner or shared need.
   - Avoid behavior changes while moving code.

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
