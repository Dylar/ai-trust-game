# Interaction Module

This module orchestrates the core interaction pipeline of the game.

It is responsible for taking a user message plus authoritative session state and turning that into:

- an explicit system decision
- deterministic execution output
- a guarded response payload
- a final user-visible response
- optional session state updates

The important point is:

> the `Processor` orchestrates the flow, but it is not the place where all logic should live

If you want to understand the module quickly, [start here](./processor_factory.go) to see how the pieces
are wired together, then dive into the individual components from there.

## Why It Is Built This Way

The module is intentionally split into small parts so that trust and authority stay explicit.

- `planning`
  Builds the planning prompt, asks the configured client for structured output, and turns that output into a validated
  `domain.Plan`.

- `policy`
  Decides whether a planned action is allowed.

- `capability`
  Computes what the current session plus claims are allowed to do, so policy checks and visible action lists do not
  drift apart.

- `execution`
  Produces deterministic outputs for allowed actions.

- `state`
  Updates authoritative session state after execution.

- `response`
  Shapes what response data may flow forward, builds the final user-visible message, and validates the final output.
  The builder can use either a static client or a provider-backed client, but the guard stays authoritative.

This separation exists so that later model-based components can be swapped in without turning the whole interaction flow
into one opaque AI step.

Two variation points are especially important right now:

- `policy.Policy`
  because the different game modes intentionally express different trust and decision rules

- `llm.Client`
  because provider access is an infrastructure boundary and should stay replaceable

The rest of the interaction flow is currently kept concrete on purpose.
That keeps the code easier to follow while preserving the important control points.

## Pipeline

The current pipeline in [`processor.go`](./processor.go) is:

1. validate incoming interaction
2. plan the interaction
3. write a planning audit event
4. resolve the policy for the current mode
5. make an explicit allow / deny decision
6. execute the allowed action deterministically
7. build structured response input
8. guard the response payload
9. build the final response message
10. validate the final response
11. update authoritative session state

If planning or response generation fails, the processor also writes a failure audit event for that step before
returning the error. This keeps model-step failures observable without moving authority out of the deterministic flow.
The planning audit step also emits early detection signals such as a claimed role exceeding the currently trusted role
or invalid planner output.

For analysis work, `pkg/audit` also provides:

- request-level aggregation that classifies completed requests as `clean`, `suspicious`, or `failed_model_step`
- session-level aggregation over stored request analyses
- optional AI-written intent summaries for suspicious or failed requests and for whole sessions

The important split is:

- structured signals and attack patterns stay authoritative for analysis
- AI-written summaries stay descriptive and supportive

## Why The Guard Comes Before The Builder

The `response` package is intentionally split into:

- `DataGuard`
- `Builder`
- `Validator`

The guard happens before the builder so that later response generation, including LLM-based generation, only sees the
data that is explicitly allowed to be turned into user-visible text.

That means the system first limits the payload and only then allows free-text generation.

## Why There Is A `NewStaticProcessor`

[`processor_factory.go`](./processor_factory.go) provides `NewStaticProcessor()`.

This is the current deterministic wiring of the whole interaction flow:

- static planner
- default policy resolver
- shared capability calculation used by policy and execution
- static executor
- static state updater
- static response guard
- static response builder
- static response validator

The goal is not to keep everything static forever.

The goal is to establish the control flow and boundaries first, so that later LLM integration can replace selected parts
without making the model the authority.

Today that replacement already exists for selected steps:

- the planner speaks to `llm.Client` and expects structured JSON output
- the response builder speaks to `llm.Client` and expects user-visible free text

The authoritative parts still remain deterministic:

- policy
- capability calculation
- execution
- state updates
- response guarding
