# Frontend Architecture

## Purpose

This document describes how frontend code should be structured in projects of this style.

It is meant as a reusable frontend playbook:

- how frontend code should be organized
- how screens and view models should work together
- where logic should live
- how routing, logging, and testing should stay explicit and understandable

For general architecture rules, see [architecture-guidelines.md](./architecture-guidelines.md).

## Frontend Structure

Frontend code should be organized around screens and user-facing flows.

The preferred structure is:

- `core/`
- `screens/`
- `services/`
- `usecases/`
- `data/`
- shared testing helpers where useful

### `core/`

`core/` contains app-wide foundational code that helps hold the frontend together.

Good candidates for `core/` are:

- app bootstrap or shell concerns
- shared dependency setup
- logging
- error handling basics
- configuration
- other truly app-wide support code

`core/` is not a fallback folder for code without a home.

Avoid putting feature-specific UI, screen behavior, or business logic into `core/`.

Logging is reused across multiple screens or flows, keep it under `core/logging/`.

Routing is app-wide and shared across screens, keep it under `core/routing/`.

App-wide dependency access should live in `core/app/` through a small `InheritedWidget`-based facade.
That facade should expose the dependencies the UI needs while keeping concrete wiring details behind a stable access
point.

### `screens/`

Each screen should live in its own feature folder, for example:

- `screens/login/`
- `screens/session_start/`
- `screens/interaction/`

A screen folder should usually keep the main screen and its view model together, for example:

- `LoginScreen`
- `LoginViewModel`

This keeps user-facing UI composition and screen-specific behavior easy to find in one place.

Small private widgets that only belong to one screen may stay in the same file as that screen.

### `services/`, `usecases/`, and `data/`

`services/` and `usecases/` contain frontend-side application logic that should not live in widgets or view models.

`data/` contains communication with the outside world, such as:

- API clients
- persistence
- platform bridges
- adapters for external interfaces

Feature-facing repositories may also live under `data/` when they abstract local persistence or app-runtime state, for
example an in-memory repository used before a real backend or proto-backed implementation exists.

Shared frontend-facing contract or app model objects may live in a small common area such as `models/` when multiple
screens depend on the same business vocabulary.

## Screen Pattern

The frontend should prefer explicit and lightweight structure over heavy abstractions.

The default screen pattern is:

- a screen owns UI composition for one user-facing flow
- a screen may be a `StatefulWidget` when it needs lifecycle handling
- a screen creates its screen-local view model in `initState`
- dependencies are resolved from `InheritedWidget`
- the view model exposes one `ScreenState`
- screen state is held in `ValueNotifier<ScreenState>`
- the UI rebuilds with `ValueListenableBuilder`
- small `StatelessWidget`s render parts of the screen state

This keeps the UI tree understandable and keeps business behavior out of widgets.

### Small UI Parts

Prefer small `StatelessWidget`s for rendering.

These widgets should:

- receive the data they need
- receive callbacks they can trigger
- stay focused on presentation

If a widget is only used by one screen, it is fine to keep it private in the same screen file.

### ScreenState

Each screen view model should expose one `ScreenState` object that represents the current UI state for that screen.

That state should contain the information the screen needs to render, for example:

- loading state
- error state
- current data to display
- enabled or disabled actions

The screen and its child widgets should render from that `ScreenState`.

### Streams

Do not use `StreamBuilder` as the default for normal screen state.

If a feature depends on a real stream, keep the stream inside the view model and translate incoming events into updates
on the `ValueNotifier<ScreenState>`.

## Where Logic Lives

### Widgets

Widgets should focus on:

- layout
- rendering
- local ephemeral UI behavior

Examples of local widget behavior:

- animation toggles
- controller lifecycle
- focus handling
- local expansion or selection state that does not matter outside the widget

Widgets should not contain:

- business rules
- API calls
- orchestration logic
- trust-sensitive decisions

### Screens

Screens own UI composition and lifecycle for one user-facing flow.

They should:

- create screen-local view models when needed
- bind UI to screen state
- forward user actions to the view model

### View Models

View models should coordinate UI-facing behavior for one screen.

They should:

- expose one `ScreenState`
- react to user actions
- call use cases and services
- map results into screen state updates

They should not:

- render widgets
- depend on widget APIs
- contain low-level transport or persistence code

Dependencies should be resolved from the `InheritedWidget` boundary in the screen and then passed into the screen-local
view model.
This keeps the view model framework-light while avoiding direct transport access from widgets.

### Services, Use Cases, And Data

Services and use cases hold frontend-side application behavior that should not sit in widgets or view models.

The data layer communicates with external systems and platform integrations.

Prefer a small sequence like this:

