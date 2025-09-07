#!/bin/bash

# Quick test script for DSP Documentation Agent
# Run this to verify all components are working

echo "======================================"
echo "DSP Documentation Agent Test Suite"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name=$1
    local test_command=$2
    local expected_pattern=$3
    
    echo -n "Testing $test_name... "
    
    if result=$($test_command 2>&1); then
        if echo "$result" | grep -q "$expected_pattern" 2>/dev/null || [ -z "$expected_pattern" ]; then
            echo -e "${GREEN}✓ PASSED${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            return 0
        else
            echo -e "${YELLOW}⚠ OUTPUT MISMATCH${NC}"
            echo "  Expected pattern: $expected_pattern"
            echo "  Got: ${result:0:100}..."
            TESTS_FAILED=$((TESTS_FAILED + 1))
            return 1
        fi
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  Error: $result"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

echo "1. Docker Environment Tests"
echo "----------------------------"

run_test "Docker is running" \
    "docker info" \
    "Server Version"

run_test "Docker Compose installed" \
    "docker-compose --version" \
    "docker-compose version"

echo ""
echo "2. MCP Server Tests"
echo "-------------------"

cd docker 2>/dev/null || cd /Users/laura/Documents/github-projects/dyson-sphere-facts/docker

run_test "Qdrant container" \
    "docker ps --format '{{.Names}}' | grep dsp-qdrant" \
    "dsp-qdrant"

run_test "Qdrant port 6333" \
    "nc -zv localhost 6333 2>&1" \
    "succeeded"

run_test "MCP RAGDocs container" \
    "docker ps --format '{{.Names}}' | grep dsp-mcp-ragdocs" \
    "dsp-mcp-ragdocs"

run_test "MCP wrapper script" \
    "[ -x ./mcp-query.sh ] && echo 'executable'" \
    "executable"

echo ""
echo "3. SSH Connection Tests (from VM)"
echo "----------------------------------"

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    echo "Running from SSH/VM environment"
    
    run_test "SSH to Docker host" \
        "ssh -o ConnectTimeout=5 laura@host.docker.internal 'echo connected' 2>&1" \
        "connected"
    
    run_test "SSH Docker access" \
        "ssh -o ConnectTimeout=5 laura@host.docker.internal 'docker ps' 2>&1" \
        "CONTAINER"
else
    echo "Not in VM - skipping SSH tests"
fi

echo ""
echo "4. n8n Tests"
echo "------------"

run_test "n8n installed" \
    "which n8n" \
    "/n8n"

run_test "n8n port 5678" \
    "lsof -i :5678 2>/dev/null | grep LISTEN" \
    "5678"

echo ""
echo "5. API Key Tests"
echo "----------------"

if [ -f .env ]; then
    run_test "Environment file exists" \
        "[ -f .env ] && echo 'exists'" \
        "exists"
    
    run_test "OpenAI key configured" \
        "grep -q 'OPENAI_API_KEY=sk-' .env && echo 'configured'" \
        "configured"
    
    run_test "Anthropic key configured" \
        "grep -q 'ANTHROPIC_API_KEY=sk-ant-' .env && echo 'configured'" \
        "configured"
else
    echo -e "${YELLOW}Warning: .env file not found${NC}"
fi

echo ""
echo "6. Documentation Tests"
echo "----------------------"

run_test "Docs directory exists" \
    "[ -d ../docs ] && echo 'exists'" \
    "exists"

run_test "Setup guide exists" \
    "[ -f ../SETUP.md ] && echo 'exists'" \
    "exists"

echo ""
echo "======================================"
echo "Test Results Summary"
echo "======================================"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}All tests passed! Your DSP Agent is ready.${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Start MCP servers: ./docker/manage-mcp.sh start"
    echo "2. Start n8n: n8n start"
    echo "3. Import workflow from n8n/dsp-agent-workflow.json"
    echo "4. Test with: 'What are Critical Photons?'"
else
    echo -e "\n${YELLOW}Some tests failed. Please check the setup.${NC}"
    echo "Refer to SETUP.md for troubleshooting."
fi

exit $TESTS_FAILED
