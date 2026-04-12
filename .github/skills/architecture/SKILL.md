---
name: architecture
description: "Use when designing system architecture, component structure, data models, or evaluating architectural decisions. Covers system design, component boundaries, data flow, and scalability considerations."
---

# Architecture

## Overview

Structured system design and component architecture. Use this when making decisions about how components relate, where data lives, and how the system scales.

**Core principle:** Good architecture makes the system easy to understand, easy to change, and hard to break.

## When to Use

- Designing new features or modules
- Evaluating data model decisions
- Planning component boundaries
- Reviewing system-level design choices
- Deciding between architectural patterns

## Architecture Decision Process

### 1. Understand Context
- What problem are we solving?
- What are the constraints (performance, cost, complexity)?
- What existing patterns does the codebase use?
- What's the expected scale (users, data volume, frequency)?

### 2. Map Components
- What are the independent units?
- What are their responsibilities?
- How do they communicate?
- What are the dependencies?

### 3. Define Boundaries
- Each component has ONE clear responsibility
- Communication through well-defined interfaces
- Components can be understood and tested independently
- Changes in one component don't cascade to others

### 4. Data Flow
- Where does data originate?
- How does it transform through the system?
- Where is it stored?
- Who can read/write it?

### 5. Evaluate Trade-offs
- Simplicity vs. flexibility
- Performance vs. maintainability
- Consistency vs. availability
- Build vs. buy

## Architecture Patterns (Flutter/Firebase)

### Feature-Based Architecture
```
lib/features/<feature>/
  ├── data/          # Repositories, data sources
  ├── domain/        # Models, business logic
  └── presentation/  # Screens, widgets, state
```

### State Management
- **Provider/Riverpod** for dependency injection and reactive state
- **Streams** for real-time Firestore data
- **ValueNotifier** for simple local state

### Data Layer
- **Repository pattern** — abstract data source from business logic
- **Firestore collections** — design for query patterns, not normalization
- **Offline-first** — local cache with sync

### Navigation
- **GoRouter** for declarative routing
- **Deep links** validated at entry point
- **Role-based routing** — guards enforce access

## Design Principles

| Principle | Application |
|-----------|------------|
| **Single Responsibility** | One reason to change per component |
| **Open/Closed** | Extend behavior without modifying existing code |
| **Dependency Inversion** | Depend on abstractions, not concretions |
| **Interface Segregation** | Small, focused interfaces |
| **YAGNI** | Don't build what you don't need yet |
| **DRY** | Extract shared logic, but only after 3+ duplications |

## Red Flags

- **God class/file** — one file doing too much (>300 lines is a smell)
- **Circular dependencies** — A depends on B depends on A
- **Leaky abstractions** — implementation details exposed through interfaces
- **Shotgun surgery** — one change requires touching many files
- **Feature envy** — a component using another component's data more than its own

## Document Decisions

For significant architecture decisions, document:
- **Context** — what prompted the decision
- **Decision** — what was chosen
- **Consequences** — what trade-offs were accepted
- **Alternatives** — what was considered and rejected
