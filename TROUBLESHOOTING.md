# DSP Documentation Agent - Troubleshooting Guide

## Quick Diagnosis

### 🔍 System Health Check
```bash
# Ofne-command system validation
./docker/validate-infrastructure.sh

# Quick status check
docker ps --filter "name=dsp" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Test all endpoints
curl http://localhost:3001/health  # Agent
curl http://localhost:3002/health  # RAG
curl http://localhost:3004/health  # Search
curl http://localhost:6333/        # Qdrant
```

## Common Issues & Solutions

### 🐳 Docker Container Issues

#### Problem: Containers Not Starting
```bash
# Symptoms
docker ps --filter "name=dsp" | wc -l    # Returns less than 3

# Diagnosis
docker-compose -f docker/docker-compose.yml logs

# Solutions
./restart.sh --rebuild                    # Force rebuild
docker system prune -f                    # Clean Docker cache
docker-compose -f docker/docker-compose.yml down --volumes && \
docker-compose -f docker/docker-compose.yml up -d
```

#### Problem: Container Memory Issues
```bash
# Symptoms
Container keeps restarting, high memory usage

# Diagnosis
docker stats --filter "name=dsp"

# Solutions
# Increase Docker Desktop memory allocation (8GB recommended)
# Restart Docker Desktop
docker-compose -f docker/docker-compose.yml restart
```

#### Problem: Qdrant Storage Corruption
```bash
# Symptoms
dsp-qdrant fails to start, storage errors in logs

# Diagnosis
docker logs dsp-qdrant | grep -i error
ls -la docker/qdrant_storage/

# Solutions
# CAUTION: This deletes all stored documents
rm -rf docker/qdrant_storage/*
docker-compose -f docker/docker-compose.yml restart qdrant
```

### 🌐 Network & Port Issues

#### Problem: Port Already in Use
```bash
# Symptoms
"Port already allocated" error during startup

# Diagnosis
lsof -i :3001    # Claudable
lsof -i :3002    # RAG server
lsof -i :3004    # Search server
lsof -i :6333    # Qdrant

# Solutions
# Kill existing processes
kill $(lsof -ti :3001)    # Replace 3001 with conflicting port
./restart.sh --all        # Restart everything
```

#### Problem: Cannot Connect to MCP Servers
```bash
# Symptoms
curl requests to localhost:3002/3004 timeout or fail

# Diagnosis
docker logs dsp-mcp-ragdocs
docker logs dsp-mcp-search
curl -v http://localhost:3002/health

# Solutions
./restart.sh                              # Quick restart
docker exec dsp-mcp-ragdocs npm install   # Reinstall dependencies
docker-compose -f docker/docker-compose.yml restart mcp-ragdocs mcp-web-search
```

### 🔑 API Key & Authentication Issues

#### Problem: OpenAI API Errors
```bash
# Symptoms
"Invalid API key" or "Rate limit exceeded" in logs

# Diagnosis
grep -i "api" docker/.env
curl -H "Authorization: Bearer $(grep OPENAI_API_KEY docker/.env | cut -d= -f2)" \
  https://api.openai.com/v1/models

# Solutions
# Verify API key in docker/.env
export OPENAI_API_KEY="sk-your-key"
./restart.sh --all
```

#### Problem: Brave Search API Issues
```bash
# Symptoms
Web search requests fail, search functionality broken

# Diagnosis
grep BRAVE_API_KEY docker/.env
docker logs dsp-mcp-search | grep -i brave

# Solutions
# Check Brave API key validity
# Restart search service
docker-compose -f docker/docker-compose.yml restart mcp-web-search
```

### 🤖 Claudable Interface Issues

#### Problem: Claudable Won't Start
```bash
# Symptoms
Cannot access http://localhost:3001

# Diagnosis
cd claudable && npm list    # Check dependencies
cat claudable/.env          # Check configuration
ps aux | grep node          # Check for existing processes

# Solutions
cd claudable
npm install                 # Reinstall dependencies
rm -rf node_modules && npm install  # Clean reinstall
./restart.sh --claudable    # Use restart script
```

#### Problem: Claudable Configuration Errors
```bash
# Symptoms
"Cannot connect to MCP servers" errors in Claudable

# Diagnosis
cat claudable/config.json | grep -A 5 mcp_servers
curl http://localhost:3002/health    # Test MCP connectivity

# Solutions
# Verify MCP endpoints in config.json:
# "rag": "http://localhost:3002"
# "search": "http://localhost:3004"
./restart.sh --all
```

