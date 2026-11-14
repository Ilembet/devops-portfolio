# devops-portfolio

Hands-on DevOps work: deployment automation, infrastructure as code, CI/CD, containers, orchestration and monitoring. Author: Vasil Ilembetov.

Русская версия: [README.md](README.md).

**Stack:** Linux, Docker and Docker Compose, GitHub Actions, Terraform and Yandex Cloud, Ansible, Kubernetes, Prometheus and Grafana (some items are still planned, see below).

Coursework from the Netology program is kept separately in the [Homeworks](https://github.com/Ilembet/Homeworks) repository.

## Repository rules

- Changes reach `main` only through pull requests.
- Branches are named `feat/...`, `fix/...`, `docs/...`; commit messages start with `feat:`, `fix:`, `docs:`.
- CI runs from the first commit: linters, secret scanning, Terraform checks.
- Secrets live only in `.env` (never committed); the repository ships `.env.example`.
- Everything a README describes is in the repository and starts with one command.

## Layout

| Folder | Contents |
| --- | --- |
| `projects/` | Applications and services used to practice the tooling |
| `infra/` | Terraform, later Ansible and Helm |
| `docs/` | Architecture, runbooks, incident reviews |

## Plan

| Period | Work | Status |
| --- | --- | --- |
| Dec 2026 | CI, first containerized project, Terraform across two zones | planned |
| Jan 2027 | Deeper Docker, image in GHCR | planned |
| Feb 2027 | CI/CD with deployment to a VM | planned |
| Mar 2027 | Ansible roles | planned |
| Apr–May 2027 | Kubernetes, Helm, monitoring, ArgoCD | planned |
| Jun 2027 | Terraform modules, database backups, end-to-end project v1 | planned |
| Jul 2027 | Documentation, runbooks, version v2 | planned |

## Working locally

Install [pre-commit](https://pre-commit.com/) once and enable the hooks:

```bash
pip install pre-commit
pre-commit install
```

After that `gitleaks`, `yamllint`, `shellcheck` and `markdownlint` run before every commit.
