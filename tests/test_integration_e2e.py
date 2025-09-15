#!/usr/bin/env python3
"""
END-TO-END INTEGRATION TESTS
Real-data testing of the complete DSP Documentation & Physics pipeline

REAL-DATA TESTING PRINCIPLES:
- No unittest.mock, no patches, no stubs
- Every HTTP call hits real endpoints
- Every Docker command checks real containers
- Tests fail when infrastructure fails
- Tests validate actual system behavior with real data flows
"""

import httpx
import asyncio
import pytest
import json
import subprocess
from pathlib import Path
from urllib.parse import quote

# Project root for path resolution
PROJECT_ROOT = Path(__file__).parent.parent


@pytest.mark.integration
@pytest.mark.asyncio
async def test_complete_rag_search_pipeline():
    """Test: Complete RAG search pipeline end-to-end
    REAL-DATA: Tests actual HTTP endpoints with real query processing.
    """
    test_queries = [
        "Critical Photons",
        "Dyson Sphere construction",
        "Antimatter production",
        "Space Warper technology"
    ]

    async with httpx.AsyncClient() as client:
        for query in test_queries:
            encoded_query = quote(query)
            response = await client.get(
                f"http://localhost:3002/search?query={encoded_query}",
                timeout=10.0
            )

            assert response.status_code == 200, f"RAG search failed for query '{query}': {response.status_code}"

            data = response.json()
            assert "query" in data, f"Missing 'query' field in response for '{query}'"
            assert "results" in data, f"Missing 'results' field in response for '{query}'"
            assert "status" in data, f"Missing 'status' field in response for '{query}'"
            assert data["query"] == query, f"Query mismatch: expected '{query}', got '{data['query']}'"
            assert len(data["results"]) > 0, f"No results returned for query '{query}'"

            # Validate result structure
            first_result = data["results"][0]
            assert "title" in first_result, f"Missing 'title' in result for '{query}'"
            assert "content" in first_result, f"Missing 'content' in result for '{query}'"
            assert "source" in first_result, f"Missing 'source' in result for '{query}'"

            print(f"✓ RAG search pipeline works for: {query}")


@pytest.mark.integration
@pytest.mark.asyncio
async def test_complete_web_search_pipeline():
    """Test: Complete web search pipeline end-to-end
    REAL-DATA: Tests actual HTTP endpoints with real physics query processing.
    """
    physics_queries = [
        "Dyson sphere physics",
        "antimatter propulsion physics",
        "stellar engineering physics",
        "megastructure orbital mechanics"
    ]

    async with httpx.AsyncClient() as client:
        for query in physics_queries:
            encoded_query = quote(query)
            response = await client.get(
                f"http://localhost:3004/search?query={encoded_query}",
                timeout=10.0
            )

            assert response.status_code == 200, f"Web search failed for query '{query}': {response.status_code}"

            data = response.json()
            assert "query" in data, f"Missing 'query' field in response for '{query}'"
            assert "results" in data, f"Missing 'results' field in response for '{query}'"
            assert "status" in data, f"Missing 'status' field in response for '{query}'"
            assert data["query"] == query, f"Query mismatch: expected '{query}', got '{data['query']}'"
            assert len(data["results"]) > 0, f"No results returned for query '{query}'"

            # Validate result structure
            first_result = data["results"][0]
            assert "title" in first_result, f"Missing 'title' in result for '{query}'"
            assert "content" in first_result, f"Missing 'content' in result for '{query}'"
            assert "source" in first_result, f"Missing 'source' in result for '{query}'"

            print(f"✓ Web search pipeline works for: {query}")


@pytest.mark.integration
@pytest.mark.asyncio
async def test_hybrid_agent_query_simulation():
    """Test: Simulate complete DSP agent hybrid query (60% game mechanics + 40% physics)
    REAL-DATA: Tests real coordination between RAG and search services.
    """

    # Simulate agent workflow for hybrid query
    hybrid_query = "How do Critical Photons work and could they exist in real physics?"

    async with httpx.AsyncClient() as client:
        # Step 1: Query DSP game mechanics (RAG)
        game_query = "Critical Photons mechanics"
        encoded_game_query = quote(game_query)
        rag_response = await client.get(
            f"http://localhost:3002/search?query={encoded_game_query}",
            timeout=10.0
        )

        assert rag_response.status_code == 200, f"RAG query failed: {rag_response.status_code}"
        rag_data = rag_response.json()

        # Step 2: Query real physics speculation (Web search)
        physics_query = "photon manipulation physics real applications"
        encoded_physics_query = quote(physics_query)
        search_response = await client.get(
            f"http://localhost:3004/search?query={encoded_physics_query}",
            timeout=10.0
        )

        assert search_response.status_code == 200, f"Search query failed: {search_response.status_code}"
        search_data = search_response.json()

        # Step 3: Validate hybrid response structure
        assert len(rag_data["results"]) > 0, "No game mechanics results"
        assert len(search_data["results"]) > 0, "No physics speculation results"

        # Step 4: Simulate agent response synthesis
        game_content = rag_data["results"][0]["content"]
        physics_content = search_data["results"][0]["content"]

        assert len(game_content) > 10, "Game mechanics content too short"
        assert len(physics_content) > 10, "Physics content too short"

        print(f"✓ Hybrid agent query simulation successful")
        print(f"  Game mechanics: {game_content[:100]}...")
        print(f"  Physics speculation: {physics_content[:100]}...")


