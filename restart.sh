#!/bin/bash

# DSP Documentation Agent - Recovery & Restart Script
# Handles MCP server recovery, Docker container management, and system health restoration

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 DSP Documentation Agent - System Recovery${NC}"
echo "=============================================="

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to wait for endpoint with timeout
wait_for_endpoint() {
    local url="$1"
    local service="$2"
    local max_attempts=15
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

    echo -e " ${RED}❌ Timeout after ${max_attempts} attempts${NC}"
    return 1
}

# Function to check container health
check_container_health() {
    local container_name="$1"

    if ! docker ps --format "{{.Names}}" | grep -q "^${container_name}$"; then
        echo -e "${RED}❌ Container $container_name not running${NC}"
        return 1
    fi

    # Check if container is healthy (not restarting)
    local status=$(docker inspect --format "{{.State.Status}}" "$container_name" 2>/dev/null)
    if [ "$status" != "running" ]; then
        echo -e "${RED}❌ Container $container_name status: $status${NC}"
        return 1
    fi

    echo -e "${GREEN}✅ Container $container_name healthy${NC}"
    return 0
}

# Function to restart single container
restart_container() {
    local container_name="$1"
    echo -e "${YELLOW}🔄 Restarting $container_name...${NC}"

    if docker ps -a --format "{{.Names}}" | grep -q "^${container_name}$"; then
        docker restart "$container_name"
        sleep 3
    else
        echo -e "${RED}❌ Container $container_name does not exist${NC}"
        return 1
    fi
}

# Parse command line arguments
RESTART_ALL=false
RESTART_CLAUDABLE=false
FORCE_REBUILD=false
SKIP_VALIDATION=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --all|-a)
            RESTART_ALL=true
            shift
            ;;
        --claudable|-c)
            RESTART_CLAUDABLE=true
            shift
            ;;
        --rebuild|-r)
            FORCE_REBUILD=true
            shift
            ;;
        --skip-validation|-s)
            SKIP_VALIDATION=true
            shift
            ;;
        --help|-h)
            echo "DSP Agent Restart Script"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --all, -a              Restart all services (MCP + Claudable)"
            echo "  --claudable, -c        Restart only Claudable interface"
            echo "  --rebuild, -r          Force rebuild Docker containers"
            echo "  --skip-validation, -s  Skip post-restart validation"
            echo "  --help, -h             Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                     # Quick MCP server restart"
            echo "  $0 --all               # Restart everything"
            echo "  $0 --claudable         # Restart only Claudable"
            echo "  $0 --rebuild           # Force rebuild and restart"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information."
            exit 1
            ;;
    esac
done

# Check prerequisites
echo -e "\n${CYAN}📋 System Check${NC}"
echo "---------------"

if ! command_exists docker; then
    echo -e "${RED}❌ Docker not found${NC}"
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker daemon not running${NC}"
    exit 1
fi

if [ ! -d "docker" ]; then
    echo -e "${RED}❌ docker/ directory not found. Run from project root.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites OK${NC}"

# Navigate to docker directory
cd docker

# Handle different restart scenarios
if [ "$FORCE_REBUILD" = true ]; then
    echo -e "\n${YELLOW}🏗️  Force Rebuild Mode${NC}"
    echo "---------------------"

    echo "Stopping all containers..."
    docker-compose down --remove-orphans

    echo "Removing images..."
    docker-compose down --rmi local --remove-orphans

    echo "Rebuilding and starting..."
    docker-compose up -d --build

elif [ "$RESTART_ALL" = true ]; then
    echo -e "\n${YELLOW}🔄 Full System Restart${NC}"
    echo "----------------------"

    echo "Stopping all services..."
    docker-compose down

    echo "Starting all services..."
    docker-compose up -d

else
    echo -e "\n${YELLOW}🔄 MCP Server Recovery${NC}"
    echo "---------------------"

    # Check current container status
    echo "Current container status:"
    docker ps --filter "name=dsp" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" || true

    # Restart problematic containers
    containers=("dsp-qdrant" "dsp-mcp-ragdocs" "dsp-mcp-search")

    for container in "${containers[@]}"; do
        if ! check_container_health "$container"; then
            restart_container "$container"
        fi
    done
fi

# Wait for services to be ready
if [ "$SKIP_VALIDATION" != true ]; then
    echo -e "\n${YELLOW}⏳ Service Health Verification${NC}"
    echo "-----------------------------"

    # Wait for each service
    wait_for_endpoint "http://localhost:6333/" "Qdrant Database"
    wait_for_endpoint "http://localhost:3002/health" "RAG Server"
    wait_for_endpoint "http://localhost:3004/health" "Search Server"

    # Run full validation if available
    if [ -x "./validate-infrastructure.sh" ]; then
        echo -e "\n${YELLOW}🔍 Running Full Validation${NC}"
        echo "-------------------------"
        ./validate-infrastructure.sh
    fi
fi

# Return to project root
cd ..

# Handle Claudable restart if requested or in --all mode
CLAUDABLE_PATH="../Claudable"
if [ "$RESTART_CLAUDABLE" = true ] || [ "$RESTART_ALL" = true ]; then
    if [ -d "$CLAUDABLE_PATH" ]; then
        echo -e "\n${YELLOW}🤖 Restarting Claudable Interface${NC}"
        echo "---------------------------------"

        # Stop existing Claudable processes
        echo "Stopping existing Claudable processes..."
        pkill -f "node.*claudable" || true
        pkill -f "npm.*start.*claudable" || true
        sleep 2

        # Check if port is still in use
        if lsof -i :3001 >/dev/null 2>&1; then
            echo -e "${YELLOW}⚠️  Port 3001 still in use, forcing cleanup...${NC}"
            # Find and kill process using port 3001
            PID=$(lsof -ti :3001)
            if [ -n "$PID" ]; then
                kill -9 "$PID" 2>/dev/null || true
                sleep 1
            fi
        fi

        # Start Claudable
        echo "Starting Claudable..."
        (cd "$CLAUDABLE_PATH" && npm start) &
        CLAUDABLE_PID=$!

        # Wait for Claudable
        sleep 5
        if wait_for_endpoint "http://localhost:3001" "Claudable Interface"; then
            echo -e "${GREEN}✅ Claudable restarted (PID: $CLAUDABLE_PID)${NC}"
        else
            echo -e "${RED}❌ Claudable restart failed${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Claudable directory not found at $CLAUDABLE_PATH${NC}"
    fi
fi

# Final status report
echo -e "\n${GREEN}🎯 System Recovery Complete${NC}"
echo "============================"
echo
echo "📊 Service Status:"
echo "  • Qdrant Database:    http://localhost:6333/"
echo "  • RAG Server:         http://localhost:3002/health"
echo "  • Search Server:      http://localhost:3004/health"

if [ -d "$CLAUDABLE_PATH" ] && ([ "$RESTART_CLAUDABLE" = true ] || [ "$RESTART_ALL" = true ]); then
    echo "  • Claudable Interface: http://localhost:3001"
fi

echo
echo "🔍 Diagnosis Commands:"
echo "  • Check containers:    docker ps --filter 'name=dsp'"
echo "  • View logs:           docker-compose -f docker/docker-compose.yml logs -f [service]"
echo "  • Full validation:     ./docker/validate-infrastructure.sh"
echo
echo "🛠️  Troubleshooting:"
echo "  • Force rebuild:       $0 --rebuild"
echo "  • Restart everything:  $0 --all"
echo "  • Get help:            $0 --help"
echo
echo -e "${GREEN}✅ System ready for queries!${NC}"