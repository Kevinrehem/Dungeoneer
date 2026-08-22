# Dungeoneer — Agent Guidelines

> This file bootstraps AI agents working on the Dungeoneer codebase.  
> Read this file FIRST before making any changes.

---

## Project Overview

Dungeoneer is a D&D 5e/2024 companion web app for managing character sheets, campaigns, and game sessions. It uses a microservices architecture with Clean Architecture principles.

## Specifications & Knowledge Index

| Document | Path | Load When |
|----------|------|-----------|
| **SPEC.md** | `docs/spec/SPEC.md` | Always — lightweight hub with context, roadmap, and architecture overview |
| **Architecture Diagrams** | `docs/spec/res/architecture-diagram.md` | Working on system design, service boundaries, Docker topology |
| **ER Diagrams** | `docs/spec/res/er-diagram.md` | Working on database schema, Flyway migrations, JPA entities |
| **Data Models** | `docs/spec/res/data-models.md` | Working on database tables, columns, constraints |
| **API Contracts** | `docs/spec/res/api-contracts.md` | Working on REST endpoints, error handling, gateway routing |
| **Frontend Spec** | `docs/spec/res/frontend-spec.md` | Working on Next.js pages, UI design, components, data fetching |
| **Infrastructure** | `docs/spec/res/infrastructure.md` | Working on Docker Compose, CI/CD, deployment, repo structure |
| **Testing Strategy** | `docs/spec/res/testing-strategy.md` | Working on test suites, JaCoCo, TDD workflow |
| **Project State** | `docs/STATE.md` | Tracking current progress, implemented features, and next steps |
| **Use Cases** | `docs/USE-CASES.md` | Domain use cases with actor diagram |
| **Architecture (Legacy)** | `docs/ARCHITECTURE.md` | Clean Architecture directory structure reference |
| **README** | `README.md` | Domain model class diagrams and design decisions |

## Core Architectural Patterns

### 1. Clean Architecture (Hexagonal)

Every Spring Boot service follows this package structure:

```
domain/model/         → Entities, Value Objects, Domain Interfaces (NO framework imports)
application/port/in/  → Use Case interfaces (inbound ports)
application/port/out/ → Repository port interfaces (outbound ports)  
application/service/  → Use Case implementations
application/dto/      → Data Transfer Objects (with Jakarta Validation)
adapter/in/web/       → REST Controllers + Web Mappers
adapter/out/persistence/ → JPA Entities + Repository Implementations
```

**Golden Rule**: The `domain` package MUST have ZERO framework imports. No Spring, no JPA, no Lombok on domain classes.

### 2. Dual Ruleset Engine

All reference data (classes, spells, feats, lineages, backgrounds) is tagged with a `ruleset` discriminator (`SRD_2014` | `SRD_2024` | `HOMEBREW`). The `RulesEngine` interface (Strategy Pattern) resolves mechanics based on the character's declared ruleset.

### 3. Data Ownership

- **player-character-service** owns: characters, ability scores, spells, feats, items, lineages, backgrounds, archetypes, subclasses
- **campaign-service** owns: campaigns, NPCs, encounters, and the campaign↔character association (stores `characterId` references, hydrates via REST)
- Services NEVER cross-query another service's database schema

### 4. Error Handling

All REST APIs return **RFC 7807 ProblemDetail** responses via `@ControllerAdvice`. Domain exceptions map to specific HTTP status codes.

### 5. Testing

**TDD (Red → Green → Refactor)**. JaCoCo enforces ≥80% line coverage on domain + application layers.

| Layer | Tool |
|-------|------|
| Unit | JUnit 5 + Mockito |
| Integration | Testcontainers + PostgreSQL |
| API | MockMvc |
| Frontend Unit | Vitest + Testing Library |
| Frontend E2E | Playwright |

## Conventions

| Aspect | Convention |
|--------|-----------|
| Language (code) | English |
| Language (UI) | Portuguese (pt-BR) |
| Branch strategy | Feature branches → PR → main |
| Commit style | Conventional Commits |
| API documentation | OpenAPI 3.0 via springdoc |
| Database migrations | Flyway (SQL-based, numbered) |
| IDs | UUID (gen_random_uuid) |
| Timestamps | TIMESTAMPTZ (UTC) |
| DTO validation | Jakarta Validation annotations |
| Build tool (Java) | Maven (global `mvn`, not wrapper) |
| Build tool (JS) | npm |

## Security Notes

- **MVP has NO authentication**. SecurityConfig permits all.
- `user_id` columns exist as NULLABLE FK placeholders.
- NEVER hardcode secrets. Use environment variables.
- CORS is configured at the API Gateway level only.

## Infrastructure

- **Local dev**: Docker Compose (single `docker-compose.yml` at repo root)
- **Production**: Vercel (frontend) + Railway (backend + PostgreSQL)
- **Database**: PostgreSQL 15, shared instance, schema-per-service
- **CI/CD**: GitHub Actions per service

## Agent Workflow & Commits

- **Ready-to-use Commit Commands**: Whenever a task or logical chunk of work is finished, the agent MUST provide the exact, ready-to-copy-and-paste `git commit` command (following the Conventional Commits style) for the user to execute.
- **Phase Pauses**: When following multi-phase implementation plans (such as TDD cycles or moving between different microservices/components), the agent MUST pause and prompt the user to commit their current progress before proceeding to the next phase. Always provide the relevant commit command during these pauses.
