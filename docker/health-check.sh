#!/bin/bash

# Health check script for MCP servers
# Can be called from n8n or cron for monitoring

check_mcp_health() {
    local container=$1
    local port=$2
    local name=$3
    
    # Check if container is running
    if docker ps --format "{{.Names}}" | grep -q "^${container}$"; then
        # Check if port is responding
        if nc -z localhost "$port" 2>/dev/null; then
            echo "OK: $name is healthy"
            return 0
        else
            echo "WARNING: $name container running but port $port not responding"
            # Try to restart
            docker restart "$container" >/dev/null 2>&1
            sleep 5
            if nc -z localhost "$port" 2>/dev/null; then
                echo "RECOVERED: $name restarted successfully"
                return 0
            else
                echo "ERROR: $name failed to recover after restart"
                return 1
            fi
        fi
    else
        echo "ERROR: $name container not running"
        # Try to start it
        docker start "$container" >/dev/null 2>&1
        sleep 5
        if docker ps --format "{{.Names}}" | grep -q "^${container}$"; then
            echo "RECOVERED: $name started successfully"
            return 0
        else
            echo "ERROR: $name failed to start"
            return 1
        fi
    fi
}

# Check all services
echo "=== MCP Server Health Check ==="
echo "Time: $(date)"
echo "---"

check_mcp_health "dsp-qdrant" 6333 "Qdrant"
check_mcp_health "dsp-mcp-ragdocs" 3001 "MCP RAGDocs"
check_mcp_health "dsp-mcp-docs-rag" 3002 "MCP Docs RAG"
check_mcp_health "dsp-mcp-search" 3003 "MCP Search"

echo "---"

# Return overall status
if docker ps | grep -q "dsp-"; then
    echo "Overall: Some services running"
    exit 0
else
    echo "Overall: No services running"
    exit 1
fi
