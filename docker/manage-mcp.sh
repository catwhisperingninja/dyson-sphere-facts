#!/bin/bash

# MCP Server Management Script for DSP Documentation Agent
# Run this on the Docker host (Mac with Docker Desktop)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}Docker is not running. Please start Docker Desktop.${NC}"
        exit 1
    fi
}

# Function to check container health
check_health() {
    local container=$1
    local status=$(docker inspect -f '{{.State.Status}}' "$container" 2>/dev/null)
    
    if [ "$status" = "running" ]; then
        echo -e "${GREEN}✓${NC} $container is running"
        return 0
    else
        echo -e "${RED}✗${NC} $container is not running (status: $status)"
        return 1
    fi
}

# Main menu
show_menu() {
    echo -e "\n${YELLOW}DSP MCP Server Manager${NC}"
    echo "========================"
    echo "1) Start all MCP servers"
    echo "2) Stop all MCP servers"
    echo "3) Restart all MCP servers"
    echo "4) Check server status"
    echo "5) View logs (all servers)"
    echo "6) View logs (specific server)"
    echo "7) Restart specific server"
    echo "8) Pull latest images"
    echo "9) Clean restart (remove data)"
    echo "0) Exit"
    echo -n "Choose option: "
}

# Function to start servers
start_servers() {
    echo -e "\n${GREEN}Starting MCP servers...${NC}"
    cd "$SCRIPT_DIR"
    
    # Check for .env file in parent directory
    if [ ! -f ../.env ]; then
        echo -e "${YELLOW}Warning: .env file not found in project root.${NC}"
        echo -e "${RED}Please create .env in project root with your API keys.${NC}"
        echo -e "Example: cp docker/.env.template ../.env${NC}"
        exit 1
    fi
    
    docker-compose --env-file ../.env up -d
    
    echo -e "\n${GREEN}Waiting for services to be ready...${NC}"
    sleep 5
    
    # Check status
    check_health "dsp-qdrant"
    check_health "dsp-mcp-ragdocs"
    check_health "dsp-mcp-docs-rag"
    check_health "dsp-mcp-search"
    
    echo -e "\n${GREEN}MCP servers started!${NC}"
    echo "Qdrant UI: http://localhost:6333/dashboard"
    echo "MCP RAGDocs: http://localhost:3001"
    echo "MCP Docs RAG: http://localhost:3002"
    echo "MCP Search: http://localhost:3003"
}

# Function to stop servers
stop_servers() {
    echo -e "\n${YELLOW}Stopping MCP servers...${NC}"
    cd "$SCRIPT_DIR"
    docker-compose --env-file ../.env down
    echo -e "${GREEN}Servers stopped.${NC}"
}

# Function to restart servers
restart_servers() {
    echo -e "\n${YELLOW}Restarting MCP servers...${NC}"
    stop_servers
    sleep 2
    start_servers
}

# Function to check status
check_status() {
    echo -e "\n${YELLOW}MCP Server Status:${NC}"
    echo "==================="
    
    check_health "dsp-qdrant"
    check_health "dsp-mcp-ragdocs"
    check_health "dsp-mcp-docs-rag"
    check_health "dsp-mcp-search"
    
    echo -e "\n${YELLOW}Port Status:${NC}"
    for port in 6333 3001 3002 3003; do
        if lsof -i :$port >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} Port $port is in use"
        else
            echo -e "${RED}✗${NC} Port $port is free"
        fi
    done
}

# Function to view logs
view_logs() {
    cd "$SCRIPT_DIR"
    docker-compose --env-file ../.env logs -f --tail=50
}

# Function to view specific server logs
view_server_logs() {
    echo "Select server:"
    echo "1) Qdrant"
    echo "2) MCP RAGDocs"
    echo "3) MCP Docs RAG"
    echo "4) MCP Search"
    read -r choice
    
    case $choice in
        1) docker logs -f --tail=50 dsp-qdrant ;;
        2) docker logs -f --tail=50 dsp-mcp-ragdocs ;;
        3) docker logs -f --tail=50 dsp-mcp-docs-rag ;;
        4) docker logs -f --tail=50 dsp-mcp-search ;;
        *) echo "Invalid choice" ;;
    esac
}

# Function to restart specific server
restart_specific() {
    echo "Select server to restart:"
    echo "1) Qdrant"
    echo "2) MCP RAGDocs"
    echo "3) MCP Docs RAG"
    echo "4) MCP Search"
    read -r choice
    
    case $choice in
        1) docker restart dsp-qdrant ;;
        2) docker restart dsp-mcp-ragdocs ;;
        3) docker restart dsp-mcp-docs-rag ;;
        4) docker restart dsp-mcp-search ;;
        *) echo "Invalid choice" ;;
    esac
}

# Function to pull latest images
pull_images() {
    echo -e "\n${YELLOW}Pulling latest images...${NC}"
    cd "$SCRIPT_DIR"
    docker-compose --env-file ../.env pull
    echo -e "${GREEN}Images updated.${NC}"
}

# Function for clean restart
clean_restart() {
    echo -e "\n${RED}WARNING: This will delete all data!${NC}"
    echo -n "Are you sure? (y/N): "
    read -r confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        cd "$SCRIPT_DIR"
        docker-compose --env-file ../.env down -v
        rm -rf qdrant_storage mcp-ragdocs-data mcp-docs-rag-data
        echo -e "${GREEN}Data cleaned. Starting fresh...${NC}"
        start_servers
    else
        echo "Cancelled."
    fi
}

# Main script
check_docker

if [ "$1" = "start" ]; then
    start_servers
elif [ "$1" = "stop" ]; then
    stop_servers
elif [ "$1" = "restart" ]; then
    restart_servers
elif [ "$1" = "status" ]; then
    check_status
elif [ "$1" = "logs" ]; then
    view_logs
else
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1) start_servers ;;
            2) stop_servers ;;
            3) restart_servers ;;
            4) check_status ;;
            5) view_logs ;;
            6) view_server_logs ;;
            7) restart_specific ;;
            8) pull_images ;;
            9) clean_restart ;;
            0) echo "Goodbye!"; exit 0 ;;
            *) echo "Invalid option" ;;
        esac
        
        echo -e "\nPress Enter to continue..."
        read
    done
fi
