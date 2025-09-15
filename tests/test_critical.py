#!/usr/bin/env python3
"""
SUPER-MINIMAL CRITICAL FUNCTION TESTS
No mocks, no fakes, no error handling - just binary pass/fail
Tests only what exists, not what's planned
"""

import subprocess
import json
import httpx
import asyncio
import sys


def test_docker_mcp_containers_running():
    """Test: Are the critical Docker containers running?"""
    # Check if dsp-mcp-ragdocs container exists and is running
    result = subprocess.run(
        ["docker", "ps", "--filter", "name=dsp-mcp-ragdocs", "--format", "{{.Names}}"],
        capture_output=True,
        text=True
    )
    assert "dsp-mcp-ragdocs" in result.stdout, "MCP RAG container not running"

    # Check if dsp-mcp-search container exists and is running
    result = subprocess.run(
        ["docker", "ps", "--filter", "name=dsp-mcp-search", "--format", "{{.Names}}"],
        capture_output=True,
        text=True
    )
    assert "dsp-mcp-search" in result.stdout, "MCP Search container not running"

    # Check if dsp-qdrant container exists and is running
    result = subprocess.run(
        ["docker", "ps", "--filter", "name=dsp-qdrant", "--format", "{{.Names}}"],
        capture_output=True,
        text=True
    )
    assert "dsp-qdrant" in result.stdout, "Qdrant container not running"

    print("✓ Docker containers running")


async def test_mcp_rag_endpoint_accessible():
    """Test: Can we reach the MCP RAG server?"""
    async with httpx.AsyncClient() as client:
        response = await client.get("http://localhost:3001/", timeout=5.0)
        assert response.status_code < 500, f"MCP RAG server error: {response.status_code}"

    print("✓ MCP RAG endpoint accessible")


async def test_mcp_search_endpoint_accessible():
    """Test: Can we reach the MCP Search server?"""
    async with httpx.AsyncClient() as client:
        response = await client.get("http://localhost:3003/", timeout=5.0)
        assert response.status_code < 500, f"MCP Search server error: {response.status_code}"

    print("✓ MCP Search endpoint accessible")


async def test_qdrant_endpoint_accessible():
    """Test: Can we reach Qdrant?"""
    async with httpx.AsyncClient() as client:
        response = await client.get("http://localhost:6333/", timeout=5.0)
        assert response.status_code < 500, f"Qdrant server error: {response.status_code}"

    print("✓ Qdrant endpoint accessible")


def test_claudable_config_valid():
    """Test: Is the Claudable config valid JSON?"""
    with open("/Users/dev/Documents/github-projects/dyson-sphere-facts/claudable/config.json", "r") as f:
        config = json.load(f)

    # Check critical fields exist
    assert "mcp_servers" in config, "Missing mcp_servers in config"
    assert "rag" in config["mcp_servers"], "Missing RAG server config"
    assert "search" in config["mcp_servers"], "Missing search server config"
    assert config["mcp_servers"]["rag"] == "http://localhost:3002", "Wrong RAG URL"
    assert config["mcp_servers"]["search"] == "http://localhost:3003", "Wrong search URL"

    print("✓ Claudable config valid")


def test_docker_compose_file_valid():
    """Test: Is docker-compose.yml valid?"""
    result = subprocess.run(
        ["docker-compose", "-f", "/Users/dev/Documents/github-projects/dyson-sphere-facts/docker/docker-compose.yml", "config"],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, "docker-compose.yml is invalid"

    print("✓ docker-compose.yml valid")


async def main():
    """Run all critical tests"""
    print("=" * 50)
    print("SUPER-MINIMAL CRITICAL FUNCTION TESTS")
    print("=" * 50)

    # Test 1: Docker containers
    test_docker_mcp_containers_running()

    # Test 2: Endpoints accessible
    await test_mcp_rag_endpoint_accessible()
    await test_mcp_search_endpoint_accessible()
    await test_qdrant_endpoint_accessible()

    # Test 3: Configuration files
    test_claudable_config_valid()
    test_docker_compose_file_valid()

    print("=" * 50)
    print("ALL CRITICAL TESTS PASSED")
    print("=" * 50)


if __name__ == "__main__":
    asyncio.run(main())