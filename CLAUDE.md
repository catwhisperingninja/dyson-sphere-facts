# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a DSP (Dyson Sphere Program) Documentation & Physics Speculation Agent that combines game mechanics knowledge with theoretical physics speculation. The agent serves content creators and sci-fi writers by bridging gaming and science communication.

## Architecture

**Local Docker Desktop Setup:**
- **All services** run locally on Docker Desktop (migrated from distributed Tailscale)
- **Claudable** chatbot interface (Node.js) on localhost:3001
- **MCP servers** run in Docker containers with HTTP bridge wrappers
- **Communication** via HTTP calls to localhost ports
- **[ORCHESTRATION: Future enhancement point for workflow management]**

**Service Port Assignments (CANONICAL REFERENCE):**
- Claudable Interface: `localhost:3001`
- MCP RAG Server: `localhost:3002`
- MCP Search Server: `localhost:3004`
- Qdrant Database: `localhost:6333`
- Qdrant Admin: `localhost:6334`

**Core Components:**
- Claudable chatbot for user interface and agent coordination
- MCP RAG server (mcp-ragdocs) for DSP documentation search  
- MCP Web Search server for physics research
- Claude 3.5 Sonnet as primary LLM via Anthropic API

## Key Commands

### Claudable Operations
```bash
# Start Claudable chatbot
cd claudable && npm start

# Configure Claudable
edit claudable/config.json
```

### MCP Server Management (Local Docker Desktop)
```bash
# Test MCP server endpoints
curl http://localhost:3002/health  # RAG docs server
curl http://localhost:3004/health  # Web search server

# Docker container management
docker ps --filter "name=dsp"
docker-compose -f docker/docker-compose.yml logs -f
```

### Network Configuration
```bash
# Local service endpoints (CANONICAL REFERENCE)
CLAUDABLE_ENDPOINT="http://localhost:3001"
RAG_ENDPOINT="http://localhost:3002"
SEARCH_ENDPOINT="http://localhost:3004"
QDRANT_ENDPOINT="http://localhost:6333"

# Test network connectivity
curl $RAG_ENDPOINT/health
curl $SEARCH_ENDPOINT/health
curl $QDRANT_ENDPOINT/
```

## File Structure

**Documentation & Configuration:**
- `dsp-agent-prd.md` - Product requirements document
- `dsp-task-list.md` - Detailed implementation tasks
- `overall-dsp-tasks.md` - High-level task overview
- `setup.sh` - Setup script for SSH commands

**[WORKFLOW: Visual vs code-based workflow management]:**
- [PLACEHOLDER: Future workflow orchestration system]
- Export workflows as JSON for version control

**Planned Structure:**
- `docs/dsp-wiki/` - Scraped DSP documentation
- `docs/prompts/system-prompt.md` - Agent personality
- `mcp-configs/` - MCP server configurations
- `scripts/` - Documentation scraping and testing utilities

## Agent Personality

The agent blends game mechanics with real physics speculation in a fun, engaging tone (not academic). It references specific DSP game items while grounding speculation in actual physics research from web searches.

**Example interactions:**
- "How do Critical Photons work?" (game mechanics)
- "Could we build a real Dyson sphere?" (physics speculation)  
- "Compare game's antimatter production to real physics" (hybrid)

## Development Workflow

### **MANDATORY FIRST-MINUTE PROJECT SCAN**
Before any work, ALWAYS perform this scan sequence:

```bash
# 1. Check dependency management approach
ls pyproject.toml package.json requirements.txt 2>/dev/null

# 2. Scan for project rules
ls CLAUDE.md AGENT.md .cursor/rules/ 2>/dev/null

# 3. If pyproject.toml exists - USE POETRY EXCLUSIVELY
# 4. If package.json exists - USE NPM/YARN
# 5. If requirements.txt only - USE PIP

# Example: Poetry detection and usage
if [ -f "pyproject.toml" ]; then
    echo "✓ Poetry project detected - using poetry for all operations"
    poetry install  # Not pip install
    poetry run pytest  # Not python -m pytest
    poetry run python script.py  # Not python script.py
fi
```

### **USER FEEDBACK INTEGRATION PROTOCOL**
When user provides methodology corrections (e.g., "we always use poetry see proj rules"):

1. **IMMEDIATE PIVOT**: Stop current approach entirely, don't incrementally adjust
2. **DOCTRINE UPDATE**: Treat as fundamental methodology gap, not preference
3. **TOOL CHAIN REVERIFICATION**: Re-validate all selected tools against corrected approach
4. **SESSION RESTART**: Apply corrected methodology to all remaining work

**Critical Pattern**: User interruptions about project rules indicate missing foundational knowledge, requiring immediate comprehensive adjustment.

### **INFRASTRUCTURE STATE VERIFICATION PROTOCOL**
Before making any configuration assumptions:

1. **VERIFY ACTUAL STATE**: Use `docker ps`, `curl` tests, or direct inspection
2. **CHECK CANONICAL REFERENCES**: Consult port mappings and service endpoints above
3. **DOCUMENT DISCREPANCIES**: If config doesn't match reality, update config first
4. **VALIDATE CROSS-REFERENCES**: Ensure all files (tests, docs, configs) use consistent ports/paths

**Critical Pattern**: Infrastructure assumptions lead to integration failures. Always verify before configuring.

### **CORE WORKFLOW PHASES**
1. **[WORKFLOW: Visual vs code-based approach]** - Future workflow orchestration system
2. **MCP Server Setup** - Deploy and configure via Docker on separate host
3. **SSH Integration** - Use SSH Execute Command nodes to communicate with MCP servers
4. **Documentation Ingestion** - Scrape DSP wikis and ingest into RAG system
5. **Testing** - Validate responses across game mechanics, physics, and hybrid questions

## Restart/Recovery

Since MCP servers require frequent restarts:
- Use restart scripts on Docker host
- [RESILIENCE: Auto-restart strategy needed] - Implement health checks in future workflow system
- Configure auto-restart policies for Docker containers
- Keep backup/restore procedures for workflows and documentation
- maintain persistent with specialized codebase agents. Everytime user hits esc, default agent returns. Persistence is required.