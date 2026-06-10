# AGENT Notes

This file holds temporary phase planning notes, discussed decisions, open questions, and follow-up items from repository
work.

Use this file to turn the broad project plan into a concrete phase definition before implementation starts.
Once a phase is implemented, move durable decisions into the focused project documentation and remove obsolete working
notes.

The notes are not the project source of truth. They are a planning area for discussion and decision-making until the
relevant decisions are implemented and reflected in stable documentation.

## Phase 13 planning notes

### Working goal

Turn persistence from a broad phase topic into a small sequence of implementation steps that preserves the existing
architecture boundaries.

Phase 13 should make state survive process and app restarts while keeping the backend authoritative for session and
interaction state.

### Phase scope

- Add PostgreSQL-backed backend persistence for users, sessions, interactions, and audit/events.
- Add local Flutter persistence with drift for app restore flows and offline read-only access to previously loaded state.
- Introduce minimal user identity for persistence restore flows.
- Keep the minimal user identity intentionally simple: it is a demo continuity mechanism, not real authentication or
  authorization.
- Persist all user-relevant app state needed to reopen the app offline, inspect prior sessions/interactions, and show a
  clear offline error if the user tries to continue a flow that requires the backend.
- Define how local app state and backend authoritative state are reconciled after restart or reconnect.
- Persist RabbitMQ queues and configure retry/dead-letter behavior for async messages.
- Define migration strategy for both backend and frontend schemas.

### First planning decisions

- Treat the backend as the source of truth for sessions, interactions, and audit/event records.
- Treat local app persistence as a full offline-readable copy of previously loaded user-facing state, but not as
  authority over backend state.
- Name the identity feature carefully in implementation and docs so it cannot be mistaken for production-grade auth.
- Add an auth-service boundary for minimal user identity, while documenting that it is intentionally not real auth yet
  and can be evolved later into proper authentication.
- Show a list of existing users and provide an input for creating/selecting a new user.

### Concrete implementation plan

#### 1. Add backend persistence foundation (DONE)

- Add a shared persistence foundation under `services/shared/foundation/persistence`.
- Add PostgreSQL as a replaceable implementation under `services/shared/foundation/persistence/postgres`.
- Keep the shared PostgreSQL package generic: connection setup, configuration, ping/health helpers, migration glue, and
  optional transaction helpers only.
- Keep service-specific repository interfaces and SQL adapters under the owning service packages.
- Use `golang-migrate` for backend schema migrations.
- Add migration files using numbered `*.up.sql` and `*.down.sql` files.
- Add initial migrations for users, sessions, interactions, audit events, client logs if needed by read views, and
  service-owned metadata.
- Add local migration commands to the development workflow.
- Add test helpers for running repository tests against PostgreSQL.
- Add tests for PostgreSQL config parsing, ping/health behavior, migration glue, and test helper setup.
- Update the shared persistence README.

#### 2. Create auth-service (DONE)

- Create `services/auth-service`.
- Add `cmd/` composition root, `service/` HTTP layer, `k8s/` values, and a service README following the existing service
  layout.
- Add health endpoint `GET /healthz`.
- Add user domain/repository boundary for minimal identity.
- Implement PostgreSQL user repository under the auth-service's service-owned persistence package.
- Add `GET /users` to list existing users.
- Add `POST /users` to create a new user from a display/login name.
- Add `POST /users/select` to return the selected user identity without validating credentials.
- Validate empty, duplicate, and overly long names.
- Return stable `userId`, display name, and timestamps.
- Ensure all auth-service responses use the same error style as the other Go services.
- Keep the service intentionally simple: no passwords, no tokens, no authorization checks.
- Add handler, repository, and migration-backed tests while building the service.
- Document in the service README that this is demo identity for restore continuity and can later become real auth.

#### 3. Wire auth-service through gateway (DONE)

- Add `AUTH_SERVICE_URL` configuration to `gateway-service`.
- Proxy `/auth/*` routes from the gateway to `auth-service`.
- Forward request metadata headers consistently.
- Update gateway tests for the new proxy route.
- Update gateway README and k8s values for the new service URL.

#### 4. Persist game-service sessions and interactions (DONE)

- Replace or supplement the in-memory session repository with a PostgreSQL-backed implementation.
- Place game-service PostgreSQL repository adapters under service-owned persistence packages.
- Persist sessions with `user_id`, role, mode, current state, created/updated timestamps, and completion/status metadata.
- Persist interactions with session id, user id, request id, user input, selected action, policy result, response text,
  timestamps, and relevant structured pipeline outputs.
- Keep the existing in-memory repository available for focused tests and lightweight runs where appropriate.
- Update `POST /session/start` so it requires/uses stable user identity from request metadata.
- Update `POST /interaction` so saved interaction records are user-scoped and session-scoped.
- Add restore/query endpoints for listing a user's resumable sessions and fetching full session detail.
- Add tests for session start persistence, interaction save behavior, user-scoped restore queries, and in-memory
  repository compatibility where it remains supported.
- Update game-service README and service-owned package READMEs for persistence behavior.

#### 5. Persist audit-service events and analysis views

- Add PostgreSQL-backed audit event storage.
- Place audit-service PostgreSQL repository adapters under the audit-service-owned persistence package.
- Persist consumed audit events instead of keeping analysis data only in memory.
- Add query support for request-level and session-level analysis views.
- Include user id when audit events provide it.
- Preserve current analysis response contracts unless a contract change is required for restore/offline read views.
- Add tests for audit event storage, request-level analysis queries, session-level analysis queries, and user id
  propagation.
- Update audit-service README for persistence behavior.

