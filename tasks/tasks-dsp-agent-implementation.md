# Task List: DSP Documentation & Physics Speculation Agent Implementation

## Architecture Overview

### Network Topology (Tailscale)
- **dev VM**: 100.86.15.93 - Development environment (current location)
- **Docker Host**: 100.122.20.18 - Docker Desktop with MCP servers
- **Communication**: HTTP calls via Tailscale network
- **MCP Ports**: 3001 (ragdocs), 3003 (brave-search), 3002 (reserved)

### Repository Structure
```
/github-projects/
  ├── dyson-sphere-facts/  (this repo - MCP servers & documentation)
  └── Claudable/           (external repo - chatbot interface)
```

### Integration Pattern
- **Claudable** (external) communicates with this repo's MCP servers via HTTP
- Configuration sharing via environment variables and config files
- MCP servers deployed in Docker containers on Tailscale host (100.122.20.18)
- Cross-repo setup documented for single-user deployment via Tailscale network

## Relevant Files

### Configuration & Integration
- `claudable/config.json` - MCP endpoint configuration (placeholder for Claudable integration)
- `docker/docker-compose.yml` - Docker container definitions for MCP servers
- `docker/.env` - API keys and environment variables
- `scripts/setup-claudable-integration.sh` - Script to configure Claudable connection

### Documentation & Data
- `docs/dsp-wiki/` - Directory for scraped DSP documentation
- `scripts/scrape-dsp-docs.js` - Documentation scraping script
- `data/test-questions.json` - Basic validation questions for testing

### MCP Server Configurations
- `mcp-configs/ragdocs-config.json` - RAG server configuration
- `mcp-configs/search-config.json` - Web search configuration
- `scripts/health-check.sh` - Basic MCP server health monitoring

### Testing (Simplified)
- `tests/basic-validation.js` - Minimal validation tests using test-focused agent
- `tests/mcp-connectivity.test.js` - Simple MCP server connection tests

### Notes

- Claudable is a SEPARATE repository requiring integration configuration
- MCP servers run in this repo's Docker containers
- Test-focused agent handles repository crawling and validation
- Focus on MVP simplicity for userbase of 1
- Balance: 60% game mechanics accuracy, 40% physics speculation

## Tasks

- [ ] 1.0 Configure Cross-Repository Integration
  * Status: **Ready to Execute**
  * Sub-tasks:
    - [ ] 1.1 Create `.env.example` with required variables (ANTHROPIC_API_KEY, BRAVE_API_KEY)
    - [ ] 1.2 Add simple README section: "Put Claudable repo next to this one, copy .env.example to .env"
    - [ ] 1.3 Hardcode MCP server URLs in config (http://100.122.20.18:3001, http://100.122.20.18:3003)

- [ ] 2.0 Deploy MCP Server Infrastructure
  * Status: **Ready to Execute**
  * Sub-tasks:
    - [ ] 2.1 Create basic `docker-compose.yml` with mcp-ragdocs and mcp-brave-search containers
    - [ ] 2.2 Map ports 3001 and 3003, set restart: always
    - [ ] 2.3 Test with `docker-compose up -d` and `curl 100.122.20.18:3001/health`

- [ ] 3.0 Implement Agent Communication Architecture
  * Status: **Ready to Execute**
  * Sub-tasks:
    - [ ] 3.1 Copy API keys from .env to Claudable's config.json manually
    - [ ] 3.2 Test basic HTTP call from Claudable to MCP server via Tailscale: `curl 100.122.20.18:3001/health`
    - [ ] 3.3 Add console.log statements for debugging (no fancy logging)

- [ ] 4.0 Create DSP Documentation Ingestion Pipeline
  * Status: **Ready to Execute**
  * Sub-tasks:
    - [ ] 4.1 Use wget to download 10-20 key DSP wiki pages to `docs/dsp-wiki/`
    - [ ] 4.2 Point mcp-ragdocs config to the docs folder
    - [ ] 4.3 Test with one search query: "Critical Photons"

- [ ] 5.0 Develop Agent Personality and Response System
  * Status: **Ready to Execute**
  * Sub-tasks:
    - [ ] 5.1 Write one-page system prompt in `prompts/system.txt` with fun tone examples
    - [ ] 5.2 Add prompt to Claudable config (copy-paste into config.json)
    - [ ] 5.3 Test with three example questions (game, physics, hybrid)

- [ ] 6.0 Implement Minimal Testing Framework
  * Status: **Ready to Execute**
  * Sub-tasks:
    - [ ] 6.1 Create `test.sh` script that tests Tailscale endpoints (curl 100.122.20.18:3001/health)
    - [ ] 6.2 Use existing test-agent to verify docs are indexed via Tailscale
    - [ ] 6.3 Manual verification: ask 3 questions, check responses make sense over network

- [ ] 7.0 Create MVP Deployment Process
  * Status: **Ready to Execute**
  * Sub-tasks:
    - [ ] 7.1 Write `start.sh`: docker-compose up -d && cd ../Claudable && npm start
    - [ ] 7.2 Write `stop.sh`: docker-compose down
    - [ ] 7.3 Add "Getting Started" section to README with 5 simple steps

---

*Generated for Claudable + Docker MCP implementation of DSP Documentation Agent*