#!/bin/bash
# Isaac Sim startup script
# Usage: ./startup.sh <optional:repo_dir>

set -e

REPO_URL="https://github.com/sra405/isaacSim.git"

# Always use $HOME/isaacSim as the repo directory
REPO_DIR="$HOME/isaacSim"

# Check to see if this is being ran inside the correct repository
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  if git remote -v | grep -q "$REPO_URL"; then
    echo "Repository already exists. Pulling latest changes..."
    git pull
  else
    echo "This is a git repo, but not the correct one. Please move outside a repository or clone $REPO_URL."
  fi
# If not inside a git repository, clone or pull the correct one
else
  if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning repository..."
    git clone "$REPO_URL" "$REPO_DIR"
  else
    echo "Repository already exists. Pulling latest changes..."
    cd "$REPO_DIR"
    git pull
    cd -
  fi
  cd "$REPO_DIR"
fi

# Ensure docker/isaac-sim directory exists
mkdir -p ./docker/isaac-sim

# Set permissions for mounted volumes
sudo chmod -R 777 ./docker/isaac-sim/

# Start Isaac Sim via Docker Compose
if [ -f .env ]; then
  echo ".env file found. Using environment variables."
else
  echo ".env file not found. Please create one with CF_TUNNEL_TOKEN if using cloudflared."
fi

echo "Starting Isaac Sim containers..."
docker compose up -d isaac-sim

echo "Fixing permissions for all mounted volumes..."
sudo chmod -R 777 ./docker/isaac-sim/

echo "Isaac Sim startup complete."