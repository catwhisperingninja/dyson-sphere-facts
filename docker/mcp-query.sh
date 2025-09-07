#!/bin/bash

# MCP Query Wrapper for n8n SSH Commands
# This script runs on the Docker host and interfaces with MCP servers
# n8n calls this via SSH from the Parallels VM

MCP_TYPE=$1
QUERY=$2

# Helper function for JSON escaping
json_escape() {
    echo "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\n/\\n/g; s/\r/\\r/g; s/\t/\\t/g'
}

# RAG Documentation Search
rag_search() {
    local query=$(json_escape "$1")
    
    # Try primary MCP server
    response=$(docker exec dsp-mcp-ragdocs sh -c "
        curl -s -X POST http://localhost:3000/search \
        -H 'Content-Type: application/json' \
        -d '{\"query\": \"$query\", \"limit\": 5}'
    " 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        echo "$response"
    else
        # Fallback to alternative RAG server
        docker exec dsp-mcp-docs-rag sh -c "
            curl -s -X POST http://localhost:3000/search \
            -H 'Content-Type: application/json' \
            -d '{\"query\": \"$query\"}'
        " 2>/dev/null
    fi
}

# Web Search
web_search() {
    local query=$(json_escape "$1")
    
    docker exec dsp-mcp-search sh -c "
        curl -s -X POST http://localhost:3000/search \
        -H 'Content-Type: application/json' \
        -d '{\"query\": \"$query\", \"max_results\": 5}'
    " 2>/dev/null
}

# Add document to RAG
add_document() {
    local url=$1
    local title=$(json_escape "$2")
    
    docker exec dsp-mcp-ragdocs sh -c "
        curl -s -X POST http://localhost:3000/add_document \
        -H 'Content-Type: application/json' \
        -d '{\"url\": \"$url\", \"title\": \"$title\"}'
    " 2>/dev/null
}

# List sources in RAG
list_sources() {
    docker exec dsp-mcp-ragdocs sh -c "
        curl -s -X GET http://localhost:3000/sources
    " 2>/dev/null
}

# Main logic
case "$MCP_TYPE" in
    "rag"|"docs")
        rag_search "$QUERY"
        ;;
    "web"|"search")
        web_search "$QUERY"
        ;;
    "add")
        add_document "$QUERY" "$3"
        ;;
    "sources")
        list_sources
        ;;
    "health")
        /Users/laura/Documents/github-projects/dyson-sphere-facts/docker/health-check.sh
        ;;
    *)
        echo "{\"error\": \"Unknown MCP type: $MCP_TYPE\"}"
        exit 1
        ;;
esac
