#!/bin/bash
# Isaac Sim startup script
# Usage: ./startup.sh <optional:repo_dir>

set -e

REPO_URL="https://github.com/sra405/isaacSim.git"

# Always use $HOME/isaacSim as the repo directory
REPO_DIR="$HOME/isaacSim"

# Clone the repo if it doesn't exist
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

# Ensure docker/isaac-sim directory exists
mkdir -p ~/docker/isaac-sim

# Set permissions for mounted volumes
sudo chmod 777 -R ~/docker/isaac-sim/

# Start Isaac Sim via Docker Compose
if [ -f .env ]; then
  echo ".env file found. Using environment variables."
else
  echo ".env file not found. Please create one with CF_TUNNEL_TOKEN if using cloudflared."
fi

echo "Starting Isaac Sim containers..."
docker compose up -d isaac-sim

echo "Isaac Sim startup complete."
