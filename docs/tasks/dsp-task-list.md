# Task List: DSP Documentation Agent Implementation with n8n

## Relevant Files

### Docker Desktop & Workflows
- `~/.n8n/workflows/dsp-agent-workflow.json` - Main n8n workflow definition
- `~/.n8n/credentials.json` - API credentials storage (auto-managed by n8n)
- `docker-compose.yml` - Docker setup for n8n (if using Docker deployment)

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

- n8n stores workflows internally but they can be exported as JSON for version control
- Most configuration happens visually in n8n's interface, reducing the need for code files
- MCP servers run as separate processes that n8n connects to via Execute Command nodes
- Use environment variables in n8n for API keys (Anthropic, OpenAI, Brave)

## Tasks

- [ ] 1.0 Environment Setup & n8n Installation
  - [ ] 1.1 Install n8n on Parallels Desktop Mac Sequoia VM using `npx n8n`
  - [ ] 1.2 Configure n8n data folder and port settings (default: localhost:5678)
  - [ ] 1.3 Set up SSH connection from Parallels VM to Docker host system
  - [ ] 1.4 Test SSH connectivity and command execution to Docker host
  - [ ] 1.5 Create environment variables file for API keys (Anthropic, OpenAI, Brave)
  - [ ] 1.6 Configure n8n credentials for Claude 3.5 Sonnet and backup models
  - [ ] 1.7 Install n8n community nodes if needed (n8n-nodes-base should suffice)

- [ ] 2.0 MCP Server Setup & Configuration
  - [ ] 2.1 SSH to Docker host and pull MCP server images
  - [ ] 2.2 Create Docker container for mcp-ragdocs with restart policy
  - [ ] 2.3 Create Docker container for Brave Search MCP server
  - [ ] 2.4 Write restart script for MCP servers (handle frequent relaunches)
  - [ ] 2.5 Configure port mappings for MCP servers accessible from Parallels VM
  - [ ] 2.6 Test MCP server connectivity from n8n using SSH Execute Command
  - [ ] 2.7 Create health check script for MCP servers
  - [ ] 2.8 Document MCP server endpoints and connection strings

- [ ] 3.0 n8n Workflow Development
  - [ ] 3.1 Create new workflow: "DSP Documentation Agent"
  - [ ] 3.2 Add Webhook trigger node for API access
  - [ ] 3.3 Add Chat trigger node for n8n's built-in chat interface
  - [ ] 3.4 Create SSH Execute Command node for mcp-ragdocs queries
  - [ ] 3.5 Create SSH Execute Command node for Brave Search MCP
  - [ ] 3.6 Add Claude (Anthropic) node with system prompt
  - [ ] 3.7 Configure response streaming for better UX
  - [ ] 3.8 Add error handling nodes for MCP server failures
  - [ ] 3.9 Create workflow variables for reusable configurations
  - [ ] 3.10 Add response formatting node for clean output
  - [ ] 3.11 Test workflow with simple queries

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
  - [ ] 6.1 Configure n8n's built-in chat interface styling
  - [ ] 6.2 Set up n8n workflow auto-save and versioning
  - [ ] 6.3 Create systemd service (or launchd for Mac) for n8n auto-start
  - [ ] 6.4 Write MCP server auto-restart cron job for Docker host
  - [ ] 6.5 Configure n8n webhook for external API access
  - [ ] 6.6 Document API endpoints for future Claudable integration
  - [ ] 6.7 Create backup script for n8n workflows and credentials
  - [ ] 6.8 Write user guide with example questions
  - [ ] 6.9 Set up monitoring for MCP server health
  - [ ] 6.10 Create quick restart script for entire system

---

I have generated the high-level tasks based on the PRD. These cover the main phases of building your DSP Documentation Agent using n8n.

**Ready to generate the detailed sub-tasks? Respond with "Go" to proceed.**