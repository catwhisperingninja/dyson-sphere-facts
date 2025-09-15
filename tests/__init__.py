"""
DSP Real-Data Test Suite

This test suite follows strict real-data testing principles:
- NO mocks, patches, stubs, or test doubles
- ALL tests interact with real services and infrastructure
- Tests fail when real systems fail
- Every HTTP call hits actual endpoints
- Every Docker command checks live containers
- Every file operation reads real filesystem

Test organization:
- test_critical.py: Infrastructure validation tests
- Future: test_mcp_integration.py, test_performance.py, etc.
"""