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
* Do NOT guess architecture - refer to [architecture docs](./project-navigation.md#architecture) when in doubt
* You CAN make suggestions for improvements, but they must be justified and aligned with existing architecture.

---

## When Implementing Changes

* Identify the correct module before coding (see [code docs](./project-navigation.md#code-near-documentation))
* Respect layer boundaries (see [architecture docs](./project-navigation.md#architecture))
* Do not mix responsibilities across layers
* Keep functions small and focused

---

## When Refactoring

* Do NOT change behavior unless explicitly requested
* Ensure all existing tests still pass
* Improve structure without breaking contracts

---

## Documentation Rules (STRICT)

You MUST update documentation if ANY of the following changes:

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
You can always check [project-navigation.md](./project-navigation.md) for more details on where to find relevant documentation.