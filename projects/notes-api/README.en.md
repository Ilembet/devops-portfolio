# notes-api

A small HTTP service built with FastAPI and PostgreSQL. It is deliberately simple: it is the base for practising Docker, CI/CD, Terraform, Kubernetes and monitoring. Русская версия: [README.md](README.md).

## Endpoints

| Method | Path | Description |
| --- | --- | --- |
| GET | `/health` | 200 when the database answers, 503 otherwise |
| POST | `/notes` | create a note, body `{"text": "..."}` |
| GET | `/notes` | the latest 100 notes |
| GET | `/docs` | automatic Swagger documentation |

## Running

Requires Docker with Compose.

```bash
cd projects/notes-api
cp .env.example .env        # then change the password in .env
docker compose up --build
```

Check it:

```bash
curl http://localhost:8000/health
curl -X POST http://localhost:8000/notes -H "Content-Type: application/json" -d '{"text":"hello"}'
curl http://localhost:8000/notes
```

Stop: `docker compose down` (data is kept), `docker compose down -v` (data is removed too).

## Tests

```bash
python -m venv .venv
source .venv/bin/activate        # Git Bash on Windows: source .venv/Scripts/activate
pip install -r requirements-dev.txt
python -m pytest
```

## Already done properly

- the image runs as a non-root user and has a `HEALTHCHECK`;
- dependency versions are pinned;
- the database is not published; only the API port is open;
- the API starts after the database passes its healthcheck;
- passwords come only from `.env`, with no defaults.

## Next

Build the image in CI, publish it to GHCR, deploy to a VM in Yandex Cloud, then Kubernetes and monitoring.
