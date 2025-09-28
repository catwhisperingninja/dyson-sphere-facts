> ⚠️ **SATIRE / HUMOR** — This repository is satirical and not a scientific resource.  
> The content is intended for entertainment and creative exploration only.

### Note on Intent
This repository was created as a playful, speculative project. Any references to scientific concepts are illustrative or humorous and should not be taken as factual. For serious research notes, please see my other repositories or contact me via my GitHub profile.

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
