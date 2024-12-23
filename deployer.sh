#!/bin/bash
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "Error: .env file not found!"
  exit 1
fi

USERNAME="$USERNAME"
TOKEN="$TOKEN"

SCRIPT_DIR="generated-script"

read -p "Enter repository folder name: " REPO_DIR
read -p "Enter application name for PM2: " APP_NAME
read -p "Enter name for the deployment script (default: backend-deploy-<repo>.sh): " SCRIPT_NAME

SCRIPT_NAME=${SCRIPT_NAME:-backend-deploy-$REPO_DIR.sh}

cat <<EOL > $SCRIPT_DIR/$SCRIPT_NAME
#!/bin/bash

USERNAME="$USERNAME"
TOKEN="$TOKEN"

# Directory of the repository
REPO_DIR="$REPO_DIR"

# Change to the repository directory
cd "\$REPO_DIR" || { echo "Repository directory not found"; exit 1; }

# Pull the latest changes
echo "Pulling latest changes..."
GIT_ASKPASS=\$(mktemp)
echo "#!/bin/bash" > \$GIT_ASKPASS
echo "echo '\$TOKEN'" >> \$GIT_ASKPASS
chmod +x \$GIT_ASKPASS
GIT_ASKPASS=\$GIT_ASKPASS git pull --no-ff
rm \$GIT_ASKPASS

# Build the project
echo "Building the project..."
npm run build || { echo "Build failed"; exit 1; }

# Restart the application using PM2
echo "Restarting the application..."
pm2 restart $APP_NAME || { echo "PM2 restart failed"; exit 1; }

# Success message
echo "Pull, build, and restart process completed successfully!"
EOL

chmod +x $SCRIPT_DIR/$SCRIPT_NAME

echo "Deployment script for $REPO_DIR has been generated: $SCRIPT_DIR/$SCRIPT_NAME"
