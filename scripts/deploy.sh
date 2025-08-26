#!/bin/bash
set -e

echo "🚀 Starting deployment process..."
echo "Branch: ${GIT_BRANCH:-unknown}"
echo "Build: ${BUILD_NUMBER:-dev}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Determine deployment environment based on branch
if [[ "${GIT_BRANCH}" == "origin/main" ]] || [[ "${GIT_BRANCH}" == "main" ]]; then
    ENVIRONMENT="production"
    PORT="5000"
elif [[ "${GIT_BRANCH}" == *"develop"* ]]; then
    ENVIRONMENT="staging"
    PORT="5001"
elif [[ "${GIT_BRANCH}" == *"feature"* ]]; then
    ENVIRONMENT="feature"
    PORT="5002"
else
    print_warning "Branch not configured for deployment: ${GIT_BRANCH}"
    exit 0
fi

print_status "Deploying to ${ENVIRONMENT} environment on port ${PORT}"

# Stop existing deployment
print_status "Stopping existing deployment..."
docker stop my-app-${ENVIRONMENT} 2>/dev/null || true
docker rm my-app-${ENVIRONMENT} 2>/dev/null || true

# Deploy new version
print_status "Deploying new version..."
docker run -d \
    --name my-app-${ENVIRONMENT} \
    -p ${PORT}:5000 \
    -e APP_VERSION=${BUILD_NUMBER} \
    -e GIT_BRANCH=${GIT_BRANCH} \
    --restart unless-stopped \
    my-app:${BUILD_NUMBER:-latest}

# Health check
print_status "Performing health check..."
sleep 5

for i in {1..30}; do
    if curl -f http://localhost:${PORT}/health > /dev/null 2>&1; then
        print_status "Deployment successful! App is healthy."
        print_status "Access your app at: http://localhost:${PORT}"
        exit 0
    fi
    echo "Waiting for app to be ready... ($i/30)"
    sleep 2
done

print_error "Deployment failed - app is not responding to health checks"
docker logs my-app-${ENVIRONMENT}
exit 1
