# Observability

This directory contains a local Grafana stack and a separate SigNoz Foundry casting. Run one telemetry backend at a time: both stacks use OTLP ports `4317` and `4318`, and SigNoz also uses port `8080`, which the main development stack assigns to Keycloak.

## Grafana, Tempo, Loki, and OpenTelemetry

Start the Grafana stack with:

```bash
docker compose -f compose.yaml up -d
```

| Service | Access |
| --- | --- |
| Grafana | `http://localhost:3001` (user `admin`; password `local-dev-password` unless `GRAFANA_ADMIN_PASSWORD` is set) |
| Prometheus | `http://localhost:9090` |
| Tempo | `http://localhost:3200` |
| Loki | `http://localhost:3100` |
| OpenTelemetry OTLP gRPC | `localhost:4317` |
| OpenTelemetry OTLP HTTP | `http://localhost:4318` |

Applications can send OTLP traces, metrics, and logs to the Collector. The Collector routes traces to Tempo, metrics to Prometheus, and logs to Loki. Grafana provisions all three data sources at startup. This is a local development setup with filesystem storage and a one-day Tempo retention period.

Stop the stack with `docker compose -f compose.yaml down`. Add `--volumes` only when you intend to delete its stored telemetry and Grafana data.

## SigNoz

SigNoz currently uses Foundry to generate its Docker Compose deployment; the Compose files previously bundled in the SigNoz repository are deprecated. From this directory, install `foundryctl` following the [SigNoz Docker guide](https://signoz.io/docs/install/docker/), then run:

```bash
foundryctl forge -f signoz-casting.yaml
docker compose -f pours/deployment/compose.yaml up -d
```

The UI is at `http://localhost:8080`. Stop SigNoz with:

```bash
docker compose -f pours/deployment/compose.yaml down
```

The generated deployment is kept under `pours/` and is not tracked. SigNoz's default ports overlap with Keycloak and the separate Grafana stack, so stop those services before starting SigNoz.
