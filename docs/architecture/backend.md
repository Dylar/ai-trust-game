# Backend Architecture

## Purpose

This document describes the preferred backend structure for projects of this style.

It is a backend playbook for:

- organizing backend services
- keeping entry points and flows understandable
- deciding where backend behavior belongs
- keeping boundaries, logging, and testing explicit

For general architecture rules, see [guidelines.md](./guidelines.md).

## Backend Structure

Backend code should be organized around services and backend-facing flows.

Each backend service should live under `services/<service-name>/`.

The preferred service structure is:

- `cmd/`
- `service/`
- `scripts/`
- `proto/` when the service exposes gRPC or service-specific contracts
- `k8s/` when the service owns service-specific Kubernetes values or deployment configuration

Shared supporting areas may exist outside individual services when they are not owned by one service:

- `services/shared/project/`
- `services/shared/foundation/`
- `services/shared/tooling/`
- `infrastructure/`

### `cmd/`

`cmd/` contains the service entrypoint and runtime wiring.

Good candidates:

- service startup
- runtime configuration
- concrete dependency creation
- factories and flow wiring
- server setup

`cmd/` is the composition root.
It may know concrete implementations because it assembles the running service.

Do not put request handling, business rules, or reusable workflow logic into `cmd/`.

### `service/`

`service/` contains the service-owned implementation.

Good candidates:

- HTTP or gRPC handlers
- request and response DTOs
- transport validation
- transport-to-domain mapping
- status code and error mapping
- small service-local behavior tied to one endpoint
- service-owned domain types and workflow packages
- service-local repository boundaries and storage adapters
- service-owned provider or model integration code

Handlers are backend entry points.
They should keep transport details close and delegate meaningful behavior to a backend flow.

Small endpoint-specific behavior may stay in `service/` when extracting it would only add ceremony.

Service-owned behavior should stay under the owning service instead of a broad root-level backend folder.
Use focused subpackages under `services/<service-name>/service/` for meaningful internal areas such as `domain/`,
`session/`, `interaction/`, `audit/`, or `llm/`.

### `scripts/`

`scripts/` contains development scripts that call service interfaces directly.

Good candidates:

- manual endpoint checks
- local request examples
- scripts for developing a new service flow
- debugging helpers before or beside a frontend

Scripts should exercise the service from the outside.
They should not become a second implementation path for service behavior.

### `proto/`

`proto/` contains service-specific gRPC or contract files when the service owns them.

Proto files are an intentional contract choice.
Use them when a stable cross-language or service boundary contract is useful.

Do not add proto only because transport objects exist.
If normal service-local DTOs are enough, keep the structure smaller.

### `k8s/`

`k8s/` contains service-specific deployment values or configuration.

Good candidates:

- environment-specific values for the service
- service-owned deployment overrides
- configuration consumed by shared Helm charts

Shared Kubernetes chart logic belongs under `infrastructure/k8s/`.
Service folders should keep only the values or deployment details owned by that service.
For Kubernetes details, see [k8s.md](../deployment/k8s.md).

### Service-Owned Domain Packages

Service-owned domain packages contain the domain language owned by one service.

Good candidates:

- trusted state
- enums and fixed categories
- actions, decisions, and plans
- claims that must stay distinct from verified state

Domain types should express business meaning clearly.
Avoid letting transport DTOs, persistence records, or provider payloads become the main business model by accident.

### `services/shared/project/`

`services/shared/project/` contains project-specific shared backend code used by multiple services.

Good candidates:

- shared project contracts
- shared event envelopes
- shared project vocabulary that intentionally crosses service boundaries

Do not put service-private behavior here.
If one service owns the concept, keep it under that service until another service truly needs the shared contract.

### `services/shared/foundation/`

`services/shared/foundation/` contains reusable backend application core and technical support.

Good candidates:

- logging abstractions
- service bootstrap helpers
- shared HTTP helpers
- reusable error, request, or runtime helpers

Foundation packages should stay generic and project-independent where practical.
Avoid putting service-specific workflows or product-specific business rules into `services/shared/foundation/`.

### `services/shared/tooling/`

`services/shared/tooling/` contains shared support for backend service tests and scripts.

Good candidates:

- reusable test helpers
- shared fake setup
- script support code
- local verification helpers

Avoid placing business logic in `services/shared/tooling/`.

### `infrastructure/`

`infrastructure/` contains delivery and operational support.

Good candidates:

- Dockerfiles
- Docker Compose files
- Helm charts
- Kubernetes chart templates
- Makefile fragments
- future Terraform or deployment automation

Infrastructure should support running and deploying the system.
It should not own backend business behavior.

## Where Logic Lives

### Service Entry Points

Service entry points receive input and return output.

Examples:

- HTTP handlers
- gRPC handlers
- CLI commands
- job runners
- queue consumers

They should:

- parse and validate transport input
- load request-scoped metadata if needed
- map transport DTOs into backend inputs
- call one focused backend flow when behavior is meaningful
- map backend results into transport responses
- translate backend errors into transport errors

