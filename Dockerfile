FROM python:3.9-slim as builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
ARG POETRY_VERSION=1.4.2
RUN pip install "poetry==${POETRY_VERSION}"

# Configure Poetry
RUN poetry config virtualenvs.create false

# Copy only requirements to cache them in Docker layer
WORKDIR /app
COPY pyproject.toml poetry.lock ./

# Install project dependencies
RUN poetry install --only main --no-interaction --no-ansi

# Production stage
FROM python:3.9-slim

WORKDIR /app
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY . .

CMD ["python", "app.py"]
