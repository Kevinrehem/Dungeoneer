# Dungeoneer — Project State

> **Last Updated**: 2026-08-22  
> **Status**: Active Development  
> **Current Phase**: Phase 1 — MVP: Character Sheet Manager

---

## 1. Current Progress

### Infrastructure & DevOps
- [x] Docker Compose configured for local development (`dungeoneer-db`, `player-character-service`, `dungeoneer-frontend`).
- [x] Frontend CI Pipeline implemented (GitHub Actions).
- [x] Initial Repository Structure and Workspaces established.

### Backend (`player-character-service`)
- [x] Clean Architecture package structure laid out.
- [x] **Domain Models Implemented**:
  - `PlayerCharacter` (core entity with validation rules for hit points, levels, etc.)
  - `AbilityScores` (Strength, Dexterity, Constitution, Intelligence, Wisdom, Charisma, and modifier calculation)
  - `Ruleset` enum (`SRD_2014`, `SRD_2024`)
  - `AbilityScoreMethod` enum (`STANDARD_ARRAY`, `POINT_BUY`, `ROLLED`)
- [x] Unit Tests implemented for domain models using JUnit 5 (TDD approach).

### Frontend (`dungeoneer-frontend`)
- [x] Next.js 16 app initialized with React 19, Tailwind CSS 4, and TypeScript.
- [x] Responsive layout and mobile optimizations started.
- [x] Basic UI structure.
- [x] Global Navbar extracted (sticky layout).
- [x] Authentication UI (Login and Register) implemented with Dark Fantasy theme, Zod, and React Hook Form.

---

## 2. In Progress / Next Steps

### Backend
- [x] Implement Use Cases (Inbound Ports) for Character Creation (`CreateCharacterUseCase`).
- [x] Implement Repository Ports (Outbound Ports) and JPA Adapters.
- [x] Implement `GlobalExceptionHandler` for centralized error handling (RFC 7807).
- [ ] Create REST API Controllers for Character management (creation, retrieval).
  - [x] `PlayerCharacterController` - POST `/api/characters` (TDD RED Phase: Failing tests written).
  - [ ] `PlayerCharacterController` - POST `/api/characters` (TDD GREEN Phase: Implementation).
- [x] Setup Flyway migrations based on the defined PostgreSQL schema.

### Frontend
- [ ] Develop the Character Creation Wizard UI (integrating with the backend API).
- [ ] Implement the Character Sheet Dashboard view.

---

## 3. Known Issues & Blockers
- No current blockers. Infrastructure is stable and domain logic implementation is progressing well.