@pytest.mark.integration
@pytest.mark.asyncio
async def test_concurrent_service_load():
    """Test: Multiple concurrent requests to all services
    REAL-DATA: Tests real system performance under concurrent load.
    """

    # Define concurrent test queries
    rag_queries = ["Critical Photons", "Space Warper", "Antimatter", "Dyson Sphere"]
    search_queries = ["fusion physics", "space engineering", "stellar mechanics", "quantum physics"]

    async with httpx.AsyncClient() as client:
        # Create concurrent tasks for RAG service
        rag_tasks = []
        for query in rag_queries:
            encoded_query = quote(query)
            task = client.get(f"http://localhost:3002/search?query={encoded_query}", timeout=15.0)
            rag_tasks.append(task)

        # Create concurrent tasks for search service
        search_tasks = []
        for query in search_queries:
            encoded_query = quote(query)
            task = client.get(f"http://localhost:3004/search?query={encoded_query}", timeout=15.0)
            search_tasks.append(task)

        # Execute all requests concurrently
        all_tasks = rag_tasks + search_tasks
        responses = await asyncio.gather(*all_tasks, return_exceptions=True)

        # Validate all responses
        success_count = 0
        for i, response in enumerate(responses):
            if isinstance(response, Exception):
                print(f"✗ Request {i} failed: {response}")
            else:
                assert response.status_code == 200, f"Request {i} failed with status {response.status_code}"
                data = response.json()
                assert "results" in data, f"Request {i} missing results"
                assert len(data["results"]) > 0, f"Request {i} has no results"
                success_count += 1

        assert success_count == len(all_tasks), f"Only {success_count}/{len(all_tasks)} requests succeeded"
        print(f"✓ Concurrent load test: {success_count}/{len(all_tasks)} requests successful")


@pytest.mark.integration
def test_docker_container_resource_usage():
    """Test: Check Docker container resource consumption
    REAL-DATA: Monitors actual Docker container resource usage.
    """

    containers = ["dsp-mcp-ragdocs", "dsp-mcp-search", "dsp-qdrant"]

    for container_name in containers:
        # Get container stats
        result = subprocess.run(
            ["docker", "stats", container_name, "--no-stream", "--format",
             "table {{.Container}}\\t{{.CPUPerc}}\\t{{.MemUsage}}\\t{{.MemPerc}}"],
            capture_output=True,
            text=True,
            timeout=10
        )

        assert result.returncode == 0, f"Failed to get stats for {container_name}: {result.stderr}"
        assert container_name in result.stdout, f"Container {container_name} not found in stats"

        # Parse basic stats (basic validation - not strict limits)
        lines = result.stdout.strip().split('\n')
        if len(lines) > 1:  # Header + data line
            stats_line = lines[1]
            print(f"✓ {container_name} resource usage: {stats_line}")


@pytest.mark.integration
def test_claudable_config_mcp_endpoints():
    """Test: Validate Claudable configuration matches actual running endpoints
    REAL-DATA: Cross-references config file with actual running Docker services.
    """

    # Read Claudable config
    config_path = PROJECT_ROOT / "claudable" / "config.json"
    with open(config_path, "r") as f:
        config = json.load(f)

    # Test each MCP endpoint from config
    mcp_servers = config.get("mcp_servers", {})

    for service_name, endpoint_url in mcp_servers.items():
        # Parse URL to test endpoint
        if endpoint_url.startswith("http://localhost:"):
            port = endpoint_url.split(":")[-1]

            # Test endpoint accessibility
            result = subprocess.run(
                ["curl", "-s", "-f", f"http://localhost:{port}/", "-m", "5"],
                capture_output=True,
                text=True
            )

            assert result.returncode == 0, f"Claudable config endpoint {service_name} ({endpoint_url}) is not accessible"

            # Validate response is JSON
            try:
                response_data = json.loads(result.stdout)
                assert "service" in response_data or "status" in response_data, \
                    f"Invalid response format from {service_name}"
            except json.JSONDecodeError:
                assert False, f"Non-JSON response from {service_name}: {result.stdout}"

            print(f"✓ Claudable config endpoint {service_name} accessible: {endpoint_url}")


async def main():
    """Run all integration tests"""
    print("=" * 60)
    print("END-TO-END INTEGRATION TESTS")
    print("=" * 60)

    # Test 1: RAG pipeline
    await test_complete_rag_search_pipeline()

    # Test 2: Web search pipeline
    await test_complete_web_search_pipeline()

    # Test 3: Hybrid agent simulation
    await test_hybrid_agent_query_simulation()

    # Test 4: Concurrent load
    await test_concurrent_service_load()

    # Test 5: Resource monitoring
    test_docker_container_resource_usage()

    # Test 6: Config validation
    test_claudable_config_mcp_endpoints()

    print("=" * 60)
    print("ALL INTEGRATION TESTS PASSED")
    print("=" * 60)


if __name__ == "__main__":
    asyncio.run(main())