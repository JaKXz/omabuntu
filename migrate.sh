#!/bin/bash

set -eEo pipefail

ascii_art='
 ▄██████▄    ▄▄▄▄███▄▄▄▄      ▄████████ ▀█████████▄  ███    █▄  ███▄▄▄▄       ███     ███    █▄
███    ███ ▄██▀▀▀███▀▀▀██▄   ███    ███   ███    ███ ███    ███ ███▀▀▀██▄ ▀█████████▄ ███    ███
███    ███ ███   ███   ███   ███    ███   ███    ███ ███    ███ ███   ███    ▀███▀▀██ ███    ███
███    ███ ███   ███   ███   ███    ███  ▄███▄▄▄██▀  ███    ███ ███   ███     ███   ▀ ███    ███
███    ███ ███   ███   ███ ▀███████████ ▀▀███▀▀▀██▄  ███    ███ ███   ███     ███     ███    ███
███    ███ ███   ███   ███   ███    ███   ███    ██▄ ███    ███ ███   ███     ███     ███    ███
███    ███ ███   ███   ███   ███    ███   ███    ███ ███    ███ ███   ███     ███     ███    ███
 ▀██████▀   ▀█   ███   █▀    ███    █▀  ▄█████████▀  ████████▀   ▀█   █▀     ▄████▀   ████████▀
'
clear
echo -e "\n$ascii_art\n"

sudo apt-get update >/dev/null
sudo apt-get install -y git >/dev/null


# Define migration variables
export OMAKUB_REPO="${OMAKUB_REPO:-omakasui/omabuntu}"
export OMAKUB_REF="${OMAKUB_REF:-main}"
export OMAKUB_BRAND="${OMAKUB_BRAND:-Omabuntu}"
export OMAKUB_MIGRATE="$HOME/.local/share/omakub/install/migrate"

# Define backup and staging locations
export BACKUP_DIR="$HOME/.local/share/omakub-backup-$(date +%Y%m%d_%H%M%S)"
MIGRATION_STAGE=$(mktemp -d "${TMPDIR:-/tmp}/omabuntu-migration.XXXXXX")
MIGRATION_SUCCEEDED=false

restore_on_failure() {
  local status=$?

  if [[ $MIGRATION_SUCCEEDED != true && -d $BACKUP_DIR/omakub ]]; then
    echo "Migration did not complete. Restoring the original Omakub checkout and .bashrc from $BACKUP_DIR."
    rm -rf "$HOME/.local/share/omakub"
    cp -a "$BACKUP_DIR/omakub" "$HOME/.local/share/omakub"
    if [[ -f $BACKUP_DIR/bashrc.bak ]]; then
      cp -a "$BACKUP_DIR/bashrc.bak" "$HOME/.bashrc"
    fi
  fi

  rm -rf "$MIGRATION_STAGE"
  return "$status"
}
trap restore_on_failure EXIT

# Check Omakub installation
if [[ ! -d $HOME/.local/share/omakub ]]; then
    echo "Error: Omakub not found. Please run the installer instead."
    exit 1
fi

# Upgrade your system
sudo apt-get update >/dev/null
sudo apt-get upgrade -y >/dev/null

# Check for gum
if ! command -v gum &>/dev/null; then
    cd /tmp
    wget -q -O gum.deb "https://github.com/charmbracelet/gum/releases/download/v0.17.0/gum_0.17.0_amd64.deb"
    sudo apt install -y --allow-downgrades ./gum.deb >/dev/null 2>&1
    rm gum.deb
    cd - >/dev/null
fi

gum style --border normal --border-foreground 6 --padding "1 2" \
  "Ready to migrate to Omabuntu?" \
  "" \
  "• Upgrade Ubuntu separately before running this migration" \
  "• Make sure you're connected to power or have a full battery" \
  "• A backup will be created before changing the Omakub checkout"

echo

# Request confirmation
if ! gum confirm "Continue with migration?"; then
  echo "Migration cancelled"
  exit 1
fi

# Clone the target before replacing the original checkout.
echo -e "\nCloning $OMAKUB_BRAND from: https://github.com/${OMAKUB_REPO}.git"
git clone --branch "$OMAKUB_REF" --single-branch "https://github.com/${OMAKUB_REPO}.git" "$MIGRATION_STAGE/omakub" >/dev/null

# Back up the original checkout and shell configuration.
mkdir -p "$BACKUP_DIR"
cp -a "$HOME/.local/share/omakub" "$BACKUP_DIR/omakub"
if [[ -f $HOME/.bashrc ]]; then
  cp -a "$HOME/.bashrc" "$BACKUP_DIR/bashrc.bak"
fi

# Replace the checkout only after the clone and backup have succeeded.
mv "$HOME/.local/share/omakub" "$MIGRATION_STAGE/omakub-original"
mv "$MIGRATION_STAGE/omakub" "$HOME/.local/share/omakub"

# Migrate
source "$OMAKUB_MIGRATE/all.sh"
source "$HOME/.local/share/omakub/install.sh"
MIGRATION_SUCCEEDED=true
