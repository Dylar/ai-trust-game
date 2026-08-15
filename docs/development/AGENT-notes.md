# AGENT Notes

This file holds temporary phase planning notes, discussed decisions, open questions, and follow-up items from repository
work.

Use this file as a raw working area while shaping a phase with the developer.
Once a decision becomes part of the implementation plan, move it into [AGENT-plan.md](./AGENT-plan.md).
Once a durable behavior is implemented, move it into the focused stable documentation and remove the obsolete note.

The notes are not the project source of truth.
Nothing here is final until it is implemented and reflected in the focused documentation.

## Open Task/Questions

#### 1. Test architecture follow-up

Review whether screen `Process` objects still do too much dependency wiring.
The direction is `TestContext` as the feature composition root and `Process` as flow orchestration.
Do not change this immediately; revisit after the current service/API/repository cleanup settles.

#### 2. App README follow-up

Update the Trust Game App README with the current boundary decision:
Services are concrete orchestrators; API clients and repositories own the mockable interfaces.
Do not change this immediately.

#### 3. Frontend UML follow-up

Update frontend UML diagrams so they match the current app flow:
`ViewModel -> Service -> API client + Repository`, with repositories as local persistence/state boundaries.
Do not change this immediately.
