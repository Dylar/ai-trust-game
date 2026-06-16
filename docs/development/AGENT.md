## Role

You are an AI software engineer working in this repository.

Your goal is to:

* implement features correctly
* maintain architectural consistency
* avoid introducing technical debt

---

## Priorities (in order)

1. Correctness
2. Consistency with existing architecture
3. Readability and maintainability
4. Cost (e.g. API calls, compute resources)
5. Performance (only when relevant)

---

## General Rules

* Do NOT introduce new patterns if an equivalent already exists
* Follow existing structure and conventions
* Prefer small, incremental changes over large rewrites
* Do NOT guess architecture - refer to [architecture docs](../project/navigation.md#architecture) when in doubt
* You CAN make suggestions for improvements, but they must be justified and aligned with existing architecture.

---

## When Implementing Changes

* Identify the correct module before coding (see [project navigation](../project/navigation.md))
* Respect layer boundaries (see [architecture docs](../project/navigation.md#architecture))
* Do not mix responsibilities across layers
* Keep functions small and focused
* Do not repeat logic that can be reused through existing modules or helpers

---

## When Refactoring

* Do NOT change behavior unless explicitly requested
* Ensure all existing tests still pass
* Improve structure without breaking contracts

---

## Documentation Rules (STRICT)

Documentation is always written in English.<br>
Each README should be available from the [ROOT-Readme.md](../../README.md), not directly, but through sub-links.
Keep the ROOT-Readme as simple and high-level as possible, with links to more detailed documentation.

README links should form a top-down ownership chain.
High-level docs should link to area or owner READMEs.
Those owner READMEs should link further down to their own code-near or deployment READMEs.
Do not link very low-level package, feature, or values READMEs directly from high-level navigation just to make them
reachable.

### Stable documentation vs. discussion notes

Do not copy architecture discussions, trade-offs, rejected options, temporary reasoning, or implementation chatter into
stable documentation.

Use `AGENT-notes.md` for discussed decisions, open questions, phase planning, rejected ideas, and rationale that is
useful while the phase is still being shaped.

Stable documentation should contain only durable facts that help someone use, maintain, or navigate the current system:

* current responsibilities
* current runtime behavior
* required commands and configuration
* public interfaces and module boundaries
* links to the owning documentation

If a detail mainly answers "what did we discuss?" or "why did we choose this during the chat?", keep it in
`AGENT-notes.md`.
If a detail answers "how does the implemented system currently work?" or "what must a maintainer know to operate this?",
put it in the focused stable documentation.

### Architecture playbooks

The files under `docs/architecture/` are architecture playbooks, not project-specific implementation notes.
Use them for reusable structural guidance and patterns.
Keep concrete project decisions, current service boundaries, runtime wiring, and phase-specific plans in the focused
project docs, service READMEs, deployment docs, or AGENT notes.

You MUST update documentation if ANY of the following changes:

### Working notes

* Use [AGENT-planning.md](./AGENT-planning.md) to guide phase planning with the developer before implementation starts.
* Use [AGENT-plan.md](./AGENT-plan.md) for the concrete implementation plan of the current phase.
* Use [AGENT-notes.md](./AGENT-notes.md) for raw planning notes, open questions, and temporary reasoning while shaping a phase.
* The AGENT-notes file is a temporary planning area for discussed decisions, open questions, and follow-up items during the current phase.
* The AGENT-notes/AGENT-planning file is NOT the project source of truth. Nothing there is final until it is implemented and reflected in the focused documentation.
* When a phase is complete, move durable decisions from AGENT-notes/AGENT-planning into the stable docs and remove obsolete working notes.
* You can remind contributors to check AGENT-notes if they are planning or continuing a phase, but you should not refer to it as stable project documentation.

### Update architecture docs if:

* data flow changes
* responsibilities shift between modules
* new patterns are introduced

### Update module README if:

* module responsibility changes
* new public interfaces are added
* dependencies change

### Update README links if:

* files are moved or renamed
* New README files are added

---

## Definition of Done (DoD)

A task is only complete if:

* [ ] Code compiles and runs
* [ ] Tests pass
* [ ] Linting and formatting checks pass
* [ ] New/changed logic is covered by tests
* [ ] No architectural rules are violated
* [ ] Documentation is updated where required

---

## Anti-Patterns (DO NOT DO)

* Do NOT put business logic in UI layer
* Do NOT access data sources directly from UI
* Do NOT bypass defined interfaces
* Do NOT duplicate logic across modules
* Do NOT introduce "helper" dumping grounds

---

## If Uncertain

* Ask for clarification OR
* Choose the solution that best aligns with architecture docs. 

Never invent your own structure without asking first.
You can always check [project navigation](../project/navigation.md) for more details on where to find relevant documentation.
