# Frontend Architecture

## Purpose

This document describes the preferred frontend structure for projects of this style.

It is a frontend playbook for:

- organizing frontend code
- keeping screens and view models understandable
- deciding where UI-facing behavior belongs
- keeping routing, logging, and testing explicit

For general architecture rules, see [guidelines.md](./guidelines.md).

## Frontend Structure

Frontend code should be organized around screens and user-facing flows.

The preferred structure is:

- `core/`
- `screens/`
- `services/`
- `usecases/`
- `models/`
- `data/`

Always use package imports for app code.
Test-only helper files may use relative imports because Dart package imports only expose files under `lib/`.

### `core/`

`core/` is the frontend application core.
It contains app-wide building blocks and conventions that are not owned by one feature.

Good candidates:

- app bootstrap or shell concerns
- shared dependency setup
- routing
- logging abstractions
- error handling basics
- runtime configuration
- app-wide theme or design primitives

App bootstrap creates `AppDependencies` and passes them into `AppRouter`.
The router composes screens and view models explicitly.

`core/` is not a fallback folder for code without a home.
Avoid putting feature-specific UI, screen behavior, or business logic into `core/`.

### `screens/`

`screens/` contains user-facing flow modules.
Each screen should live in its own feature folder, for example:

- `screens/login/`
- `screens/session_start/`
- `screens/interaction/`

A screen folder may contain:

- the screen widget
- the screen view model
- the screen state
- screen-specific keys
- small screen-specific widgets
- screen-specific logging helpers

Keep small private widgets in the screen file when that is still readable.
Move them into nearby files when the main screen becomes hard to scan.

### `services/`

`services/` contains feature- or domain-specific application behavior that should not live in widgets.

Services group operations for one area and may use repositories, data clients, and reusable use cases.
Use a service when behavior is shared, meaningful on its own, or would make a view model too broad.

Small screen-specific behavior may stay in the view model when extracting it would only add ceremony.

### `usecases/`

`usecases/` contains more general reusable application behavior.

Use cases may be called by view models or services.
Domain-specific use cases should stay near the owning service or feature instead of being moved into global
`usecases/` by default.

### `models/`

`models/` contains shared data shapes and vocabulary.

Good candidates:

- app-facing domain models
- enums and value objects

Models should describe data and meaning.
They should not own loading, storing, caching, or updating behavior.

### `data/`

`data/` contains communication with external systems and platform integrations.
It is the concrete implementation side of frontend boundaries.

Examples:

- API clients
- repositories for stored app state
- persistence adapters
- platform bridges
- DTOs and transport mapping
- concrete logging adapters that send events outside the app

Repositories are concrete boundary implementations and should usually live under `data/`.

## Where Logic Lives

### Widgets And Screens

Widgets should focus on layout, rendering, and local ephemeral UI behavior.

Good widget-owned behavior:

- animation toggles
- controller lifecycle
- focus handling
- local expansion or selection state that does not matter outside the widget

Screen widgets are frontend entry points.
They own UI composition and lifecycle for one user-facing flow.
They bind UI to screen state, forward user actions to the view model, and dispose the screen-local view model when they
own it.

Widgets and screens should not contain:

- business rules
- API calls
- orchestration logic
- trust-sensitive decisions

### View Models

View models coordinate UI-facing behavior for one screen.

They should:

- expose one `ScreenState`
- react to user actions
- call services or use cases when needed
- map results into screen state updates
- stay free of widget APIs

A view model is the flow for one screen.
If behavior becomes reusable across screens, move it into a service or use case.
Do not turn one screen view model into a multi-screen object.

## Screen Pattern

The frontend should prefer explicit and lightweight structure over heavy abstractions.

The default screen pattern is:

- routing composes the screen and its screen-local view model
- dependencies come from the app-wide dependency boundary
- the screen receives its view model through the constructor
- the view model exposes one `ScreenState`
- screen state is held in `ValueNotifier<ScreenState>`
- the UI rebuilds with `ValueListenableBuilder`
- small widgets render parts of the screen state

This keeps UI composition understandable and keeps behavior out of widgets.

Do not use `StreamBuilder` as the default for normal screen state.
If a feature depends on a real stream, keep the stream inside the view model and translate incoming events into
`ScreenState` updates.

## Boundaries

Use explicit boundaries where the frontend communicates with the outside world.
In this playbook, `data/` usually contains the concrete boundary implementations.

