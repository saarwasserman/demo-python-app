FROM python:3.13-slim-bookworm AS builder


# Python
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get upgrade -y \
    && pip install --upgrade pip

# Poetry

ENV POETRY_HOME=/opt/poetry \
    POETRY_VERSION=1.8.2
    
RUN python3 -m venv ${POETRY_HOME} \
    && ${POETRY_HOME}/bin/pip install poetry==${POETRY_VERSION} \
    && ${POETRY_HOME}/bin/poetry --version

# Dependencies installation
WORKDIR /app

COPY pyproject.toml poetry.lock* /app/

RUN python3 -m venv /opt/venv \
    && . /opt/venv/bin/activate \
    && ${POETRY_HOME}/bin/poetry install --no-root --only main


COPY . /app

FROM python:3.13-slim-bookworm AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app /app

ENV PATH="/opt/venv/bin:$PATH"

EXPOSE 8000

CMD ["python", "-m", "fastapi", "run", "--host", "0.0.0.0", "--port", "8000"]
