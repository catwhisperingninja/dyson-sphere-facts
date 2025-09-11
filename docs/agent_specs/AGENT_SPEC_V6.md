# AGENT SPECIFICATION V5 - SECURE ENVIRONMENT HANDLING

## 🚨 MANDATORY SETUP FOR ALL AGENTS

### Step 1: Install Poetry

```bash
curl -sSL https://install.python-poetry.org | python3 -
```

### Step 2: Add Poetry to PATH

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Step 3: Navigate to Repository Root

```bash
# This works from ANY directory in the repo:
cd $(git rev-parse --show-toplevel 2>/dev/null) || cd /home/dev/Documents/github-projects/pydantic-trader
```

### Step 4: Verify .env File Exists

```bash
ls -la .env  # MUST see .env file
# If missing, STOP and report issue immediately
```

### Step 5: Load Environment Variables SECURELY

```bash
# SECURE METHOD - Does not leak secrets to process list
# Run this BEFORE any Poetry commands:
set -a  # Enable automatic exporting
[ -f .env ] && source .env  # Source the file if it exists
set +a  # Disable automatic exporting

# Verify it loaded (shows partial key only):
echo ${DUNE_API_KEY:0:10}  # Shows first 10 chars only
```

### Step 6: Install Dependencies

```bash
poetry install
```

### Step 7: Verify Setup

```bash
poetry run python -c "import os; print('✅ Setup complete' if os.getenv('DUNE_API_KEY') else '❌ Missing env vars')"
```

---

## 📝 STANDARD OPERATING PROCEDURES

### Always Start From Repo Root

```bash
# This command works from anywhere in the repo:
cd $(git rev-parse --show-toplevel)

# Fallback if not in git repo:
cd /home/dev/Documents/github-projects/pydantic-trader
```

### Secure Environment Loading Pattern

```bash
# Always use this pattern before running any Python/Poetry commands:
cd $(git rev-parse --show-toplevel)
set -a && [ -f .env ] && source .env && set +a
```

### Running Applications

```bash
# Pattern for running any Python file:
cd $(git rev-parse --show-toplevel)
set -a && [ -f .env ] && source .env && set +a
BRANCH=$(git branch --show-current)
poetry run python [script_name].py > "output_${BRANCH}_$(date +%Y%m%d_%H%M%S).md" 2>&1
```

### Running Tests

```bash
# Pattern for running tests:
cd $(git rev-parse --show-toplevel)
set -a && [ -f .env ] && source .env && set +a
BRANCH=$(git branch --show-current)
poetry run pytest pydantic_trader/tests/[test_file] -v > "test_${BRANCH}_$(date +%Y%m%d_%H%M%S).md" 2>&1
```

---

## ⚠️ SECURITY WARNINGS

### NEVER DO THIS (Insecure Methods)

```bash
# ❌ INSECURE - Leaks secrets to process list:
export $(grep -v '^#' .env | xargs)

# ❌ INSECURE - Shows full API keys:
cat .env
echo $DUNE_API_KEY  # Full key visible

# ❌ INSECURE - Breaks on spaces/newlines:
export $(cat .env | xargs)
```

### ALWAYS DO THIS (Secure Methods)

```bash
# ✅ SECURE - No process list leak:
set -a && source .env && set +a

# ✅ SECURE - Partial verification only:
echo ${DUNE_API_KEY:0:10}

# ✅ SECURE - Check without exposing:
[ -n "$DUNE_API_KEY" ] && echo "Key loaded" || echo "Key missing"
```

---

## 🎯 AGENT RESPONSIBILITIES

### What You CAN Do

- Run `uni_handler.py` and capture output to .md files
- Run tests in `pydantic_trader/tests/` directory
- Create analysis reports in .md format
- Comment on PRs with findings
- Read and analyze existing code

### What You CANNOT Do

- Create new directories (especially not `/scripts/`)
- Modify production code files
- Use mock data, cache, or fallback values
- Run bare `pip` or `python` (always use `poetry run`)
- Expose full API keys or secrets

### Report Naming Convention

```
[TYPE]_[DESCRIPTION]_[BRANCH]_YYYYMMDD_HHMMSS.md

Where:
- TYPE: test | run | analysis | audit
- DESCRIPTION: brief-kebab-case (e.g., duplicate-detection)
- BRANCH: git branch name (no spaces)
- TIMESTAMP: YYYYMMDD_HHMMSS format

Examples:
- test_token-math_main_20250812_143022.md
- run_arbitrage-scan_main_20250812_143022.md
- analysis_duplicate-bug_fix-refresh_20250812_143022.md
```

---

## 📋 COMMON ISSUES & SOLUTIONS

### Issue: "DUNE_API_KEY not found"

```bash
# Solution - reload environment:
cd $(git rev-parse --show-toplevel)
set -a && [ -f .env ] && source .env && set +a
```

### Issue: "Not in a git repository"

```bash
# Solution - use absolute path:
cd /home/dev/Documents/github-projects/pydantic-trader
```

### Issue: "poetry: command not found"

```bash
# Solution - add to PATH:
export PATH="$HOME/.local/bin:$PATH"
```

### Issue: Can't find .env file

```bash
# Check you're in right location:
pwd  # Should show .../pydantic-trader
ls -la .env  # Should show the file
```

---

## ✅ QUICK REFERENCE CARD

```bash
# 1. Go to repo root (works from anywhere):
cd $(git rev-parse --show-toplevel)

# 2. Load environment securely:
set -a && [ -f .env ] && source .env && set +a

# 3. Run with output capture:
BRANCH=$(git branch --show-current)
poetry run python uni_handler.py > "run_description_${BRANCH}_$(date +%Y%m%d_%H%M%S).md" 2>&1

# 4. Check it worked:
ls -la *.md  # See your output file
```

## Zero Tolerance Rules

- NO mock data - use real Dune data or return empty
- NO fallback values - fail fast with clear errors
- NO cache layers - always fetch fresh data
- USE Poetry for everything - never bare pip/python

---

## MCP Server Tools Available

- **Uniswap Pools MCP**: `get_token_pools`, `get_pool_data`
- **HTTP Gateway**: http://localhost:8888 (with logging)
- **Note**: Aave MCP exists but is OUT OF SCOPE for MVP
