# Architecture Guidelines

## Goal

Define the structural rules of the system.<br>
This document is the source of truth for general architectural decisions.<br>
Use the more specific playbooks when applying these rules in one part of the system:

- [Backend Architecture](./architecture-backend.md)
- [Frontend Architecture](./architecture-frontend.md)

## Core Ideas

- responsibilities should be explicit
- business rules should not leak into delivery code
- boundaries should stay visible
- infrastructure and external systems should stay replaceable
- behavior should stay testable
- reusable application building blocks should stay separate from feature behavior
- shared contracts should be intentional

## Architectural Roles

Different parts of the system may use different names, but the same architectural roles usually appear again and again.

### Entry Points

Entry points receive input and return output.

Examples:

- HTTP handlers
- screens
- CLI commands
- queue consumers

Entry points should stay thin and focused on transport or UI concerns.

### Flows

Flows coordinate meaningful behavior.

Examples:

- use cases
- processors
- view models
- application services
- orchestrators

Flows should own the steps of one coherent workflow without becoming unbounded god objects.

### Application Core

Application core defines reusable building blocks and conventions for an app or service.

Examples:

- app or service bootstrap
- shared configuration
- logging abstractions
- base error or result types
- lifecycle setup
- routing or navigation primitives

Application core should not depend on one feature, one transport, one UI, or one product-specific workflow.
It should make apps and services easier to assemble without becoming a place for business behavior.

### Boundaries

Boundaries isolate replaceable technologies, external systems, and communication with the outside world.

Examples:

- repositories
- provider clients
- API clients
- persistence adapters
- platform bridges

Boundaries should keep external concerns and technical choices from leaking into the rest of the system.
Changing a database, transport, provider, or platform should usually require changes at the boundary, not everywhere.

### Infrastructure

Infrastructure contains concrete technical implementations and operational support.

Examples:

- database implementations
- HTTP client implementations
- provider implementations
- logging sinks
- Docker, Compose, Kubernetes, and deployment support
- operational helpers

Infrastructure should stay behind boundaries where application code depends on replaceable behavior.
Operational support should be clearly owned and should not become a dumping ground for unrelated code.

## Dependency Rules

Prefer these dependency directions:

- entry points may call flows
- flows may use application core and boundaries
- application core should not depend on feature behavior, transport, or UI details
- boundaries should isolate external systems instead of spreading those concerns everywhere
- infrastructure should implement technical choices without owning business behavior

## Patterns

Prefer:

- thin entry points
- focused flow objects
- reusable application core with clear ownership
- explicit responsibilities
- intentional boundaries
- replaceable infrastructure behind boundaries

## Anti-Patterns

Avoid:

- business logic inside entry points
- hidden boundary crossing
- duplicated logic across unrelated parts of the system
- product-specific behavior inside application core
- dumping code into generic helper folders without ownership
- large components with mixed responsibilities

## Testing And Logging

Testing and logging should follow the architecture instead of cutting across it.

Prefer:

- tests that describe behavior, not implementation trivia
- logs at meaningful boundaries and decision points
- structured context over noisy free-form messages

The backend and frontend playbooks define the concrete testing and logging style for each side of the system.

## Extending The System

When adding a new feature:

1. identify the meaningful behavior
2. decide which flow should own it
3. introduce or reuse boundaries where needed
4. keep the entrypoint thin
5. update tests and documentation accordingly

## Notes

If this document conflicts with the code, either:

- the code is wrong and should be fixed
- or the document is outdated

If uncertain ask before changing the document.
