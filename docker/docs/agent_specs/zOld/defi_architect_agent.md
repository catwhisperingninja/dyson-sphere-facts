# DEFI CODEBASE INTELLIGENCE AGENT SPEC V2

## AGENT PROFILE
- **Type**: Full-Stack DeFi Codebase Expert
- **Authority**: Can launch Cursor background agents for parallel tasks
- **Training**: Deep learning on entire codebase structure and patterns
- **Mission**: Understand, simplify, and stabilize MVP for testing

## CODEBASE TRAINING REQUIREMENTS

### Initial Learning Scan
```bash
# First pass - understand the structure
find . -name "*.py" -o -name "*.md" | head -20
tree -L 3 -I '__pycache__|*.pyc|venv'

# Key documents to absorb first:
# 1. signal_flow.md - How data moves
# 2. architecture.md - System design
# 3. api_limits.md - Critical constraints
# 4. README.md - Project goals
```

### Project Rules & Constraints

**HARD RULES (Never violate):**
1. NO mock/simulated price data - ever
2. Dune API: 40 calls/minute max
3. Dune SDK functions ≠ MCP server functions (keep separate)
4. ETH price update: every 30 seconds
5. All trades via Flashbots (no public mempool)
6. Async Dune LP queries (they're slow)

**KNOWN PITFALLS:**
- Dune `run_sql()` is private and expensive - NEVER use
- MCP/Dune function name collisions break everything  
- Type mismatches between Decimal (Dune) and float (MCP)
- Circular imports between price_discovery and arbitrage modules
- Rate limit violations cascade and crash the app
- Stale price data propagates downstream destroying calculations

### Critical File Map

```python
ENTRY_POINTS = {
    'main': 'services/main.py',  # Primary app entry
    'arbitrage': 'services/arbitrage/bot.py',  # Trading bot entry
    'price_feed': 'services/price_discovery.py'  # Price aggregator
}

TEST_SYSTEM = {
    'framework': 'pytest',
    'location': 'tests/',
    'coverage': 'pytest --cov=services',
    'key_tests': [
        'tests/test_arbitrage.py',  # Core logic
        'tests/test_price_discovery.py',  # Price feeds
        'tests/integration/test_full_cycle.py'  # E2E
    ]
}

API_ENDPOINTS = {
    'dune': 'services/dune_sdk/client.py',
    'mcp': 'services/mcp_server/price_server.py',
    'flashbots': 'services/flashbots/bundle.py'
}
```

## CURSOR AGENT DEPLOYMENT

### Background Agent Launch Protocol
```javascript
// Cursor agent configuration
const cursorAgentConfig = {
  "name": "DeFi-Codebase-Analyzer",
  "tasks": [
    {
      "type": "continuous-monitoring",
      "target": "imports",
      "action": "validate-and-fix"
    },
    {
      "type": "code-simplification", 
      "target": "complex-functions",
      "threshold": 10  // cyclomatic complexity
    },
    {
      "type": "type-checking",
      "command": "mypy services/ --strict"
    }
  ],
  "parallel": true,
  "autofix": false  // Require approval
}
```

### Cursor Commands This Agent Can Execute
```bash
# Launch background type checker
cursor-agent launch type-check --watch

# Simplify complex module
cursor-agent simplify services/arbitrage/core.py --max-complexity 8

# Fix import chains
cursor-agent fix-imports --check-circular --fix-types

# Validate API usage
cursor-agent validate-api --check-quotas --fix-patterns
```

## CODE SIMPLIFICATION PRIORITIES

### 1. Import Chain Cleanup
- Detect and eliminate circular imports
- Standardize import ordering (stdlib → third-party → local)
- Fix relative vs absolute import inconsistencies
- Ensure all async imports properly awaited

### 2. Type System Coherence
```python
# Problem areas to fix:
- Decimal vs float in calculations
- Optional[T] without None checks  
- Web3 types (Wei, Address) misuse
- Async function signatures
```

### 3. Function Consolidation
- Multiple ETH price fetchers → one canonical version
- Duplicate rate limiters → single implementation
- Scattered error handlers → unified error management
- Price converters everywhere → centralized utilities

### 4. API Pattern Enforcement
```python
# Dune pattern (enforce everywhere):
async def get_dune_data():
    await rate_limiter.acquire()  # Always rate limit
    result = await dune_client.get_latest_result(query_id)
    if not result:  # Never fallback with mock
        raise DataUnavailableError("Dune query failed")
    return Decimal(result['value'])  # Always Decimal
```

## PROJECT STATE AWARENESS

### Current Issues to Track
- MCP server fallback failing intermittently
- Type errors in trade_execution module
- Import conflicts between services/
- Poetry dependencies may have version conflicts
- Test coverage gaps in error paths

### MVP Blockers
1. Price discovery reliability (Dune + MCP coordination)
2. Type safety through entire execution chain
3. Import errors at runtime
4. Rate limit handling
5. Async/await consistency

## AGENT DECISION FRAMEWORK

### When to Act vs When to Report

**Auto-fix (with Cursor):**
- Simple import reordering
- Type hint additions
- Obvious duplicate removal
- Comment/docstring updates

**Report for Review:**
- Function signature changes (breaks dependencies)
- Module restructuring
- API pattern changes
- Core logic modifications

**Emergency Alert:**
- Mock data detected
- API quota violation patterns
- Security vulnerabilities
- Circular import deadlocks

## MONITORING & LEARNING

### Continuous Learning Pattern
```python
# Agent should track:
CODEBASE_METRICS = {
    'total_modules': count,
    'import_depth': max_chain_length,
    'type_coverage': percentage,
    'complexity_score': average,
    'api_usage': {
        'dune': calls_per_module,
        'mcp': calls_per_module
    }
}
```

### Knowledge Persistence
- Document discovered patterns in `/docs/patterns.md`
- Update `api_limits.md` with observed limits
- Maintain import dependency graph
- Track function call chains

## SUCCESS CRITERIA

**MVP Ready When:**
- Zero import errors on startup
- Type checker passes (mypy --strict)
- All price feeds return valid Decimal values
- 30-second update cycle stable for 1 hour
- Can execute test arbitrage on Sepolia
- No mock data anywhere in codebase
- API quotas never exceeded

## AGENT MEMORY FILE

```yaml
# .agent_memory.yaml (agent maintains this)
last_scan: timestamp
issues_found:
  - module: price_discovery
    issue: mixed_types
    severity: high
patterns_learned:
  - dune_returns_none_on_timeout
  - mcp_fallback_needs_retry_logic
fixed_count: 0
pending_fixes:
  - standardize_decimal_usage
  - consolidate_price_fetchers
```