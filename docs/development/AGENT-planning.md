# Agent Planning Playbook

This playbook tells an agent how to guide a developer from a broad project phase to a concrete phase plan.

The agent does not write the plan alone.
The agent leads the planning conversation, asks questions, records open points, and turns agreed decisions into an
incremental plan.

## Planning Files

- `docs/development/AGENT.md`
  General development instructions.
- `docs/development/AGENT-planning.md`
  General planning instructions for agents.
- `docs/development/AGENT-plan.md`
  Concrete implementation plan for the current phase.
- `docs/development/AGENT-notes.md`
  Working notes for open questions, temporary reasoning, rejected ideas, and things that still need clarification.
- `docs/project/plan.md`
  Broad project roadmap.

`AGENT-notes.md` is raw and movable.
`AGENT-plan.md` is sorted and actionable.
`docs/project/plan.md` stays broad and project-facing.

## Core Rule

Ask before assuming.

If a decision changes data flow, ownership, user experience, persistence behavior, runtime wiring, or test strategy,
the agent must make the question visible before writing the decision into `AGENT-plan.md`.

Good planning question:

- What does "loaded user" mean?
- Do we load only the user list, or also sessions and interactions?
- What works offline?
- Which screen owns the transition?
- Which service owns the data?

Bad planning move:

- Guess the behavior.
- Hide the guess in a task.
- Build around the guess before the developer agrees.

## Planning Flow

### 1. Read First

The agent reads:

- `docs/development/AGENT.md`
- `docs/project/plan.md`
- `docs/project/navigation.md`
- relevant `docs/architecture/` playbooks
- owning README files for affected apps, services, shared packages, and infrastructure

The agent then summarizes the phase in simple language.

### 2. Create Rough Areas

The agent proposes rough work areas first.

Use short names:

- backend service
- shared package
- app screen
- app data layer
- persistence
- messaging
- runtime
- tests
- docs

At this step, do not write detailed tasks yet.
The goal is only to find the logical pieces of the phase.

### 3. Sort The Areas

The agent and developer sort the areas by development order.

Prefer an order where each step creates useful structure for the next step.
It is okay if the app is temporarily incomplete between steps.
It is not okay to introduce a wrong boundary just to make an intermediate step look finished.

Temporary incomplete state is allowed.
Technical debt is not.

Example:

- Good:
  Backend endpoint exists before UI uses it.
- Bad:
  UI reads a database directly because it is faster for now.

### 4. Discuss One Area At A Time

For each area, the agent asks what must happen there.

Write the area in `AGENT-plan.md` with:

- heading
- goal
- concrete bullet points
- what this area does not do
- tests or checks for this area
- architecture references when useful

Use simple language.
Prefer several small bullets over one long sentence.
Make these bullets in logical groups so they are easy to read and check off while coding.

Example:

```markdown
#### Auth service

Goal:

- Create simple user identity.
- Not real auth.

Do:

- Add user repository interface.
- Add Postgres implementation.
- Add `GET /users`.
- Add `POST /users`.

Do not:

- No passwords.
- No tokens.
- No permissions.

Checks:

- Handler tests.
- Repository tests.
- Migration test.
```

### 5. Record Unclear Things In Notes

If something is unclear, put it in `AGENT-notes.md`.

Use notes for:

- open questions
- options
- trade-offs
- things to ask the developer
- rejected ideas
- reminders that block `AGENT-plan.md`

Do not silently resolve unclear things.
Do not put unresolved questions into `AGENT-plan.md` as if they were decisions.

### 6. Move Decisions Into The Plan

After the developer answers, move the agreed decision from `AGENT-notes.md` into `AGENT-plan.md`.

The plan should describe what will be built.
The notes may keep why it was discussed while the phase is still being shaped.

### 7. Keep Cross-References Clear

When a task belongs to a later area, say so.

Example:

- "This area creates the sync service."
- "This area does not build the login screen."
- "The login screen uses this in the next area."

This prevents one area from silently growing into the whole phase.

### 8. Attach Tests Near The Work

Do not create one giant late "test everything" section.

Put tests near the thing they verify:

- repository tests near repository work
- handler tests near endpoint work
- widget tests near screen work
- sync tests near sync work
- compose smoke checks near runtime work

End the full phase plan with final verification.

### 9. Check Architecture Rules

For every area, check the relevant architecture playbook.

The agent should explicitly watch for:

- UI must not own business logic.
- UI must not access data sources directly.
- services must keep their ownership boundaries.
- shared packages must stay generic.
- persistence adapters belong behind repository boundaries.
- runtime wiring belongs in composition roots or infrastructure files.

If an implementation shortcut would violate a boundary, record it as a problem and ask for a different plan.
In app use other areas as templates, if a screen or data layer is special discuss how to implement it.
You can make suggestions, but do this in AGENT-notes.md and ask the developer before writing it into the plan.

### 10. Mark Status

Use status markers in `AGENT-plan.md`:

- `(IN PROGRESS)`
- `(DONE)`

Only mark `(DONE)` after code, tests, verification, and required documentation are complete for that area.

If a task changes during implementation, update the plan to match reality.

## Writing Style

Use simple language.

Prefer:

- "Build auth-service."
- "No real login yet."
- "User can be selected."
- "Loaded means local sessions or interactions exist."

Avoid:

- vague architecture slogans
- long paragraphs
- hidden assumptions
- tasks that sound complete but do not say what to edit

The plan should be easy to follow while coding.

## Completion

Before implementation starts, `AGENT-plan.md` should have:

- phase goal
- ordered areas
- concrete tasks per area
- clear non-goals per area (if possible revere to the area that owns the non-goal)
- tests near the work
- final verification
- unresolved questions either answered or still visible in `AGENT-notes.md`

When the phase ends:

- move durable facts into stable documentation
- remove obsolete planning chatter
- keep `docs/project/plan.md` broad
- keep `AGENT-plan.md` as the record of what was actually implemented until cleanup removes or archives it
