#!/bin/bash

# DSP Agent Query Testing Suite
# Tests the complete system with example queries demonstrating 60/40 balance

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 DSP Agent Query Testing Suite${NC}"
echo "================================"

# Function to test query and validate response
test_query() {
    local description="$1"
    local query="$2"
    local expected_sources="$3"

    echo -e "\n${CYAN}Testing: $description${NC}"
    echo "Query: $query"
    echo "Expected sources: $expected_sources"
    echo -n "Response: "

    # Make the request and capture response
    response=$(curl -s -X POST http://localhost:3001/chat \
        -H "Content-Type: application/json" \
        -d "{\"message\":\"$query\"}" || echo "ERROR")

    if [ "$response" = "ERROR" ]; then
        echo -e "${RED}❌ Request failed${NC}"
        return 1
    fi

    # Extract response text and source counts
    response_text=$(echo "$response" | jq -r '.response // "No response"')
    rag_sources=$(echo "$response" | jq -r '.sources.rag // 0')
    search_sources=$(echo "$response" | jq -r '.sources.search // 0')

    # Validate response length (should be substantial)
    if [ ${#response_text} -lt 50 ]; then
        echo -e "${RED}❌ Response too short (${#response_text} chars)${NC}"
        return 1
    fi

    # Check source usage matches expectations
    case $expected_sources in
        "rag")
            if [ "$rag_sources" -gt 0 ] && [ "$search_sources" -eq 0 ]; then
                echo -e "${GREEN}✅ Correct sources (RAG: $rag_sources, Search: $search_sources)${NC}"
            else
                echo -e "${YELLOW}⚠️  Unexpected sources (RAG: $rag_sources, Search: $search_sources)${NC}"
            fi
            ;;
        "search")
            if [ "$search_sources" -gt 0 ] && [ "$rag_sources" -eq 0 ]; then
                echo -e "${GREEN}✅ Correct sources (RAG: $rag_sources, Search: $search_sources)${NC}"
            else
                echo -e "${YELLOW}⚠️  Unexpected sources (RAG: $rag_sources, Search: $search_sources)${NC}"
            fi
            ;;
        "both")
            if [ "$rag_sources" -gt 0 ] && [ "$search_sources" -gt 0 ]; then
                echo -e "${GREEN}✅ Correct sources (RAG: $rag_sources, Search: $search_sources)${NC}"
            else
                echo -e "${YELLOW}⚠️  Expected both sources (RAG: $rag_sources, Search: $search_sources)${NC}"
            fi
            ;;
        *)
            echo -e "${GREEN}✅ Response received (RAG: $rag_sources, Search: $search_sources)${NC}"
            ;;
    esac

    # Show first 150 characters of response
    echo "Preview: ${response_text:0:150}..."

    return 0
}

# Test basic health first
echo -e "\n${YELLOW}📋 Health Check${NC}"
echo "---------------"
health_response=$(curl -s http://localhost:3001/health)
if echo "$health_response" | jq -e '.status == "ok"' >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Agent health OK${NC}"
else
    echo -e "${RED}❌ Agent health check failed${NC}"
    echo "Response: $health_response"
    exit 1
fi

# Test game mechanics queries (should use RAG)
echo -e "\n${BLUE}🎮 Game Mechanics Queries (60% Focus)${NC}"
echo "====================================="

test_query "Critical Photons mechanics" \
    "How do Critical Photons work in DSP?" \
    "rag"

test_query "Recipe optimization" \
    "What is the most efficient antimatter production setup in DSP?" \
    "rag"

test_query "Solar sail calculations" \
    "How many Solar Sails do I need for a Dyson Sphere around a K-class star?" \
    "rag"

# Test physics speculation queries (should use search)
echo -e "\n${BLUE}🔬 Physics Speculation Queries (40% Focus)${NC}"
echo "==========================================="

test_query "Real Dyson sphere feasibility" \
    "Could we actually build a real Dyson sphere?" \
    "search"

test_query "Current antimatter research" \
    "What is the current state of real antimatter research?" \
    "search"

test_query "Space engineering papers" \
    "Are there any recent research papers on stellar engineering?" \
    "search"

# Test hybrid queries (should use both sources)
echo -e "\n${BLUE}🔀 Hybrid Queries (Game + Physics)${NC}"
echo "=================================="

test_query "Game vs reality comparison" \
    "Compare DSP antimatter production to real physics" \
    "both"

test_query "Technology assessment" \
    "How realistic are the technologies in DSP?" \
    "both"

test_query "Scale comparison" \
    "How long would it actually take to build a real Dyson sphere compared to DSP?" \
    "both"

# Test tone and personality
echo -e "\n${BLUE}🎭 Personality & Tone Tests${NC}"
echo "==========================="

test_query "Excitement test" \
    "Tell me about Critical Photons - make it exciting!" \
    "rag"

test_query "Content creator support" \
    "Give me 3 video ideas comparing DSP technologies to real physics" \
    "both"

# Performance tests
echo -e "\n${BLUE}⚡ Performance Tests${NC}"
echo "==================="

echo -n "Simple query timing: "
time_start=$(date +%s.%N)
curl -s -X POST http://localhost:3001/chat \
    -H "Content-Type: application/json" \
    -d '{"message":"What is Iron Ore used for in DSP?"}' >/dev/null
time_end=$(date +%s.%N)
duration=$(echo "$time_end - $time_start" | bc -l)
echo "${duration}s"

# Final summary
echo -e "\n${GREEN}🎯 Testing Summary${NC}"
echo "=================="
echo "✅ All test categories completed"
echo "📊 Check responses above for:"
echo "   • Appropriate source usage (RAG vs Search vs Both)"
echo "   • Fun, engaging tone (not academic)"
echo "   • Technical accuracy and game knowledge"
echo "   • 60/40 balance between game mechanics and physics"
echo
echo "🔧 If issues found:"
echo "   • Check MCP server logs: docker-compose -f docker/docker-compose.yml logs"
echo "   • Restart services: ./restart.sh"
echo "   • Review agent configuration: claudable/config.json"
echo
echo -e "${GREEN}✅ DSP Agent testing complete!${NC}"