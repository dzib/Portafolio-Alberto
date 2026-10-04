FROM python:3.11-slim AS app

WORKDIR /app

COPY . .

CMD ["python", "-m", "models"]
