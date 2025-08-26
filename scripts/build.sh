#!/bin/bash
set -e

echo "🏗️  Starting build process..."
echo "Branch: ${GIT_BRANCH:-unknown}"
echo "Build: ${BUILD_NUMBER:-dev}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Clean up previous builds
print_status "Cleaning up previous builds..."
docker-compose down --volumes --remove-orphans 2>/dev/null || true

# Build Docker image
print_status "Building Docker image..."
docker build -t my-app:${BUILD_NUMBER:-latest} .

# Verify image was built
if docker images my-app:${BUILD_NUMBER:-latest} | grep -q "my-app"; then
    print_status "Docker image built successfully"
else
    print_error "Failed to build Docker image"
    exit 1
fi

# Tag image for different environments
if [[ "${GIT_BRANCH}" == "origin/main" ]] || [[ "${GIT_BRANCH}" == "main" ]]; then
    docker tag my-app:${BUILD_NUMBER:-latest} my-app:production
    print_status "Tagged image for production"
elif [[ "${GIT_BRANCH}" == *"develop"* ]]; then
    docker tag my-app:${BUILD_NUMBER:-latest} my-app:staging
    print_status "Tagged image for staging"
else
    docker tag my-app:${BUILD_NUMBER:-latest} my-app:feature
    print_status "Tagged image for feature branch"
fi

print_status "Build completed successfully!"