Typical examples:

- API clients
- platform bridges
- persistence adapters

Widgets, screens, and view models should not call API clients directly.
Use services, use cases, or repositories between UI-facing code and `data/`.

API clients should receive transport dependencies explicitly, such as an `http.Client` and a base `Uri`.
Do not hardcode backend URLs inside individual API methods.

## State Ownership

Choose the smallest state owner that matches the lifetime of the state:

- screen-local state belongs in a screen view model and `ScreenState`
- temporary multi-screen flow state belongs in a flow-local `FlowController` and `FlowState`
- app-wide long-lived state belongs in an app dependency, service, or repository

For real multi-screen flows, create one flow-local `FlowController` per flow instance.
It owns the immutable `FlowState`, exposes flow-specific mutation methods, and may extend or wrap
`ValueNotifier<FlowState>`.
Pass it through the involved routes or screen constructors.
The creator owns disposal when the flow ends.

## Dependency Direction

Prefer this direction for feature behavior:

```text
screen -> view model -> service/usecase -> repository -> data -> external system
```

For multi-screen flows, screen view models may also use the flow-local controller:

```text
screen -> view model -> FlowController
```

## Routing And Logging

### Routing

Keep routing simple and explicit by default.

Prefer:

- central routing under `core/routing/`
- screen-oriented routes
- route arguments only for navigation-relevant input
- static screen entrypoints to improve discoverability

Avoid:

- hiding business state inside routes
- spreading route definitions across unrelated files too early
- adopting complex router setups before there is a real need

### Logging

Frontend logging should stay lightweight and intentional.

Prefer logging for:

- screen-level lifecycle events when useful for debugging
- failed loads or failed user actions
- unexpected state transitions
- integration errors that affect the user experience

Avoid:

- noisy logs for normal rendering
- logging every widget interaction by default
- duplicating backend logs in the UI without adding useful context
- logging sensitive user or session data carelessly

## Testing

Frontend tests should describe user-visible behavior and business-relevant user journeys.

Prefer screen tests for user-facing flows.
Keep the real screen, view model, and internal feature flow together when practical, and mock the transport boundary or
test dependency instead of mocking the whole screen flow.

Use smaller unit tests for isolated logic when it is stable and meaningful on its own, such as:

- pure state mapping
- validation rules
- reusable service behavior
- API client request and error handling

### Interaction Test Architecture

Interaction tests should be separated into four test-side layers:

1. `ScreenBot`s for UI interaction and screen assertions
2. `Process` objects for business flows and user journeys
3. test cases for short, readable scenarios
4. `TestContext` objects for test dependency setup and composition

### Screen Bots

Screen bots encapsulate UI interactions for one screen or a closely related set of screens.

They may:

- locate UI elements
- perform screen actions
- expose screen-state assertions
- use stable `Key` selectors for routine interaction and structural assertions
- use visible text assertions when the text itself is meaningful behavior

Each screen bot should build on shared bot mechanics such as tapping, entering text, scrolling, pumping, and finder
resolution.

Screen bots should not contain business flow decisions.
They should stay focused on what the user can do and see on a screen.

### Processes

Processes represent business flows or user journeys.

They are reusable across test cases and should use screen bots, base bots, app bots, and other processes to perform the
steps needed by a scenario.

Processes should contain:

- macro steps for significant user journey actions
- micro steps for smaller reusable actions that support macro steps
- waiting or pumping needed to move through loading or transition states

Process names and method names should describe the business intent of the action, not low-level UI mechanics.

### Test Cases

Test cases are the scenario entrypoint.

They should:

- stay short and readable
- use a `Given / When / Then` mindset or an equivalent clear phase structure
- call the process layer for scenario actions and verification steps
- avoid direct UI interaction through bots unless commenting a deliberate trade-off

Tests should mostly use macro steps from processes.
They may use micro steps when a scenario needs specific setup or verification.

### Test Context

A `TestContext` is the test-side composition root for one feature's tests.

It should:

- create and expose the needed bots
- create and expose the needed processes
- hold test dependency setup for the scenario
- keep setup details out of test cases

It should not hide substantial scenario logic.

The normal interaction test call direction is:

```text
test case -> process -> screen bot -> base bot / Flutter tester
```

## Project-Specific Notes

For repository-specific frontend details, continue with the [project navigation](../project/navigation.md#apps).
