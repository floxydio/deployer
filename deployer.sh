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
mkdir -p "$SCRIPT_DIR"

read -p "Choose build type (PM2/DOCKER): " BUILD_TYPE
read -p "Enter repository folder name: " REPO_DIR

if [[ "$BUILD_TYPE" == "pm2" || "$BUILD_TYPE" == "PM2" ]]; then
  read -p "Enter application name for PM2: " APP_NAME
  SCRIPT_NAME=${SCRIPT_NAME:-backend-deploy-$REPO_DIR.sh}

  cat <<EOL > $SCRIPT_DIR/$SCRIPT_NAME
#!/bin/bash

USERNAME="$USERNAME"
TOKEN="$TOKEN"

REPO_DIR="$REPO_DIR"

cd "\$REPO_DIR" || { echo "Repository directory not found"; exit 1; }

echo "Pulling latest changes..."
GIT_ASKPASS=\$(mktemp)
echo "#!/bin/bash" > \$GIT_ASKPASS
echo "echo '\$TOKEN'" >> \$GIT_ASKPASS
chmod +x \$GIT_ASKPASS
GIT_ASKPASS=\$GIT_ASKPASS git pull --no-ff
rm \$GIT_ASKPASS

echo "Building the project..."
npm run build || { echo "Build failed"; exit 1; }

echo "Restarting the application..."
pm2 restart $APP_NAME || { echo "PM2 restart failed"; exit 1; }

echo "Pull, build, and restart process completed successfully!"
EOL
  chmod +x $SCRIPT_DIR/$SCRIPT_NAME
  echo "Deployment script for $REPO_DIR has been generated: $SCRIPT_DIR/$SCRIPT_NAME"

elif [[ "$BUILD_TYPE" == "docker" || "$BUILD_TYPE" == "DOCKER" ]]; then
  SCRIPT_NAME=${SCRIPT_NAME:-backend-deploy-$REPO_DIR.sh}

  cat <<EOL > $SCRIPT_DIR/$SCRIPT_NAME
#!/bin/bash

USERNAME="$USERNAME"
TOKEN="$TOKEN"

REPO_DIR="$REPO_DIR"

cd "\$REPO_DIR" || { echo "Repository directory not found"; exit 1; }

echo "Pulling latest changes..."
GIT_ASKPASS=\$(mktemp)
echo "#!/bin/bash" > \$GIT_ASKPASS
echo "echo '\$TOKEN'" >> \$GIT_ASKPASS
chmod +x \$GIT_ASKPASS
GIT_ASKPASS=\$GIT_ASKPASS git pull --no-ff
rm \$GIT_ASKPASS

echo "Stopping Docker containers..."
sudo docker compose down || { echo "Docker down failed"; exit 1; }

echo "Starting Docker containers..."
sudo docker compose up -d || { echo "Docker up failed"; exit 1; }

echo "Pull, build, and restart process completed successfully!"
EOL
  chmod +x $SCRIPT_DIR/$SCRIPT_NAME
  echo "Deployment Docker script for $REPO_DIR has been generated: $SCRIPT_DIR/$SCRIPT_NAME"

else
  echo "Invalid build type. Please choose either PM2 or DOCKER."
  exit 1
fi
