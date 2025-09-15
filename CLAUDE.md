# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a DSP (Dyson Sphere Program) Documentation & Physics Speculation Agent that combines game mechanics knowledge with theoretical physics speculation. The agent serves content creators and sci-fi writers by bridging gaming and science communication.

## Architecture

**Deployment Setup:**
- **Development VM**: 100.86.15.93 (dev) - Current agent environment
- **Docker Host**: 100.122.20.18 (osx-hostname-docker-desktop) - MCP servers
- **Claudable** chatbot interface (Node.js) on dev VM
- **MCP servers** run in Docker containers on Docker host via Tailscale
- **Communication** via HTTP calls over Tailscale network (100.122.20.18:3001, 100.122.20.18:3003)
- **[ORCHESTRATION: Future enhancement point for workflow management]**

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

### MCP Server Management (Tailscale Network)
```bash
# Test Tailscale connectivity
ping 100.122.20.18

# Test MCP server endpoints
curl http://100.122.20.18:3001/health  # RAG docs server
curl http://100.122.20.18:3003/health  # Web search server

# Note: Docker commands run on host 100.122.20.18
# Access via SSH or direct console on Docker host
```

### Network Configuration
```bash
# Tailscale IPs (CRITICAL NETWORK TOPOLOGY)
DEV_VM="100.86.15.93"          # Development environment
DOCKER_HOST="100.122.20.18"    # Docker Desktop with MCP servers

# MCP Endpoints
RAG_ENDPOINT="http://100.122.20.18:3001"
SEARCH_ENDPOINT="http://100.122.20.18:3003"

# Test network connectivity
curl $RAG_ENDPOINT/health
curl $SEARCH_ENDPOINT/health
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