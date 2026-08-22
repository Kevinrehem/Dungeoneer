---
name: Spring Boot Stack
description: Best practices for developing CRUD features using Clean Architecture, Java 21, and Spring Boot 4.x.
---

# Spring Boot Stack Rules

When developing backend features in this project, you **MUST** follow these core guidelines.

## 1. Clean Architecture Boundaries

- **Domain Isolation**: Strictly follow Clean Architecture boundaries. The `domain` package must have **ZERO framework imports**. No Spring, no JPA, no Lombok on domain classes.
- **Manual Mapping**: Use manual mapping (`.fromEntity`, `.toDomain`, `.toDto`) for DTO-to-Entity and Entity-to-Domain conversions. Do **not** use MapStruct or other automated mappers. This keeps the domain pure and reduces dependencies.

*See `res/mapping-guidelines.md` for manual mapping strategies.*

## 2. Test-Driven Development (TDD)

- **Methodology**: Enforce **TDD (Test-Driven Development)** as a primary method. Write the failing test (Red), make it pass (Green), and then optimize (Refactor).
- **Execution Plans**: Implementation plans executed using this skill **MUST have pauses for manual commits** between the Red, Green, and Refactor stages. You must generate the exact `git commit -m "..."` command ready for the user to copy-paste. The commit messages must follow Conventional Commits (e.g. `test: add failing test for ...`, `feat: implement ... to pass test`, `refactor: clean up ...`).

## 3. Strict Testing Boundaries

- **Optimize Execution Speed**: Maintain strict testing boundaries to keep test suites blazing fast.
- **Domain & Application Logic**: Must be tested with plain JUnit 5 + Mockito. **NO Spring Context** is allowed in these layers.
- **Persistence & Web Adapters**: Must use sliced contexts (e.g., `@DataJpaTest`, `@WebMvcTest`). Do not load the full `@SpringBootTest` unless writing end-to-end integration tests using Testcontainers.

*See `res/testing-boundaries.md` for optimized unit testing setups.*

---

## Associated Resources

The following resources are available in the `/res/` subdirectory. Lazy-load them when you are actively working on their specific domain.

| Resource Name | Path | Description |
| --- | --- | --- |
| Mapping Guidelines | `res/mapping-guidelines.md` | Examples of manual mapping strategies between DTOs, Domain Entities, and JPA Entities. |
| Testing Boundaries | `res/testing-boundaries.md` | Examples of optimized unit testing setups (plain JUnit vs `@DataJpaTest`). |
