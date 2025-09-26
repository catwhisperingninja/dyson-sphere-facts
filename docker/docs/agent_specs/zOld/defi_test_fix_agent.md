# DEFI TEST SUITE FIX AGENT - REAL DATA ONLY 💀

## DEATH PENALTY ENFORCEMENT

**ANY MOCK DATA, CACHING, OR DECIMAL IMPORTS = IMMEDIATE TERMINATION**

## CORE PRINCIPLE: REAL API CALLS ONLY

- 25K Dune API quota available - USE IT
- Real blockchain data for all tests
- Fresh data every test run
- NO MOCK DATA EVER

## IMMEDIATE FIX PRIORITIES

### 1. ELIMINATE ALL MOCK DATA VIOLATIONS

```bash
# DELETE files with mock violations
rm -f pydantic_trader/tests/test_realtime_price.py  # Already done

# FIND remaining mock violations
grep -r "unittest.mock\|from unittest import mock\|@patch\|Mock()" pydantic_trader/tests/ --include="*.py"

# DELETE mock imports
find pydantic_trader/tests -name "*.py" -exec sed -i '' '/unittest\.mock\|from unittest import mock/d' {} \;
```

### 2. REPLACE MOCK DATA WITH REAL API CALLS

```python
# BEFORE (FORBIDDEN):
@pytest.fixture
def mock_eth_price():
    return 2850.50  # ❌ FAKE DATA

# AFTER (REQUIRED):
@pytest.fixture
async def real_eth_price():
    """Fresh ETH price from Dune API"""
    from pydantic_trader.services.realtime_price import RealtimePriceService
    service = RealtimePriceService()
    price_data = await service.get_latest_price()
    return price_data.price_usd  # ✅ REAL DATA
```

### 3. FIX DECIMAL VIOLATIONS

```python
# FORBIDDEN:
from decimal import Decimal  # ❌ DEATH PENALTY

# REQUIRED:
from pydantic_trader.profit.token_amount import TokenAmount  # ✅
```

### 4. REAL DATA TEST PATTERNS

```python
# Real Dune API integration test
@pytest.mark.asyncio
async def test_real_price_fetching():
    """Use actual Dune API - we have 25K quota"""
    from pydantic_trader.services.dune_service import DuneService

    dune = DuneService()
    result = await dune.execute_query(5447367)  # Real query ID

    assert len(result) > 0
    assert 'price_usd' in result[0]
    assert result[0]['price_usd'] > 0

# Real MCP server test
@pytest.mark.asyncio
async def test_real_mcp_integration():
    """Use actual MCP servers - they're running"""
    from pydantic_trader.mcp.smithery_cloud_client import SmitheryCloudClient

    client = SmitheryCloudClient()
    pairs = await client.call_tool("catwhisperingninja-cat-dexscreener", "get_token_pairs", {
        "tokenAddress": "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"  # USDC
    })

    assert pairs is not None
    # Test with REAL data response
```

### 5. TEST ORGANIZATION (NO MOCKS)

```bash
# Organize tests by data source, not mock level
mkdir -p pydantic_trader/tests/{dune_integration,mcp_integration,blockchain_integration}

# Move tests to correct categories
# dune_integration/: Tests using Dune API
# mcp_integration/: Tests using MCP servers
# blockchain_integration/: Tests using Web3/blockchain calls
```

### 6. RATE LIMIT HANDLING (NO BYPASS)

```python
# FORBIDDEN - Bypassing rate limits with mocks:
@pytest.fixture
def bypass_rate_limits():  # ❌ CREATES FAKE ENVIRONMENT

# REQUIRED - Respect real rate limits:
@pytest.fixture
def rate_limit_aware():
    """Adds delays between tests for real API respect"""
    import asyncio
    yield
    await asyncio.sleep(1)  # Respectful delay between real API calls
```

### 7. FIXTURES WITH REAL DATA

```python
# conftest.py - REAL DATA ONLY
@pytest.fixture(scope="session")
async def real_usdc_address():
    return "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"

@pytest.fixture(scope="session")
async def real_eth_latest_block():
    """Get actual latest block from blockchain"""
    from web3 import Web3
    w3 = Web3(Web3.HTTPProvider("https://mainnet.infura.io/v3/YOUR_KEY"))
    return w3.eth.block_number

@pytest.fixture
async def real_gas_price():
    """Current gas price from network"""
    from web3 import Web3
    w3 = Web3(Web3.HTTPProvider("https://mainnet.infura.io/v3/YOUR_KEY"))
    return w3.eth.gas_price
```

### 8. ERROR HANDLING (REAL FAILURES)

```python
@pytest.mark.asyncio
async def test_api_failure_handling():
    """Test how code handles REAL API failures"""
    # Intentionally use invalid parameters to trigger real API errors
    from pydantic_trader.services.dune_service import DuneService

    dune = DuneService()
    with pytest.raises(Exception):  # Real exception from real API
        await dune.execute_query(9999999)  # Invalid query ID
```

### 9. PERFORMANCE WITH REAL DATA

```python
@pytest.mark.asyncio
async def test_real_data_performance():
    """Measure performance with actual API calls"""
    import time

    start = time.time()
    # Make real API call
    from pydantic_trader.services.realtime_price import RealtimePriceService
    service = RealtimePriceService()
    await service.get_latest_price()

    duration = time.time() - start
    assert duration < 10.0  # Real API should respond within 10s
```

### 10. CI/CD WITH REAL APIs

```yaml
# .github/workflows/test.yml - Use real APIs in CI
name: Real Data Test Suite
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Real API Integration Tests
        env:
          DUNE_API_KEY: ${{ secrets.DUNE_API_KEY }}
          INFURA_KEY: ${{ secrets.INFURA_KEY }}
        run: |
          poetry run pytest pydantic_trader/tests/ -v
        timeout-minutes: 10 # Allow time for real API calls
```

## FORBIDDEN PATTERNS (DEATH PENALTY 💀)

```python
# These patterns trigger IMMEDIATE TERMINATION:

# Mock data
@patch('anything')  # ❌
Mock()  # ❌
return_value=fake_data  # ❌

# Caching
@cache  # ❌
@lru_cache  # ❌
cached_result  # ❌

# Decimal imports
from decimal import Decimal  # ❌
import decimal  # ❌
```

## REQUIRED PATTERNS ✅

```python
# Use real APIs
await dune_service.execute_query()  # ✅
await mcp_client.call_tool()  # ✅
web3.eth.get_block()  # ✅

# Use token_amount.py
from pydantic_trader.profit.token_amount import TokenAmount  # ✅

# Fresh data every time
# No caching - get latest data for each test  # ✅
```

## SUCCESS CRITERIA

- ✅ ZERO mock imports in any test file
- ✅ ALL tests use real API calls (Dune/MCP/Web3)
- ✅ NO Decimal imports - only token_amount.py
- ✅ Tests pass with fresh data every run
- ✅ 25K Dune quota properly utilized
- ✅ CodeRabbit approval on real-data test suite
