# Finch local development setup

This repository is designed to run locally with Finch and Docker Compose. The following commands keep the local setup predictable and easy to reset.

## Prerequisites

- Docker Desktop or Finch-enabled Docker runtime
- Go 1.22+
- Finch installed and available on your PATH

## One-time setup

```bash
cp .env.example .env
finch vm start
```

## Start the local stack

```bash
make finch-up
make finch-status
```

The stack includes Redis, OpenSearch, and three ServeLinc replicas.

## Watch logs

```bash
make finch-logs
```

## Stop and reset

```bash
make finch-down
make finch-reset
```

`finch-reset` tears down the stack and starts it again from a clean state.

## Health checks

Quick validation:

```bash
curl http://localhost:9200/_cluster/health
curl http://localhost:6379/ping
```

## Notes

- The compose file uses `OPENSEARCH_URL=http://opensearch:9200` for inter-container traffic.
- For local host debugging, the `.env` file can be used to override values if needed.
- Keep `OPENSEARCH_URL` empty only if telemetry is intentionally disabled in a test environment.
