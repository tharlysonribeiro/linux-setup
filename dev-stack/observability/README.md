# Observability

These are optional local telemetry backends. Start either the Grafana stack or SigNoz from this directory. Do not run both at once: they both publish OTLP ports `4317` and `4318`. SigNoz also uses `8080`, already used by Keycloak in the main development stack.

## Grafana, Tempo, Loki, and OpenTelemetry

Start the stack from this directory:

```bash
docker compose up -d --wait
docker compose ps
```

| Service | Host access | Purpose |
| --- | --- | --- |
| OpenTelemetry Collector | OTLP gRPC `localhost:4317`; OTLP HTTP `http://localhost:4318` | Receives app telemetry and routes it to the backends |
| Tempo | `http://localhost:3200` | Traces |
| Loki | `http://localhost:3100` | Logs sent to the Collector via OTLP |
| Prometheus | `http://localhost:9090` | Metrics from the Collector's Prometheus exporter |
| Grafana | `http://localhost:3001` | Queries Prometheus, Tempo, and Loki |

Grafana's local login is `admin` / `local-dev-password`. Set `GRAFANA_ADMIN_PASSWORD` before startup to use another local password. The three data sources are provisioned automatically.

Applications running on the host can send OTLP to `localhost:4317` or `http://localhost:4318`. Container logs are not collected automatically; applications must send logs through OTLP or you must add a log collector. The stack uses local Docker volumes and a one-day Tempo retention period, so it is intended for development rather than production.

Stop the stack from this directory with:

```bash
docker compose down
```

This keeps stored telemetry and Grafana data. To delete them too, run `docker compose down --volumes`.

## SigNoz

SigNoz is an alternative telemetry backend. Its current Docker deployment uses Foundry to generate Compose files; the Compose files formerly bundled in the SigNoz repository are deprecated. Install `foundryctl` using the [official SigNoz Docker guide](https://signoz.io/docs/install/docker/), then from this directory run:

```bash
foundryctl forge -f signoz-casting.yaml
docker compose -f pours/deployment/compose.yaml up -d --wait
docker compose -f pours/deployment/compose.yaml ps
```

The UI is at `http://localhost:8080`; OTLP uses `localhost:4317` and `localhost:4318`. Stop SigNoz with:

```bash
docker compose -f pours/deployment/compose.yaml down
```

Foundry generates the deployment under `pours/`, which is ignored by Git. Stopping SigNoz keeps its data volumes; `docker compose -f pours/deployment/compose.yaml down --volumes` deletes them. SigNoz needs at least 4 GB of available memory for the local deployment.
