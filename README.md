# DSP Documentation Agent

AI agent for Dyson Sphere Program game mechanics + real physics speculation.

## Stack
- **Claudable** - Agent orchestration (free)
- **Docker Desktop** - MCP servers (Qdrant, RAG, Search)
- **MCP Inspector** - Server management

## Quick Start

```bash
# 1. Start MCP servers
cd docker && docker-compose up -d

# 2. Verify servers
../tools/docker-enum.sh

# 3. Run Claudable
cd ../claudable
npm install
npm start
```

## Endpoints
- Qdrant: http://localhost:6333/dashboard
- MCP RAG: http://localhost:3001
- MCP Search: http://localhost:3003

## Tools Available
- `tools/docker-enum.sh` - List MCP servers
- `tools/clean-env.sh` - Clean environment vars

## Test Query
"What are Critical Photons in DSP?"