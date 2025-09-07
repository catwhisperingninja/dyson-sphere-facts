# Environment Variables Setup - SINGLE .env FILE

## ✅ You only need ONE .env file at the project root!

Place your `.env` file here:
```
/Users/laura/Documents/github-projects/dyson-sphere-facts/.env
```

## Setup Instructions:

1. **Copy the template to project root:**
```bash
cd /Users/laura/Documents/github-projects/dyson-sphere-facts
cp docker/.env.template .env
```

2. **Edit the .env file with your API keys:**
```bash
nano .env
# Or use your preferred editor
```

3. **Required API Keys:**
- `OPENAI_API_KEY` - For embeddings in RAG (get from platform.openai.com)
- `ANTHROPIC_API_KEY` - For Claude responses (get from console.anthropic.com)
- `BRAVE_API_KEY` - For web search (get free tier from brave.com/search/api)

## Why only one .env?

- **Simplicity**: One file to manage all environment variables
- **Docker Compose**: Reads from parent directory with `--env-file ../.env`
- **n8n**: Can reference the same variables via SSH
- **Security**: One place to secure your API keys

## The scripts are already configured!

All scripts now use the root `.env`:
- `docker/manage-mcp.sh` uses `docker-compose --env-file ../.env`
- No need for multiple `.env` files
- Everything reads from the single source of truth

## Example .env content:

```env
# API Keys
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxx
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxx
BRAVE_API_KEY=BSAxxxxxxxxxxxxx

# Optional
GEMINI_API_KEY=AIxxxxxxxxxxxxx
QDRANT_API_KEY=

# Docker/SSH Settings
DOCKER_HOST_IP=host.docker.internal
DOCKER_HOST_USER=laura

# n8n Settings (if running in Docker)
N8N_USER=admin
N8N_PASSWORD=changeme
```

That's it! One `.env` file at the project root handles everything. 🎉
