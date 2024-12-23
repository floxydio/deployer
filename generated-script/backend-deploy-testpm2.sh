#!/bin/bash

USERNAME="test"
TOKEN="test"

# Directory of the repository
REPO_DIR="testpm2"

# Change to the repository directory
cd "$REPO_DIR" || { echo "Repository directory not found"; exit 1; }

# Pull the latest changes
echo "Pulling latest changes..."
GIT_ASKPASS=$(mktemp)
echo "#!/bin/bash" > $GIT_ASKPASS
echo "echo '$TOKEN'" >> $GIT_ASKPASS
chmod +x $GIT_ASKPASS
GIT_ASKPASS=$GIT_ASKPASS git pull --no-ff
rm $GIT_ASKPASS

# Build the project
echo "Building the project..."
npm run build || { echo "Build failed"; exit 1; }

# Restart the application using PM2
echo "Restarting the application..."
pm2 restart 0 || { echo "PM2 restart failed"; exit 1; }

# Success message
echo "Pull, build, and restart process completed successfully!"
