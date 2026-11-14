import os
from contextlib import contextmanager

os.environ.setdefault("DATABASE_URL", "postgresql://u:p@localhost:5432/none")

import psycopg  # noqa: E402
from fastapi.testclient import TestClient  # noqa: E402

from app import main  # noqa: E402

client = TestClient(main.app)


def test_health_returns_503_when_db_is_down(monkeypatch):
    @contextmanager
    def broken_db():
        raise psycopg.OperationalError("down")
        yield  # pragma: no cover

    monkeypatch.setattr(main, "db", broken_db)
    response = client.get("/health")
    assert response.status_code == 503


def test_create_note_rejects_empty_text():
    response = client.post("/notes", json={"text": ""})
    assert response.status_code == 422
