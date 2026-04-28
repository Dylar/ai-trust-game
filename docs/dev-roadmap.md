# Development Roadmap

## Tech Stack

The project starts small, but is planned with a broader service-oriented setup in mind.

- `Go`  
  Main backend language for the service layer. Familiar from work and a good fit for explicit backend services.

- `HTTP`  
  Used first to keep the interaction loop simple while shaping the system behavior.

- `gRPC / Protobuf`  
  Planned for later service boundaries and possibly for the client-server contract once the client is introduced.

- `Groq`  
  Planned as the first LLM provider because it is easy to start with and relatively inexpensive for experimentation.

- `Flutter`  
  Planned for the client, mainly as a web/mobile UI to make the system behavior easier to explore interactively.

- `PostgreSQL`  
  Planned for persistent session and audit storage. A practical choice for structured backend state and easy
  self-hosting later.

- `RabbitMQ`  
  Optional later step for async communication between components if the architecture grows in that direction.

- `Docker`  
  Planned for packaging and reproducible runtime setup.

- `Kubernetes`  
  Planned as the deployment environment once the project moves beyond a single local service.

## Development Phases

### Phase 1 - Service Foundation (Done)

- basic HTTP service
- routing and request handling
- project structure
- formatting and linting baseline
- initial tests
- basic developer workflow

Goal: establish a clean and maintainable baseline

### Phase 2 - Observability & Runtime (Done)

- structured logging
- request lifecycle tracking
- request metadata
- error classification
- basic audit events
- simple `/chat` endpoint as baseline playground

Goal: make runtime behavior visible and understandable

### Phase 3 - Session & State (Done)

- session model (`Session`, `Role`, `Mode`)
- session start flow
- in-memory repository
- first stateful interaction using session state

Goal: introduce authoritative server-side state and make interaction stateful

### Phase 4 - Interaction Flow (Done)

- refine interaction request / response model
- strengthen validation and error handling
- separate transport, interaction logic, and later decision logic
- prepare interaction flow for LLM and policy integration

Goal: define a clean and extensible interaction flow before adding AI

### Phase 5 - Policy & Decision Layer (Done)

- separate claims from verified state
- introduce policy checks
- model restricted actions and protected information
- make decisions explicit and testable

Goal: move control into deterministic system logic

### Phase 6 - Security Modes (Done)

- introduce easy / medium / hard modes
- vary validation and enforcement by mode
- compare permissive vs. strict system behavior
- prepare guard and validation points for later model output

Goal: demonstrate how architecture changes system security

### Phase 7 - Execution & Response Flow (Done)

- separate planning, policy, execution, and response building
- model deterministic execution for allowed actions
- define structured outputs between execution steps
- prepare guard and validation points for later model-generated responses

Goal: complete the controlled interaction pipeline before integrating a real model

### Phase 8 - LLM Integration & Traceability (Done)

- introduce provider abstraction and model client boundaries
- define prompt construction for the existing pipeline stages
- integrate the first provider into the intended flow points
- move planning to structured model output with schema-guided JSON
- move response building to model-backed free-text generation
- improve model-output error handling and logging context
- keep policy, capability checks, state updates, and response data guarding authoritative

Goal: introduce model-backed planning and response generation without giving the model system authority

### Phase 9 - Audit Analysis & Detection (Done)

- enrich audit and model-step observability
- make planning / response generation failures easier to detect and inspect
- prepare detection signals for suspicious interaction patterns and prompt-injection-like behavior
- analyze how mode, policy, and prompt quality change observable outcomes

Goal: turn runtime traces into useful detection and analysis signals

### Phase 10 - Client / UI

- build Flutter client (web first)
- session start and interaction flow
- client-side session handling
- analysis detail views for sessions and requests
- app logging interface and client-side log shipping to the backend
- error and loading handling across the main user-facing flows

Goal: validate system behavior through real user interaction

### Phase 11 - Integration, Delivery & Operations

- CI/CD pipelines
- container builds
- deployment automation
- Docker and Kubernetes setup
- production-like local and remote runtime setup

Goal: run the system in a production-like environment

### Phase 12 - Service Decomposition

- split into services where useful
- introduce gRPC / Proto contracts
- define clear service boundaries
- separate responsibilities so later persistence, telemetry, and model routing can evolve independently

Goal: move towards scalable architecture

### Phase 13 - Persistence

- Backend: PostgreSQL integration
- Frontend: drift integration
- persistent backend sessions and interactions
- local app persistence and restore flows
- audit/event storage
- define how app-side persisted state and backend authoritative state stay aligned
- define migration strategy for persisted frontend and backend schemas

Goal: move beyond in-memory runtime state

### Phase 14 - Monitoring, Dashboards & Analysis

- mode comparison views and security posture comparisons
- ingest and correlate backend audit events, backend logs, and client-side logs
- audit and log dashboards
- monitoring-oriented analysis over runtime traces and stored events
- prepare operator-facing observability views beyond the gameplay UI

Goal: turn observability data into explorable operator and evaluation views

### Phase 15 - Testing

- integration tests across service and persistence boundaries
- end-to-end and system tests across backend, frontend, and deployed runtime
- regression suites for security modes, analysis flows, and observability behavior
- define the final validation baseline for release-like environments

Goal: verify the system holistically once architecture, persistence, delivery, and observability are in place

### Phase 16 - Multi-Model / Agent Setup

- multiple providers
- role-specific models
- different models per pipeline step such as planning vs. response generation
- model comparison and routing

Goal: decouple responsibilities from a single model and support step-specific model choice
