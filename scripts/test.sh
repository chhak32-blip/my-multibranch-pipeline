#!/bin/bash
set -e

echo "🧪 Starting test process..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Start services for testing
print_status "Starting test environment..."
export APP_VERSION=${BUILD_NUMBER:-test}
export GIT_BRANCH=${GIT_BRANCH:-test}

docker-compose up -d

# Wait for services to be healthy
print_status "Waiting for services to be ready..."
sleep 15

# Check if services are running
if ! docker-compose ps | grep -q "Up"; then
    print_error "Services failed to start"
    docker-compose logs
    exit 1
fi

# Run unit tests inside container
print_status "Running unit tests..."
docker-compose exec -T app python -m pytest tests/ -v --tb=short || {
    print_status "Pytest not available, running unittest instead..."
    docker-compose exec -T app python -m unittest tests.test_app -v
}

# Run integration tests
print_status "Running integration tests..."

# Test health endpoint
for i in {1..10}; do
    if curl -s http://localhost:5000/health | grep -q "healthy"; then
        print_status "Health check passed"
        break
    fi
    echo "Waiting for health check... ($i/10)"
    sleep 2
    if [ $i -eq 10 ]; then
        print_error "Health check failed"
        exit 1
    fi
done

# Test calculator endpoints
if curl -s "http://localhost:5000/calculate/add?a=5&b=3" | grep -q '"result":8'; then
    print_status "Calculator test passed"
else
    print_error "Calculator test failed"
    exit 1
fi

print_status "All tests passed successfully!"

# Cleanup
docker-compose down