### 📚 RAG & Search Functionality Issues

#### Problem: No Search Results from RAG
```bash
# Symptoms
RAG searches return empty results

# Diagnosis
curl "http://localhost:3002/search?q=test"
docker exec dsp-qdrant curl http://localhost:6333/collections

# Solutions
# Check if documents are loaded in Qdrant
curl http://localhost:6333/collections/documents/points/count
# Re-ingest documentation if needed
./restart.sh --rebuild
```

#### Problem: Web Search Not Working
```bash
# Symptoms
Physics searches fail or return no results

# Diagnosis
curl "http://localhost:3004/search?q=physics"
docker logs dsp-mcp-search | tail -20

# Solutions
# Check Brave API quota and key validity
./restart.sh
# Verify internet connectivity from container
docker exec dsp-mcp-search curl https://api.search.brave.com/
```

## Performance Troubleshooting

### 🐌 Slow Response Times

#### Problem: Agent Responses Take Too Long
```bash
# Diagnosis
time curl -X POST http://localhost:3001/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"test"}'

# Check resource usage
docker stats --filter "name=dsp"

# Solutions
# Increase Docker memory allocation
# Restart services to clear memory leaks
./restart.sh --all
# Consider switching to lighter Claude model in config
```

### 💾 Storage Issues

#### Problem: Docker Disk Space
```bash
# Diagnosis
docker system df
du -sh docker/qdrant_storage/

# Solutions
docker system prune -f                    # Clean unused data
docker volume prune -f                    # Clean volumes
# Rotate Qdrant storage if too large
```

## Emergency Recovery

### 🚨 Complete System Reset
```bash
# Nuclear option - resets everything
docker-compose -f docker/docker-compose.yml down --volumes --rmi all
rm -rf docker/qdrant_storage/*
docker system prune -af
./start.sh
```

### 🔧 Component-by-Component Recovery

#### 1. Reset Qdrant Only
```bash
docker-compose -f docker/docker-compose.yml stop qdrant
rm -rf docker/qdrant_storage/*
docker-compose -f docker/docker-compose.yml up -d qdrant
```

#### 2. Reset MCP Servers Only
```bash
docker-compose -f docker/docker-compose.yml restart mcp-ragdocs mcp-web-search
```

#### 3. Reset Claudable Only
```bash
./restart.sh --claudable
```

## Monitoring & Maintenance

### 📊 Health Monitoring
```bash
# Add to crontab for automated monitoring
# */5 * * * * /path/to/dyson-sphere-facts/docker/validate-infrastructure.sh

# Manual monitoring commands
watch 'docker ps --filter "name=dsp" --format "table {{.Names}}\t{{.Status}}"'
```

### 🔄 Preventive Maintenance
```bash
# Weekly cleanup
docker-compose -f docker/docker-compose.yml restart
docker system prune -f

# Monthly full restart
./restart.sh --rebuild
```

## Getting Help

### 📋 Collecting Debug Information
```bash
# Generate comprehensive debug report
echo "=== System Info ===" > debug-report.txt
uname -a >> debug-report.txt
docker --version >> debug-report.txt

echo "=== Container Status ===" >> debug-report.txt
docker ps --filter "name=dsp" >> debug-report.txt

echo "=== Port Usage ===" >> debug-report.txt
lsof -i :3001 >> debug-report.txt
lsof -i :3002 >> debug-report.txt
lsof -i :3004 >> debug-report.txt

echo "=== Docker Logs ===" >> debug-report.txt
docker-compose -f docker/docker-compose.yml logs --tail=50 >> debug-report.txt

echo "=== Validation Output ===" >> debug-report.txt
./docker/validate-infrastructure.sh >> debug-report.txt 2>&1
```

### 🔍 Log Analysis
```bash
# View specific service logs
docker-compose -f docker/docker-compose.yml logs -f qdrant
docker-compose -f docker/docker-compose.yml logs -f mcp-ragdocs
docker-compose -f docker/docker-compose.yml logs -f mcp-web-search

# Search for specific errors
docker-compose -f docker/docker-compose.yml logs | grep -i error
docker-compose -f docker/docker-compose.yml logs | grep -i fail
```

---

**Remember**: Most issues can be resolved with `./restart.sh --all`. When in doubt, restart everything and run the validation script.
