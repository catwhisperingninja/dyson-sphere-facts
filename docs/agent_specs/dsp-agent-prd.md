# Product Requirements Document
## DSP Documentation & Physics Speculation Agent

**Version:** 1.0 MVP  
**Date:** Created December 2024  
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
5. **Support conversational interaction** through chosen interface

### Documentation & Knowledge
6. **Ingest DSP wikis and documentation** (dsp-wiki.com, Reddit guides, official docs)
7. **Access web search** for current physics papers and speculation
8. **[PLACEHOLDER: YouTube Transcript Integration]** - Process DSP tutorial videos if time permits

### Technical Integration
9. **Use existing RAG/documentation tools** via MCP servers or framework features
10. **Deploy through simple interface** (Claudable or chosen framework's UI)
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

---

## 6. Technical Architecture Decisions

### Framework Selection
**[TECH DECISION NEEDED - Choose ONE]:**

#### Option A: n8n (Visual + Powerful)
- ✅ Visual workflow builder
- ✅ Native LangChain/AI support  
- ✅ 400+ integrations
- ✅ MCP server support confirmed
- ✅ Self-hostable
- 📝 **Setup:** `npx n8n` or Docker
- 🤔 **Consideration:** Might be overkill for single agent

#### Option B: Agent Squad (Multi-Agent)
- ✅ Multiple specialized agents (DSP expert, physics expert, web searcher)
- ✅ SupervisorAgent coordination
- ✅ Python and TypeScript
- ✅ Pre-built components
- 📝 **Setup:** `pip install agent-squad[all]`
- 🤔 **Consideration:** AWS-focused but works anywhere

#### Option C: Strands (Lightweight MCP)
- ✅ Native MCP support built-in
- ✅ Super lightweight
- ✅ Hot reloading tools
- ✅ Simple decorators for tools
- 📝 **Setup:** `pip install strands-agents`
- 🤔 **Consideration:** Newer framework, less ecosystem

#### Option D: LangGraph + MCP Adapters (Standard)
- ✅ Industry standard (LangChain)
- ✅ Proven MCP integration
- ✅ Huge ecosystem
- ✅ teddynote-lab/langgraph-mcp-agents exists
- 📝 **Setup:** Use existing repo or minimal config
- 🤔 **Consideration:** More traditional coding approach

### MCP Server Selection
**[TECH DECISION - Can use multiple]:**
- **Documentation RAG:** 
  - Needle (production-ready, requires API key)
  - mcp-ragdocs (OpenAI/Qdrant based)
  - kazuph/mcp-docs-rag (local directory, Gemini)
- **Web Search:**
  - Brave Search MCP
  - Perplexity MCP
  - Google Search MCP

### Model Provider
**[TECH DECISION]:**
- Primary: Claude 3.5 Sonnet (via Anthropic API)
- Fallback: OpenAI GPT-4
- Local option: Ollama with Llama/Mistral

### Deployment Interface
**[TECH DECISION]:**
- **Claudable** (original plan, Node.js based)
- **Framework's built-in UI** (n8n, Streamlit for Agent Squad)
- **Simple FastAPI + frontend**

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
- ✅ **Framework:** n8n for visual workflow building
- ✅ **MCP Servers:** mcp-ragdocs + Brave Search
- ✅ **Deployment:** n8n's built-in interface initially
- ✅ **Model:** Claude 3.5 Sonnet via n8n

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
   - Game mechanics: "How do Critical Photons work?"
   - Physics speculation: "Could we build a real Dyson sphere?"
   - Hybrid: "Compare game's antimatter production to real physics"

---

## 10. Phase 2 Considerations (Post-MVP)

Once MVP is working, consider adding:
- **DSP Calculator integration** for production chains
- **Blueprint analysis** capabilities
- **Comparison tools** (e.g., "sphere vs nuclear" calculator)
- **Citation system** for documentation sources
- **Memory system** for ongoing projects/stories
- **Multi-agent specialization** (separate physics vs game experts)

---

## Implementation Notes

### Quick Start Path:
1. Choose framework based on comfort level
2. Set up chosen MCP servers (start with 1 RAG + 1 search)
3. Ingest core DSP documentation
4. Configure system prompt
5. Deploy with simplest interface option
6. Test with example questions
7. Iterate on prompt and documentation

### Risk Mitigation:
- Start with smallest viable setup
- Use existing solutions (MCP servers, frameworks)
- Avoid custom RAG implementation
- Keep deployment local initially
- Focus on fun over perfection

---

## Appendix: Framework Comparison Matrix

| Feature | n8n | Agent Squad | Strands | LangGraph |
|---------|-----|-------------|---------|-----------|
| Learning Curve | Low (visual) | Medium | Low | Medium-High |
| MCP Support | Yes | Via tools | Native | Via adapters |
| Multi-Agent | Yes | Native | Single | Yes |
| Deployment | Docker/npx | Python/TS | Python | Python |
| UI Included | Yes | Examples | No | Via templates |
| Best For | Visual builders | Team agents | Simple tools | Standard approach |

---

**Next Steps:**
1. Review framework options and make selection
2. Identify specific MCP servers to use
3. Gather DSP documentation URLs
4. Begin implementation with chosen stack