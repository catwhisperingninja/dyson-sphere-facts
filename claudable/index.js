#!/usr/bin/env node

/**
 * DSP Documentation & Physics Speculation Agent
 * Standalone interface connecting Claude API with local MCP servers
 */

const express = require('express');
const cors = require('cors');
const axios = require('axios');
const path = require('path');
const fs = require('fs');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

const app = express();
const PORT = process.env.DSP_AGENT_PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Load configuration
const config = JSON.parse(fs.readFileSync(path.join(__dirname, 'config.json'), 'utf8'));

// Replace environment variables in config
function resolveEnvVars(obj) {
  if (typeof obj === 'string') {
    return obj.replace(/\$\{([^}]+)\}/g, (match, varName) => process.env[varName] || match);
  }
  if (Array.isArray(obj)) {
    return obj.map(resolveEnvVars);
  }
  if (obj && typeof obj === 'object') {
    const resolved = {};
    for (const [key, value] of Object.entries(obj)) {
      resolved[key] = resolveEnvVars(value);
    }
    return resolved;
  }
  return obj;
}

const resolvedConfig = resolveEnvVars(config);

// DSP Agent System Prompt
const SYSTEM_PROMPT = `You are the DSP Documentation & Physics Speculation Agent, a fun and engaging AI that bridges gaming and science communication. You help content creators and sci-fi writers by combining Dyson Sphere Program game mechanics with real physics speculation.

**Your personality**: Enthusiastic but not academic. Think "science communicator who loves gaming" rather than "research professor."

**Your knowledge balance (60/40 rule)**:
- 60% Dyson Sphere Program game mechanics, items, and strategies
- 40% Real physics speculation and theoretical engineering

**Response patterns**:
1. **Game Mechanics Questions**: Reference specific DSP items, recipes, technologies
2. **Physics Questions**: Ground speculation in real research, cite recent studies when possible
3. **Hybrid Questions**: Compare game mechanics to real physics - what's realistic, what's not?

**Tools available**:
- RAG search for DSP documentation and guides
- Web search for current physics research and papers
- Your training knowledge for general physics concepts

Always maintain your fun, engaging tone while being technically accurate. Bridge the gap between gaming and real science!`;

// MCP Server Communication
class MCPClient {
  constructor(baseURL, serverName) {
    this.baseURL = baseURL;
    this.serverName = serverName;
    this.axios = axios.create({
      timeout: 10000,
      headers: { 'Content-Type': 'application/json' }
    });
  }

  async health() {
    try {
      const response = await this.axios.get(`${this.baseURL}/health`);
      return response.data;
    } catch (error) {
      throw new Error(`${this.serverName} health check failed: ${error.message}`);
    }
  }

  async search(query, options = {}) {
    try {
      const response = await this.axios.post(`${this.baseURL}/search`, {
        query,
        ...options
      });
      return response.data;
    } catch (error) {
      throw new Error(`${this.serverName} search failed: ${error.message}`);
    }
  }
}

// Initialize MCP clients
const ragClient = new MCPClient(resolvedConfig.mcp_servers.rag, 'RAG Server');
const searchClient = new MCPClient(resolvedConfig.mcp_servers.search, 'Search Server');

// Claude API integration
async function callClaude(messages, system = SYSTEM_PROMPT) {
  const response = await axios.post('https://api.anthropic.com/v1/messages', {
    model: resolvedConfig.claude.model,
    max_tokens: 4000,
    system: system,
    messages: messages
  }, {
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': resolvedConfig.claude.api_key,
      'anthropic-version': '2023-06-01'
    }
  });

  return response.data.content[0].text;
}

// Routes

// Health check
app.get('/health', async (req, res) => {
  try {
    const ragHealth = await ragClient.health();
    const searchHealth = await searchClient.health();

    res.json({
      status: 'ok',
      timestamp: new Date().toISOString(),
      services: {
        rag: ragHealth,
        search: searchHealth,
        claude: { status: 'configured', model: resolvedConfig.claude.model }
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Main chat endpoint
app.post('/chat', async (req, res) => {
  try {
    const { message, conversation = [] } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }

    console.log(`[DSP Agent] Processing query: "${message}"`);

    // Determine if we need RAG search, web search, or both
    const needsGameInfo = /dyson sphere program|dsp|critical photon|antimatter|solar sail|sphere|swarm|logistics|recipe|technology|blueprint/i.test(message);
    const needsPhysicsInfo = /physics|real|actually|possible|theoretical|engineering|energy|fusion|stellar|engineering|research|study|paper/i.test(message);

    let ragResults = null;
    let searchResults = null;

    // Perform searches based on query analysis
    if (needsGameInfo) {
      try {
        console.log('[DSP Agent] Searching DSP documentation...');
        ragResults = await ragClient.search(message);
      } catch (error) {
        console.warn('[DSP Agent] RAG search failed:', error.message);
      }
    }

    if (needsPhysicsInfo) {
      try {
        console.log('[DSP Agent] Searching physics research...');
        searchResults = await searchClient.search(message + ' physics research paper recent');
      } catch (error) {
        console.warn('[DSP Agent] Web search failed:', error.message);
      }
    }

    // Build context for Claude
    let contextMessage = '';
    if (ragResults && ragResults.results) {
      contextMessage += `\n\nDSP DOCUMENTATION CONTEXT:\n${ragResults.results.map(r => r.content || r).join('\n\n')}`;
    }
    if (searchResults && searchResults.results) {
      contextMessage += `\n\nPHYSICS RESEARCH CONTEXT:\n${searchResults.results.map(r => r.content || r).join('\n\n')}`;
    }

    // Prepare messages for Claude
    const messages = [
      ...conversation,
      {
        role: 'user',
        content: `${message}${contextMessage}`
      }
    ];

    // Get response from Claude
    console.log('[DSP Agent] Generating response with Claude...');
    const response = await callClaude(messages);

    res.json({
      response,
      sources: {
        rag: ragResults ? ragResults.results?.length || 0 : 0,
        search: searchResults ? searchResults.results?.length || 0 : 0
      },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('[DSP Agent] Error:', error);
    res.status(500).json({
      error: 'Internal server error',
      details: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Configuration endpoint
app.get('/config', (req, res) => {
  res.json({
    name: resolvedConfig.name,
    version: resolvedConfig.version,
    mcp_servers: Object.keys(resolvedConfig.mcp_servers),
    claude_model: resolvedConfig.claude.model
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 DSP Documentation & Physics Speculation Agent running on port ${PORT}`);
  console.log(`📚 RAG Server: ${resolvedConfig.mcp_servers.rag}`);
  console.log(`🔍 Search Server: ${resolvedConfig.mcp_servers.search}`);
  console.log(`🤖 Claude Model: ${resolvedConfig.claude.model}`);
  console.log(`\n💡 Try: curl -X POST http://localhost:${PORT}/chat -H "Content-Type: application/json" -d '{"message":"How do Critical Photons work?"}'`);
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n🛑 DSP Agent shutting down gracefully...');
  process.exit(0);
});