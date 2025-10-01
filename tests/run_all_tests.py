#!/usr/bin/env python3
"""
Utility script to execute all troubleshooting documentation tests via pytest.
Testing Framework: pytest
"""


import subprocess
import sys
from pathlib import Path


def main() -> int:
    tests_dir = Path(__file__).parent
    result = subprocess.run(  # nosec
        [sys.executable, "-m", "pytest", "-vv", str(tests_dir)],
        check=False,
        shell=False,
    )
    return result.returncode


if __name__ == "__main__":
    sys.exit(main())