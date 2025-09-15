#!/bin/bash

echo "========================================="
echo "DSP BUILD VERIFICATION SCRIPT"
echo "========================================="
echo

# Check Poetry is working
echo "1. Poetry Configuration Check:"
if poetry check; then
    echo "✅ Poetry configuration valid"
else
    echo "❌ Poetry configuration failed"
    exit 1
fi
echo

# Check Docker containers
echo "2. Docker Container Status:"
if docker ps --filter "name=dsp-" --format "{{.Names}}" | grep -q "dsp-"; then
    echo "✅ Docker containers running:"
    docker ps --filter "name=dsp-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
else
    echo "❌ Docker containers not running"
    exit 1
fi
echo

# Run critical tests
echo "3. Critical Function Tests:"
if poetry run python tests/test_critical.py; then
    echo "✅ All critical tests passed"
else
    echo "❌ Critical tests failed"
    exit 1
fi
echo

# Run pytest
echo "4. pytest Framework Test:"
if poetry run pytest tests/test_critical.py -v; then
    echo "✅ pytest framework working"
else
    echo "❌ pytest framework failed"
    exit 1
fi
echo

# Test HTTP endpoints
echo "5. HTTP Endpoint Verification:"
echo "RAG Server Health:"
curl -s http://localhost:3002/health || echo "❌ RAG endpoint failed"
echo
echo "Search Server Health:"
curl -s http://localhost:3004/health || echo "❌ Search endpoint failed"
echo
echo "Qdrant Server Health:"
curl -s http://localhost:6333/ | grep -q "qdrant" && echo "✅ Qdrant accessible" || echo "❌ Qdrant failed"
echo

echo "========================================="
echo "BUILD VERIFICATION COMPLETE"
echo "System ready for production build"
echo "========================================="