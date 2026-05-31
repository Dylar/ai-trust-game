# Domain Model

This package contains the core business types that the rest of the backend should speak in.

These types keep trust boundaries and business meaning explicit.

## Why These Types Matter

The main architectural theme of the project is:

> user claims are not the same as trusted system state

The domain package gives that split names so it does not stay implicit in handler code, prompts, or provider payloads.

## Key Concepts

### Session

[`session.go`](./session.go) defines the authoritative server-side session object.

It splits into:

- `Settings`
  the selected game configuration

- `State`
  the mutable authoritative state the system carries forward across requests

This is intentionally not the same as raw user input.

### Claims

[`claims.go`](./claims.go) defines user- or planner-derived claims.

Claims may describe what the user says about themselves, for example a claimed role.
They are useful input for planning and policy, but they are not automatically trusted state.

### Plan

[`plan.go`](./plan.go) defines the structured output expected from the planning step.

It contains:

- the requested `Action`
- extracted `Claims`
- an optional submitted password
- the preferred response language

The plan is important, but it is still only an input into later policy and execution steps.
It does not bypass deterministic checks.

## Trust-Sensitive Distinctions

Several fields may look similar at first glance, but they mean different things:

- `Session.Settings.Role`
  the role chosen when the session starts

- `Session.State.TrustedRole`
  the role state the server currently trusts during later decisions

- `Plan.Claims.Role`
  a claim extracted from the current message or planner output

These values are intentionally kept separate so the system can demonstrate different trust models:

- easy mode may tolerate unsafe behavior
- medium mode may partially trust claims
- hard mode should rely on authoritative session state

## Fixed Categories

The package also defines the stable enums used across the interaction flow:

- [`role.go`](./role.go)
  `guest`, `employee`, `admin`

- [`mode.go`](./mode.go)
  `easy`, `medium`, `hard`

- [`action.go`](./action.go)
  the supported interaction actions such as reading the secret or listing available actions

These fixed categories help keep prompt outputs, policy decisions, and deterministic execution aligned around one
shared vocabulary.
