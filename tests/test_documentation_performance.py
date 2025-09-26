import re
import time

import pytest

REPLICATION_FACTOR = 120
BASE_SNIPPET = """
## Quick Diagnosis

### 🔍 System Health Check
```bash
# One-command system validation
./docker/validate-infrastructure.sh

# Quick status check
docker ps --filter "name=dsp" --format "table {{.Names}}\\t{{.Status}}\\t{{.Ports}}"
```

curl http://localhost:3001/health
curl http://localhost:3002/health
curl http://localhost:3004/health
curl http://localhost:6333/
"""


@pytest.fixture(scope="module")
def large_markdown():
    return BASE_SNIPPET * REPLICATION_FACTOR


def test_regex_extraction_performance(large_markdown):
    patterns = [
        r"```bash\n(.*?)```",
        r"http://localhost:\d+",
        r"docker\s+[A-Za-z-]+",
        r"curl\s+http://localhost:\d+/[A-Za-z]*",
    ]
    start = time.perf_counter()
    for pattern in patterns:
        matches = re.findall(pattern, large_markdown, re.DOTALL)
        assert isinstance(matches, list)
    elapsed = time.perf_counter() - start
    assert elapsed < 1.0, f"Regex extraction exceeded time budget: {elapsed:.3f}s"


def test_code_block_processing_scalability(large_markdown):
    start = time.perf_counter()
    blocks = re.findall(r"```bash\n(.*?)```", large_markdown, re.DOTALL)
    processed = []
    for block in blocks:
        filtered = "\n".join(
            line for line in block.splitlines() if not line.strip().startswith("#")
        )
        processed.append(filtered)
    elapsed = time.perf_counter() - start
    assert processed, "Expected to capture bash blocks during processing"
    assert elapsed < 0.6, f"Processing time too high for repeated content: {elapsed:.3f}s"


def test_scaling_behaviour_with_document_size():
    sizes = [10, 100, 500]
    baseline_time = None
    for factor in sizes:
        content = BASE_SNIPPET * factor
        start = time.perf_counter()
        _ = re.findall(r"```bash\n(.*?)```", content, re.DOTALL)
        _ = re.findall(r"http://localhost:\d+", content)
        elapsed = time.perf_counter() - start
        if baseline_time is None:
            baseline_time = elapsed
        else:
            scaling_ratio = elapsed / baseline_time
            size_ratio = factor / sizes[0]
            assert scaling_ratio <= size_ratio * 2, (
                f"Processing should scale approximately linearly; "
                f"observed {scaling_ratio:.2f}x vs expected <= {size_ratio * 2:.2f}x"
            )
        assert elapsed < factor / 40, (
            f"Processing time {elapsed:.3f}s exceeds acceptable bound for size factor {factor}"
        )