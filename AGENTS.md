# Repository Instructions

## Purpose

This repository prepares Ubuntu workstations and provides a Docker Compose stack for local development services.

## Guidelines

- Write documentation, comments, command output, and examples in English.
- Keep personal names, email addresses, machine-specific paths, tokens, and real credentials out of tracked files.
- Keep Ubuntu workstation setup under `ubuntu/` and local development services under `dev-stack/`.
- Keep home-hosted applications such as Jellyfin in the separate homelab repository.
- Preserve the installer's opt-in behavior; do not run system-changing installer options during validation.
- Use obvious local-only values in `.env.example`; keep `.env` untracked.

## Validation

- Check the installer syntax with `bash -n ubuntu/setup.sh`.
- Check its help output with `ubuntu/setup.sh --help`.
- Validate Compose with `docker compose --env-file dev-stack/.env.example -f dev-stack/compose.yaml config`.
