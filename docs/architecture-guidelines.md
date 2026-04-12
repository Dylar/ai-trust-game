# Architecture Guidelines

## Goal

Define the structural rules of the system.

This document is the source of truth for general architectural decisions.

Use the more specific playbooks when applying these rules in one part of the system:

- [Backend Architecture](./architecture-backend.md)
- [Frontend Architecture](./architecture-frontend.md)

## Core Ideas

- responsibilities should be explicit
- business rules should not leak into delivery code
- boundaries should stay visible
- infrastructure and external systems should stay replaceable
- behavior should stay testable
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

### Core Logic

Core logic contains the business meaning of the system.

Examples:

- rules
- state transitions
- domain concepts
- decisions
- validations that matter to the business

Core logic should stay independent from transport and UI details whenever practical.

### Boundaries

Boundaries isolate communication with the outside world or with meaningful technical seams.

Examples:

- repositories
- provider clients
- API clients
- persistence adapters
- platform bridges

Boundaries should keep external concerns from leaking into the rest of the system.

### Foundation

Foundation code holds shared technical support for the application.

Examples:

- app or service bootstrap
- shared configuration
- logging setup
- common test support
- operational helpers

Foundation should support the system without turning into a dumping ground for unrelated code.

## Dependency Rules

Prefer these dependency directions:

- entry points may call flows
- flows may use core logic and boundaries
- core logic should not depend on transport or UI details
- boundaries should isolate external systems instead of spreading those concerns everywhere
- foundation code should support the system, not own business behavior

## Patterns

Prefer:

- thin entry points
- focused flow objects
- explicit responsibilities
- intentional boundaries
- shared support code with clear ownership

## Anti-Patterns

Avoid:

- business logic inside entry points
- hidden boundary crossing
- duplicated logic across unrelated parts of the system
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

1. identify the core behavior
2. decide which flow should own it
3. introduce or reuse boundaries where needed
4. keep the entrypoint thin
5. update tests and documentation accordingly

## Notes

If this document conflicts with the code, either:

- the code is wrong and should be fixed
- or the document is outdated and should be updated

ask if uncertain.