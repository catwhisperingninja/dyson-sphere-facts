# DSP Documentation Agent - Example Queries

This guide demonstrates the agent's capabilities with test queries that showcase the **60/40 balance** (60% game mechanics, 40% physics speculation) and the fun, engaging tone.

## Query Categories

### 🎮 Game Mechanics (60% Focus)

#### Basic DSP Items & Recipes
```bash
# Critical Photons - Core game mechanic
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"How do Critical Photons work in DSP? What recipes use them?"}'

# Antimatter Production
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"What is the most efficient antimatter production setup in DSP?"}'

# Solar Sails
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"How many Solar Sails do I need for a Dyson Sphere around a K-class star?"}'

# Ray Receivers
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"What is the optimal Ray Receiver layout for maximum power efficiency?"}'
```

#### Advanced Game Strategy
```bash
# Logistics & Scaling
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"How do I scale up my factory to produce 1000 Science Matrix per minute?"}'

# Multi-planet Operations
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"What is the best strategy for automating multiple planets with Interstellar Logistics?"}'

# Resource Optimization
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"Which planets should I prioritize for mining rare resources like Kimberlite and Spiniform?"}'
```

### 🔬 Physics Speculation (40% Focus)

#### Real Dyson Sphere Engineering
```bash
# Feasibility Questions
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"Could we actually build a real Dyson sphere? What are the engineering challenges?"}'

# Material Science
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"What materials would we need for a real Dyson sphere? Are there any realistic alternatives to the game solid structures?"}'

# Energy Collection
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"How would we actually collect and transmit energy from a real Dyson sphere to Earth?"}'
```

#### Theoretical Physics Research
```bash
# Antimatter Physics
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"What is the current state of real antimatter research? How close are we to the production methods shown in DSP?"}'

# Stellar Engineering
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"Are there any recent research papers on stellar engineering or megastructures like Dyson spheres?"}'

# Space-based Manufacturing
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"What are the latest developments in space-based manufacturing and asteroid mining?"}'
```

### 🔀 Hybrid Questions (Game + Physics)

#### Comparative Analysis
```bash
# Game vs Reality
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"Compare DSP antimatter production to real physics - what does the game get right and wrong?"}'

# Technology Assessment
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"How realistic are the technologies in DSP? Which ones might be possible and which are pure sci-fi?"}'

# Scale Comparisons
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"The game lets you build a Dyson sphere in hours - how long would it actually take to build one?"}'

# Energy Efficiency
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"Does DSP solar sail efficiency match real physics? How much energy could we actually capture?"}'
```

## Testing Different Agent Personalities

### 🎯 Testing Tone Consistency

#### Should Sound Fun & Engaging (NOT Academic)
```bash
# Good response tone examples:
# "Oh, Critical Photons! These little energy packets are absolutely fascinating..."
# "Real Dyson spheres? Now we're talking about some seriously epic engineering!"
# "DSP makes antimatter look easy, but the real physics is mind-blowing..."

curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"Tell me about Critical Photons - make it exciting!"}'
```

#### Testing Knowledge Balance
```bash
# Should demonstrate both game knowledge AND real physics
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"Explain how DSP Dyson swarms work, and how that compares to real space engineering proposals"}'

# Should prioritize game mechanics but include physics context
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"What is the best Critical Photon setup in DSP?"}'
```

## Content Creator & Sci-Fi Writer Use Cases

### 📹 YouTube Content Ideas
```bash
# Video concept queries
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"Give me 5 video ideas comparing DSP technologies to real physics for my YouTube channel"}'

# Fact-checking assistance
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"I want to make a video about real Dyson spheres - what are the most recent research developments I should cover?"}'
```

### ✍️ Sci-Fi Writing Assistance
```bash
# Worldbuilding help
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"I am writing a sci-fi story about humanity building their first Dyson sphere - what realistic challenges should they face?"}'

# Technical authenticity
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"What would be realistic antimatter production methods for a sci-fi story set 200 years in the future?"}'
```

## Performance Testing Queries

### 🏃‍♂️ Response Speed Tests
```bash
# Simple game query (should be fast - RAG only)
time curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"What is Iron Ore used for in DSP?"}'

# Physics query (slower - web search required)
time curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"Latest Dyson sphere research papers"}'

# Complex hybrid query (slowest - both sources)
time curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"How realistic are DSP power transmission methods compared to current space solar power research?"}'
```

### 🔍 Search Quality Tests
```bash
# Test RAG precision
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"White Science Matrix recipe requirements"}'

# Test web search current events
curl -X POST http://localhost:3001/chat -H "Content-Type: application/json" \
  -d '{"message":"NASA Dyson sphere news 2024"}'
```

## Expected Response Patterns

### ✅ Good Responses Should Include:

1. **Game Mechanics Focus (60%)**:
   - Specific DSP item names, recipes, numbers
   - Strategic advice and optimization tips
   - Reference to game mechanics and systems

2. **Physics Context (40%)**:
   - Real scientific concepts and research
   - Current developments in space technology
   - Comparative analysis with game mechanics

3. **Engaging Tone**:
   - Enthusiasm without being academic
   - "Science communicator who loves gaming" style
   - Bridge between gaming and real science

4. **Source Attribution**:
   - Clear indication when using RAG vs web search
   - Response metadata showing source counts

### ❌ Poor Responses Would Include:

- Purely academic tone
- Only game info without physics context (or vice versa)
- Incorrect game mechanics or outdated physics
- No enthusiasm or engagement
- Missing source attribution

## Automated Testing Script

Save this as `test-agent-queries.sh`:

```bash
#!/bin/bash

echo "🧪 DSP Agent Query Testing Suite"
echo "================================"

# Test basic functionality
echo "Testing basic health..."
curl -s http://localhost:3001/health | jq .

# Test game mechanics query
echo -e "\n🎮 Testing game mechanics query..."
curl -s -X POST http://localhost:3001/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Critical Photon recipe"}' | jq .

# Test physics query
echo -e "\n🔬 Testing physics query..."
curl -s -X POST http://localhost:3001/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"real Dyson sphere engineering"}' | jq .

# Test hybrid query
echo -e "\n🔀 Testing hybrid query..."
curl -s -X POST http://localhost:3001/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Compare DSP solar sails to real physics"}' | jq .

echo -e "\n✅ Testing complete!"
```

Run with:
```bash
chmod +x test-agent-queries.sh
./test-agent-queries.sh
```