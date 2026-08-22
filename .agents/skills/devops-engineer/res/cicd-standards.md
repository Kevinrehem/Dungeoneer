# CI/CD Standards

Guidelines and YAML snippets for integrating vulnerability scans and Conventional Commits.

## 1. Vulnerability Scanning (Trivy)

Add the following step to your GitHub Actions workflows after building your Docker images to run a vulnerability scan using Trivy:

```yaml
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'dungeoneer/backend:latest'
          format: 'table'
          exit-code: '1'
          ignore-unfixed: true
          vuln-type: 'os,library'
          severity: 'CRITICAL,HIGH'
```
*Note: Make sure `exit-code: '1'` is set to fail the build if vulnerabilities are found.*

## 2. Conventional Commits Verification

Ensure that PR titles or commit messages follow the Conventional Commits standard (e.g., `feat: add new spell`, `fix: correct dice logic`). Add a commit lint action to your workflow:

```yaml
      - name: Validate PR Title (Conventional Commits)
        uses: amannn/action-semantic-pull-request@v5
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          types: |
            feat
            fix
            docs
            style
            refactor
            perf
            test
            build
            ci
            chore
            revert
```

## 3. Strict Branch Protection Rules

If creating documentation or advising on repository settings, ensure these branch protection rules are recommended for the `main` branch:
- Require pull request reviews before merging.
- Require status checks to pass before merging (e.g., test and build workflows, Trivy scan, semantic pull request validation).
- Enforce linear history (require rebase or squash merges).
