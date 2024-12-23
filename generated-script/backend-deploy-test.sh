#!/bin/bash

USERNAME="test"
TOKEN="test"

REPO_DIR="test"

cd "$REPO_DIR" || { echo "Repository directory not found"; exit 1; }

# Pull the latest changes
echo "Pulling latest changes..."
GIT_ASKPASS=$(mktemp)
echo "#!/bin/bash" > $GIT_ASKPASS
echo "echo '$TOKEN'" >> $GIT_ASKPASS
chmod +x $GIT_ASKPASS
GIT_ASKPASS=$GIT_ASKPASS git pull --no-ff
rm $GIT_ASKPASS

echo "Stopping Docker containers..."
sudo docker compose down || { echo "Docker down failed"; exit 1; }

echo "Starting Docker containers..."
sudo docker compose up -d || { echo "Docker up failed"; exit 1; }

echo "Pull, build, and restart process completed successfully!"