They should not:

- own larger business workflows
- call providers directly for business behavior
- hide policy decisions inside transport code
- coordinate many unrelated dependencies
- become the main home of stateful logic

For HTTP handlers, `ServeHTTP` should usually be the transport entrypoint.
Private helper methods may keep small endpoint-specific behavior close by.

### Backend Flows

Backend flows coordinate meaningful behavior.

Possible names include:

- processor
- use case
- application service
- orchestrator
- flow

Use one consistent name within a feature or service.
The responsibility matters more than the label.

A flow should own one coherent backend workflow.
Introduce one when:

- a request does more than simple mapping
- multiple meaningful steps need coordination
- state must be loaded and updated
- business decisions need to stay explicit
- provider, repository, or infrastructure calls should not leak into handlers

Small workflows do not need a separate flow object when the responsibility stays clear and tests can still describe the
behavior.
If this is a deliberate architectural trade-off, document it in the owning feature README.

### Domain Types

Domain types describe backend meaning.

Prefer them for:

- trusted state
- business inputs and outputs
- decisions and outcomes
- fixed categories and enums
- distinctions that must remain explicit

Keep user claims separate from verified state.
Keep provider payloads and persistence records separate from domain types unless sharing the model is an intentional
contract decision.

## Flow Pattern

The backend should prefer explicit and lightweight flow objects over hidden orchestration.

The default flow pattern is:

- the entry point handles transport concerns
- the flow receives explicit input
- the flow coordinates domain steps and boundaries
- repositories own stored state access
- provider clients own external provider calls
- the flow returns a result the entry point can map to transport output

Split a flow into collaborators when the steps have:

- different rules
- different tests
- different boundary concerns
- different replacement needs

Do not split a flow only because a pattern says every step needs its own type.
Keep the structure as small as possible while preserving clear ownership.
If this introduces a deliberate architectural trade-off, document the trade-off in the owning feature README.

## Boundaries

Use explicit boundaries where the backend communicates with the outside world or crosses a meaningful technical seam.

Typical examples:

- repositories
- provider clients
- audit sinks
- external service adapters
- persistence adapters

Interfaces are useful for real boundaries or intentional variation points.
Prefer placing an interface near the package that consumes the behavior.

Concrete types are the default for:

- flow objects
- internal helpers
- domain services without an external boundary
- implementations that do not need replacement

The goal is not "everything behind an interface".
The goal is "interfaces where replacement, testing, or separation actually matters".

## State Ownership

Choose the smallest state owner that matches the lifetime of the state:

- request-local state belongs in request input, handler-local variables, or flow input
- workflow state belongs in the backend flow that coordinates the workflow
- persisted state belongs behind a repository boundary
- trusted business state belongs in domain types
- runtime configuration belongs in the composition root or reusable service core

Avoid passing raw transport DTOs deep into backend flows.
Avoid letting external provider payloads become authoritative state.

## Dependency Direction

Prefer this direction for service behavior:

```text
cmd -> service entry point -> flow/usecase -> repository/provider client -> external system
                                      -> domain
```

Shared application core may be used by entry points, flows, and boundary implementations:

```text
service/flow/boundary -> services/shared/foundation
```

Do not let domain logic depend on transport packages, concrete deployment infrastructure, or runtime entrypoints.

## Contracts

Use shared contracts intentionally.

Proto, OpenAPI, or shared DTO packages may be useful when:

- multiple clients or services need the same stable contract
- Go and Flutter models should remain aligned
- generated code reduces duplicate manual mapping
- the contract is owned and versioned deliberately

Avoid introducing shared contracts when service-local DTOs are enough.
Avoid treating a provider payload as the project contract unless that dependency is intentionally part of the boundary.

## Logging And Testing

### Logging

Backend logging should make runtime behavior understandable without turning the system into noise.

Prefer logging at:

- service entrypoints
- important flow boundaries
- explicit allow or deny decisions when they matter
- external integration failures
- unexpected validation or state failures

Prefer structured logs with stable fields such as:

- request or session identifiers
- mode, role, or other important context
- action or flow step names
- provider or integration name
- error type or category

Avoid:

- logging secrets or restricted data
- logging full sensitive payloads by default
- adding logs to every helper and internal branch
- duplicating the same failure at many layers without adding new context

### Testing

Backend tests should be behavior-first.

Prefer a BDD-style structure without introducing Gherkin files or heavy extra tooling.

That means:

- describe scenarios clearly
- keep setup, action, and expectation easy to read
- focus on observable behavior
- test decisions and outcomes rather than private implementation details

Good candidates for backend tests are:

- policy and decision logic
- state transitions
- flow-step behavior
- transport-to-flow mapping

Use mocks or fakes at real boundaries such as:

- repositories
- provider clients
- audit sinks
- external adapters

Avoid mocking internal details that are not true architectural boundaries.

## Project-Specific Notes

For repository-specific backend details, continue with the [code-near documentation](../project-navigation.md#backend).
