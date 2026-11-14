# notes-api

Небольшой HTTP-сервис на FastAPI с PostgreSQL. Приложение намеренно простое: оно нужно как основа для отработки Docker, CI/CD, Terraform, Kubernetes и мониторинга. English version: [README.en.md](README.en.md).

## Эндпоинты

| Метод | Путь | Описание |
| --- | --- | --- |
| GET | `/health` | 200, если база отвечает; 503, если нет |
| POST | `/notes` | создать заметку, тело `{"text": "..."}` |
| GET | `/notes` | последние 100 заметок |
| GET | `/docs` | автоматическая документация Swagger |

## Запуск

Нужен Docker с Compose.

```bash
cd projects/notes-api
cp .env.example .env        # затем замени пароль в .env
docker compose up --build
```

Проверка:

```bash
curl http://localhost:8000/health
curl -X POST http://localhost:8000/notes -H "Content-Type: application/json" -d '{"text":"hello"}'
curl http://localhost:8000/notes
```

Остановка: `docker compose down` (данные сохраняются), `docker compose down -v` (вместе с данными).

## Тесты

```bash
python -m venv .venv
source .venv/bin/activate        # Git Bash на Windows: source .venv/Scripts/activate
pip install -r requirements-dev.txt
python -m pytest
```

## Что уже сделано правильно

- образ не от root, с `HEALTHCHECK`;
- версии зависимостей закреплены;
- база не публикуется наружу, порт открыт только у API;
- API стартует после того, как база прошла healthcheck;
- пароли только из `.env`, без значений по умолчанию.

## Дальше по плану

Сборка образа в CI, публикация в GHCR, деплой на ВМ в Yandex Cloud, затем Kubernetes и мониторинг.
