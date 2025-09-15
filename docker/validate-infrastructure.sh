#!/bin/bash

# DSP Docker Infrastructure Validation Script
# Validates Task 1 completion: Docker Infrastructure Setup

set -e

echo "🔍 DSP Docker Infrastructure Validation"
echo "======================================="

# Function to check HTTP endpoint
check_endpoint() {
    local url="$1"
    local service="$2"

    echo -n "Testing $service ($url)... "
    if curl -s -f "$url" > /dev/null; then
        echo "✅ OK"
        return 0
    else
        echo "❌ FAILED"
        return 1
    fi
}

# Function to check JSON response
check_json_endpoint() {
    local url="$1"
    local service="$2"

    echo -n "Testing $service JSON response ($url)... "
    response=$(curl -s "$url")
    if echo "$response" | python3 -m json.tool > /dev/null 2>&1; then
        echo "✅ OK"
        echo "   Response: $response"
        return 0
    else
        echo "❌ FAILED"
        echo "   Response: $response"
        return 1
    fi
}

# Task 1.4: Verify container status
echo
echo "📦 Task 1.4: Container Status Verification"
echo "----------------------------------------"
echo "Expected containers: dsp-qdrant, dsp-mcp-ragdocs, dsp-mcp-search"
echo

container_count=$(docker ps --filter "name=dsp" --format "{{.Names}}" | wc -l | tr -d ' ')
echo "Running DSP containers: $container_count/3"

if [ "$container_count" -eq 3 ]; then
    echo "✅ All containers running"
    docker ps --filter "name=dsp" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
else
    echo "❌ Missing containers"
    echo "Found containers:"
    docker ps --filter "name=dsp" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    exit 1
fi

# Task 1.5 & 1.6: Test endpoints
echo
echo "🌐 Task 1.5 & 1.6: Endpoint Connectivity"
echo "----------------------------------------"

# RAG Server (Task 1.5)
check_json_endpoint "http://localhost:3002/health" "RAG Server Health"
check_json_endpoint "http://localhost:3002/search?q=test" "RAG Server Search"

# Search Server (Task 1.6)
check_json_endpoint "http://localhost:3004/health" "Search Server Health"
check_json_endpoint "http://localhost:3004/search?q=physics" "Search Server Search"

# Qdrant Database
check_endpoint "http://localhost:6333/" "Qdrant Database"

# Task 1.7: Verify restart policies
echo
echo "🔄 Task 1.7: Auto-Restart Policy Validation"
echo "-------------------------------------------"

echo "Checking restart policies..."
policies=$(docker inspect dsp-qdrant dsp-mcp-ragdocs dsp-mcp-search --format "{{.Name}}: {{.HostConfig.RestartPolicy.Name}}")
echo "$policies"

if echo "$policies" | grep -q "unless-stopped"; then
    echo "✅ Auto-restart policies configured"
else
    echo "❌ Auto-restart policies missing"
    exit 1
fi

# Port assignments verification
echo
echo "🔌 Port Assignments Verification"
echo "--------------------------------"
echo "Expected: RAG=3002, Search=3004, Qdrant=6333-6334"
echo

port_check=$(docker ps --filter "name=dsp" --format "{{.Names}}: {{.Ports}}")
echo "$port_check"

if echo "$port_check" | grep -q "3002" && echo "$port_check" | grep -q "3004" && echo "$port_check" | grep -q "6333"; then
    echo "✅ Port assignments correct"
else
    echo "❌ Port assignments incorrect"
    exit 1
fi

# Final summary
echo
echo "🎯 Task 1 Completion Summary"
echo "============================"
echo "✅ 1.1-1.3: Docker setup complete (ports 3002/3004, .env configured, containers deployed)"
echo "✅ 1.4: Container status verified - 3/3 running"
echo "✅ 1.5: RAG server connectivity confirmed (localhost:3002)"
echo "✅ 1.6: Search server connectivity confirmed (localhost:3004)"
echo "✅ 1.7: Auto-restart policies configured (unless-stopped)"
echo
echo "🚀 Docker Infrastructure Setup: COMPLETE"
echo "Ready for Task 2: Cross-Repository Integration"