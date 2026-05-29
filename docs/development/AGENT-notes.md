# AGENT Notes

This file holds temporary phase planning notes, discussed decisions, open questions, and follow-up items from repository
work.

Use this file to turn the broad roadmap into a concrete phase definition before implementation starts. Once a phase is
implemented, move durable decisions into the focused project documentation and remove obsolete working notes.

The notes are not the project source of truth. They are a planning area for discussion and decision-making until the
relevant decisions are implemented and reflected in stable documentation.

## Phase 12 Notes

Phase 12 should focus on service ownership and repository structure, not on adding gRPC or Proto contracts.
The current direction is to remove gRPC/Proto from the Phase 12 scope because it would add code generation,
contract-versioning, and tooling overhead without a clear project need yet.

Target service split:

- `gateway-service`
  owns the public backend entry point for external access into the cluster.
  External clients should call the gateway instead of cluster-internal services directly.
  The gateway can later own cross-cutting public-edge concerns such as auth, CORS, rate limiting, request shaping,
  and routing.
- `game-service`
  owns the core product logic such as sessions, interactions, modes, policies, and the current game flow.
  This replaces the current `main-service` name because the service will no longer be the generic main backend entry
  point after the gateway exists.
- `logging-service`
  owns log ingestion from the app through the gateway and, later, service or cluster-internal logs.
  Async communication for internal log delivery is intentionally undecided and should be evaluated when that work
  becomes concrete.
- `audit-service`
  owns audit event ingestion, audit analysis, audit read models, and later audit persistence.

Repository structure direction:

- Move the current `app/` folder to an `apps/` hierarchy, for example `apps/trust-game-app/`.
  This keeps app ownership consistent with service ownership and leaves room for future apps.
- Move service-owned backend code from root-level `internal/` and `pkg/` into the services that own the behavior.
- Keep service-private Go code in `services/<service-name>/internal/` where the Go import restriction helps protect
  service boundaries.
- Keep shared service contracts out of service-private `internal/` packages.
  Service-owned contracts can live close to the owning service, and truly shared contracts should live in an explicitly
  named shared location.
- Keep truly shared Go foundations only in an explicitly named shared location if multiple services need them.
  Avoid keeping a broad root-level `pkg/` as a mixed ownership area.
- Keep root-level directories focused on repository-wide concerns such as documentation, infrastructure, tooling, and
  top-level orchestration.

Communication direction:

- Public API: HTTP/JSON through `gateway-service`.
- Internal service communication: HTTP/JSON by default for now.
- Async messaging for logging or audit delivery is a future decision and should not be locked in during this planning
  step.
- Do not introduce gRPC/Proto unless a later service boundary has a concrete need that justifies the extra tooling.

Phase 12 success criteria:

- Public cluster traffic enters through `gateway-service`.
- `game-service`, `logging-service`, and `audit-service` have explicit ownership and deployment/runtime structure.
- The app lives under `apps/`.
- Service-owned code is no longer mixed into root-level backend folders without clear ownership.
- Documentation reflects the new boundaries and any deliberate shared-code location.
