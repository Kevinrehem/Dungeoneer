# Dungeoneer — Project Specification

> **Version**: 1.0.0  
> **Last Updated**: 2026-08-22  
> **Status**: Draft — Pending Approval  
> **Authors**: @jaca (Product Owner), Antigravity (Spec Writer)

---

## Modular Spec Index

This specification follows a **progressive referencing** strategy. The hub (this file) contains high-level context, architectural decisions, and summaries. Detailed specs are lazy-loaded from `res/` when needed.

| Module | Path | When to Load |
|--------|------|--------------|
| **Architecture Diagrams** | [res/architecture-diagram.md](res/architecture-diagram.md) | Working on system design, service boundaries, Docker topology |
| **ER Diagrams** | [res/er-diagram.md](res/er-diagram.md) | Working on database schema, Flyway migrations, JPA entities |
| **Data Models** | [res/data-models.md](res/data-models.md) | Working on database tables, columns, constraints |
| **API Contracts** | [res/api-contracts.md](res/api-contracts.md) | Working on REST endpoints, error handling, gateway routing |
| **Frontend Spec** | [res/frontend-spec.md](res/frontend-spec.md) | Working on Next.js pages, UI design, components, data fetching |
| **Infrastructure** | [res/infrastructure.md](res/infrastructure.md) | Working on Docker Compose, CI/CD, deployment, repo structure |
| **Testing Strategy** | [res/testing-strategy.md](res/testing-strategy.md) | Working on test suites, JaCoCo, TDD workflow |
| **Project State** | [../STATE.md](../STATE.md) | Tracking current progress, implemented features, and next steps |

---

## 1. Context & Vision

### 1.1 Problem Statement

Dungeon Masters and Players of Dungeons & Dragons need a unified, modern tool to manage character sheets, campaigns, NPCs, and game mechanics. Existing tools are either too simplistic (paper sheets), locked behind paywalls (D&D Beyond), or lack proper engineering (homebrew spreadsheets).

### 1.2 Product Vision

**Dungeoneer** is a web-based D&D companion that delivers a premium, dark-fantasy-themed experience for managing characters, campaigns, and game sessions. It supports both D&D 5e (2014) and D&D 2024 Revised rulesets, ships with pre-seeded SRD content, and allows homebrew extensions.

### 1.3 Target Users

| Actor | Description |
|-------|-------------|
| **Player** | Creates and manages character sheets, tracks HP/spells/inventory during sessions |
| **Dungeon Master (DM)** | Creates campaigns, builds NPCs, designs encounters, manages sessions |

### 1.4 Key Differentiators

- **Dual Ruleset Support**: Toggle between 5e 2014 and 2024 rules per character
- **Batteries Included**: Ships with full SRD data (classes, spells, feats, lineages, backgrounds)
- **Homebrew First-Class**: DMs can create custom content that extends or overrides SRD data
- **Clean Architecture**: Domain logic is framework-agnostic and thoroughly tested
- **Dark Fantasy UX**: Premium RPG-themed interface with interactive dice rolling

---

## 2. Ruleset Strategy

### 2.1 Dual Ruleset Support

Dungeoneer supports both **D&D 5e 2014** (SRD 5.1, CC-BY-4.0) and **D&D 2024 Revised** (SRD 5.2).

- **Granularity**: Per-character. Each character declares its ruleset at creation time.
- **Campaign Enforcement**: Campaigns declare a ruleset. Only characters matching the campaign's ruleset can join.
- **Domain Impact**: Reference data is tagged with a `ruleset` discriminator (`SRD_2014` | `SRD_2024` | `HOMEBREW`).

### 2.2 Key Mechanical Differences

| Mechanic | 5e 2014 | 2024 Revised |
|----------|---------|--------------|
| **Race/Lineage** | Race grants fixed ASI | Lineage is cosmetic; Background grants ASI |
| **Background** | Grants skills + tool proficiencies | Grants ASI + Origin Feat + skills |
| **Feats** | Optional rule, replaces ASI at level-up | Integrated into backgrounds and class features |
| **Spellcasting** | Prepared vs Known per class | Unified "Prepared Spells" system |
| **Multiclass Prereqs** | Ability score minimums | Same, with updated thresholds |

These differences are encapsulated in a **RulesEngine** abstraction (Strategy Pattern) that resolves mechanics based on the character's declared ruleset.

---

## 3. Phased Roadmap

### Phase 1 — MVP: Character Sheet Manager

| Feature | Description |
|---------|-------------|
| Character CRUD | Create, read, update, delete characters via multi-step wizard |
| Character Sheet Dashboard | Card-based, rearrangeable dashboard with all character data |
| Level Up / Multiclass | Add levels, pick subclass, update spellcasting |
| Ability Score Generation | Standard Array, Point Buy (27-point), and server-validated 4d6-drop-lowest |
| Spell Search & Filter | Searchable SRD spell database (filter by class, level, school, components) |
| Interactive Dice Rolling | Client-side animated dice rolls on attacks, skills, and spells |
| Inventory Management | Add/remove items, weight tracking, attunement slots, feat injection from items |
| SRD Data Seeding | Pre-populate all SRD reference data via Flyway migrations |
| Homebrew Content | DMs can create custom classes, spells, feats, lineages, backgrounds |

### Phase 2 — Campaign & NPC Management

| Feature | Description |
|---------|-------------|
| Campaign CRUD | Create/manage campaigns with ruleset enforcement |
| NPC Stat Block Builder | Create NPC stat blocks reusing AbilityScores/DiceRoll domain logic |
| Campaign-Character Association | Add characters to campaigns (campaign-service owns the relationship) |

### Phase 3 — Session Tools

