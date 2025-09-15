const express = require('express');
const { spawn } = require('child_process');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'mcp-ragdocs-http' });
});

app.get('/', (req, res) => {
  res.json({ service: 'DSP MCP RAG Server', status: 'running' });
});

app.get('/search', async (req, res) => {
  const query = req.query.q || req.query.query;
  if (!query) {
    return res.status(400).json({ error: 'Missing query parameter' });
  }

  try {
    console.log(`Searching for: ${query}`);

    // For now, return a mock response since we don't have docs loaded
    res.json({
      query,
      results: [
        {
          title: "DSP Documentation Search",
          content: `Mock result for query: ${query}. RAG server is running but no documents are loaded yet.`,
          source: "mcp-ragdocs"
        }
      ],
      status: "mock_response"
    });
  } catch (err) {
    console.error('Search error:', err);
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`DSP RAG HTTP Bridge listening on port ${PORT}`);
});