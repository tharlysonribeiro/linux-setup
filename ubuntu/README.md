# Ubuntu Workstation Setup

`setup.sh` is an opt-in bootstrap script for Ubuntu 22.04 or later and compatible Zorin OS releases. It installs only the components selected on the command line and requests `sudo` only when a system change requires it.

## Requirements

- Ubuntu 22.04 or later, or a compatible Zorin OS release
- Internet access
- A regular user account with `sudo` access

Run the script as your regular user. Do not start it with `sudo`.

## Usage

```bash
./setup.sh --help
./setup.sh --java --maven
./setup.sh --essentials
```

Use `--all` to select every available component. Review the help output and script before using it.

| Option | Installs or configures |
| --- | --- |
| `--sdkman` | SDKMAN for Bash and Zsh |
| `--java` | Temurin Java through SDKMAN |
| `--maven` | Apache Maven through SDKMAN |
| `--node` | Node.js LTS and npm from NodeSource |
| `--zsh` | Zsh, Oh My Zsh, autosuggestions, and syntax highlighting |
| `--zsh-default` | Sets Zsh as the default shell |
| `--docker` | Docker Engine, Buildx, and the Docker Compose plugin |
| `--github-cli` | GitHub CLI (`gh`) |
| `--dbeaver` | DBeaver Community via Snap |
| `--database-tools` | PostgreSQL, MySQL, and Redis clients |
| `--terminal-tools` | `jq`, `yq`, `htop`, `tree`, `ripgrep`, `fzf`, and `direnv` |
| `--fonts` | JetBrains Mono Nerd Font for the current user |
| `--chrome` | Google Chrome Stable |
| `--vscode` | Visual Studio Code |
| `--intellij` | IntelliJ IDEA Community via Snap |
| `--codex` | Codex CLI via npm |
| `--steam` | Steam and i386 architecture support |
| `--essentials` | Docker, GitHub CLI, DBeaver, database clients, terminal tools, fonts, and Chrome |
| `--all` | Every component listed above |

## Java and Maven

SDKMAN manages the active Java and Maven versions, including `JAVA_HOME`.

```bash
sdk current java
sdk current maven
```

Maven is stored in `$HOME/.local/tools` by default. Set `TOOLS_DIR` to use another location:

```bash
TOOLS_DIR="$HOME/tools" ./setup.sh --maven
```

For projects with an `.sdkmanrc` file, use `sdk env` to activate the configured versions.

## After installation

- After installing Docker, sign out and back in before using Docker without `sudo`. Membership in the `docker` group grants root-equivalent privileges.
- After changing the default shell, sign out and back in to apply the change.
- Run `codex` to authenticate the Codex CLI.
- Run `gh auth login` to authenticate GitHub CLI.

The script adds third-party package repositories for Docker, Node.js, Visual Studio Code, and GitHub CLI. Review the installer and select only the components you need.