- screen resolves dependencies from `InheritedWidget`
- view model calls a service or use case
- service delegates to repositories or `data/`
- repositories coordinate stored app state when needed
- `data/` performs transport or platform work

Avoid letting the screen or view model talk directly to API clients.

### Boundaries

Use explicit boundaries where the frontend communicates with the outside world.

Typical examples:

- API clients
- platform bridges
- persistence adapters
- shared contract models such as proto definitions

Frontend code should consume these boundaries through clear services, use cases, or adapters instead of letting widgets
talk to them directly.

## Routing, Logging, And Testing

### Routing

Keep routing simple and explicit by default.

Central routing setup should usually live under `core/routing/`.

Prefer:

- a small central routing setup
- screen-oriented routes
- route arguments only for navigation-relevant input
- the screen's own navigation entrypoint as a static function on the screen widget, that improves discoverability

Avoid:

- hiding business state inside routes
- spreading route definitions across unrelated files too early
- adopting complex router setups before there is a real need

Routing should help users move between screens.
It should not become a second state-management system.

When practical, keep the actual screen invocation close to the screen itself, for example as a static function on the
screen widget.

This makes it easy to see from the screen definition itself how that screen is intended to be opened.

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

### Testing

Frontend tests should follow the same behavior-first approach as the backend, but expressed through UI-facing flows.

Prefer:

- tests that describe user-visible behavior
- screen tests over tests for every small widget
- readable setup and interaction flow
- minimal boilerplate inside the test body

Screen tests should be as close to integration tests as practical.

Prefer:

- keeping the real screen, view model, and internal feature flow together
- mocking transport boundaries instead of whole services
- testing the behavior of the feature, not the implementation of one layer in isolation

Mock deeper layers only when a test would otherwise become unnecessarily hard to control or no longer useful for the
scenario being tested.

If a piece of logic is isolated, stable, and meaningful on its own, write a unit test for it.

Good candidates:

- view model helper logic
- state mapping
- small pure transformations
- validation rules

Keep frontend interaction tests readable by structuring them around clear scenario steps.

Prefer:

- `Given / When / Then` comments or an equivalent clear test-phase structure
- stable selectors such as `Key`s for interaction and structural assertions
- using visible text assertions only where the text itself is meaningful user-facing behavior

Avoid:

- relying on large numbers of fragile text finders for routine interaction
- hiding the scenario structure inside low-level test helpers
- mixing setup, actions, and assertions into one unstructured block

### Robot Pattern

Use the Robot Pattern as the preferred style for frontend interaction tests.

Robots should:

- perform user actions
- expose high-level assertions
- keep test code focused on behavior

Robots should not:

- hide architecture problems
- contain business logic
- become a second implementation of the screen

Shared robots and other frontend test helpers should live in one shared testing area when they are reused across
multiple screens or flows.

The preferred test structure in this repository is:

- `AppBot`
- `BaseScreenBot`
- feature-specific `ScreenBot`
- feature-specific `Process` when a flow needs orchestration across multiple actions
- feature-specific test `Context` as a small composition root

Responsibilities:

- `AppBot`
  starts the app and owns app-wide test setup concerns

- `BaseScreenBot`
  contains reusable low-level UI test mechanics such as finder resolution, taps, scrolling, and pumping

- `ScreenBot`
  exposes screen-specific actions and assertions
  it should stay focused on what the user can do and see on one screen

- `Process`
  combines multiple screen actions into a meaningful flow step
  it may wait for transient states to complete, but it should not become a second implementation of the feature

- `Context`
  wires together the bots and processes needed for one feature's tests
  it acts as a small test-side composition root and should not hide substantial logic

Prefer introducing a `Process` as soon as it helps keep the `ScreenBot` limited to "do" and "expect" behavior.
Do not wait until a flow spans many screens if a process already improves clarity.

## Project-Specific Notes

In this repository, frontend architecture currently also follows these additional defaults:

- Flutter is the chosen frontend stack
- `InheritedWidget` is the default dependency injection mechanism
- `AppDependencies` is the current app-wide dependency facade
- `ValueNotifier<ScreenState>` is the default screen-state mechanism
- screen-level tests with the Robot Pattern are preferred
- feature tests should prefer `AppBot` + `BaseScreenBot` + `ScreenBot` + optional `Process` + feature `Context`
- screen bots should stay on the level of screen actions and screen assertions
- processes should hold test-flow orchestration such as waiting through loading transitions
- `Key`-based selectors are the default for test interaction points
- shared frontend models may live under `models/` before later proto-based contracts exist
- the current frontend boundary style is `AppDependencies` -> `services/` -> `data/`
- backend state remains authoritative for trust-sensitive behavior
