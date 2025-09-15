# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a DSP (Dyson Sphere Program) Documentation & Physics Speculation Agent that combines game mechanics knowledge with theoretical physics speculation. The agent serves content creators and sci-fi writers by bridging gaming and science communication.

## Architecture

**Deployment Setup:**
- **Claudable** chatbot interface (Node.js) 
- **MCP servers** run in Docker containers locally via Docker Desktop
- **Communication** via direct HTTP calls to localhost MCP servers
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

### MCP Server Management (on Docker host via SSH)
```bash
# Restart MCP servers
docker restart mcp-ragdocs mcp-brave-search

# Full recreate if needed
docker-compose down && docker-compose up -d

# Test MCP server connectivity
docker exec mcp-ragdocs-container npx @hannesrudolph/mcp-ragdocs search 'Critical Photons'
```

### SSH Commands ([ORCHESTRATION: Future workflow management])
```bash
# Example MCP query via SSH Execute Command
ssh docker-host "docker exec mcp-ragdocs-container npx @hannesrudolph/mcp-ragdocs search 'Critical Photons'"
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