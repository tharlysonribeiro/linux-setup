#!/usr/bin/env bash
# Optional workstation bootstrap for Ubuntu and Zorin OS.
# Run without sudo; the script requests elevated access only when needed.
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="${TOOLS_DIR:-$HOME/.local/tools}"
SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
JAVA_VERSION="${JAVA_VERSION:-25.0.4-tem}"
MAVEN_VERSION="${MAVEN_VERSION:-3.9.12}"
INTELLIJ_PACKAGE="${INTELLIJ_PACKAGE:-intellij-idea-community}"

want_sdkman=false
want_java=false
want_maven=false
want_node=false
want_zsh=false
want_zsh_default=false
want_docker=false
want_github_cli=false
want_dbeaver=false
want_database_tools=false
want_terminal_tools=false
want_fonts=false
want_chrome=false
want_essentials=false
want_vscode=false
want_intellij=false
want_codex=false
want_steam=false

need_sudo() {
  sudo -v
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Components:
  --sdkman         Install and configure SDKMAN for Bash and Zsh
  --java           Install Temurin Java $JAVA_VERSION with SDKMAN
  --maven          Install Maven $MAVEN_VERSION and register it with SDKMAN
  --node           Install the current Node.js LTS release and npm (NodeSource)
  --zsh            Install Zsh, Oh My Zsh, autosuggestions, and syntax highlighting
  --zsh-default    Set Zsh as the default shell (also enables --zsh)
  --docker         Install Docker Engine, Buildx, and the official Compose plugin
  --github-cli     Install GitHub CLI (gh) from its official repository
  --dbeaver        Install DBeaver Community with Snap
  --database-tools Install PostgreSQL, MySQL, and Redis clients
  --terminal-tools Install jq, yq, htop, tree, ripgrep, fzf, and direnv
  --fonts          Install JetBrains Mono Nerd Font for the current user
  --chrome         Install Google Chrome Stable
  --vscode         Install Visual Studio Code from its official repository
  --intellij       Install IntelliJ IDEA Community with Snap
  --codex          Install the Codex CLI globally with npm
  --steam          Install Steam and enable i386 and multiverse
  --all            Install all components above
  --essentials     Install Docker, GitHub CLI, DBeaver, database clients,
                   terminal tools, fonts, and Chrome

Other options:
  --java-version VERSION    Example: 25.0.4-tem
  --maven-version VERSION   Example: 3.9.12
  --help, -h                Show this help

Examples:
  $0 --java --maven
  $0 --zsh --node --vscode --codex
  $0 --docker --java --maven
  $0 --essentials
  $0 --all

Optional environment variables: JAVA_VERSION, MAVEN_VERSION, TOOLS_DIR, and INTELLIJ_PACKAGE.
For IntelliJ Ultimate: INTELLIJ_PACKAGE=intellij-idea-ultimate $0 --intellij
EOF
}

need_ubuntu_family() {
  if [[ ! -r /etc/os-release ]]; then
    echo "Could not identify the operating system." >&2
    exit 1
  fi
  # shellcheck disable=SC1091
  source /etc/os-release
  if [[ "${ID:-}" != "ubuntu" && "${ID:-}" != "zorin" && " ${ID_LIKE:-} " != *" ubuntu "* ]]; then
    echo "This script supports Ubuntu and Zorin OS; detected: ${PRETTY_NAME:-unknown}." >&2
    exit 1
  fi
}

install_base_packages() {
  need_sudo
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg unzip zip tar git build-essential software-properties-common
}

ensure_sdkman_shell_init() {
  local rc
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    touch "$rc"
    if ! grep -Fq 'sdkman-init.sh' "$rc"; then
      cat >>"$rc" <<'EOF'

# SDKMAN!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
EOF
    fi
  done
}

