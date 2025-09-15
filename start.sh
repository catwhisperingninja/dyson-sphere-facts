#!/bin/bash

# DSP Documentation Agent - MVP Deployment Script
# Launches Docker containers and initializes the complete system

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 DSP Documentation Agent - MVP Deployment${NC}"
echo "============================================="

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to wait for endpoint
wait_for_endpoint() {
    local url="$1"
    local service="$2"
    local max_attempts=30
    local attempt=1

    echo -n "Waiting for $service ($url)..."
    while [ $attempt -le $max_attempts ]; do
        if curl -s -f "$url" >/dev/null 2>&1; then
            echo -e " ${GREEN}✅ Ready${NC}"
            return 0
        fi
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done

    echo -e " ${RED}❌ Timeout${NC}"
    return 1
}

# Check prerequisites
echo -e "\n${YELLOW}📋 Prerequisites Check${NC}"
echo "----------------------"

if ! command_exists docker; then
    echo -e "${RED}❌ Docker not found. Please install Docker Desktop.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker found${NC}"

if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker daemon not running. Please start Docker Desktop.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker daemon running${NC}"

# Check required directories
if [ ! -d "docker" ]; then
    echo -e "${RED}❌ docker/ directory not found. Run from project root.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Project structure valid${NC}"

# Check environment file
if [ ! -f "docker/.env" ]; then
    echo -e "${RED}❌ docker/.env file missing. Please create with required API keys.${NC}"
    echo "Required variables: OPENAI_API_KEY, BRAVE_API_KEY"
    exit 1
fi
echo -e "${GREEN}✅ Environment configuration found${NC}"

# Check for Claudable repository
CLAUDABLE_PATH="../Claudable"
if [ ! -d "$CLAUDABLE_PATH" ]; then
    echo -e "${YELLOW}⚠️  Claudable repository not found at $CLAUDABLE_PATH${NC}"
    echo "   The agent will run without Claudable interface."
fi

# Stop any existing containers
echo -e "\n${YELLOW}🛑 Stopping Existing Containers${NC}"
echo "--------------------------------"
cd docker
docker-compose down --remove-orphans || true

# Start Docker infrastructure
echo -e "\n${YELLOW}🐳 Starting Docker Infrastructure${NC}"
echo "--------------------------------"
docker-compose up -d

# Wait for services to be ready
echo -e "\n${YELLOW}⏳ Waiting for Services${NC}"
echo "----------------------"
wait_for_endpoint "http://localhost:6333/" "Qdrant Database"
wait_for_endpoint "http://localhost:3002/health" "RAG Server"
wait_for_endpoint "http://localhost:3004/health" "Search Server"

# Validate infrastructure
echo -e "\n${YELLOW}🔍 Infrastructure Validation${NC}"
echo "----------------------------"
if [ -x "./validate-infrastructure.sh" ]; then
    ./validate-infrastructure.sh
else
    echo -e "${RED}❌ Validation script not executable${NC}"
    chmod +x ./validate-infrastructure.sh
    ./validate-infrastructure.sh
fi

# Return to project root
cd ..

# Start Claudable if available
if [ -d "$CLAUDABLE_PATH" ]; then
    echo -e "\n${YELLOW}🤖 Starting Claudable Interface${NC}"
    echo "------------------------------"

    # Check if Claudable has dependencies installed
    if [ ! -d "$CLAUDABLE_PATH/node_modules" ]; then
        echo "Installing Claudable dependencies..."
        (cd "$CLAUDABLE_PATH" && npm install)
    fi

    # Check if Claudable is already running
    if lsof -i :3001 >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Port 3001 in use. Stopping existing Claudable...${NC}"
        pkill -f "node.*claudable" || true
        sleep 2
    fi

    # Start Claudable in background
    echo "Starting Claudable on http://localhost:3001..."
    (cd "$CLAUDABLE_PATH" && npm start) &
    CLAUDABLE_PID=$!

    # Wait for Claudable to start
    sleep 5
    if wait_for_endpoint "http://localhost:3001" "Claudable Interface"; then
        echo -e "${GREEN}✅ Claudable started (PID: $CLAUDABLE_PID)${NC}"
        echo "   Save this PID to stop Claudable later: kill $CLAUDABLE_PID"
    else
        echo -e "${RED}❌ Claudable failed to start${NC}"
    fi
fi

# Display final status
echo -e "\n${GREEN}🎯 DSP Documentation Agent - Deployment Complete${NC}"
echo "================================================="
echo
echo "📊 Service Status:"
echo "  • Qdrant Database:    http://localhost:6333/"
echo "  • RAG Server:         http://localhost:3002/health"
echo "  • Search Server:      http://localhost:3004/health"
if [ -d "$CLAUDABLE_PATH" ]; then
    echo "  • Claudable Interface: http://localhost:3001"
fi
echo
echo "🧪 Testing Commands:"
echo "  • Test RAG search:     curl 'http://localhost:3002/search?q=dyson+sphere'"
echo "  • Test web search:     curl 'http://localhost:3004/search?q=physics'"
echo "  • Full validation:     ./docker/validate-infrastructure.sh"
echo
echo "🔧 Management Commands:"
echo "  • Restart services:    ./restart.sh"
echo "  • Stop services:       docker-compose -f docker/docker-compose.yml down"
echo "  • View logs:           docker-compose -f docker/docker-compose.yml logs -f"
echo
echo -e "${GREEN}✅ System ready for DSP documentation queries!${NC}"

# Optional: Run example queries
read -p "Run example queries to test the system? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\n${BLUE}🧪 Running Example Queries${NC}"
    echo "=========================="

    echo -e "\n1. Testing RAG server with DSP query..."
    curl -s "http://localhost:3002/search?q=dyson+sphere" | python3 -m json.tool || echo "RAG query failed"

    echo -e "\n2. Testing search server with physics query..."
    curl -s "http://localhost:3004/search?q=theoretical+physics" | python3 -m json.tool || echo "Search query failed"

    echo -e "\n${GREEN}✅ Example queries complete${NC}"
fi