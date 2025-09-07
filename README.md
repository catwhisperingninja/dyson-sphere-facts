# DYSON-SPHERE-FACTS

Perfect! I've generated the detailed sub-tasks accounting for your specific
setup with:

- **Parallels VM** (Node.js/n8n) → SSH → **Docker Host** (MCP servers)
- Frequent MCP server restarts handled via scripts
- Remote execution via SSH Execute Command nodes in n8n

## Key Architecture Highlights:

### Your Setup Flow:

1. **n8n runs** on Parallels Mac VM (Node.js system)
2. **MCP servers run** in Docker containers on separate host
3. **n8n connects** to MCP servers via SSH Execute Commands
4. **Restart scripts** handle the frequent MCP relaunches

### Critical Implementation Notes:

**For MCP Server Communication (Task 3.4-3.5):**

```bash
# n8n SSH Execute Command node would run:
ssh docker-host "docker exec mcp-ragdocs-container npx @hannesrudolph/mcp-ragdocs search 'Critical Photons'"
```

**For Auto-Restart (Task 2.4):**

```bash
#!/bin/bash
# restart-mcp-servers.sh on Docker host
docker restart mcp-ragdocs mcp-brave-search
# Or full recreate if needed:
docker-compose down && docker-compose up -d
```

### Quick Start Priority:

Start with tasks **1.1-1.4** to verify SSH connectivity, then jump to
**3.1-3.6** to get a basic workflow running. You can refine the MCP setup
iteratively.

Want me to:

1. Create specific Docker Compose files for the MCP servers?
2. Write the SSH Execute Command configurations for n8n?
3. Generate the restart/health check scripts?

The architecture actually works in your favor - having MCP servers on a
dedicated Docker host means better resource management and easy scaling!
