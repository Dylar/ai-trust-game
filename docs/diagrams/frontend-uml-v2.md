# Frontend UML V2

This version keeps the diagrams intentionally small.
The focus is on the main interaction path, not on every implementation detail.

The existing diagrams are best described as `interaction flow diagrams` or simple `flowcharts`.
They are useful for quick reading because they show the main path without full time-lane detail.

## Standard Interaction

```mermaid
flowchart LR
    U["User"]
    S["Screen"]
    V["ViewModel"]
    ST["State"]
    SV["Service"]
    R["Repository"]
    API["API"]

    U -- "1. submit input" --> S
    S -- "2. call method" --> V
    V -- "3./11. update state" --> ST
    V -- "4./12. notify new state" --> S
    V -- "5. execute use case" --> SV
    SV -- "6. get or change data" --> R
    R -- "7. fetch if needed" --> API
    API -- "8. response" --> R
    R -- "9. app data" --> SV
    SV -- "10. result" --> V
```

### Sequence Diagram

```mermaid
sequenceDiagram
    actor User
    participant Screen
    participant ViewModel
    participant State
    participant Service
    participant Repository
    participant API

    User->>Screen: 1. submit input
    Screen->>ViewModel: 2. call method
    ViewModel->>State: 3. update state
    ViewModel->>Screen: 4. notify new state
    ViewModel->>Service: 5. execute use case
    Service->>Repository: 6. get or change data
    Repository->>API: 7. fetch if needed
    API-->>Repository: 8. response
    Repository-->>Service: 9. app data
    Service-->>ViewModel: 10. result
    ViewModel->>State: 11. update state
    ViewModel->>Screen: 12. notify new state
```

## Information Dialog

```mermaid
flowchart LR
    U["User"]
    S["Screen"]
    D["Dialog"]
    V["ViewModel"]
    ST["State"]

    U -- "1. tap action" --> S
    S -- "2./7. call method" --> V
    V -- "3./8. update state" --> ST
    V -- "4./9. notify new state" --> S
    S -- "5. show dialog" --> D
    U -- "6. tap OK" --> D
```

### Sequence Diagram

```mermaid
sequenceDiagram
    actor User
    participant Screen
    participant ViewModel
    participant State
    participant Dialog

    User->>Screen: 1. tap action
    Screen->>ViewModel: 2. call method
    ViewModel->>State: 3. update state
    ViewModel->>Screen: 4. notify new state
    Screen->>Dialog: 5. show dialog
    User->>Dialog: 6. tap OK
    Dialog->>ViewModel: 7. call method
    ViewModel->>State: 8. update state
    ViewModel->>Screen: 9. notify new state
```

## Decision Dialog

```mermaid
flowchart LR
    U["User"]
    S["Screen"]
    D["Dialog"]
    V["ViewModel"]
    ST["State"]
    SV["Service"]
    R["Repository"]

    U -- "1. tap action" --> S
    S -- "2. call method" --> V
    V -- "3./8a./8b./13b. update state" --> ST
    V -- "4./9a./14b. notify new state" --> S
    S -- "5. show dialog" --> D

    U -- "6a. tap Cancel" --> D
    D -- "7a./7b. call method" --> V

    U -- "6b. tap Confirm" --> D
    V -- "9b. execute action" --> SV
    SV -- "10b. update data" --> R
    R -- "11b. result" --> SV
    SV -- "12b. result" --> V
```

### Sequence Diagram

```mermaid
sequenceDiagram
    actor User
    participant Screen
    participant ViewModel
    participant State
    participant Dialog
    participant Service
    participant Repository

    User->>Screen: 1. tap action
    Screen->>ViewModel: 2. call method
    ViewModel->>State: 3. update state
    ViewModel->>Screen: 4. notify new state
    Screen->>Dialog: 5. show dialog

    alt Cancel
        User->>Dialog: 6a. tap Cancel
        Dialog->>ViewModel: 7a. call method
        ViewModel->>State: 8a. update state
        ViewModel->>Screen: 9a. notify new state
    else Confirm
        User->>Dialog: 6b. tap Confirm
        Dialog->>ViewModel: 7b. call method
        ViewModel->>State: 8b. update state
        ViewModel->>Service: 9b. execute action
        Service->>Repository: 10b. update data
        Repository-->>Service: 11b. result
        Service-->>ViewModel: 12b. result
        ViewModel->>State: 13b. update state
        ViewModel->>Screen: 14b. notify new state
    end
```