#### 6. Persist logging-service client logs

- Add PostgreSQL-backed client log storage.
- Place logging-service PostgreSQL repository adapters under the logging-service-owned persistence package.
- Persist log entries with request id, session id, user id, level, message, timestamp, and structured metadata.
- Keep ingestion behavior compatible with the existing app log shipping flow.
- Add query support for stored client logs used by UI and analysis views.
- Add tests for log ingestion persistence and stored log queries.
- Update logging-service README for persistence behavior.

#### 7. Configure RabbitMQ persistence

- Configure durable exchanges and queues for audit/log async delivery.
- Configure persistent messages where the publisher controls delivery mode.
- Add broker volume setup in Docker Compose.
- Add persistent volume configuration in Kubernetes values/charts.
- Move broker credentials into Kubernetes Secrets.
- Add retry and dead-letter queue configuration.
- Add focused messaging tests or runtime checks for durable queue/exchange declaration, persistent publishing, retry, and
  dead-letter behavior.
- Update RabbitMQ and infrastructure docs for persistence, Secrets, and volumes.

#### 8. Update Docker Compose runtime

- Add PostgreSQL service to the compose setup.
- Add auth-service to compose.
- Wire database URLs for auth-service, game-service, audit-service, and logging-service as needed.
- Add database volume for local persistence.
- Ensure gateway can reach auth-service through the compose network.
- Add or update make commands for starting the full persistence stack.
- Add a compose smoke check for service health, database connectivity, and gateway-to-auth routing.
- Update Docker Compose documentation.

#### 9. Update Kubernetes runtime

- Add auth-service Helm values for dev, test, and prod.
- Add PostgreSQL configuration or document the expected external PostgreSQL dependency for each environment.
- Add Secrets for database credentials and RabbitMQ credentials.
- Add persistent volume values for PostgreSQL and RabbitMQ where the environment owns storage.
- Wire service URLs through gateway, game-service, audit-service, and logging-service values.
- Update deployment docs after implementation.
- Add template/value checks for the changed Helm configuration.

#### 10. Add Flutter local persistence

- Add drift dependencies to `apps/trust-game-app`.
- Create a local database layer under the app's existing data/service boundaries.
- Add local tables for selected user, known users, sessions, interactions, analysis/audit views, client logs, and sync or
  restore metadata.
- Track when known users were last selected.
- Derive whether a user is loaded from locally persisted sessions for that user.
- Persist every user-facing record the app has already loaded so it can be inspected offline.
- Add repository abstractions so screens do not access drift directly.
- Add local schema migrations for app database changes.
- Add drift database tests for local tables, local migrations, selected-user state, loaded/unloaded user derivation, and
  cached session/interaction reads.

#### 11. Create login screen

- Always show a login/user-selection screen before entering the main app flow.
- Show two user lists: loaded users and unloaded users.
- Derive loaded users from users that have locally persisted sessions.
- Treat known users without locally persisted sessions as unloaded users.
- Sort both lists by last selected timestamp, newest first.
- Treat loaded users as available for offline read-only use.
- Treat unloaded users as requiring an online backend load before entering their app state.
- Preselect the last selected user when one exists.
- If online, refresh the list from auth-service.
- Add an input for creating a new user.
- On selection or creation, persist the selected user locally.
- Make the copy/UI clear and lightweight without presenting it as secure login.
- Handle offline startup by allowing the last selected/local users to be selected, but prevent creating a new user while
  offline.
- Add UI/state tests for user list sorting, preselection, user creation, user selection, and offline restrictions.

#### 12. Implement app startup and restore flow

- On startup, load the selected user and cached state from drift.
- Route to the login/user-selection screen before entering the main app flow.
- Preselect the last selected user when local state contains one.
- Continue into the main app flow only after the user confirms, selects, or creates a user.
- If the selected user is loaded locally, allow offline read-only entry.
- If the selected user is not loaded locally, require online backend access to load that user's app state first.
- If online, fetch authoritative resumable sessions for the selected user and update local drift data.
- If offline, show cached sessions, interactions, and analysis views read-only.
- When the user tries to continue a backend-dependent flow offline, show a clear offline error.
- Reconcile stale local session references when the backend no longer has a session.
- Add app startup tests for selected user restore, online refresh, offline read-only entry, unloaded-user online loading,
  and stale local session handling.

#### 13. Update session and interaction UI flows

- Ensure session start sends the selected user id through the existing request metadata path.
- Ensure interaction requests continue to include session id and user id metadata.
- Update home/session screens to show restored sessions from local persistence.
- Update detail screens to read from local persistence first and refresh from backend when online.
- Preserve current loading and error handling patterns.
- Add tests for session start metadata, interaction metadata, restored session display, detail-screen cached reads, and
  offline action errors.
- Update app README for local persistence and offline restore behavior.

#### 14. Run end-to-end verification

- Start the full compose stack with PostgreSQL, RabbitMQ, gateway, auth-service, game-service, audit-service,
  logging-service, and Flutter web.
- Create/select a user.
- Start a session and complete at least one interaction.
- Verify session, interaction, audit, and log data are written to persistent storage.
- Restart backend services and confirm the app can restore the same user/session state.
- Restart the browser/app and confirm local restore works.
- Stop backend connectivity and confirm offline read-only behavior works.
- Restart RabbitMQ and confirm durable queued messages behave according to the configured persistence rules.
- Run backend tests, Flutter tests, linting, and formatting after the full persistence path works.

#### 15. Final documentation cleanup

- Confirm all changed stable docs are linked from the proper README ownership chain.
- Move durable decisions from these notes into stable docs and delete obsolete phase-planning notes.
