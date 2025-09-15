const express = require('express');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'mcp-brave-search-http' });
});

app.get('/', (req, res) => {
  res.json({ service: 'DSP MCP Brave Search Server', status: 'running' });
});

app.get('/search', async (req, res) => {
  const query = req.query.q || req.query.query;
  if (!query) {
    return res.status(400).json({ error: 'Missing query parameter' });
  }

  try {
    console.log(`Web searching for: ${query}`);

    // For now, return a mock response since Brave container is unstable
    res.json({
      query,
      results: [
        {
          title: "Dyson Sphere Physics Speculation",
          content: `Mock physics result for: ${query}. Brave search integration pending container stability.`,
          source: "brave-search-mock"
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
  console.log(`DSP Search HTTP Bridge listening on port ${PORT}`);
});