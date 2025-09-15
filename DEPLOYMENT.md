# DSP Documentation Agent - MVP Deployment Guide

## Overview

The DSP Documentation Agent combines Dyson Sphere Program game mechanics with real physics speculation, serving content creators and sci-fi writers. This guide covers complete MVP deployment for the single-user setup.

## Architecture

**Local Docker Desktop Setup:**
- **Qdrant Vector Database**: Port 6333 (document storage)
- **MCP RAG Server**: Port 3002 (DSP documentation search)
- **MCP Search Server**: Port 3004 (physics research search)
- **Claudable Interface**: Port 3001 (user interaction)

**Communication Flow:**
```
User → Claudable (3001) → HTTP → MCP Servers (3002/3004) → Claude API → Response
```

## Prerequisites

1. **Docker Desktop** - Running and accessible
2. **Node.js 18+** - For Claudable interface
3. **API Keys** - OpenAI and Brave Search (configured in `docker/.env`)
4. **Git repositories**:
   - This repository: `/path/to/dyson-sphere-facts/`
   - Claudable: `/path/to/Claudable/` (optional but recommended)

## Quick Start (Recommended)

### One-Command Deployment

```bash
./start.sh
```

This script will:
- Check all prerequisites
- Start Docker infrastructure (Qdrant + MCP servers)
- Wait for services to be ready
- Validate all endpoints
- Start Claudable interface (if available)
- Display service status and example commands

### Example Output

```
🚀 DSP Documentation Agent - MVP Deployment
=============================================

📋 Prerequisites Check
----------------------
✅ Docker found
✅ Docker daemon running
✅ Project structure valid
✅ Environment configuration found

🐳 Starting Docker Infrastructure
--------------------------------
[+] Running 4/4
 ✅ Network dsp-network        Created
 ✅ Container dsp-qdrant       Started
 ✅ Container dsp-mcp-ragdocs  Started
 ✅ Container dsp-mcp-search   Started

⏳ Waiting for Services
----------------------
Waiting for Qdrant Database (http://localhost:6333/)... ✅ Ready
Waiting for RAG Server (http://localhost:3002/health)... ✅ Ready
Waiting for Search Server (http://localhost:3004/health)... ✅ Ready

🎯 DSP Documentation Agent - Deployment Complete
=================================================

📊 Service Status:
  • Qdrant Database:    http://localhost:6333/
  • RAG Server:         http://localhost:3002/health
  • Search Server:      http://localhost:3004/health
  • Claudable Interface: http://localhost:3001

✅ System ready for DSP documentation queries!
```

## Testing the Deployment

### Health Check
```bash
curl http://localhost:3001/health
```

### Example Queries

**Game Mechanics (60%):**
```bash
curl -X POST http://localhost:3001/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"How do Critical Photons work in DSP?"}'
```

**Physics Speculation (40%):**
```bash
curl -X POST http://localhost:3001/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Could we actually build a real Dyson sphere?"}'
```

**Hybrid Questions:**
```bash
curl -X POST http://localhost:3001/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Compare DSP antimatter production to real physics research"}'
```

## Recovery & Maintenance

### Restart Options

```bash
# Quick MCP server restart
./restart.sh

# Restart everything (MCP + Claudable)
./restart.sh --all

# Restart only Claudable interface
./restart.sh --claudable

# Force rebuild Docker containers
./restart.sh --rebuild

# Get help
./restart.sh --help
```

### Manual Container Management

```bash
# Check container status
docker ps --filter "name=dsp"

# View logs
docker-compose -f docker/docker-compose.yml logs -f [service_name]

# Stop all services
docker-compose -f docker/docker-compose.yml down

# Start all services
docker-compose -f docker/docker-compose.yml up -d
```

## Configuration

### Environment Variables

**Required in `docker/.env`:**
```env
OPENAI_API_KEY=sk-your-openai-key
BRAVE_API_KEY=your-brave-search-key
```

### Claudable Configuration

**Location:** `claudable/config.json`

Key settings:
- MCP server endpoints (localhost:3002, 3004)
- Claude API model selection
- Port configuration (3001)

### Agent Personality

The agent follows a **60/40 balance**:
- **60% DSP Game Mechanics**: Items, recipes, strategies, technologies
- **40% Physics Speculation**: Real research, engineering challenges, comparisons

**Tone**: Fun and engaging (science communicator, not academic)

## File Structure

```
dyson-sphere-facts/
├── start.sh                    # 🚀 Main deployment script
├── restart.sh                  # 🔄 Recovery/restart script
├── DEPLOYMENT.md               # 📖 This guide
├── docker/
│   ├── docker-compose.yml      # 🐳 Container definitions
│   ├── .env                    # 🔑 API keys
│   └── validate-infrastructure.sh # ✅ Health validation
├── claudable/                  # 🤖 Agent interface
└── docs/                       # 📚 DSP documentation
```

## Port Allocation

| Service | Port | Purpose |
|---------|------|---------|
| Claudable | 3001 | User interface & API |
| MCP RAG | 3002 | DSP documentation search |
| MCP Search | 3004 | Physics research search |
| Qdrant | 6333 | Vector database |
| Qdrant Admin | 6334 | Database admin interface |

## Validation

### Automated Validation
```bash
./docker/validate-infrastructure.sh
```

### Manual Health Checks
```bash
# Test each endpoint
curl http://localhost:6333/               # Qdrant
curl http://localhost:3002/health         # RAG server
curl http://localhost:3004/health         # Search server
curl http://localhost:3001/health         # Claudable

# Test search functionality
curl "http://localhost:3002/search?q=dyson+sphere"
curl "http://localhost:3004/search?q=physics"
```

## Success Indicators

✅ **Deployment Successful:**
- All 3 Docker containers running
- All health endpoints return 200 OK
- Validation script passes completely
- Example queries return coherent responses
- Claudable interface accessible in browser

## Next Steps

1. **Load DSP Documentation**: Use documentation scraping to populate the RAG system
2. **Test Agent Responses**: Verify 60/40 balance and tone consistency
3. **Monitor Performance**: Check response times and resource usage
4. **Backup Configuration**: Save working `.env` and config files

## Future Enhancements

- **[ORCHESTRATION]**: Automated health monitoring and recovery
- **Documentation Pipeline**: Automated DSP wiki scraping and updates
- **Analytics**: Query pattern analysis and response quality metrics
- **Scaling**: Multi-user deployment considerations

---

**MVP Focus**: Single-user deployment with maximum simplicity and reliability.
**Userbase**: 1 (you)
**Maintenance**: Minimal - restart scripts handle most issues