# DSP Documentation Agent Setup Guide

## Architecture Overview

```
Parallels VM (Node.js/n8n)
    ↓ SSH
Docker Host Mac (MCP Servers in Docker)
    ↓
Response back to n8n → User
```

## Prerequisites

### On Mac Host (Docker Desktop)

- Docker Desktop installed and running
- SSH access enabled (System Preferences → Sharing → Remote Login)
- Git installed

### On Parallels VM

- Node.js 18+ installed
- n8n installed (`npm install -g n8n`)
- SSH key pair generated (`ssh-keygen -t rsa`)

## Step 1: Setup Docker MCP Servers (Mac Host)

1. **Navigate to project directory:**

```bash
cd /Users/laura/Documents/github-projects/dyson-sphere-facts
```

2. **Copy and configure environment (ONE .env file at project root):**

```bash
cp docker/.env.template .env
# Edit .env with your API keys:
# - OPENAI_API_KEY (for embeddings)
# - ANTHROPIC_API_KEY (for Claude)
# - BRAVE_API_KEY (for web search)
```

3. **Make scripts executable:**

```bash
chmod +x manage-mcp.sh health-check.sh mcp-query.sh
```

4. **Start MCP servers:**

```bash
./manage-mcp.sh start
```

5. **Verify services are running:**

```bash
./manage-mcp.sh status
```

You should see:

- Qdrant UI at http://localhost:6333/dashboard
- MCP services on ports 3001, 3002, 3003

## Step 2: Setup SSH Access (Parallels VM → Mac)

1. **On Parallels VM, copy SSH key to Mac host:**

```bash
ssh-copy-id laura@host.docker.internal
# Or use the Mac's IP address
ssh-copy-id laura@192.168.x.x
```

2. **Test SSH connection:**

```bash
ssh laura@host.docker.internal "docker ps"
```

3. **Test MCP query wrapper:**

```bash
ssh laura@host.docker.internal "/Users/laura/Documents/github-projects/dyson-sphere-facts/docker/mcp-query.sh health"
```

## Step 3: Setup n8n (Parallels VM)

1. **Start n8n:**

```bash
# Basic start
n8n start

# Or with custom port and basic auth
N8N_PORT=5678 \
N8N_BASIC_AUTH_ACTIVE=true \
N8N_BASIC_AUTH_USER=admin \
N8N_BASIC_AUTH_PASSWORD=yourpassword \
n8n start
```

2. **Access n8n:** Open browser to `http://localhost:5678`

3. **Configure credentials in n8n UI:**

   a. Go to Credentials → New

   b. Create "SSH" credential named "dockerHost":

   - Host: `host.docker.internal` (or Mac IP)
   - Port: 22
   - Username: `laura`
   - Private Key: (paste contents of `~/.ssh/id_rsa`)

   c. Create "Anthropic" credential:

   - API Key: (your Anthropic API key)

4. **Import workflow:**

   - In n8n, go to Workflows → Import
   - Upload `/n8n/dsp-agent-workflow.json`
   - Or copy-paste the JSON content

5. **Test the workflow:**
   - Click "Execute Workflow"
   - Use test node to send: `{"query": "What are Critical Photons?"}`

## Step 4: Ingest DSP Documentation

1. **Download DSP wiki content** (on Mac host):

```bash
cd /Users/laura/Documents/github-projects/dyson-sphere-facts/docs

# Example: Download key pages
curl -o dyson-sphere.md "https://dsp-wiki.com/Dyson_Sphere?action=raw"
curl -o critical-photons.md "https://dsp-wiki.com/Critical_Photon?action=raw"
curl -o antimatter.md "https://dsp-wiki.com/Antimatter?action=raw"
# Add more pages as needed
```

2. **Ingest into RAG system:**

```bash
# Use the MCP server to add documents
cd ../docker
./mcp-query.sh add "https://dsp-wiki.com/Dyson_Sphere" "Dyson Sphere"
./mcp-query.sh add "https://dsp-wiki.com/Critical_Photon" "Critical Photons"
# Or batch ingest local files
```

## Step 5: Configure Auto-Restart (Optional)

1. **On Mac host, add cron job for health checks:**

```bash
crontab -e
# Add this line (runs every 5 minutes):
*/5 * * * * /Users/laura/Documents/github-projects/dyson-sphere-facts/docker/health-check.sh >> /Users/laura/Documents/github-projects/dyson-sphere-facts/logs/health.log 2>&1
```

2. **On Parallels VM, auto-start n8n:**

```bash
# Create systemd service (Linux) or launchd plist (Mac VM)
# Example for Mac VM with launchd:
cat > ~/Library/LaunchAgents/com.dsp.n8n.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.dsp.n8n</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/n8n</string>
        <string>start</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/n8n.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/n8n.error.log</string>
</dict>
</plist>
EOF

launchctl load ~/Library/LaunchAgents/com.dsp.n8n.plist
```

## Step 6: Test the Complete System

1. **Via n8n Chat Interface:**

   - Open n8n workflow
   - Click on Chat Trigger node
   - Select "Test Chat"
   - Try queries like:
     - "How do Critical Photons work in DSP?"
     - "Could we actually build a Dyson sphere?"
     - "Compare game antimatter to real physics"

2. **Via Webhook API:**

```bash
curl -X POST http://localhost:5678/webhook/dsp-agent \
  -H "Content-Type: application/json" \
  -d '{"query": "What would it cost to build a real Dyson sphere?"}'
```

3. **Check logs if issues:**

```bash
# On Mac host:
./docker/manage-mcp.sh logs

# On Parallels VM:
tail -f ~/.n8n/logs/n8n.log
```

## Troubleshooting

### MCP Servers Won't Start

- Check Docker Desktop is running
- Verify ports 6333, 3001-3003 are free
- Check API keys in `.env` file
- Review logs: `docker-compose logs`

### SSH Connection Fails

- Verify Remote Login enabled on Mac
- Check firewall settings
- Test with: `ssh -v laura@host.docker.internal`
- Try using IP instead of hostname

### n8n Workflow Errors

- Check credentials are configured correctly
- Verify SSH key has correct permissions (600)
- Test MCP wrapper manually first
- Enable verbose logging in n8n

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

# Parallels VM - n8n
n8n start                      # Start n8n
n8n export:workflow --all      # Export all workflows
n8n import:workflow            # Import workflow

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