ensure_sdkman() {
  if [[ ! -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
    echo "Installing SDKMAN..."
    # The installer uses HOME to choose its destination. Set it explicitly to
    # avoid installing into root's home when the environment comes from sudo.
    curl -fsSL https://get.sdkman.io | env HOME="$HOME" SDKMAN_DIR="$SDKMAN_DIR" bash
  fi
  ensure_sdkman_shell_init
  # shellcheck disable=SC1090
  # sdkman-init.sh reads unset variables. The main script uses set -u, so
  # disable nounset only while loading SDKMAN.
  with_nounset_disabled source "$SDKMAN_DIR/bin/sdkman-init.sh"
}

with_nounset_disabled() {
  local had_nounset=false
  [[ $- == *u* ]] && had_nounset=true
  set +u
  "$@"
  local status=$?
  $had_nounset && set -u
  return "$status"
}

install_java() {
  ensure_sdkman
  if [[ ! -d "$SDKMAN_DIR/candidates/java/$JAVA_VERSION" ]]; then
    with_nounset_disabled sdk install java "$JAVA_VERSION"
  fi
  with_nounset_disabled sdk default java "$JAVA_VERSION"
}

install_maven() {
  ensure_sdkman
  local archive="$TOOLS_DIR/apache-maven-$MAVEN_VERSION-bin.tar.gz"
  local maven_home="$TOOLS_DIR/apache-maven-$MAVEN_VERSION"
  if [[ ! -x "$maven_home/bin/mvn" ]]; then
    mkdir -p "$TOOLS_DIR"
    echo "Downloading Apache Maven $MAVEN_VERSION to $TOOLS_DIR..."
    curl -fL --retry 3 -o "$archive" \
      "https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz"
    tar -xzf "$archive" -C "$TOOLS_DIR"
    rm -f "$archive"
  fi
  if [[ ! -d "$SDKMAN_DIR/candidates/maven/$MAVEN_VERSION" ]]; then
    with_nounset_disabled sdk install maven "$MAVEN_VERSION" "$maven_home"
  fi
  with_nounset_disabled sdk default maven "$MAVEN_VERSION"
}

install_node() {
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt-get install -y nodejs
}

install_zsh() {
  need_sudo
  sudo apt-get install -y zsh
  local zsh_dir="$HOME/.oh-my-zsh"
  local custom_dir="$zsh_dir/custom/plugins"
  if [[ ! -d "$zsh_dir/.git" ]]; then
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$zsh_dir"
  else
    git -C "$zsh_dir" pull --ff-only
  fi
  if [[ ! -d "$custom_dir/zsh-autosuggestions/.git" ]]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$custom_dir/zsh-autosuggestions"
  fi
  if [[ ! -d "$custom_dir/zsh-syntax-highlighting/.git" ]]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$custom_dir/zsh-syntax-highlighting"
  fi

  mkdir -p "$HOME/.zshrc.d"
  cat >"$HOME/.zshrc.d/dev-setup.zsh" <<'EOF'
# Managed by setup.sh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="${ZSH_THEME:-robbyrussell}"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source "$ZSH/oh-my-zsh.sh"
EOF
  touch "$HOME/.zshrc"
  if ! grep -Fq '.zshrc.d/dev-setup.zsh' "$HOME/.zshrc"; then
    cat >>"$HOME/.zshrc" <<'EOF'

# Oh My Zsh and plugins installed by setup.sh
[[ -r "$HOME/.zshrc.d/dev-setup.zsh" ]] && source "$HOME/.zshrc.d/dev-setup.zsh"
EOF
  fi
}

install_docker() {
  if command -v docker >/dev/null 2>&1; then
    echo "Docker is already installed: $(docker --version)"
    if ! docker compose version >/dev/null 2>&1; then
      echo "The existing Docker installation does not provide 'docker compose'. Install the Compose plugin with its package manager." >&2
      return 1
    fi
  else
    local codename
    # shellcheck disable=SC1091
    source /etc/os-release
    codename="${UBUNTU_CODENAME:-${VERSION_CODENAME:?Could not detect the Ubuntu release codename}}"
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $codename
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  fi
  sudo systemctl enable --now docker
  if ! id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
    sudo usermod -aG docker "$USER"
    echo "Your user was added to the docker group. Sign out and back in before using Docker without sudo."
  fi
  docker --version
  docker compose version
}

install_github_cli() {
  sudo install -d -m 0755 /etc/apt/keyrings
  sudo curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    -o /etc/apt/keyrings/githubcli-archive-keyring.gpg
  sudo chmod a+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update
  sudo apt-get install -y gh
}

install_dbeaver() {
  need_sudo
  sudo apt-get install -y snapd
  sudo snap install dbeaver-ce --classic
}

install_database_tools() {
  sudo apt-get install -y postgresql-client default-mysql-client redis-tools
}

install_terminal_tools() {
  sudo apt-get install -y jq yq htop tree ripgrep fzf direnv
}

install_fonts() {
  local font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
  local archive
  archive="$(mktemp --suffix=.zip)"
  mkdir -p "$font_dir"
  curl -fL --retry 3 -o "$archive" \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  unzip -oq "$archive" -d "$font_dir"
  rm -f "$archive"
  fc-cache -f "$HOME/.local/share/fonts"
}

install_chrome() {
  local chrome_deb
  chrome_deb="$(mktemp --suffix=.deb)"
  curl -fL --retry 3 -o "$chrome_deb" \
    https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  need_sudo
  sudo apt-get install -y "$chrome_deb"
  rm -f "$chrome_deb"
}

set_zsh_default() {
  local zsh_path
  zsh_path="$(command -v zsh)"
  if [[ "${SHELL:-}" != "$zsh_path" ]]; then
    chsh -s "$zsh_path"
    echo "Zsh was set as the default shell. Sign out and back in to apply the change."
  fi
}

install_vscode() {
  sudo install -d -m 0755 /etc/apt/keyrings
  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/packages.microsoft.gpg >/dev/null
  sudo chmod a+r /etc/apt/keyrings/packages.microsoft.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
    | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
  sudo apt-get update
  sudo apt-get install -y code
}

install_intellij() {
  sudo apt-get install -y snapd
  sudo snap install "$INTELLIJ_PACKAGE" --classic
}

install_codex() {
  if ! command -v npm >/dev/null; then
    install_node
  fi
  npm install -g @openai/codex
}

install_steam() {
  need_sudo
  sudo dpkg --add-architecture i386
  sudo add-apt-repository -y multiverse
  sudo apt-get update
  sudo apt-get install -y steam-installer
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --sdkman) want_sdkman=true ;;
    --java) want_java=true; want_sdkman=true ;;
    --maven) want_maven=true; want_sdkman=true ;;
    --node) want_node=true ;;
    --zsh) want_zsh=true ;;
    --zsh-default) want_zsh=true; want_zsh_default=true ;;
    --docker) want_docker=true ;;
    --github-cli) want_github_cli=true ;;
    --dbeaver) want_dbeaver=true ;;
    --database-tools) want_database_tools=true ;;
    --terminal-tools) want_terminal_tools=true ;;
    --fonts) want_fonts=true ;;
    --chrome) want_chrome=true ;;
    --essentials) want_essentials=true; want_docker=true; want_github_cli=true; want_dbeaver=true; want_database_tools=true; want_terminal_tools=true; want_fonts=true; want_chrome=true ;;
    --vscode) want_vscode=true ;;
    --intellij) want_intellij=true ;;
    --codex) want_codex=true ;;
    --steam) want_steam=true ;;
    --all) want_sdkman=true; want_java=true; want_maven=true; want_node=true; want_zsh=true; want_docker=true; want_github_cli=true; want_dbeaver=true; want_database_tools=true; want_terminal_tools=true; want_fonts=true; want_chrome=true; want_vscode=true; want_intellij=true; want_codex=true; want_steam=true ;;
    --java-version) JAVA_VERSION="${2:?Missing the Java version}"; shift ;;
    --maven-version) MAVEN_VERSION="${2:?Missing the Maven version}"; shift ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 2 ;;
  esac
  shift
done

need_ubuntu_family
if $want_node || $want_zsh || $want_docker || $want_github_cli || $want_dbeaver || $want_database_tools || $want_terminal_tools || $want_chrome || $want_vscode || $want_intellij || $want_steam; then
  install_base_packages
fi

$want_sdkman && ensure_sdkman
$want_java && install_java
$want_maven && install_maven
$want_node && install_node
$want_zsh && install_zsh
$want_zsh_default && set_zsh_default
$want_docker && install_docker
$want_github_cli && install_github_cli
$want_dbeaver && install_dbeaver
$want_database_tools && install_database_tools
$want_terminal_tools && install_terminal_tools
$want_fonts && install_fonts
$want_chrome && install_chrome
$want_vscode && install_vscode
$want_intellij && install_intellij
$want_codex && install_codex
$want_steam && install_steam

echo
echo "Done. Open a new terminal or run: source ~/.zshrc"
if $want_java; then
  echo "Java:  $(java -version 2>&1 | head -n 1)"
  echo "JAVA_HOME: $JAVA_HOME"
fi
if $want_maven; then
  echo "Maven: $(mvn -version 2>&1 | head -n 1)"
fi
