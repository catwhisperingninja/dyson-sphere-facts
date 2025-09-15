#!/usr/bin/env node

/**
 * DSP Agent Integration Test Suite
 * Tests the complete integration chain: Claudable → MCP servers → Claude API
 */

const axios = require('axios');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

const BASE_URL = 'http://localhost:3001';

class TestRunner {
  constructor() {
    this.passed = 0;
    this.failed = 0;
    this.results = [];
  }

  async runTest(name, testFn) {
    console.log(`\n🧪 Testing: ${name}`);
    try {
      await testFn();
      console.log(`✅ PASS: ${name}`);
      this.passed++;
      this.results.push({ name, status: 'PASS' });
    } catch (error) {
      console.log(`❌ FAIL: ${name}`);
      console.log(`   Error: ${error.message}`);
      this.failed++;
      this.results.push({ name, status: 'FAIL', error: error.message });
    }
  }

  async testHealthCheck() {
    const response = await axios.get(`${BASE_URL}/health`);
    if (response.data.status !== 'ok') {
      throw new Error(`Health check failed: ${response.data.status}`);
    }
    if (!response.data.services.rag || !response.data.services.search) {
      throw new Error('MCP services not available');
    }
  }

  async testConfigEndpoint() {
    const response = await axios.get(`${BASE_URL}/config`);
    if (!response.data.name || !response.data.mcp_servers) {
      throw new Error('Invalid configuration response');
    }
  }

  async testGameMechanicsQuery() {
    const response = await axios.post(`${BASE_URL}/chat`, {
      message: 'How do Critical Photons work in DSP?'
    });

    if (!response.data.response) {
      throw new Error('No response received');
    }

    if (response.data.sources.rag === 0) {
      console.log('⚠️  Warning: No RAG sources used for game mechanics query');
    }

    console.log(`   📊 Sources: RAG=${response.data.sources.rag}, Search=${response.data.sources.search}`);
    console.log(`   💬 Response preview: "${response.data.response.substring(0, 100)}..."`);
  }

  async testPhysicsQuery() {
    const response = await axios.post(`${BASE_URL}/chat`, {
      message: 'Could we actually build a real Dyson sphere with current physics?'
    });

    if (!response.data.response) {
      throw new Error('No response received');
    }

    if (response.data.sources.search === 0) {
      console.log('⚠️  Warning: No search sources used for physics query');
    }

    console.log(`   📊 Sources: RAG=${response.data.sources.rag}, Search=${response.data.sources.search}`);
    console.log(`   💬 Response preview: "${response.data.response.substring(0, 100)}..."`);
  }

  async testHybridQuery() {
    const response = await axios.post(`${BASE_URL}/chat`, {
      message: 'Compare DSP antimatter production to real physics - what\'s realistic?'
    });

    if (!response.data.response) {
      throw new Error('No response received');
    }

    console.log(`   📊 Sources: RAG=${response.data.sources.rag}, Search=${response.data.sources.search}`);
    console.log(`   💬 Response preview: "${response.data.response.substring(0, 100)}..."`);
  }

  async testErrorHandling() {
    try {
      await axios.post(`${BASE_URL}/chat`, {});
    } catch (error) {
      if (error.response?.status !== 400) {
        throw new Error(`Expected 400 error, got ${error.response?.status}`);
      }
    }
  }

  async run() {
    console.log('🚀 DSP Agent Integration Test Suite');
    console.log('=====================================');

    // Wait for server to be ready
    console.log('\n⏳ Waiting for DSP Agent to be ready...');
    let ready = false;
    for (let i = 0; i < 10; i++) {
      try {
        await axios.get(`${BASE_URL}/health`, { timeout: 5000 });
        ready = true;
        break;
      } catch (error) {
        console.log(`   Attempt ${i + 1}/10: Server not ready yet...`);
        await new Promise(resolve => setTimeout(resolve, 2000));
      }
    }

    if (!ready) {
      console.log('❌ Server never became ready. Make sure DSP Agent is running on port 3001');
      process.exit(1);
    }

    console.log('✅ Server ready, starting tests...');

    // Run tests
    await this.runTest('Health Check', () => this.testHealthCheck());
    await this.runTest('Configuration Endpoint', () => this.testConfigEndpoint());
    await this.runTest('Game Mechanics Query', () => this.testGameMechanicsQuery());
    await this.runTest('Physics Speculation Query', () => this.testPhysicsQuery());
    await this.runTest('Hybrid Query', () => this.testHybridQuery());
    await this.runTest('Error Handling', () => this.testErrorHandling());

    // Report results
    console.log('\n📊 Test Results');
    console.log('================');
    console.log(`✅ Passed: ${this.passed}`);
    console.log(`❌ Failed: ${this.failed}`);
    console.log(`🎯 Success Rate: ${Math.round((this.passed / (this.passed + this.failed)) * 100)}%`);

    if (this.failed > 0) {
      console.log('\n❌ Failed Tests:');
      this.results.filter(r => r.status === 'FAIL').forEach(result => {
        console.log(`   - ${result.name}: ${result.error}`);
      });
      process.exit(1);
    } else {
      console.log('\n🎉 All tests passed! DSP Agent integration is working correctly.');
      process.exit(0);
    }
  }
}

// Run tests if called directly
if (require.main === module) {
  const runner = new TestRunner();
  runner.run().catch(error => {
    console.error('\n💥 Test runner crashed:', error.message);
    process.exit(1);
  });
}

module.exports = TestRunner;