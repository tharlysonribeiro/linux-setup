# Development Stack

This is the default local development stack. It starts only when you run `docker compose` in this directory; observability and K3s are optional stacks with separate Compose files. Home-hosted applications belong in a separate homelab setup.

Docker Engine and the Compose v2 plugin are required.

## Services

| Service | Host access | Notes |
| --- | --- | --- |
| ZooKeeper | `localhost:2181` | Kafka coordination |
| Kafka | `localhost:9092` | Containers on this Compose network use `kafka:9092` |
| Schema Registry | `http://localhost:8081` | Uses Kafka |
| Kafdrop | `http://localhost:9000` | Kafka browser |
| MySQL | `localhost:3306` | Shared by Keycloak and local applications |
| Keycloak | `http://localhost:8080` | OIDC provider; admin credentials come from `.env` |
| Authentik | `http://localhost:9001` | Separate OIDC provider with its own PostgreSQL database |
| RabbitMQ | `localhost:5672`; management UI at `http://localhost:15672` | Already included in this stack |

## Start the stack

From this directory, copy the example environment file and start the services:

```bash
cp .env.example .env
docker compose config
docker compose up -d --wait
docker compose ps
```

The credentials in `.env.example` are local development examples. `.env` is ignored by Git. Replace the sample passwords and Authentik secret before using the stack in any shared or persistent environment. The Authentik administrator is created through its first-run setup page; its PostgreSQL service is internal and does not publish port `5432` on the host.

Keycloak and Authentik run independently. OIDC clients, providers, users, and federation are not preconfigured; create them in the identity service you choose for each application.

## Optional stacks

The Grafana stack and SigNoz instructions are in [`observability/`](observability/). K3s is in [`k3s/`](k3s/). Start each from its own directory. SigNoz uses host ports `8080`, `4317`, and `4318`, which conflict with Keycloak and the Grafana stack's OpenTelemetry Collector; stop those services before starting SigNoz.

## Logs and shutdown

```bash
docker compose logs -f
docker compose down
```

The default shutdown removes containers and preserves the MySQL and Authentik PostgreSQL volumes. To delete those databases and all other volumes belonging to this Compose project:

```bash
docker compose down --volumes
```

`down --volumes` permanently deletes the local database data created by this stack.
