# REAL-DATA TEST AGENT - NO MOCKS ALLOWED 🚫

## CORE ENFORCEMENT: REAL DATA OR DEATH

**ANY MOCK DATA, FAKE RESPONSES, OR STUBBED CALLS = IMMEDIATE REJECTION**

## PRIMARY DIRECTIVE: PRODUCTION-LIKE TESTING

- Call real APIs
- Use real databases
- Test against live services
- Fresh data every run
- NO MOCK DATA EVER

## FORBIDDEN PATTERNS (AUTOMATIC FAILURE)

```python
# These patterns trigger IMMEDIATE REJECTION:

# Mock imports - ALL BANNED
from unittest.mock import *  # ❌
import mock  # ❌
@patch('anything')  # ❌
Mock()  # ❌
MagicMock()  # ❌

# Fake data - ALL BANNED
fake_response = {"fake": "data"}  # ❌
test_data = "hardcoded_value"  # ❌
return_value = predetermined_result  # ❌

# Stubbing - ALL BANNED
@stub  # ❌
when().thenReturn()  # ❌
sinon.stub()  # ❌
```

## REQUIRED PATTERNS

### 1. REAL API INTEGRATION

```python
# ALWAYS use actual API endpoints
@pytest.mark.asyncio
async def test_real_api_response():
    """Test with ACTUAL API call - no mocks"""
    import httpx
    
    async with httpx.AsyncClient() as client:
        # Real API call to production or staging
        response = await client.get("https://api.actual-service.com/v1/data")
        
        # Test real response structure
        assert response.status_code == 200
        data = response.json()
        assert 'id' in data  # Real field from real API
        assert data['timestamp'] > 0  # Real timestamp
```

### 2. REAL DATABASE OPERATIONS

```python
# Use actual database - test or production replica
async def test_database_operations():
    """Test with REAL database connection"""
    # Connect to actual test database
    conn = await asyncpg.connect(
        host='real-test-db.company.com',
        database='test_db',
        user='test_user'
    )
    
    # Real query, real data
    result = await conn.fetch("SELECT * FROM users WHERE active = true")
    assert len(result) > 0  # Real records
    
    await conn.close()
```

### 3. REAL FILE OPERATIONS

```python
# Use actual filesystem
def test_file_processing():
    """Test with REAL files on disk"""
    import tempfile
    import os
    
    # Create real temp file
    with tempfile.NamedTemporaryFile(mode='w', delete=False) as f:
        f.write("actual test content")
        temp_path = f.name
    
    # Process real file
    result = process_file(temp_path)
    assert result.success
    
    # Clean up real file
    os.unlink(temp_path)
```

### 4. REAL SERVICE INTEGRATION

```python
# Test actual service communication
async def test_service_integration():
    """Services must actually talk to each other"""
    # Start real service instances
    service_a = await ServiceA.start(port=8001)
    service_b = await ServiceB.start(port=8002)
    
    # Real request between services
    response = await service_a.call_service_b("/real-endpoint")
    
    assert response.status == "success"
    assert response.data is not None
    
    await service_a.stop()
    await service_b.stop()
```

### 5. REAL ERROR SCENARIOS

```python
# Trigger actual errors from real systems
async def test_real_error_handling():
    """Test how system handles REAL failures"""
    import httpx
    
    # Call with invalid parameters to trigger real API error
    async with httpx.AsyncClient() as client:
        response = await client.get(
            "https://api.service.com/v1/user/99999999"  # Non-existent user
        )
        
        assert response.status_code == 404
        error = response.json()
        assert error['error'] == 'User not found'  # Real error message
```

### 6. REAL AUTHENTICATION

```python
# Use actual auth tokens and sessions
async def test_real_authentication():
    """Test with REAL authentication flow"""
    # Get real token from auth service
    auth_response = await authenticate(
        username="test_user_real",
        password=os.getenv("TEST_USER_PASSWORD")  # Real password
    )
    
    token = auth_response.token
    
    # Use real token for protected endpoint
    headers = {"Authorization": f"Bearer {token}"}
    response = await client.get("/protected", headers=headers)
    
    assert response.status_code == 200
```

