# Audit Module

This module contains runtime audit event types, sinks, request analysis, and session-level aggregation helpers.

Its job is to keep observability concerns explicit without moving system authority into logging or model output.

## What Lives Here

- event types and constructors for interaction and suspicious-input audit records
- sink interfaces and concrete sink implementations
- request-level analysis that turns a completed request trace into a compact classification
- session-level aggregation over stored request analyses
- repository boundaries for storing request analyses
- optional AI-written intent summaries that sit next to the structured analysis

## Structured Analysis

[`analysis.go`](./analysis.go) derives stable, machine-readable fields from emitted audit events.

At request level this includes:

- `classification`
  One of `clean`, `suspicious`, or `failed_model_step`
- `signals`
  Concrete observed markers such as suspicious planner output or claimed role mismatches
- `attack_patterns`
  Small, structured intent-like patterns derived from authoritative audit data such as `Action` and `Suspicion`

At session level this includes:

- overall session `classification`
- deduplicated session `signals`
- deduplicated session `attack_patterns`
- the chronologically ordered request analyses that belong to the session

Important:

- `signals` and `attack_patterns` are the stable, testable system view
- they intentionally stay small and structured
- they are not replaced by free-form AI text

## Intent Summaries

[`intent_summarizer.go`](./intent_summarizer.go) adds an optional second layer: free-form intent summaries.

These summaries are helpful for human inspection, but they are not authoritative and they are not the source of truth
for detection.

There are two levels:

- request `intent_summary`
  a short sentence for one completed request
- session `intent_summary`
  a short summary of what the user appeared to do across multiple requests

The current design keeps these summaries separate from the structured analysis:

- request summaries are generated only for `suspicious` or `failed_model_step` requests
- session summaries are generated on read in the session analysis handler
- neither summary type changes the stored structured signals or classifications

## Repository Boundary

[`repository.go`](./repository.go) defines `RequestAnalysisRepository`.

The first implementation is [`in_memory_repository.go`](./in_memory_repository.go).
This keeps the current phase lightweight while preserving a clean replacement point for later persistence.

The repository stores completed request analyses.
Session analysis is currently computed by reading those stored request analyses back out and aggregating them.

## Analyzing Sink

[`sink_analyzing.go`](./sink_analyzing.go) provides `AnalyzingSink`.

It decorates another `Sink`, collects events per `RequestID`, and stores a `RequestAnalysis` once a request reaches a
logical end:

- `StepStateUpdated` for a completed successful interaction flow
- `StepDecided` with `OutcomeDenied` for requests that stop at policy denial
- a failed planner or response-builder step for an early model-step failure

This keeps request-level analysis in the observability layer instead of mixing it into transport responses or core
interaction decisions.

## API Read Model

The main service exposes the stored analyses through:

- `GET /analysis/request/{requestId}`
- `GET /analysis/session/{sessionId}`

The request endpoint returns one stored request analysis.

The session endpoint returns:

- the aggregated structured session view
- the ordered request analyses for that session
- an optional session-level `intent_summary`

That means request analysis is write-time, while session summarization is currently read-time.
