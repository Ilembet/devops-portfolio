import os
from contextlib import contextmanager

import psycopg
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

DATABASE_URL = os.environ["DATABASE_URL"]


@contextmanager
def db():
    """Open a short-lived connection; commits on success, rolls back on error."""
    with psycopg.connect(DATABASE_URL, connect_timeout=3) as conn:
        yield conn


def init_db() -> None:
    with db() as conn:
        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS notes (
                id SERIAL PRIMARY KEY,
                text TEXT NOT NULL,
                created_at TIMESTAMPTZ NOT NULL DEFAULT now()
            )
            """
        )


class NoteIn(BaseModel):
    text: str = Field(min_length=1, max_length=1000)


app = FastAPI(title="notes-api")


@app.on_event("startup")
def on_startup() -> None:
    init_db()


@app.get("/health")
def health():
    """Liveness plus database check: 200 when the DB answers, 503 otherwise."""
    try:
        with db() as conn:
            conn.execute("SELECT 1")
    except psycopg.Error:
        raise HTTPException(status_code=503, detail="database unavailable")
    return {"status": "ok"}


@app.post("/notes", status_code=201)
def create_note(note: NoteIn):
    with db() as conn:
        row = conn.execute(
            "INSERT INTO notes (text) VALUES (%s) RETURNING id, text, created_at",
            (note.text,),
        ).fetchone()
    return {"id": row[0], "text": row[1], "created_at": row[2]}


@app.get("/notes")
def list_notes():
    with db() as conn:
        rows = conn.execute(
            "SELECT id, text, created_at FROM notes ORDER BY id DESC LIMIT 100"
        ).fetchall()
    return [{"id": r[0], "text": r[1], "created_at": r[2]} for r in rows]
