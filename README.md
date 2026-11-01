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

## Local development stack

The Compose stack in [`dev-stack/`](dev-stack/) provides Kafka, ZooKeeper, Schema Registry, Kafdrop, MySQL, Keycloak, and RabbitMQ for local development and integration work.

```bash
cd dev-stack
cp .env.example .env
docker compose up -d
docker compose ps
```

See [dev-stack/README.md](dev-stack/README.md) for service endpoints, credentials setup, logs, and shutdown commands. The sample credentials are for local development only.
