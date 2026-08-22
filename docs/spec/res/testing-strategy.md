# Testing Strategy

> Extracted from [SPEC.md](../SPEC.md) Section 9 — Lazy-loaded by agents working on test suites and CI quality gates.

---

## Methodology

**Test-Driven Development (TDD)** with Red → Green → Refactor commit discipline.

Each feature implementation follows:

1. **Red**: Write a failing test that describes the expected behavior
2. **Green**: Write the minimum code to make the test pass
3. **Refactor**: Clean up the code while keeping tests green

Commits should reflect this cycle (e.g., `test: add failing test for ...`, `feat: implement ...`, `refactor: extract ...`).

---

## Test Pyramid

| Layer | Tool | Scope | Coverage Target |
|-------|------|-------|----------------|
| **Unit** | JUnit 5 + Mockito | Domain models, use case services, value objects | ≥ 80% line coverage |
| **Integration** | Testcontainers + PostgreSQL | Repository adapters, Flyway migrations | All repository methods |
| **API** | MockMvc | REST controllers, request validation, response structure | All endpoints |
| **Frontend Unit** | Vitest + Testing Library | React components, hooks, utilities | ≥ 70% |
| **Frontend E2E** | Playwright | Full user flows (create character, level up, spell search) | Critical paths |

---

## Backend Testing Details

### Unit Tests (domain + application layers)

- **What to test**: Domain entity behavior, value object invariants, use case service logic, DTO validation
- **Examples**:
  - `AbilityScores.getModifier()` returns correct modifier for all score values
  - `PlayerCharacter.levelUp()` increments level and recalculates proficiency bonus
  - `PointBuyValidator` rejects totals exceeding 27 points
  - `RulesEngine` resolves correct mechanics per ruleset
- **Mocking**: Use Mockito for outbound port interfaces (repositories)
- **No Spring context**: Unit tests do NOT load the Spring application context

### Integration Tests (adapter layer)

- **What to test**: JPA entity mapping, Flyway migrations, repository queries
- **Infrastructure**: Testcontainers spins up a real PostgreSQL 15 container
- **Examples**:
  - `CharacterRepositoryImpl.save()` persists and retrieves correctly
  - Flyway migrations apply cleanly on a fresh database
  - Query methods return filtered results (by ruleset, by class, etc.)

### API Tests (controller layer)

- **What to test**: HTTP method + path routing, request body validation, response status codes, ProblemDetail error format
- **Tool**: MockMvc (no real server, no real database)
- **Examples**:
  - `POST /api/characters` with valid body → 201 Created
  - `POST /api/characters` with missing name → 422 with ProblemDetail
  - `GET /api/characters/{id}` with non-existent ID → 404 with ProblemDetail

---

## Frontend Testing Details

### Component Tests (Vitest + Testing Library)

- **What to test**: Component rendering, user interactions, conditional display, form validation
- **Examples**:
  - Character card renders name, level, HP correctly
  - Ability score modifier displays correct value for score 14 → +2
  - Point Buy UI disables "+" button when budget exhausted
  - Spell filter returns correct results

### E2E Tests (Playwright)

- **What to test**: Full user flows against a running dev server
- **Examples**:
  - Complete character creation wizard from start to finish
  - Level-up flow with subclass selection
  - Spell search with multiple filters applied

---

## Coverage Enforcement

### JaCoCo Configuration

```xml
<!-- Add to pom.xml build/plugins -->
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.12</version>
    <executions>
        <execution>
            <goals><goal>prepare-agent</goal></goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals><goal>report</goal></goals>
        </execution>
        <execution>
            <id>check</id>
            <phase>verify</phase>
            <goals><goal>check</goal></goals>
            <configuration>
                <rules>
                    <rule>
                        <element>BUNDLE</element>
                        <limits>
                            <limit>
                                <counter>LINE</counter>
                                <value>COVEREDRATIO</value>
                                <minimum>0.80</minimum>
                            </limit>
                        </limits>
                        <includes>
                            <include>com.dungeoneer.*.domain.**</include>
                            <include>com.dungeoneer.*.application.**</include>
                        </includes>
                    </rule>
                </rules>
            </configuration>
        </execution>
    </executions>
</plugin>
```

### Thresholds

| Layer | Metric | Minimum |
|-------|--------|---------|
| Domain + Application (Java) | Line coverage | 80% |
| Frontend components | Line coverage | 70% |
| E2E | Critical path coverage | All wizard + sheet flows |
