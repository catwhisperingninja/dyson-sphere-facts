#!/bin/bash
# Docker MCP Server Enumeration - Clean and simple

echo "🔍 MCP Servers in Docker Desktop:"
echo "================================"

# List running MCP containers with their ports
docker ps --filter "name=mcp" --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}" 2>/dev/null || echo "No MCP servers running"

echo ""
echo "📊 All DSP containers:"
docker ps --filter "name=dsp" --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}" 2>/dev/null

echo ""
echo "🌐 Exposed endpoints:"
echo "  Qdrant:     http://localhost:6333/dashboard"
echo "  MCP RAG:    http://localhost:3001"
echo "  MCP Docs:   http://localhost:3002"
echo "  MCP Search: http://localhost:3003"