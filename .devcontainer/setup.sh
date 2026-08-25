#!/bin/bash
set -e

echo "Starting Devcontainer setup..."

# Frontend setup
echo "Installing frontend dependencies..."
if [ -d "dungeoneer-frontend" ]; then
  cd dungeoneer-frontend
  npm install
  cd ..
else
  echo "Frontend directory not found!"
fi

# Backend setup
echo "Building backend dependencies..."
# Find all pom.xml files and run maven build
find . -name "pom.xml" -type f | while read -r pom_file; do
  dir=$(dirname "$pom_file")
  echo "Running mvn clean install in $dir..."
  (cd "$dir" && mvn clean install -DskipTests)
done

echo "Devcontainer setup complete!"
