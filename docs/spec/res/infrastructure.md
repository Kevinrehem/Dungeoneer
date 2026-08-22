# Infrastructure Specification

> Extracted from [SPEC.md](../SPEC.md) Sections 7-8 — Lazy-loaded by agents working on Docker, CI/CD, and deployment.

---

## Docker Compose (Local Development)

### Canonical File: `docker-compose.yml` (repo root)

**Services**:

| Service | Image / Build Context | Port | Depends On |
|---------|----------------------|------|------------|
| `db` | `postgres:15-alpine` | 5432 | — |
| `player-character-service` | `./player-character-service/backend` | 8080 | db |
| `api-gateway` | `./api-gateway` | 9090 | player-character-service |
| `dungeoneer-frontend` | `./dungeoneer-frontend` | 3000 | api-gateway |
| `campaign-service` *(Phase 2)* | `./campaign-service/backend` | 8081 | db |

**Network**: Single bridge network (`dungeoneer-net`).

**Volumes**: `db-data` for PostgreSQL persistence.

### Environment Variables (never hardcoded)

| Variable | Service | Default (dev only) |
|----------|---------|-------------------|
| `DB_PASSWORD` | db, player-character-service, campaign-service | (none — must be set) |
| `SPRING_DATASOURCE_URL` | player-character-service | `jdbc:postgresql://db:5432/dungeoneer` |
| `SPRING_DATASOURCE_USERNAME` | player-character-service | `postgres` |
| `SPRING_DATASOURCE_PASSWORD` | player-character-service | `${DB_PASSWORD}` |
| `SPRING_PROFILES_ACTIVE` | all Spring services | `dev` |
| `NEXT_PUBLIC_API_URL` | dungeoneer-frontend | `http://localhost:9090` |

---

## Repository Structure

```
Dungeoneer/                          # Orchestrator monorepo
├── docker-compose.yml               # Canonical compose file
├── .env.example                     # Template for env vars
├── .github/workflows/
│   ├── backend-ci.yml               # CI for player-character-service
│   ├── campaign-ci.yml              # CI for campaign-service (Phase 2)
│   ├── gateway-ci.yml               # CI for api-gateway
│   └── frontend-ci.yml              # CI for dungeoneer-frontend
├── docs/
│   ├── spec/
│   │   ├── SPEC.md                  # Hub specification (lightweight)
│   │   └── res/                     # Modular spec fragments + diagrams
│   ├── USE-CASES.md
│   └── ARCHITECTURE.md
├── AGENTS.md                        # Agent bootstrap file
├── dungeoneer-frontend/             # Git submodule → Next.js app
├── player-character-service/        # Git submodule → Spring Boot service
├── campaign-service/                # Git submodule → Spring Boot service (Phase 2)
└── api-gateway/                     # Git submodule → Spring Cloud Gateway
```

> **Note**: The `apps/` directory is **deleted**. All submodules live at the repo root.

### Git Submodules

| Submodule | Repository | Branch |
|-----------|-----------|--------|
| `dungeoneer-frontend` | `Witches-Of-The-Country/dungeoneer-frontend` | `main` |
| `player-character-service` | `Witches-Of-The-Country/player-character-service` | `main` |
| `campaign-service` | `Witches-Of-The-Country/campaign-service` | `main` (Phase 2) |
| `api-gateway` | `Witches-Of-The-Country/api-gateway` | `main` |

---

## Deployment Targets

| Environment | Frontend | Backend | Database |
|-------------|----------|---------|----------|
| **Development** | `npm run dev` (local) or Docker | Docker Compose | PostgreSQL in Docker |
| **Production** | Vercel | Railway (free tier) | Railway PostgreSQL |

### Vercel Configuration

- Auto-deploy from `dungeoneer-frontend` submodule
- Environment variable: `NEXT_PUBLIC_API_URL` → Railway backend URL

### Railway Configuration

- Deploy each Spring Boot service as a separate Railway service
- Shared PostgreSQL instance with schema-per-service
- Environment variables for database credentials injected via Railway dashboard

---

## CI/CD (GitHub Actions)

### Per-Service Workflows

Each service has its own CI workflow in `.github/workflows/`:

#### Backend CI (`backend-ci.yml`)

```yaml
triggers:
  - push to main (paths: player-character-service/**)
  - PR to main

steps:
  1. Checkout (with submodules)
  2. Setup Java 21 (temurin)
  3. Cache Maven dependencies
  4. Run: mvn clean test (with Testcontainers)
  5. Generate JaCoCo coverage report
  6. Fail if coverage < 80% (domain + application)
  7. Build Docker image (verify Dockerfile)
```

#### Frontend CI (`frontend-ci.yml`)

```yaml
triggers:
  - push to main (paths: dungeoneer-frontend/**)
  - PR to main

steps:
  1. Checkout (with submodules)
  2. Setup Node.js 20
  3. npm ci
  4. npm run lint
  5. npm run build
  6. npx vitest run (unit tests)
  7. npx playwright test (E2E, if configured)
```
