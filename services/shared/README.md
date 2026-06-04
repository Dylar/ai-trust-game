# Shared Service Code

This directory contains Go code that is shared between backend services.

It is split by ownership:

- [`project/`](./project/)
  project-specific shared contracts and vocabulary used by multiple services

- [`foundation/`](./foundation/)
  generic service foundation packages such as runtime bootstrap, logging, and HTTP transport helpers

- [`tooling/`](./tooling/)
  backend service test helpers, script support, mocks, and assertions

Service-owned behavior should stay under the owning service.
Move code here only when more than one service needs it or when it is intentionally generic foundation code.
