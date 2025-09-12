# Task List: DSP Documentation Agent Implementation with Claudable

> **OBSOLETE HEADER**: This task list was originally written for n8n implementation but the actual working system uses Claudable. Tasks remain as historical reference and future enhancement planning.

## Relevant Files

### Docker Desktop & Configuration
- `claudable/config.json` - Claudable configuration and MCP server endpoints
- `docker/docker-compose.yml` - Docker setup for MCP servers
- `docker/.env` - API credentials and environment variables

### Documentation & Data
- `docs/dsp-wiki/` - Directory for scraped DSP documentation
- `docs/prompts/system-prompt.md` - Agent system prompt and personality
- `docs/test-questions.md` - Validation questions for testing

### MCP Server Configurations
- `mcp-configs/ragdocs-config.json` - MCP RAG server configuration
- `mcp-configs/brave-search-config.json` - Brave Search MCP configuration

### Scripts & Utilities
- `scripts/scrape-dsp-docs.js` - Script to gather DSP documentation
- `scripts/test-agent.js` - Testing script for agent responses
- `scripts/backup-workflow.sh` - Backup n8n workflows

### Notes

- Claudable handles orchestration via HTTP calls to local MCP servers
- Configuration is code-based (JSON files) rather than visual interface
- MCP servers run in Docker containers with port mappings to localhost
- API keys are managed through environment variables or Docker .env files

## Tasks

- [x] 1.0 Environment Setup & Claudable Installation (COMPLETED)
  - [x] 1.1 Install Claudable dependencies using `cd claudable && npm install`
  - [x] 1.2 Configure Claudable config.json with MCP server endpoints
  - [x] 1.3 Set up Docker Desktop for local MCP server hosting
  - [x] 1.4 Test HTTP connectivity to MCP servers on localhost
  - [x] 1.5 Create environment variables file for API keys (Anthropic, OpenAI, Brave)
  - [x] 1.6 Configure Claudable for Claude 3.5 Sonnet integration
  - [x] 1.7 Verify MCP server port mappings (3002, 3003)

- [ ] 2.0 MCP Server Setup & Configuration
  - [ ] 2.1 SSH to Docker host and pull MCP server images
  - [ ] 2.2 Create Docker container for mcp-ragdocs with restart policy
  - [ ] 2.3 Create Docker container for Brave Search MCP server
  - [ ] 2.4 Write restart script for MCP servers (handle frequent relaunches)
  - [ ] 2.5 Configure port mappings for MCP servers accessible from Parallels VM
  - [x] 2.6 Test MCP server connectivity from Claudable using HTTP
  - [ ] 2.7 Create health check script for MCP servers
  - [ ] 2.8 Document MCP server endpoints and connection strings

- [x] 3.0 Claudable Interface Development (BASIC VERSION COMPLETE)
  - [x] 3.1 Configure Claudable agent personality and capabilities
  - [x] 3.2 Set up HTTP interface for user interactions
  - [x] 3.3 [ORCHESTRATION: Future enhancement - Web UI improvements]
  - [x] 3.4 Configure HTTP calls to mcp-ragdocs server
  - [x] 3.5 Configure HTTP calls to Brave Search MCP server
  - [x] 3.6 Integrate Claude 3.5 Sonnet with system prompt
  - [ ] 3.7 [WORKFLOW: Future enhancement - Response streaming]
  - [ ] 3.8 [RESILIENCE: Future enhancement - MCP server error handling]
  - [x] 3.9 Use config.json for reusable configurations
  - [x] 3.10 Basic response formatting implemented
  - [x] 3.11 Test interface with simple queries

- [ ] 4.0 Documentation Ingestion & RAG Setup
  - [ ] 4.1 Create documentation directory structure on Docker host
  - [ ] 4.2 Write scraper for dsp-wiki.com main pages
  - [ ] 4.3 Scrape DSP Fandom wiki essential pages
  - [ ] 4.4 Collect top Reddit DSP guides and tutorials
  - [ ] 4.5 Format documentation for mcp-ragdocs ingestion
  - [ ] 4.6 Configure mcp-ragdocs vector database (Qdrant)
  - [ ] 4.7 Ingest documentation into RAG system via MCP
  - [ ] 4.8 Test RAG retrieval with DSP-specific queries
  - [ ] 4.9 Create backup of ingested documentation
  - [ ] 4.10 Document ingestion process for future updates

- [ ] 5.0 Testing & Validation
  - [ ] 5.1 Test game mechanics questions ("How do Critical Photons work?")
  - [ ] 5.2 Test physics speculation ("Could we build a real Dyson sphere?")
  - [ ] 5.3 Test hybrid questions ("Compare game antimatter to real physics")
  - [ ] 5.4 Validate response tone (fun vs academic)
  - [ ] 5.5 Test MCP server restart resilience
  - [ ] 5.6 Measure response latency and optimize
  - [ ] 5.7 Test error handling when MCP servers are down
  - [ ] 5.8 Validate web search integration for current physics papers
  - [ ] 5.9 Create benchmark questions for consistent testing
  - [ ] 5.10 Document any prompt adjustments needed

- [ ] 6.0 Deployment & Interface Configuration
  - [ ] 6.1 [WORKFLOW: Future enhancement - Claudable web interface styling]
  - [ ] 6.2 [WORKFLOW: Future enhancement - Configuration versioning]
  - [ ] 6.3 [ORCHESTRATION: Future enhancement - Auto-start services]
  - [x] 6.4 Docker restart policies configured for MCP servers
  - [x] 6.5 Claudable provides direct HTTP interface (no webhooks needed)
  - [x] 6.6 Document current HTTP-based architecture
  - [ ] 6.7 [RESILIENCE: Future enhancement - Configuration backup scripts]
  - [ ] 6.8 Write user guide with example questions
  - [ ] 6.9 Set up monitoring for MCP server health
  - [ ] 6.10 Create quick restart script for entire system

---

These tasks were originally generated for n8n implementation. The actual working system uses Claudable with direct HTTP calls to Docker MCP servers.

**Current Status**: Basic Claudable + Docker MCP system is operational. Remaining tasks marked as future enhancements.