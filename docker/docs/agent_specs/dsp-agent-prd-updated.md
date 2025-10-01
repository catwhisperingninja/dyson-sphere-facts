# Product Requirements Document
## DSP Documentation & Physics Speculation Agent

**Version:** 1.1 MVP  
**Date:** Updated January 2025  
**Target User:** Content creators exploring Dyson Sphere Program mechanics and theoretical mega-structures  
**Development Philosophy:** EASY BUILD, userbase of 1, fun over academic rigor

---

## 1. Introduction/Overview

A specialized AI agent that combines deep knowledge of Dyson Sphere Program game mechanics with theoretical physics speculation about mega-structures. This agent serves content creators, sci-fi writers, and curious players who want to explore both the game's intricate systems and the wild possibilities of actual Dyson sphere construction.

The agent bridges gaming and science communication by treating the game's physics seriously while maintaining a fun, engaging tone. It can answer detailed questions about DSP mechanics while also speculating about real-world mega-engineering projects using web searches and physics knowledge.

---

## 2. Goals

1. **Enable Fun Physics Speculation** - Allow users to explore "what if" scenarios comparing game mechanics to theoretical physics
2. **Provide DSP Expertise** - Answer detailed questions about game mechanics, production chains, and optimization strategies  
3. **Support Content Creation** - Help creators generate interesting discussions about mega-structures and space engineering
4. **Maintain Simplicity** - Focus on easy deployment and maintenance for a single user

---

## 3. User Stories

### Primary User Stories
1. **Hard Sci-Fi Writer**: "As a hard sci-fi writer, I want detailed and realistic physics explanations with speculative theorizing based on web searches and actual data, generating solid hypotheses for story elements"

2. **Content Creator**: "As a content creator, I want to explore both DSP mechanics and theoretical mega-structure concepts to create engaging content comparing game mechanics to real physics"

3. **New Player**: "As a new DSP player, I want quick answers about basic game mechanics without searching multiple wikis"

### Example Interactions
- "What would a cost-benefit analysis of Dyson sphere construction look like compared to 150 nuclear power facilities?"
- "How do Critical Photons relate to antimatter production in terms of quantum field theory?"
- "If we built a folding spacetime warp gate with a basic sphere, what physics would apply?"

---

## 4. Functional Requirements

### Core Agent Capabilities
1. **Answer DSP game mechanics questions** using ingested documentation
2. **Perform web searches** for latest physics research and speculation
3. **Blend game mechanics with real physics** in responses
4. **Generate fun, engaging explanations** (not dry academic text)
5. **Support conversational interaction** through Claudable interface

### Documentation & Knowledge
6. **Ingest DSP wikis and documentation** (dsp-wiki.com, Reddit guides, official docs)
7. **Access web search** for current physics papers and speculation
8. **[PLACEHOLDER: YouTube Transcript Integration]** - Process DSP tutorial videos if time permits

### Technical Integration
9. **Use existing MCP servers** via Docker Desktop/modelinspector protocol
10. **Deploy through Claudable** (Node.js based chatbot interface)
11. **Support streaming responses** for better UX

---

## 5. Non-Goals (Out of Scope for MVP)

1. **Production chain calculations** - Save for Phase 2
2. **Blueprint sharing/storage** - Not needed
3. **Multi-language support** - English only
4. **User authentication** - Single user
5. **Complex error handling** - Keep it simple
6. **Scalability considerations** - Userbase of 1
7. **Real-time game data** - Static documentation only
8. **Mod compatibility** - Base game only
9. **Multi-agent orchestration** - Single agent handles all tasks

---

## 6. Technical Architecture Decisions

### Frontend Interface
**Claudable** - Node.js based chatbot interface for conversational interaction

### Agent Architecture
**Two-Agent Design** with Claude 4 Sonnet:

**Frontend Agent (Claudable Handler):**
- Manages Claudable interface interactions
- Formats requests for backend agent
- Handles response streaming and presentation
- Maintains conversation context

**Backend Agent (DSP Specialist):**
- Core DSP game mechanics expertise
- Physics speculation and research
- Direct MCP server orchestration
- Web searches for current science

**Inter-Agent Communication:**
- Structured report format for state transfer
- Frontend agent passes full conversation context + user query
- Backend agent returns structured response with:
  - Answer content
  - Sources used (MCP servers accessed)
  - Confidence levels for speculative content
  - Any follow-up suggestions
- Both agents maintain awareness via shared context reports

### MCP Server Stack (via Docker Desktop/modelinspector)

#### Available MCP Servers:
**Documentation & RAG:**
- `Context7` - Already installed, can fetch DSP-related documentation
- `web3-research-mcp` - Can be adapted for physics/DSP documentation
- `mcp-ragdocs` - For DSP wiki ingestion (to be added)

**Web Search & Research:**
- Brave Search MCP (via existing Docker container)
- Additional physics/science search servers as available

**Existing Infrastructure (available if needed):**
- Various crypto/DeFi servers from `/Users/dev/Documents/MCP/`
- Can leverage for economic comparisons if relevant

### Connection Method
- Docker Desktop containers accessed via `modelinspector` protocol
- Direct MCP protocol connections (no SSH)
- Enumerate available servers: `mcp --server-url <modelinspector-endpoint>`

### Orchestration Approach
```
Claudable Frontend
    ↓
Single DSP Agent (Claude 3.5 Sonnet)
    ↓
Direct MCP Server Calls
    ↓
Docker Desktop MCP Containers
```

### Model Provider
- Primary: Claude 3.5 Sonnet (via Anthropic API)
- Direct orchestration through single agent
- Fallback: OpenAI GPT-4 if needed

---

## 7. System Prompt & Agent Personality

```
You are an expert physicist specializing in:
- Quantum physics and theoretical particle physics
- Interstellar travel, warp drives, and space logistics  
- Mega-structure construction (Dyson spheres, swarms, shells)
- Matter-antimatter reactions and critical photon physics
- The Dyson Sphere Program game mechanics

You blend game mechanics with real physics speculation. Be fun and engaging, 
not boring or overly academic. Use metaphors like "1 million International 
Space Stations" for scale. Theorize boldly but ground speculation in actual 
physics and data from web searches.

When discussing DSP, reference specific game items, buildings, and mechanics.
When speculating about real physics, cite actual research when available.

You have direct access to MCP servers for documentation and web search.
Use these tools naturally to enhance your responses.
```

---

## 8. Success Metrics

Given userbase of 1, success is defined as:
1. **It works** - Agent responds to questions
2. **It's fun** - Responses are engaging, not dry
3. **It's easy** - Can be set up in < 1 hour
4. **It's useful** - Provides value for content creation

---

## 9. Open Questions

### Resolved Decisions:
- ✅ **Architecture:** Direct MCP orchestration with single agent
- ✅ **Frontend:** Claudable for chat interface
- ✅ **MCP Servers:** Docker Desktop containers via modelinspector
- ✅ **Model:** Claude 3.5 Sonnet with direct API access

### Remaining Questions:
1. **Documentation sources priority:**
   - Primary: dsp-wiki.com
   - Secondary: Reddit guides, official docs
   - YouTube transcripts: Phase 2

2. **Content balance:**
   - 60% game mechanics accuracy
   - 40% physics speculation and fun theories
   - Always prioritize engagement over academic rigor

3. **Initial test questions for validation:**
   - Game mechanics: "How do Critical Photons work