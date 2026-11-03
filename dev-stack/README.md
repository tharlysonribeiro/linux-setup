# Development Stack

Docker Compose services for local development and integration testing. This stack is intended for a developer workstation; home-hosted applications belong in a separate homelab setup.

## Services

| Service | Access |
| --- | --- |
| ZooKeeper | `localhost:2181` |
| Kafka | `kafka:9092` from containers on the Compose network |
| Schema Registry | `http://localhost:8081` |
| Kafdrop | `http://localhost:9000` |
| MySQL | `localhost:3306` |
| Keycloak | `http://localhost:8080` |
| Authentik | `http://localhost:9001` |
| RabbitMQ | `localhost:5672`; management UI at `http://localhost:15672` |

## Start the stack

From this directory, create a local environment file and start the services:

```bash
cp .env.example .env
docker compose config
docker compose up -d
docker compose ps
```

The credentials in `.env.example` are local development examples. `.env` is ignored by Git. Change the values before using the stack in any shared or persistent environment.

Authentik uses its own PostgreSQL database and is available at `http://localhost:9001`. On first access, complete the initial setup to create its administrator account. Keycloak remains available separately at `http://localhost:8080`; configure OIDC providers and clients in the identity service you choose for an application.

## Logs and shutdown

```bash
docker compose logs -f
docker compose down
```

The default shutdown keeps the MySQL data volume. To remove the containers and all stack data:

```bash
docker compose down --volumes
```

`down --volumes` permanently deletes the MySQL data created by this stack.