### 7. REAL RATE LIMITS

```python
# Respect actual API rate limits
async def test_rate_limit_handling():
    """Test against REAL rate limits"""
    import asyncio
    
    responses = []
    for i in range(100):  # Trigger real rate limit
        response = await call_api("/endpoint")
        responses.append(response)
        
        if response.status_code == 429:  # Real rate limit hit
            retry_after = int(response.headers.get('Retry-After', 1))
            await asyncio.sleep(retry_after)  # Real wait time
    
    # Verify rate limit was actually encountered
    rate_limited = [r for r in responses if r.status_code == 429]
    assert len(rate_limited) > 0
```

## TEST ORGANIZATION

```bash
# Organize by real data source
tests/
├── api_integration/      # Real API tests
├── database_integration/ # Real DB tests  
├── service_integration/  # Real service tests
├── filesystem_tests/     # Real file operations
├── network_tests/        # Real network conditions
└── performance_tests/    # Real load testing
```

## ENVIRONMENT CONFIGURATION

```yaml
# test_config.yml - Real endpoints only
test:
  api_base_url: "https://staging-api.company.com"  # Real staging
  database_url: "postgresql://test-db.company.com/testdb"  # Real test DB
  redis_url: "redis://test-redis.company.com:6379"  # Real Redis
  
production_replica:
  api_base_url: "https://api.company.com"  # Real production (read-only)
  database_url: "postgresql://read-replica.company.com/prod"  # Read replica
```

## CI/CD CONFIGURATION

```yaml
# .github/workflows/test.yml
name: Real Data Test Suite
on: [push, pull_request]

jobs:
  real-tests:
    runs-on: ubuntu-latest
    services:
      postgres:  # Real database container
        image: postgres:14
        env:
          POSTGRES_PASSWORD: real_password
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
      
      redis:  # Real Redis container
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
    
    steps:
      - uses: actions/checkout@v2
      
      - name: Run Real Integration Tests
        env:
          API_KEY: ${{ secrets.REAL_API_KEY }}
          DB_CONNECTION: ${{ secrets.REAL_DB_CONNECTION }}
        run: |
          pytest tests/ -v --no-mock-allowed
        timeout-minutes: 30  # Allow time for real operations
```

## VERIFICATION CHECKLIST

Before ANY test is accepted:

- ✅ ZERO mock/patch/stub imports
- ✅ ALL external calls go to real endpoints
- ✅ Database tests use real database
- ✅ File tests use real filesystem
- ✅ Network tests use real network conditions
- ✅ Auth tests use real authentication
- ✅ Error tests trigger real errors
- ✅ Tests pass with fresh data every run

## SUCCESS CRITERIA

1. **No Mock Detection**: `grep -r "mock\|Mock\|patch\|stub" tests/` returns NOTHING
2. **Real Endpoints**: All HTTP calls point to actual URLs
3. **Fresh Data**: Each test run gets different timestamps/IDs
4. **Real Failures**: Tests can actually fail from real issues
5. **Production-Like**: Test environment mirrors production

## CACHING REQUIREMENTS (IF ABSOLUTELY NECESSARY)

### STRICT CACHE RULES - VIOLATE = REJECTION

```python
# IF you MUST implement caching:

class StrictCache:
    """DOCUMENTED CACHE - EASY TO FIND AND REMOVE"""
    def __init__(self):
        self.cache = {}
        self.timestamps = {}
        self.max_age_seconds = 30  # SHORT TTL ONLY
    
    def get(self, key):
        """MUST CHECK: Is data fresh? Is it duplicated?"""
        # DEDUPLICATION CHECK
        if key in self.cache:
            # AGE CHECK - NO OLD DATA EVER
            if time.time() - self.timestamps[key] > self.max_age_seconds:
                del self.cache[key]  # DELETE STALE DATA
                del self.timestamps[key]
                return None  # FORCE FRESH FETCH
            
            # LOG CACHE HIT FOR MONITORING
            logger.warning(f"CACHE HIT: {key} - age: {time.time() - self.timestamps[key]}s")
            return self.cache[key]
        return None
    
    def set(self, key, value):
        """MUST VALIDATE: No duplicates, timestamp everything"""
        # CHECK FOR DUPLICATE DATA
        for existing_key, existing_value in self.cache.items():
            if existing_value == value and existing_key != key:
                logger.error(f"DUPLICATE DATA DETECTED: {key} matches {existing_key}")
                
        self.cache[key] = value
        self.timestamps[key] = time.time()

# REQUIRED DOCUMENTATION AT EVERY CACHE POINT:
# TODO: CACHE HERE - REMOVE FOR PRODUCTION
# WARNING: CACHED DATA - MAX AGE 30 SECONDS
# CACHE LOCATION: Easy grep target for removal
```

