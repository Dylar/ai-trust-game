# Capability Module

This module computes what the current interaction is allowed to do from the perspective of one mode.

It is a small but important piece of the trust model because it turns:

- authoritative session state
- current claims
- current mode

into one explicit capability set.

## Responsibility

[`capability.go`](./capability.go) answers questions such as:

- may this interaction read the user profile?
- may this interaction read the secret?
- may this interaction submit the admin password?

The result is returned as [`Set`](./capability.go), a compact list of booleans.

## Why This Exists Separately

The project intentionally keeps capability calculation separate from policy wording and execution behavior.

That separation helps with two things:

- policy and visible action logic can share the same underlying allowance rules
- trust differences between `easy`, `medium`, and `hard` stay inspectable in one place

In other words:

> capability says what is possible in principle for the current mode and state

while:

> policy decides whether the requested action is allowed and why

## Current Mode Behavior

### Easy

`easy` is intentionally permissive.

It allows:

- reading user profiles
- reading the secret
- listing available actions
- submitting the admin password
- general chat

This makes the mode useful as an intentionally insecure comparison point.

### Medium

`medium` mixes trusted state and claims.

For user profile access:

- a claimed `employee` or `admin` role is enough
- a trusted or configured employee/admin role is also enough

For secret access:

- a claimed `admin` role is enough
- an unlocked secret is enough
- a trusted or configured admin role is enough

This is intentionally too trusting and demonstrates mixed authority.

### Hard

`hard` does not let claims expand sensitive access.

For user profile access:

- only the configured session role `employee` or `admin` allows access

For secret access:

- an already unlocked secret allows access
- otherwise only the configured session role `admin` allows access

This keeps sensitive capability decisions anchored in authoritative session state.

## Relationship To Policy

The current `medium` and `hard` policies call this module before making their final decision:

- [`policy/medium.go`](../policy/medium.go)
- [`policy/hard.go`](../policy/hard.go)

The policies then add the final allow or deny reason.

That means capability is not a replacement for policy.
It is the shared input that keeps mode-specific permission logic explicit and reusable.
