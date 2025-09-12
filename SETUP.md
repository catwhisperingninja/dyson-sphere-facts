# DSP Documentation Agent Setup Guide

## Architecture Overview

```
Claudable Interface (Node.js)
    ↓ HTTP
Docker Desktop (MCP Servers)
    ↓
Response back to Claudable → User
```

## Prerequisites

### System Requirements

- Docker Desktop installed and running
- Node.js 18+ installed
- Git installed
- API Keys:
  - ANTHROPIC_API_KEY (for Claude)
  - BRAVE_API_KEY (for web search)
  - OPENAI_API_KEY (for embeddings)

## Step 1: Setup Docker MCP Servers

1. **Navigate to project directory:**

```bash
cd /path/to/dyson-sphere-facts
```

2. **Configure environment:**

```bash
# Copy environment template
cp docker/.env.template docker/.env
# Edit docker/.env with your API keys:
# - OPENAI_API_KEY (for embeddings)
# - ANTHROPIC_API_KEY (for Claude)
# - BRAVE_API_KEY (for web search)
```

3. **Start MCP servers:**

```bash
cd docker
docker-compose up -d
```

4. **Verify services are running:**

```bash
../tools/docker-enum.sh
```

You should see:

- Qdrant UI at http://localhost:6333/dashboard
- MCP RAG server on port 3002
- MCP Search server on port 3003

## Step 2: Setup Claudable Interface

1. **Install Claudable dependencies:**

```bash
cd claudable
npm install
```

2. **Configure Claudable:**

The `config.json` file defines MCP server endpoints:

```json
{
  "mcp_servers": {
    "rag": "http://localhost:3002",
    "search": "http://localhost:3003"
  },
  "claude": {
    "api_key": "${ANTHROPIC_API_KEY}"
  }
}
```

3. **Test MCP server connectivity:**

```bash
# Verify Docker containers are running
../tools/docker-enum.sh
# Test endpoints directly
curl http://localhost:3002/health
curl http://localhost:3003/health
```

## Step 3: Start Claudable Agent

1. **Start Claudable:**

```bash
cd claudable
npm start
```

2. **Access the interface:**

Claudable will start a web interface (check console output for URL).

3. **Environment variables:**

Ensure your environment has the required API keys:

```bash
export ANTHROPIC_API_KEY="your-key-here"
export BRAVE_API_KEY="your-key-here"
export OPENAI_API_KEY="your-key-here"
```

4. **Test the agent:**

Try queries like:
- "What are Critical Photons in DSP?"
- "Could we actually build a Dyson sphere?"
- "Compare game antimatter to real physics"

## Step 4: Ingest DSP Documentation

1. **[ORCHESTRATION: Future enhancement - Automated documentation scraping]**

2. **Manual document ingestion:**

```bash
# Documents can be ingested via the RAG MCP server
# Direct API calls or through Claudable interface
# See MCP server documentation for ingestion methods
```

3. **Verify ingestion:**

```bash
# Check Qdrant dashboard for document collections
open http://localhost:6333/dashboard
```

## Step 5: Configure Auto-Restart (Optional)

1. **[RESILIENCE: Future enhancement - Auto-restart strategy needed]**

2. **Docker auto-restart policies:**

```bash
# Docker containers already configured with restart policies
# See docker/docker-compose.yml for current settings
```

3. **Manual restart commands:**

```bash
# Restart all MCP servers
cd docker
docker-compose restart

# Restart specific services
docker-compose restart qdrant
docker-compose restart mcp-ragdocs
```

## Step 6: Test the Complete System

1. **Via Claudable Interface:**

   - Open your browser to Claudable's web interface
   - Try test queries:
     - "How do Critical Photons work in DSP?"
     - "Could we actually build a Dyson sphere?"
     - "Compare game antimatter to real physics"

2. **Direct API testing:**

```bash
# Test MCP servers directly
curl -X POST http://localhost:3002/query \
  -H "Content-Type: application/json" \
  -d '{"query": "Critical Photons"}'
```

3. **Check logs if issues:**

```bash
# Docker container logs
docker-compose logs -f

# Specific service logs
docker-compose logs mcp-ragdocs
docker-compose logs qdrant
```

## Troubleshooting

### MCP Servers Won't Start

- Check Docker Desktop is running
- Verify ports 6333, 3001-3003 are free
- Check API keys in `.env` file
- Review logs: `docker-compose logs`

### Claudable Connection Issues

- Verify Docker containers are running: `docker ps`
- Check MCP server health endpoints
- Verify API keys are set correctly
- Test direct HTTP connections to MCP servers

### [ORCHESTRATION: Future workflow management troubleshooting]

### RAG Returns No Results

- Ensure documents are ingested
- Check Qdrant is running: http://localhost:6333
- Verify OpenAI API key for embeddings
- Check MCP server logs

## Next Steps

1. **Add more documentation:**

   - Scrape more DSP wiki pages
   - Add Reddit guides
   - Include game patch notes

2. **Optimize prompts:**

   - Test and refine system prompt
   - Add few-shot examples
   - Tune temperature settings

3. **Enhance workflow:**

   - Add conversation memory
   - Implement follow-up questions
   - Add source citations

4. **Phase 2 features:**
   - DSP Calculator integration
   - Blueprint analysis
   - Multi-agent specialization

## Useful Commands

```bash
# Mac Host - Docker Management
docker/manage-mcp.sh status    # Check all services
docker/manage-mcp.sh restart   # Restart all services
docker/manage-mcp.sh logs      # View all logs

# Claudable Management
cd claudable && npm start       # Start Claudable
npm install                    # Install dependencies
npm run dev                    # Development mode

# Testing MCP
docker/mcp-query.sh rag "Critical Photons"
docker/mcp-query.sh web "Dyson sphere cost estimate"
docker/mcp-query.sh sources
```

## Support

For issues or questions:

- Check logs first
- Verify all services are running
- Test each component individually
- Document any error messages

Good luck with your DSP Documentation Agent! 🚀
