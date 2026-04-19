# Audit Module

This module contains runtime audit event types, sinks, and request-level analysis helpers.

Its job is to keep observability concerns explicit without moving system authority into logging or model output.

## What Lives Here

- event types and constructors for interaction and suspicious-input audit records
- sink interfaces and concrete sink implementations
- request-level analysis that turns a completed request trace into a compact classification
- repository boundaries for storing request analyses

## Request Analysis

`analysis.go` classifies one request as:

- `clean`
- `suspicious`
- `failed_model_step`

The analysis is derived from the emitted audit events and their signals.

## Repository Boundary

`repository.go` defines `RequestAnalysisRepository`.

The first implementation is `InMemoryRequestAnalysisRepository` in [`in_memory_repository.go`](./in_memory_repository.go).
This keeps the current phase lightweight while preserving a clean replacement point for later persistence.

## Analyzing Sink

[`sink_analyzing.go`](./sink_analyzing.go) provides `AnalyzingSink`.

It decorates another `Sink`, collects events per `RequestID`, and stores a `RequestAnalysis` once a request reaches a
logical end:

- `StepStateUpdated` for a completed successful interaction flow
- a failed planner or response-builder step for an early model-step failure

This keeps request-level analysis in the observability layer instead of mixing it into transport responses or core
interaction decisions.
