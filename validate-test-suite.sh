#!/bin/bash
# Test Suite Validation Script
# Validates that the DSP real-data test suite is properly configured
# This script can be run by other agents to verify test readiness

set -e

echo "🔍 DSP Test Suite Validation"
echo "================================"

# Check Poetry setup
echo "✅ Validating Poetry configuration..."
poetry check || exit 1

# Check test dependencies
echo "✅ Checking test dependencies..."
poetry show pytest > /dev/null || { echo "❌ pytest not installed"; exit 1; }
poetry show pytest-asyncio > /dev/null || { echo "❌ pytest-asyncio not installed"; exit 1; }
poetry show httpx > /dev/null || { echo "❌ httpx not installed"; exit 1; }

# Check test file structure
echo "✅ Validating test file structure..."
test -f tests/__init__.py || { echo "❌ Missing tests/__init__.py"; exit 1; }
test -f tests/conftest.py || { echo "❌ Missing tests/conftest.py"; exit 1; }
test -f tests/test_critical.py || { echo "❌ Missing tests/test_critical.py"; exit 1; }
test -f tests/README.md || { echo "❌ Missing tests/README.md"; exit 1; }

# Check pytest can discover tests
echo "✅ Verifying pytest test discovery..."
COLLECTED=$(poetry run pytest --collect-only tests/ -q | grep "collected" | awk '{print $1}')
if [ "$COLLECTED" != "12" ]; then
    echo "❌ Expected 12 tests, found $COLLECTED"
    exit 1
fi

# Verify no forbidden imports
echo "✅ Scanning for forbidden mock imports..."
poetry run python -c "
import ast
from pathlib import Path

def check_file(filepath):
    with open(filepath, 'r') as f:
        tree = ast.parse(f.read())
        for node in ast.walk(tree):
            if isinstance(node, ast.Import):
                for alias in node.names:
                    if any(x in alias.name for x in ['mock', 'patch', 'stub', 'fake']):
                        return False
            elif isinstance(node, ast.ImportFrom):
                if node.module and any(x in node.module for x in ['mock', 'patch', 'stub', 'fake']):
                    return False
                for alias in node.names:
                    if any(x in alias.name for x in ['mock', 'patch', 'stub', 'fake']):
                        return False
    return True

test_files = list(Path('tests').glob('*.py'))
for f in test_files:
    if not check_file(f):
        print(f'FORBIDDEN IMPORT FOUND in {f}')
        exit(1)
print('All files clean')
" || exit 1

# Check infrastructure markers
echo "✅ Verifying pytest markers..."
poetry run pytest tests/ -m infrastructure --collect-only -q > /dev/null || exit 1

# Verify project structure references
echo "✅ Checking project path references..."
test -f claudable/config.json || { echo "❌ Missing claudable/config.json"; exit 1; }
test -f docker/docker-compose.yml || { echo "❌ Missing docker/docker-compose.yml"; exit 1; }

echo ""
echo "🎉 TEST SUITE VALIDATION COMPLETE"
echo "================================"
echo "✅ Poetry configuration valid"
echo "✅ Test dependencies installed"
echo "✅ 12 tests discovered successfully"
echo "✅ No forbidden mock imports detected"
echo "✅ pytest markers configured"
echo "✅ Real-data testing principles enforced"
echo ""
echo "🚀 Test suite is ready!"
echo "📋 To run tests when infrastructure is ready:"
echo "   poetry run pytest tests/"
echo "   poetry run pytest tests/ -m infrastructure"
echo ""
echo "⚠️  REMEMBER: Tests will fail if Docker containers are not running"
echo "    This is INTENTIONAL - tests only pass with real infrastructure"