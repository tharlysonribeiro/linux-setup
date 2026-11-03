# Linux Setup

Scripts for preparing an Ubuntu development workstation and running local development services with Docker Compose.

## Ubuntu workstation

Supports Ubuntu 22.04 or later and compatible Zorin OS releases. Run the installer as your regular user; it requests `sudo` only for system changes.

```bash
cd ubuntu
chmod +x setup.sh
./setup.sh --help
```

Choose the components you need. For example:

```bash
./setup.sh --java --maven
./setup.sh --docker --github-cli
```

See [ubuntu/README.md](ubuntu/README.md) for supported components and configuration details.

## Local development stacks

Docker Engine with the Compose v2 plugin is required. Each stack is started from its own directory and can be stopped independently.

| Stack | Starts by default? | Services | Guide |
| --- | --- | --- | --- |
| Development | Yes, when you run its Compose file | Kafka, ZooKeeper, Schema Registry, Kafdrop, MySQL, Keycloak, Authentik, RabbitMQ | [`dev-stack/README.md`](dev-stack/README.md) |
| Grafana observability | No | OpenTelemetry Collector, Tempo, Loki, Prometheus, Grafana | [`dev-stack/observability/README.md`](dev-stack/observability/README.md) |
| SigNoz | No; alternative telemetry backend | SigNoz and its required storage/collector services | [`dev-stack/observability/README.md`](dev-stack/observability/README.md) |
| K3s | No | Single-node Kubernetes cluster | [`dev-stack/k3s/README.md`](dev-stack/k3s/README.md) |

Start the main development stack:

```bash
cd dev-stack
cp .env.example .env
docker compose up -d --wait
docker compose ps
```

The other stacks are opt-in. They use separate Compose files so you can run only the services needed for your task. Check each guide for host ports, credentials, persistence, and port conflicts before starting optional stacks together. Sample credentials are for local development only.
