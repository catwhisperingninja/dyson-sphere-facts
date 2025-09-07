# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a DSP (Dyson Sphere Program) Documentation & Physics Speculation Agent that combines game mechanics knowledge with theoretical physics speculation. The agent serves content creators and sci-fi writers by bridging gaming and science communication.

## Architecture

**Deployment Setup:**
- **n8n** runs on Parallels Mac VM (Node.js system)
- **MCP servers** run in Docker containers on separate host
- **Communication** via SSH Execute Command nodes in n8n
- **Auto-restart scripts** handle frequent MCP server relaunches

**Core Components:**
- n8n visual workflows for agent orchestration
- MCP RAG server (mcp-ragdocs) for DSP documentation search
- MCP Brave Search server for physics research
- Claude 3.5 Sonnet as primary LLM via Anthropic API

## Key Commands

### n8n Operations
```bash
# Start n8n (on Parallels VM)
npx n8n

# Access n8n interface
open http://localhost:5678
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

### SSH Commands (from n8n)
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

**n8n Workflows (stored internally by n8n):**
- Main workflow: "DSP Documentation Agent" 
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

1. **n8n Visual Development** - Most configuration happens in n8n's visual interface
2. **MCP Server Setup** - Deploy and configure via Docker on separate host
3. **SSH Integration** - Use SSH Execute Command nodes to communicate with MCP servers
4. **Documentation Ingestion** - Scrape DSP wikis and ingest into RAG system
5. **Testing** - Validate responses across game mechanics, physics, and hybrid questions

## Restart/Recovery

Since MCP servers require frequent restarts:
- Use restart scripts on Docker host
- Implement health checks in n8n workflows  
- Configure auto-restart policies for Docker containers
- Keep backup/restore procedures for workflows and documentation