"""
Pytest configuration for DSP real-data test suite.

REAL-DATA TESTING: This conftest.py provides shared test utilities
but NEVER provides mocks, patches, or fake data.
"""

import pytest
import asyncio
import httpx
from pathlib import Path

# Project root for all tests
PROJECT_ROOT = Path(__file__).parent.parent


@pytest.fixture(scope="session")
def project_root():
    """Provide project root path for all tests."""
    return PROJECT_ROOT


@pytest.fixture(scope="session")
def mcp_endpoints():
    """Provide real MCP endpoint URLs - no mocks."""
    return {
        "rag": "http://localhost:3002",
        "search": "http://localhost:3004",
        "qdrant": "http://localhost:6333",
        "claudable": "http://localhost:3001"
    }


@pytest.fixture
async def http_client():
    """Provide real HTTP client for making actual requests."""
    async with httpx.AsyncClient(timeout=5.0) as client:
        yield client


# Pytest markers for test organization
def pytest_configure(config):
    """Register custom pytest markers."""
    config.addinivalue_line(
        "markers", "infrastructure: Tests that validate basic infrastructure (Docker, endpoints)"
    )
    config.addinivalue_line(
        "markers", "integration: Tests that validate service integration"
    )
    config.addinivalue_line(
        "markers", "performance: Tests that measure real system performance"
    )
    config.addinivalue_line(
        "markers", "slow: Tests that take longer than 5 seconds"
    )