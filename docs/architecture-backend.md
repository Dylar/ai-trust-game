# Backend Architecture

## Purpose

This document describes how backend code should be structured in projects of this style.

It is meant as a reusable backend playbook:

- how services should be organized
- how backend flows should be modeled
- where logic should live
- how boundaries should be defined
- how testing and logging should be approached

For general architecture rules, see [architecture-guidelines.md](./architecture-guidelines.md).

## Service Structure

Each backend service should live under `services/<service-name>/`.

The preferred structure is:

- `cmd/`
- `scripts/`
- `service/`
- `proto/` when the service exposes gRPC or service-specific contracts
- `k8s/` when the service owns service-specific Kubernetes deployment files

Shared supporting areas may also exist outside the individual service:

- `tooling/` for shared helpers used by tests and scripts
- `pkg/k8s/` for shared Kubernetes building blocks reused by multiple services

### `cmd/`

`cmd/` contains the service entrypoint and runtime wiring.

This is where:

- the service starts
- concrete dependencies are created
- factories and flow wiring live
- runtime configuration is applied

### `scripts/`

`scripts/` contains development scripts that call the service interfaces directly.

Prefer one script per service interface when practical.

These scripts are especially useful:

- before a frontend exists
- while developing a new endpoint
- for manual debugging of one service flow

### `service/`

`service/` contains the service-facing code.

This usually means:

- DTOs
- handlers
- transport mapping
- small service-local logic

### `proto/`

If a service defines gRPC or service-specific contracts, keep them in `services/<service-name>/proto/`.

This keeps service boundary contracts close to the service that owns them.

### `k8s/`

If a service owns service-specific deployment configuration, keep it in `services/<service-name>/k8s/`.

This usually contains the concrete Kubernetes configuration for that service and is often an application of shared
patterns or building blocks from `pkg/k8s/`.

## Flow Objects

When backend behavior involves a meaningful workflow, prefer one explicit flow object behind the service entrypoint.

Possible names include:

- `processor`
- `use case`
- `application service`
- `orchestrator`

The important part is the responsibility, not the label, but keep it consistent within the project.

A flow object usually owns one coherent backend workflow.

Introduce one when:

- a request does more than simple data mapping
- multiple meaningful steps need coordination
- state must be loaded and updated
- business decisions need to stay explicit
- provider or infrastructure calls should not leak into handlers

If a workflow grows further, split distinct steps into separate collaborators when they have:

- different rules
- different tests
- different boundary concerns
- different replacement needs

## Service Entry Points

Entry points such as HTTP handlers, CLI commands, job runners, or queue consumers should stay thin.

They should:

- parse and validate transport input
- load request-scoped metadata if needed
- delegate to one backend flow
- map the result back to the transport response

They should not:

- own larger business workflows
- decide policy deep inside transport code
- coordinate many unrelated dependencies
- become the main home of stateful logic

For HTTP handlers, `ServeHTTP` should typically be the entrypoint, while local `handleX` methods may keep small
service-bound logic close by.

If a `handleX` method grows into a meaningful workflow, move it into a dedicated flow object.

## Where Logic Lives

Not all business logic must automatically live in `internal/`.

Use `service/` for logic that is:

- clearly tied to one service interface
- still small enough to stay understandable near the handler
- not yet a reusable backend workflow

Use `internal/` for logic that is:

- transport-independent
- reused across entrypoints
- large enough to deserve its own backend workflow
- important enough to model as a separate core concept

This means:

- `service/` owns the service-facing shell and may keep small service-local logic
- `internal/` owns larger or more reusable backend workflows and core concepts

### Domain Types

Domain types should express business meaning clearly.

Prefer them for:

- trusted state
- enums and fixed categories
- actions, decisions, and plans
- claims that must stay distinct from verified state

Avoid letting transport DTOs or provider payloads become the main business model by accident.

### Contracts And Proto

Proto may be used as a shared cross-language contract model when consistency between Go and Flutter is an explicit goal.

In this style, that is an intentional architectural decision.

Prefer:

- using proto objects as the shared contract when the same objects should remain stable across languages
- avoiding parallel internal models unless there is a clear reason for separation
- separating service-specific proto contracts from broader shared contracts when their concerns diverge

Proto is therefore not treated as "just transport" here.
It may also act as a stable shared object model across languages.

## Boundaries

Use boundaries where the backend communicates with the outside world or crosses a meaningful technical seam.

Typical examples:

- repositories
- provider clients
- audit sinks
- external service adapters

Interfaces are the default for these kinds of boundaries.

Concrete types are the default for:

- flow objects
- internal helpers
- domain services without an external boundary

The goal is not “everything behind an interface”.
The goal is “interfaces where replacement, testing, or separation actually matters”.

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

### Shared Helpers

Tests and scripts may share reusable support through `tooling/`.

Prefer:

- reusing existing helpers from `tooling/`
- extending those helpers when that reduces duplication
- keeping `tooling/` focused on shared support code

Avoid placing business logic in `tooling/`.

## Heuristics

When adding new backend code, ask:

- Is this service-local logic or a reusable backend workflow?
- Does this deserve a dedicated flow object?
- Is this a real boundary or just an internal detail?
- Would another developer immediately know where this code belongs?
- Does this structure make later growth easier without overengineering today?

If the answer is unclear, prefer the simpler structure first and split later once the boundary is real.

## Project-Specific Notes

In this repository, backend architecture also follows these additional rules:

- verified state and user claims must stay distinct
- trust-sensitive decisions should remain explicit
- policy, execution, state changes, and guarded data exposure should stay deterministic
- model providers may help with interpretation or phrasing, but should not silently become the authority

For repository-specific backend details, continue with the [code-near documentation](./project-navigation.md#backend).
