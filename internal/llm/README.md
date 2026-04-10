# LLM Module

This module contains the provider abstraction and concrete client implementations for model-backed generation.

Its job is intentionally small:

- define a provider-independent client interface
- model provider selection as an explicit type
- implement provider-specific API adapters behind the shared interface

It does not decide where in the interaction pipeline a model is used.
That wiring happens in the application composition root.

## What Lives Here

- [`client.go`](./client.go)
  defines the provider-independent `Client` interface plus request and response types

- [`provider.go`](./provider.go)
  defines the `Provider` type and parsing for configured provider values

- [`client_static.go`](./client_static.go)
  provides a simple static implementation for tests and deterministic flows

- [`client_groq.go`](./client_groq.go)
  contains the Groq-backed implementation of the shared client interface

## Runtime Provider Selection

Runtime provider selection currently happens in the main service composition root:

- [`main.go`](../../services/main-service/cmd/main.go)
- [`processor_factory.go`](../../services/main-service/cmd/processor_factory.go)

The current environment variable is:

- `LLM_PROVIDER`

Intended values right now:

- `static`
- `groq`
- `openai`

Unknown providers currently fall back to `static`.

## Provider-Specific Environment Variables

Provider-specific configuration is loaded only in the composition root, not inside the interaction module.

Current variables:

- `GROQ_API_KEY`
  required when `LLM_PROVIDER=groq`

- `GROQ_MODEL`
  optional when `LLM_PROVIDER=groq`

This keeps provider-specific runtime concerns at the application edge while the core interaction pipeline only depends
on the shared `llm.Client` abstraction.

