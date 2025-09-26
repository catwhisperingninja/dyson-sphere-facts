import re
from pathlib import Path

import pytest

DOC_PATH = Path(__file__).parent.parent / "docs" / "troubleshooting.md"


@pytest.fixture(scope="module")
def troubleshooting_text():
    if not DOC_PATH.exists():
        pytest.skip("Troubleshooting documentation file not found")
    return DOC_PATH.read_text(encoding="utf-8")


@pytest.fixture(scope="module")
def bash_code_blocks(troubleshooting_text):
    pattern = r"```bash\n(.*?)```"
    return [block.strip() for block in re.findall(pattern, troubleshooting_text, re.DOTALL)]


def test_code_blocks_present_and_populated(bash_code_blocks):
    assert bash_code_blocks, "Expected troubleshooting guide to include bash code blocks"
    assert len(bash_code_blocks) >= 20, "Expected comprehensive troubleshooting commands"
    assert all(block for block in bash_code_blocks), "Code blocks should not be empty"


def test_port_documentation_consistency(troubleshooting_text):
    expected_ports = {
        "3001": "Agent",
        "3002": "RAG",
        "3004": "Search",
        "6333": "Qdrant",
    }
    for port, service in expected_ports.items():
        assert f":{port}" in troubleshooting_text, f"Port {port} for {service} should be referenced"
        comment_signature = f"# {service}"
        assert comment_signature in troubleshooting_text, f"Port {port} comment should include '{comment_signature}'"


def test_container_names_and_services_documented(troubleshooting_text):
    expected_containers = ["dsp-qdrant", "dsp-mcp-ragdocs", "dsp-mcp-search"]
    for name in expected_containers:
        assert name in troubleshooting_text, f"Expected references to container '{name}'"


def test_script_paths_valid(troubleshooting_text):
    script_paths = ["./restart.sh", "./start.sh", "./docker/validate-infrastructure.sh"]
    for path in script_paths:
        assert path in troubleshooting_text, f"Expected script path '{path}' in documentation"


def test_dangerous_commands_have_warnings(troubleshooting_text):
    flagged_commands = [
        "rm -rf docker/qdrant_storage/*",
        "docker system prune -f",
        "docker-compose -f docker/docker-compose.yml down --volumes",
    ]
    upper_text = troubleshooting_text.upper()
    caution_markers = ["CAUTION", "WARNING", "NUCLEAR OPTION", "DELETES"]
    for command in flagged_commands:
        if command in troubleshooting_text:
            index = troubleshooting_text.index(command)
            window = upper_text[max(0, index - 300): index + 300]
            assert any(marker in window for marker in caution_markers), (
                f"Dangerous command '{command}' should include nearby cautionary text"
            )


def test_required_sections_present(troubleshooting_text):
    expected_sections = [
        "Docker Container Issues",
        "Network & Port Issues",
        "API Key & Authentication Issues",
        "Performance Troubleshooting",
        "Emergency Recovery",
        "Monitoring & Maintenance",
    ]
    for section in expected_sections:
        assert section in troubleshooting_text, f"Section '{section}' should be documented"


def test_every_problem_has_diagnosis_and_solutions(troubleshooting_text):
    problem_sections = troubleshooting_text.split("#### Problem:")
    # First split chunk is the content before the first problem, skip it
    for chunk in problem_sections[1:]:
        assert "# Diagnosis" in chunk, "Each problem section should detail diagnosis steps"
        assert "# Solutions" in chunk, "Each problem section should list solutions"


def test_health_check_endpoints(troubleshooting_text):
    endpoints = [
        "http://localhost:3001/health",
        "http://localhost:3002/health",
        "http://localhost:3004/health",
        "http://localhost:6333/",
    ]
    for endpoint in endpoints:
        assert endpoint in troubleshooting_text, f"Expected health endpoint '{endpoint}' to be documented"


def test_environment_variables_documented(troubleshooting_text):
    for key in ("OPENAI_API_KEY", "BRAVE_API_KEY"):
        assert key in troubleshooting_text, f"Environment variable '{key}' should be referenced"


def test_line_continuations_are_clean(troubleshooting_text):
    multiline_commands = re.findall(r"[^\n`]*\\\s*\n[^\n`]*", troubleshooting_text)
    for command in multiline_commands:
        lines = command.split("\n")
        for line in lines[:-1]:
            if "\\" in line:
                trailing = line[line.rfind("\\") + 1:]
                assert trailing.strip() == "", f"No characters should follow backslash in: '{line}'"


def test_markdown_code_fences_balanced(troubleshooting_text, bash_code_blocks):
    open_fences = troubleshooting_text.count("```bash")
    total_fences = troubleshooting_text.count("```")
    assert open_fences == len(bash_code_blocks)
    assert total_fences == open_fences * 2, "Code fences should be balanced"


def test_docker_compose_paths_consistent(troubleshooting_text):
    matches = re.findall(r"-f\s+([^\s]+docker-compose\.yml)", troubleshooting_text)
    if matches:
        assert len(set(matches)) == 1, "docker-compose calls should reuse a single compose file path"
        assert matches[0].startswith("docker/"), "docker-compose path should be rooted in docker directory"


def test_no_known_typos(troubleshooting_text):
    assert "Ofne-command" not in troubleshooting_text, "Typo 'Ofne-command' detected; should be 'One-command'"


def test_no_placeholder_text(troubleshooting_text):
    forbidden_markers = ["TODO", "FIXME", "TBD"]
    for marker in forbidden_markers:
        assert marker not in troubleshooting_text, f"Placeholder '{marker}' should not appear in shipped docs"