| Feature | Description |
|---------|-------------|
| Encounter Builder | Build combat encounters with CR calculation and difficulty estimation |
| Initiative Tracker | Turn-order tracker for combat sessions |

---

## 4. System Architecture

### 4.1 Container Overview

| Container | Technology | Responsibility |
|-----------|-----------|----------------|
| `dungeoneer-frontend` | Next.js 16, React 19, TailwindCSS 4, shadcn/ui | UI, client-side state, dice animations |
| `api-gateway` | Spring Cloud Gateway (Spring Boot 4.x, Java 21) | Routing, CORS, rate limiting, future auth |
| `player-character-service` | Spring Boot 4.x, Java 21, Clean Architecture | Character CRUD, domain logic, spells, feats |
| `campaign-service` | Spring Boot 4.x, Java 21, Clean Architecture | Campaigns, NPCs, encounters (Phase 2+) |
| `db` | PostgreSQL 15 | Shared instance, schema-per-service |

> 📐 See [res/architecture-diagram.md](res/architecture-diagram.md) for C4 diagrams and Docker topology.

### 4.2 Communication

- **Frontend → API Gateway**: REST over HTTP (`NEXT_PUBLIC_API_URL`)
- **API Gateway → Services**: REST over HTTP (internal Docker network)
- **Service → Service**: REST over HTTP through the API Gateway
- **Service → Database**: JDBC (schema isolation)

### 4.3 Clean Architecture (Per Service)

```
domain/model/              → Entities, Value Objects, Domain Interfaces (ZERO framework imports)
application/port/in/       → Use Case interfaces (inbound ports)
application/port/out/      → Repository port interfaces (outbound ports)
application/service/       → Use Case implementations
application/dto/           → DTOs with Jakarta Validation
adapter/in/web/            → REST Controllers + Web Mappers
adapter/out/persistence/   → JPA Entities + Repository Implementations
```

### 4.4 Data Ownership

- **player-character-service** owns: characters, ability scores, spells, feats, items, lineages, backgrounds, archetypes, subclasses
- **campaign-service** owns: campaigns, NPCs, encounters, campaign↔character association
- Services **NEVER** cross-query another service's database schema — they use REST calls

> 📊 See [res/data-models.md](res/data-models.md) for full table definitions.  
> 📊 See [res/er-diagram.md](res/er-diagram.md) for ER diagrams.  
> 🔌 See [res/api-contracts.md](res/api-contracts.md) for REST endpoints and error handling.

---

## 5. SRD Data Scope (Flyway Seed)

| Category | Count | Source |
|----------|-------|--------|
| Classes (Archetypes) | 13 | All SRD base classes |
| Subclasses | 13 (1 per class) | SRD only (e.g., Champion, Life Domain) |
| Lineages/Races | 9 | Human, Elf, Dwarf, Halfling, Gnome, Half-Elf, Half-Orc, Tiefling, Dragonborn |
| Backgrounds | 6 | Acolyte, Criminal, Folk Hero, Noble, Sage, Soldier |
| Spells | ~300 | SRD 5.1 spell list |
| Feats | ~40 | SRD feats |

All reference data tagged with `source = 'SRD'` and `ruleset = 'SRD_2014'` or `'SRD_2024'`.
Homebrew content uses `source = 'HOMEBREW'` and `owner_id` for scoping.

---

## 6. Security (MVP)

- **No authentication**. Single-user mode. `SecurityConfig` does `permitAll()`.
- `user_id` columns exist as **NULLABLE FK placeholders** for future auth.
- CORS configured at the **API Gateway** level only.
- **NEVER hardcode secrets** — use environment variables.
- Future auth: JWT tokens validated at the Gateway, `X-User-Id` header forwarded.

---

## 7. Language & Localization

| Artifact | Language |
|----------|----------|
| Code, API paths, DB columns, comments, commits | English |
| UI labels, text, error messages | Portuguese (pt-BR) |

---

## 8. Technology Versions (Locked)

| Technology | Version |
|-----------|---------|
| Java | 21 (LTS) |
| Spring Boot | 4.0.6 |
| Spring Cloud Gateway | Compatible with Boot 4.x |
| Maven | 3.9.6 |
| PostgreSQL | 15 (Alpine) |
| Node.js | 20 (LTS) |
| Next.js | 16.2.6 |
| React | 19.2.4 |
| TypeScript | 5.x |
| TailwindCSS | 4.x |
| Docker Compose | v2 (no `version:` key) |

> 🏗️ See [res/infrastructure.md](res/infrastructure.md) for Docker Compose, CI/CD, and deployment details.  
> 🧪 See [res/testing-strategy.md](res/testing-strategy.md) for TDD methodology, JaCoCo config, and coverage thresholds.

---

## 9. Open Decisions (Deferred)

| Topic | Status | Notes |
|-------|--------|-------|
| Authentication provider | Deferred | JWT vs OAuth2 vs Keycloak — decide before Phase 2 |
| Real-time features (WebSocket) | Deferred to Phase 3+ | Campaign session collaboration |
| Character export to PDF | Not scoped | Community-requested, low priority |
| Mobile app (React Native / PWA) | Not scoped | Responsive web is sufficient |

---

## 10. References

- [D&D SRD 5.1 (CC-BY-4.0)](https://dnd.wizards.com/resources/systems-reference-document)
- [Spring Boot 4.x Documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [Next.js 16 Documentation](https://nextjs.org/docs)
- [shadcn/ui](https://ui.shadcn.com/)
- [TanStack Query](https://tanstack.com/query/latest)
- [RFC 7807 — Problem Details for HTTP APIs](https://datatracker.ietf.org/doc/html/rfc7807)
