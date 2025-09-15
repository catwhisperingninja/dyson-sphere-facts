# Task List: DSP Documentation Agent Implementation - Local Docker Desktop Setup

## Architecture Update (September 2024)

**Current State**: Migrated to fully local Docker Desktop environment. Both repositories local.
**Network**: localhost-only, no Tailscale dependencies
**Repository Structure**:
- `/github-projects/dyson-sphere-facts/` (this repo - MCP servers)
- `/github-projects/Claudable/` (horizontal repo - generic app builder interface)
**MCP Endpoints**: http://localhost:3002 (RAG), http://localhost:3004 (Search)
**Port Allocation**: Claudable uses localhost:3001, MCP servers use 3002+ to avoid conflicts

## Relevant Files

### Docker Infrastructure & Configuration

- `docker/docker-compose.yml` - MCP server container definitions (Qdrant, mcp-ragdocs, mcp-web-search)
- `docker/.env` - API credentials (OPENAI_API_KEY, BRAVE_API_KEY)
- `../Claudable/.env` - Claudable configuration (localhost:3001)
- `../Claudable/` - Generic Next.js app builder (horizontal repository)

### RAG Implementation Options

**Current**: Custom mcp-ragdocs with Qdrant vector database
**Alternative**: Needle.app SDK for simplified managed RAG (reduces infrastructure complexity)

### Documentation & Testing

- `docs/dsp-wiki/` - Directory for scraped DSP documentation
- `scripts/scrape-dsp-docs.js` - Documentation collection script
- `tests/basic-validation.js` - Minimal validation using test-focused agent

### Notes

- Docker containers run locally via Docker Desktop
- Communication via HTTP to localhost (no network dependencies)
- Claudable is generic app builder, may need DSP-specific configuration
- Available MCP Docker images: `mcp/brave-search`, multiple RAG options
- Focus on MVP simplicity for single-user deployment

## Tasks

- [ ] 1.0 Configure Local Docker Infrastructure

  - [ ] 1.1 Update `docker-compose.yml` to use ports 3002 (RAG) and 3004 (Search) to avoid Claudable conflict
  - [ ] 1.2 Create `docker/.env` file with OPENAI_API_KEY and BRAVE_API_KEY
  - [ ] 1.3 Deploy containers: `docker-compose up -d` in docker/ directory
  - [ ] 1.4 Verify container status: `docker ps | grep dsp`
  - [ ] 1.5 Test localhost connectivity: `curl http://localhost:3002/health`
  - [ ] 1.6 Test MCP endpoints: `curl http://localhost:3004/health`
  - [ ] 1.7 Configure auto-restart policies for local development stability

- [ ] 2.0 Configure Cross-Repository Integration (Claudable + DSP MCP)

  - [ ] 2.1 **Architecture Decision**: Extend Claudable for DSP vs create standalone DSP interface
  - [ ] 2.2 Configure Claudable to connect to local MCP servers (localhost:3002, 3004)
  - [ ] 2.3 Test basic integration: Claudable → HTTP → MCP servers
  - [ ] 2.4 Configure shared API keys between repositories (OPENAI_API_KEY)
  - [ ] 2.5 Test basic query flow: User → Claudable → DSP MCP servers → Response
  - [ ] 2.6 Implement error handling for localhost HTTP connection issues

- [ ] 3.0 DSP Documentation Ingestion & RAG Implementation

  - [ ] 3.1 **RAG Architecture Decision**: mcp-ragdocs (current) vs Needle.app (managed)
  - [ ] 3.2 Create docs directory structure: `mkdir -p docs/dsp-wiki`
  - [ ] 3.3 Scrape key DSP documentation pages (10-15 essential guides)
  - [ ] 3.4 **If mcp-ragdocs**: Configure Qdrant vector database via Docker
  - [ ] 3.5 **If Needle.app**: Set up managed RAG service with SDK integration
  - [ ] 3.6 Test document ingestion and search functionality
  - [ ] 3.7 Validate retrieval quality with DSP-specific queries
  - [ ] 3.8 Create simple backup/restore process for documentation

- [ ] 4.0 Agent Personality & Response System

  - [ ] 4.1 Create system prompt emphasizing fun tone (not academic)
  - [ ] 4.2 Configure 60/40 balance: game mechanics vs physics speculation
  - [ ] 4.3 Test response quality with example interactions:
    - "How do Critical Photons work?" (game mechanics)
    - "Could we build a real Dyson sphere?" (physics speculation)
    - "Compare game antimatter to real physics" (hybrid)
  - [ ] 4.4 Implement web search integration for current physics research
  - [ ] 4.5 Validate tone consistency across query types

- [ ] 5.0 Testing & Validation (Using Test-Focused Agent)

  - [ ] 5.1 Create `tests/basic-validation.sh` script for localhost connectivity
  - [ ] 5.2 Use test-focused agent for repository crawling and system validation
  - [ ] 5.3 Test core functionality:
    - Game mechanics queries via RAG system
    - Physics speculation via web search integration
    - Hybrid responses combining both sources
  - [ ] 5.4 Validate response tone and 60/40 content balance
  - [ ] 5.5 Test MCP server restart resilience on local Docker Desktop
  - [ ] 5.6 Basic performance validation (response times acceptable for single user)

- [ ] 6.0 MVP Deployment & Documentation

  - [ ] 6.1 Create `start.sh` script to launch local Docker containers and Claudable
  - [ ] 6.2 Create `restart.sh` for MCP server recovery
  - [ ] 6.3 Write simple README with setup steps for local Docker Desktop deployment
  - [ ] 6.4 Document troubleshooting for localhost connectivity issues
  - [ ] 6.5 Create example question list for testing agent responses
  - [ ] 6.6 [ORCHESTRATION: Future enhancement - Automated health monitoring]

---

## Architecture Migration Summary

**Previous**: N8N visual workflows (never implemented), Tailscale distributed setup
**Current**: Fully local Docker Desktop deployment
**Repository Structure**: dyson-sphere-facts/ and Claudable/ as horizontal repositories
**MCP Servers**: Docker containers on localhost (ports 3002, 3004)
**Interface**: Claudable (generic app builder) running on localhost:3001

## Key Decisions Required

1. **RAG Implementation**: Custom mcp-ragdocs vs Needle.app managed service
2. **Claudable Integration**: Extend for DSP-specific features vs standalone DSP interface
3. **Port Configuration**: MCP servers use 3002+ to avoid conflict with Claudable:3001

## Available Docker Images for MCP
- `mcp/brave-search` - Web search functionality
- Multiple RAG options available in local Docker images
- Existing docker-compose.yml configured for basic setup

**Focus**: MVP simplicity for single-user deployment with test-focused agent validation
