# API Contracts

> Extracted from [SPEC.md](../SPEC.md) Section 5.1 — Lazy-loaded by agents working on REST endpoints.

---

## player-character-service Endpoints (Phase 1)

### Character Management

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/characters` | Create a new character |
| `GET` | `/api/characters` | List all characters |
| `GET` | `/api/characters/{id}` | Get character by ID |
| `PUT` | `/api/characters/{id}` | Update character |
| `DELETE` | `/api/characters/{id}` | Delete character |
| `POST` | `/api/characters/{id}/level-up` | Level up a character |
| `POST` | `/api/characters/{id}/multiclass` | Add a new class to a character |

### Spell Search

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/spells` | List/search spells (query params: class, level, school, name) |
| `GET` | `/api/spells/{id}` | Get spell details |

### Reference Data

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/reference/classes` | List all available classes |
| `GET` | `/api/reference/lineages` | List all available lineages |
| `GET` | `/api/reference/backgrounds` | List all available backgrounds |
| `GET` | `/api/reference/feats` | List all available feats |

### Homebrew Content

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/reference/homebrew/spells` | Create homebrew spell |
| `POST` | `/api/reference/homebrew/feats` | Create homebrew feat |
| `POST` | `/api/reference/homebrew/classes` | Create homebrew class |

---

## API Gateway Routing

| Path Prefix | Target Service |
|-------------|----------------|
| `/api/characters/**` | `player-character-service:8080` |
| `/api/spells/**` | `player-character-service:8080` |
| `/api/reference/**` | `player-character-service:8080` |
| `/api/campaigns/**` | `campaign-service:8081` |
| `/api/npcs/**` | `campaign-service:8081` |

---

## Error Handling

All REST APIs return **RFC 7807 ProblemDetail** responses via `@ControllerAdvice`.

### Domain Exception → HTTP Status Mapping

| Domain Exception | HTTP Status | Example |
|-----------------|-------------|---------|
| `CharacterNotFoundException` | 404 | Character ID doesn't exist |
| `InvalidAbilityScoreException` | 422 | Point Buy exceeds 27 points |
| `MulticlassPrerequisiteException` | 422 | Doesn't meet ability score minimum |
| `SpellSlotExhaustedException` | 409 | No spell slots remaining |
| `RulesetMismatchException` | 409 | 2014 character trying to join 2024 campaign |

### ProblemDetail Response Example

```json
{
  "type": "https://dungeoneer.app/errors/invalid-ability-score",
  "title": "Invalid Ability Score",
  "status": 422,
  "detail": "Point Buy total exceeds the 27-point budget. Current total: 31.",
  "instance": "/api/characters",
  "timestamp": "2026-08-22T03:00:00Z"
}
```

---

## API Documentation

- **OpenAPI 3.0** via `springdoc-openapi-starter-webmvc-ui`
- Swagger UI available at `/swagger-ui.html` per service in dev
- **TypeScript client generation** from OpenAPI spec using `openapi-typescript-codegen` or `orval`
- Generated client lives in `dungeoneer-frontend/lib/api/generated/`
