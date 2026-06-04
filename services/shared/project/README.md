# Shared Project Code

This directory is reserved for project-specific shared backend contracts and vocabulary.

Good candidates:

- event envelope types used by multiple services
- shared request or message contracts
- project vocabulary that intentionally crosses service boundaries

Current packages:

- [`audit/`](./audit/)
  audit event producer contracts shared by services that emit audit events

- [`domain/`](./domain/)
  game-domain vocabulary that intentionally crosses service boundaries

- [`llm/`](./llm/)
  project-specific LLM client contracts used by multiple services

Do not place service-private behavior here.
If one service owns the concept, keep it inside that service until another service truly needs the shared contract.
