# DSP Real-Data Test Suite

This test suite validates the Dyson Sphere Program Documentation & Physics Speculation system using **strict real-data testing principles**.

## Core Philosophy: REAL DATA OR DEATH

**ZERO TOLERANCE FOR MOCKS**

This test suite **ABSOLUTELY REJECTS** all forms of test doubles:
- ❌ `unittest.mock` and `patch` decorators
- ❌ Fake/hardcoded test data
- ❌ Stubbed responses or predetermined results
- ❌ Any form of test fakes or doubles

**ONLY REAL DATA ALLOWED**

All tests use:
- ✅ Real API calls to actual endpoints
- ✅ Live Docker containers and services
- ✅ Actual filesystem operations
- ✅ Fresh data retrieved at runtime
- ✅ Real HTTP requests with real timeouts

## Test Structure

### Infrastructure Tests (`@pytest.mark.infrastructure`)

Located in `test_critical.py` - validates basic system infrastructure:

1. **Docker Container Validation**
   - Real `docker ps` commands check live containers
   - Validates `dsp-mcp-ragdocs`, `dsp-mcp-search`, `dsp-qdrant` containers

2. **HTTP Endpoint Validation**
   - Real HTTP requests to actual endpoints
   - Tests localhost:3002 (RAG), localhost:3004 (Search), localhost:6333 (Qdrant)
   - Real connection errors and timeouts

3. **Configuration Validation**
   - Reads actual JSON config files from filesystem
   - Validates real docker-compose.yml with `docker-compose config`

### Future Test Categories

- `@pytest.mark.integration` - Service-to-service integration tests
- `@pytest.mark.performance` - Real performance measurement tests
- `@pytest.mark.slow` - Tests taking >5 seconds

## Running Tests

### Prerequisites

**CRITICAL**: Infrastructure must be running for tests to pass. This is intentional - tests fail when real systems fail.

1. Start Docker containers:
   ```bash
   cd docker && docker-compose up -d
   ```

2. Verify all services are running:
   ```bash
   docker ps | grep dsp-
   ```

### Test Execution

```bash
# Run all tests
poetry run pytest tests/

# Run only infrastructure tests
poetry run pytest tests/ -m infrastructure

# Run with verbose output
poetry run pytest tests/ -v

# Collect tests without running (useful for validation)
poetry run pytest --collect-only tests/
```

### Expected Behavior

- **When infrastructure is DOWN**: Tests fail immediately with clear error messages
- **When infrastructure is UP**: Tests pass, validating actual system state
- **Network issues**: Tests fail with real timeout/connection errors
- **Configuration problems**: Tests fail when reading actual config files

## Test File Organization

```
tests/
├── __init__.py           # Test suite documentation
├── conftest.py           # Pytest configuration (NO MOCKS)
├── test_critical.py      # Infrastructure validation tests
└── README.md            # This documentation
```

## Key Implementation Details

### Path Resolution
```python
PROJECT_ROOT = Path(__file__).parent.parent
config_path = PROJECT_ROOT / "claudable" / "config.json"
```

### Real HTTP Requests
```python
async with httpx.AsyncClient() as client:
    response = await client.get("http://localhost:3002/", timeout=5.0)
    assert response.status_code < 500
```

### Real Docker Commands
```python
result = subprocess.run(
    ["docker", "ps", "--filter", "name=dsp-mcp-ragdocs"],
    capture_output=True, text=True, timeout=10
)
```

## Error Handling Strategy

Tests provide **explicit failure messages** when real systems fail:

- Docker container not running: `"MCP RAG container not running. Found: [actual output]"`
- HTTP endpoint unreachable: `"Cannot connect to MCP RAG server at localhost:3002: [error]"`
- Config file missing: `"Claudable config file not found at [path]"`
- Timeout issues: `"MCP RAG server timeout: [error]"`

## Dependencies

All testing dependencies managed via Poetry:

```toml
[tool.poetry.group.dev.dependencies]
pytest = "^7.4.0"
pytest-asyncio = "^0.21.0"
httpx = "^0.25.0"  # For real HTTP requests
```

**NOTE**: No mock libraries in dependencies - this is intentional.

## Integration with CI/CD

These tests are designed for:
- **Development environment validation**
- **Integration testing in staging**
- **Production readiness verification**

Tests will fail in CI if infrastructure is not properly configured - this ensures real system validation.

## Adding New Tests

When adding tests, follow these principles:

1. **Real Data Only**: Every test must interact with real systems
2. **Clear Markers**: Use appropriate `@pytest.mark.*` markers
3. **Explicit Errors**: Provide clear failure messages
4. **Timeout Handling**: Add timeouts for all external calls
5. **Path Resolution**: Use `PROJECT_ROOT` for relative paths

### Example Test Template

```python
@pytest.mark.infrastructure
@pytest.mark.asyncio
async def test_new_endpoint():
    \"\"\"Test description.
    REAL-DATA: Explanation of real data interaction.
    \"\"\"
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get("http://localhost:PORT/", timeout=5.0)
            assert response.status_code < 500, f"Error: {response.status_code} - {response.text}"
        except httpx.ConnectError as e:
            assert False, f"Cannot connect: {e}"

    print("✓ Test passed")
```

---

**Remember**: If you're tempted to add mocks, patches, or fake data - **DON'T**. Fix the real system instead.