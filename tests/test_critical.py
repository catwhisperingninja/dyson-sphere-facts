#!/usr/bin/env python3
"""
SUPER-MINIMAL CRITICAL FUNCTION TESTS
No mocks, no fakes, no error handling - just binary pass/fail
Tests only what exists, not what's planned

REAL-DATA TESTING PRINCIPLES:
- No unittest.mock, no patches, no stubs
- Every HTTP call hits real endpoints
- Every Docker command checks real containers
- Every file read accesses real filesystem
- Tests fail when infrastructure fails
"""

import subprocess
import json
import httpx
import asyncio
import sys
import os
import pytest
from pathlib import Path

# Project root for path resolution
PROJECT_ROOT = Path(__file__).parent.parent


@pytest.mark.infrastructure
def test_docker_mcp_containers_running():
    """Test: Are the critical Docker containers running?
    REAL-DATA: Uses actual docker ps commands to check live containers.
    """
    containers_to_check = [
        ("dsp-mcp-ragdocs", "MCP RAG container not running"),
        ("dsp-mcp-search", "MCP Search container not running"),
        ("dsp-qdrant", "Qdrant container not running")
    ]

    for container_name, error_msg in containers_to_check:
        result = subprocess.run(
            ["docker", "ps", "--filter", f"name={container_name}", "--format", "{{.Names}}"],
            capture_output=True,
            text=True,
            timeout=10  # Add timeout for subprocess calls
        )
        assert result.returncode == 0, f"Docker command failed: {result.stderr}"
        assert container_name in result.stdout, f"{error_msg}. Found: {result.stdout.strip()}"

    print("✓ Docker containers running")


@pytest.mark.infrastructure
@pytest.mark.asyncio
async def test_mcp_rag_endpoint_accessible():
    """Test: Can we reach the MCP RAG server?
    REAL-DATA: Makes actual HTTP request to real MCP server endpoint.
    """
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get("http://localhost:3002/", timeout=5.0)
            assert response.status_code < 500, f"MCP RAG server error: {response.status_code} - {response.text}"
        except httpx.ConnectError as e:
            assert False, f"Cannot connect to MCP RAG server at localhost:3002: {e}"
        except httpx.TimeoutException as e:
            assert False, f"MCP RAG server timeout: {e}"

    print("✓ MCP RAG endpoint accessible")


@pytest.mark.infrastructure
@pytest.mark.asyncio
async def test_mcp_search_endpoint_accessible():
    """Test: Can we reach the MCP Search server?
    REAL-DATA: Makes actual HTTP request to real MCP search endpoint.
    """
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get("http://localhost:3004/", timeout=5.0)
            assert response.status_code < 500, f"MCP Search server error: {response.status_code} - {response.text}"
        except httpx.ConnectError as e:
            assert False, f"Cannot connect to MCP Search server at localhost:3004: {e}"
        except httpx.TimeoutException as e:
            assert False, f"MCP Search server timeout: {e}"

    print("✓ MCP Search endpoint accessible")


@pytest.mark.infrastructure
@pytest.mark.asyncio
async def test_qdrant_endpoint_accessible():
    """Test: Can we reach Qdrant?
    REAL-DATA: Makes actual HTTP request to real Qdrant database.
    """
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get("http://localhost:6333/", timeout=5.0)
            assert response.status_code < 500, f"Qdrant server error: {response.status_code} - {response.text}"
        except httpx.ConnectError as e:
            assert False, f"Cannot connect to Qdrant at localhost:6333: {e}"
        except httpx.TimeoutException as e:
            assert False, f"Qdrant server timeout: {e}"

    print("✓ Qdrant endpoint accessible")


@pytest.mark.infrastructure
def test_claudable_config_valid():
    """Test: Is the Claudable config valid JSON?
    REAL-DATA: Reads actual config file from filesystem, validates real JSON structure.
    """
    config_path = PROJECT_ROOT / "claudable" / "config.json"
    assert config_path.exists(), f"Claudable config file not found at {config_path}"

    with open(config_path, "r") as f:
        config = json.load(f)

    # Check critical fields exist
    assert "mcp_servers" in config, "Missing mcp_servers in config"
    assert "rag" in config["mcp_servers"], "Missing RAG server config"
    assert "search" in config["mcp_servers"], "Missing search server config"

    # Validate actual endpoint URLs match expected ports
    expected_rag_url = "http://localhost:3002"
    expected_search_url = "http://localhost:3004"
    assert config["mcp_servers"]["rag"] == expected_rag_url, f"Wrong RAG URL: expected {expected_rag_url}, got {config['mcp_servers']['rag']}"
    assert config["mcp_servers"]["search"] == expected_search_url, f"Wrong search URL: expected {expected_search_url}, got {config['mcp_servers']['search']}"

    print("✓ Claudable config valid")


@pytest.mark.infrastructure
def test_docker_compose_file_valid():
    """Test: Is docker-compose.yml valid?
    REAL-DATA: Validates actual docker-compose.yml file using real docker-compose command.
    """
    compose_path = PROJECT_ROOT / "docker" / "docker-compose.yml"
    assert compose_path.exists(), f"docker-compose.yml not found at {compose_path}"

    result = subprocess.run(
        ["docker-compose", "-f", str(compose_path), "config"],
        capture_output=True,
        text=True,
        timeout=10
    )
    assert result.returncode == 0, f"docker-compose.yml is invalid: {result.stderr}"

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