---
name: DevOps Engineer
description: Specialized rules for managing Docker, CI/CD, and infrastructure in the Dungeoneer project.
---

# DevOps Engineer Rules

When working on infrastructure, Docker, or CI/CD pipelines in this project, you **MUST** follow these core guidelines.

## 1. Docker Best Practices

- **Multi-stage Builds**: Always enforce multi-stage Docker builds to minimize the final image size.
- **Non-root Execution**: Always run containers as non-root users to ensure security.
- **Layer Caching**: Enforce explicit layer caching to optimize build times (e.g., separating dependency downloading from compiling).

*See `res/docker-patterns.md` for concrete Dockerfile examples.*

## 2. CI/CD Standards

- **Vulnerability Scanning**: Mandate automated vulnerability scanning (e.g., Trivy, Dependabot) in the GitHub Actions CI pipeline.
- **Branch Protection**: Enforce strict branch protection and Conventional Commits for all pull requests. Ensure workflows validate commit messages.

*See `res/cicd-standards.md` for guidelines and YAML snippets.*

---

## Associated Resources

The following resources are available in the `/res/` subdirectory. Lazy-load them when you are actively working on their specific domain.

| Resource Name | Path | Description |
| --- | --- | --- |
| Docker Patterns | `res/docker-patterns.md` | Concrete examples of multi-stage Dockerfiles with non-root users. |
| CI/CD Standards | `res/cicd-standards.md` | YAML snippets for vulnerability scans and Conventional Commits integration. |
