# ai-trust-game

## TL;DR

A small project to explore how AI-based systems behave under different levels of trust, and what happens when the
surrounding system relies too much on model behavior instead of explicit rules and verified state.

## What is this?

This project simulates a small game-like interaction where a user tries to gain access to restricted capabilities or
information.

The goal is not to build a chatbot for its own sake, but to show how system behavior changes depending on where trust
and authority live.

In one mode, the system is intentionally too permissive.  
In another, it becomes stricter and keeps control in server-side logic.

## Why this project?

This project is interested in what goes wrong when the system around the model is designed poorly:

- user claims are treated as truth
- model output is treated as authority
- decisions are implicit instead of explicit
- security is added too late

The idea is to make those differences visible in a small and understandable setup.

For more details on the project design and architecture, see the documentation:<br>
[Project description](./docs/project/description.md).

## Quick Start

Run the local container stack:

```bash
make compose-up
```

Use localhost:3000 in your browser to access the frontend.<br>
The backend is available at localhost:8080.

For more commands and development scripts, see the documentation:<br>

- [Development commands and example scripts](./docs/development/commands.md)

## Project Navigation

Look into this table of contents for more details.<br>
There is everything from architecture to development roadmap.

- [Navigation links](./docs/project-navigation.md)