### NO CACHE PROMISE = NO CACHE ALLOWED

If you cannot guarantee:
- ✅ Deduplication checks on every write
- ✅ Timestamp validation on every read  
- ✅ Automatic expiration of stale data
- ✅ Clear documentation at cache points
- ✅ Easy to find and remove

**THEN NO CACHING ALLOWED**

## CODERABBIT INTEGRATION

### PR REVIEW AUTOMATION

```yaml
# .github/coderabbit.yml
reviews:
  auto_review:
    enabled: true
    level: "comprehensive"
    
  unresolved_comments:
    track: true
    assume_latest_commit: true  # CRITICAL: Only latest commit matters
    
  impact_documentation:
    high_severity_requires: "IMPACT.md"
```

### HANDLING CODERABBIT COMMENTS

```python
# When CodeRabbit flags an issue:

def handle_coderabbit_comment(comment):
    """Process unresolved CodeRabbit comments"""
    
    # ASSUMPTION: Comment is on MOST RECENT COMMIT ONLY
    if comment.commit != latest_commit:
        return  # Skip old comments
    
    if comment.severity == "HIGH" and comment.unresolved:
        # DO NOT AUTO-FIX - DOCUMENT IMPACT
        impact_file = f"{date}_{commit_id[:7]}_{branch}_IMPACT.md"
        
        with open(impact_file, 'w') as f:
            f.write(f"""# HIGH IMPACT ISSUE DETECTED

**Date**: {date}
**Commit**: {commit_id}
**Branch**: {branch}

## CodeRabbit Finding
{comment.description}

## Potential Impact
{comment.impact_analysis}

## ACTION REQUIRED
Manual review needed before proceeding.
DO NOT PERFORM automated fix.
""")
        
        raise Exception(f"High impact issue documented in {impact_file}")
```

## MCP INTEGRATION VIA CURSOR

### STANDARD MCP INTERACTION PATTERN

```python
# Standard way to interact with MCP servers in Cursor

from mcp import Client
import asyncio

class MCPInterface:
    """Standard MCP client for Cursor-connected servers"""
    
    def __init__(self):
        # Cursor MCP servers (auto-discovered)
        self.cursor_servers = self._discover_cursor_servers()
        
        # Docker Desktop MCP servers on LAN
        self.docker_servers = self._discover_docker_servers()
        
    async def call_tool(self, server_name: str, tool_name: str, params: dict):
        """Call any MCP tool through Cursor"""
        
        # Try Cursor-integrated servers first
        if server_name in self.cursor_servers:
            client = self.cursor_servers[server_name]
            return await client.call_tool(tool_name, params)
        
        # Fallback to Docker Desktop servers
        if server_name in self.docker_servers:
            client = self.docker_servers[server_name]
            return await client.call_tool(tool_name, params)
        
        raise ValueError(f"MCP server {server_name} not found")
    
    def _discover_cursor_servers(self):
        """Auto-discover Cursor MCP integrations"""
        # Cursor provides: Context7, Sequoia AI, repo connections
        return {
            'context7': Client('cursor://context7'),
            'sequoia': Client('cursor://sequoia'),
            'repo': Client('cursor://current-repo')
        }
    
    def _discover_docker_servers(self):
        """Discover Docker Desktop MCP servers on LAN"""
        # PLACEHOLDER: Add exact Docker MCP discovery here
        # Docker Desktop runs MCP containers accessible via:
        # - Service discovery 