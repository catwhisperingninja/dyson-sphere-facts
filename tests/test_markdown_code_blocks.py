import os
import re
import subprocess
import tempfile
from pathlib import Path

import pytest

DOC_PATH = Path(__file__).parent.parent / "docs" / "troubleshooting.md"


@pytest.fixture(scope="module")
def markdown_content():
    if not DOC_PATH.exists():
        pytest.skip("Troubleshooting documentation file not found")
    return DOC_PATH.read_text(encoding="utf-8")


@pytest.fixture(scope="module")
def bash_blocks(markdown_content):
    pattern = r"```bash\n(.*?)```"
    return [block.strip() for block in re.findall(pattern, markdown_content, re.DOTALL)]


def test_bash_blocks_have_valid_shell_syntax(bash_blocks):
    for index, block in enumerate(bash_blocks):
        with tempfile.NamedTemporaryFile(mode="w", suffix=".sh", delete=False) as tmp_file:
            tmp_file.write("#!/usr/bin/env bash\nset -e\n")
            tmp_file.write(block)
            tmp_path = tmp_file.name

        try:
            result = subprocess.run(
                ["bash", "-n", tmp_path],
                capture_output=True,
                text=True,
                check=False,
            )
            if result.returncode != 0:
                stderr = result.stderr or ""
                acceptable_phrases = (
                    "command not found",
                    "No such file or directory",
                    "docker-compose: not found",
                    "docker: not found",
                    "curl: not found",
                )
                if not any(phrase in stderr for phrase in acceptable_phrases):
                    pytest.fail(
                        f"Bash syntax error in block #{index}:\n{stderr}\nBlock:\n{block}"
                    )
        finally:
            os.unlink(tmp_path)


def test_comments_preceded_by_space(bash_blocks):
    for block in bash_blocks:
        for line in block.splitlines():
            if "#" in line and not line.strip().startswith("#"):
                before = line.split("#", 1)[0]
                assert before.endswith(" "), (
                    f"Inline comment should be preceded by a space: '{line}'"
                )


def test_environment_variable_expansions_non_empty(bash_blocks):
    variable_pattern = re.compile(r"\$\(([^)]+)\)|\$\{([^}]+)\}")
    for block in bash_blocks:
        for match in variable_pattern.finditer(block):
            content = next(filter(None, match.groups()))
            assert content.strip(), f"Variable expansion should contain content: '{match.group(0)}'"


def test_no_tabs_used_for_indentation(bash_blocks):
    for block in bash_blocks:
        assert "\t" not in block, "Tabs detected in bash block; prefer spaces for portability"


def test_curl_commands_include_protocol(bash_blocks):
    for block in bash_blocks:
        for line in block.splitlines():
            if "curl" in line and not line.strip().startswith("#"):
                assert "http://" in line or "https://" in line, f"Curl command missing protocol: '{line}'"


def test_backslash_line_continuations_have_no_trailing_text(bash_blocks):
    for block in bash_blocks:
        lines = block.splitlines()
        for idx, line in enumerate(lines[:-1]):
            if line.rstrip().endswith("\\"):
                trailing = line[len(line.rstrip()) - 1:]
                assert trailing == "\\", f"Only backslash should terminate line continuation: '{line}'"
                assert lines[idx + 1].strip(), "Continuation line should contain content"


def test_long_commands_wrapped_with_line_continuation(bash_blocks):
    for block in bash_blocks:
        for line in block.splitlines():
            if len(line) > 120 and not line.strip().startswith("#"):
                assert "\\" in line, f"Long command should use line continuation: '{line}'"


def test_docker_compose_invocations_include_file_flag(bash_blocks):
    compose_calls = [
        line
        for block in bash_blocks
        for line in block.splitlines()
        if "docker-compose" in line and not line.strip().startswith("#")
    ]
    for call in compose_calls:
        assert "-f docker/docker-compose.yml" in call, (
            f"docker-compose invocation should pin compose file path: '{call}'"
        )