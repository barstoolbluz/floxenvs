#!/usr/bin/env python3
"""
Verify all Category D environments match comfyui helpf pattern exactly.
"""

import os
import re
import sys

FLOXENVS_DIR = "/home/daedalus/dev/floxenvs"

# All 36 Category D environments
CATEGORY_D_ENVS = [
    # Batch 1
    "airflow-k8s-executor", "airflow-local-dev", "airflow-stack",
    "colima-headless", "dagster-headless", "harlequin-postgres",
    # Batch 2
    "jenkins-full-stack", "jupyterlab", "jupyterlab-headless",
    "kind", "mariadb", "mariadb-headless",
    # Batch 3
    "mysql", "mysql-headless", "n8n", "n8n-headless",
    "neo4j", "neo4j-headless",
    # Batch 4
    "nginx-headless", "nodered", "ollama-headless", "open-webui",
    "postgres", "postgres-headless",
    # Batch 5
    "postgres-metabase", "prefect-headless", "python-postgres",
    "python310", "python311", "python312",
    # Batch 6
    "python313", "redis", "redis-headless",
    "temporal-headless", "temporal-ui", "wsl2-ollama",
]


def verify_hook_readme_fetch(content, env_name):
    """Verify hook section has correct README fetch pattern."""
    expected_pattern = f'''  # Fetch README.md if not present
  README_FILE="$FLOX_ENV_PROJECT/README.md"
  if [ ! -f "$README_FILE" ]; then
    if curl -fsSL https://raw.githubusercontent.com/barstoolbluz/floxenvs/main/{env_name}/README.md -o "$README_FILE" 2>/dev/null; then
      echo "✓ Downloaded README.md (use 'helpf' to view)"
    fi
  fi'''

    if expected_pattern in content:
        return True, "Hook README fetch: OK"

    # Check if it exists but with wrong format
    if "# Fetch README.md" in content or "README_FILE=" in content:
        return False, "Hook README fetch: WRONG FORMAT"

    return False, "Hook README fetch: MISSING"


def verify_bash_helpf(content, env_name):
    """Verify bash helpf function matches pattern."""
    # Key elements to check
    checks = []

    # Check for correct README_FILE path
    if f'local README_FILE="$FLOX_ENV_PROJECT/README.md"' in content:
        checks.append(("Bash README_FILE path", True))
    else:
        checks.append(("Bash README_FILE path", False))

    # Check for correct README_URL
    expected_url = f'local README_URL="https://raw.githubusercontent.com/barstoolbluz/floxenvs/main/{env_name}/README.md"'
    if expected_url in content:
        checks.append(("Bash README_URL", True))
    else:
        checks.append(("Bash README_URL", False))

    # Check for --help option
    if 'if [ "$1" = "--help" ]; then' in content:
        checks.append(("Bash --help", True))
    else:
        checks.append(("Bash --help", False))

    # Check for --force option
    if 'if [ "$1" = "--force" ]; then' in content:
        checks.append(("Bash --force", True))
    else:
        checks.append(("Bash --force", False))

    # Check for bat usage
    if 'bat --style=auto --paging=always "$README_FILE"' in content:
        checks.append(("Bash bat usage", True))
    else:
        checks.append(("Bash bat usage", False))

    # Check for export -f
    if 'export -f helpf' in content:
        checks.append(("Bash export", True))
    else:
        checks.append(("Bash export", False))

    all_ok = all(check[1] for check in checks)

    if all_ok:
        return True, "Bash helpf: OK"
    else:
        failed = [check[0] for check in checks if not check[1]]
        return False, f"Bash helpf: FAILED ({', '.join(failed)})"


def verify_zsh_helpf(content, env_name):
    """Verify zsh helpf function matches pattern."""
    # Key elements to check (similar to bash but without export -f)
    checks = []

    # Find zsh section
    zsh_section = re.search(r'zsh\s*=\s*\'\'\'(.*?)(?=\'\'\')', content, re.DOTALL)
    if not zsh_section:
        return False, "Zsh section: MISSING"

    zsh_content = zsh_section.group(1)

    # Check for correct README_FILE path
    if f'local README_FILE="$FLOX_ENV_PROJECT/README.md"' in zsh_content:
        checks.append(("Zsh README_FILE path", True))
    else:
        checks.append(("Zsh README_FILE path", False))

    # Check for correct README_URL
    expected_url = f'local README_URL="https://raw.githubusercontent.com/barstoolbluz/floxenvs/main/{env_name}/README.md"'
    if expected_url in zsh_content:
        checks.append(("Zsh README_URL", True))
    else:
        checks.append(("Zsh README_URL", False))

    # Check for --help option
    if 'if [ "$1" = "--help" ]; then' in zsh_content:
        checks.append(("Zsh --help", True))
    else:
        checks.append(("Zsh --help", False))

    # Check for --force option
    if 'if [ "$1" = "--force" ]; then' in zsh_content:
        checks.append(("Zsh --force", True))
    else:
        checks.append(("Zsh --force", False))

    # Check for bat usage
    if 'bat --style=auto --paging=always "$README_FILE"' in zsh_content:
        checks.append(("Zsh bat usage", True))
    else:
        checks.append(("Zsh bat usage", False))

    all_ok = all(check[1] for check in checks)

    if all_ok:
        return True, "Zsh helpf: OK"
    else:
        failed = [check[0] for check in checks if not check[1]]
        return False, f"Zsh helpf: FAILED ({', '.join(failed)})"


def verify_fish_helpf(content, env_name):
    """Verify fish helpf function matches pattern (if fish section exists)."""
    # Find fish section
    fish_section = re.search(r'fish\s*=\s*\'\'\'(.*?)(?=\'\'\')', content, re.DOTALL)
    if not fish_section:
        return True, "Fish section: N/A"

    fish_content = fish_section.group(1)

    if 'function helpf' not in fish_content:
        return False, "Fish helpf: MISSING"

    checks = []

    # Check for correct README_FILE path
    if f'set README_FILE "$FLOX_ENV_PROJECT/README.md"' in fish_content:
        checks.append(("Fish README_FILE path", True))
    else:
        checks.append(("Fish README_FILE path", False))

    # Check for correct README_URL
    expected_url = f'set README_URL "https://raw.githubusercontent.com/barstoolbluz/floxenvs/main/{env_name}/README.md"'
    if expected_url in fish_content:
        checks.append(("Fish README_URL", True))
    else:
        checks.append(("Fish README_URL", False))

    # Check for --help option
    if 'if test "$argv[1]" = "--help"' in fish_content:
        checks.append(("Fish --help", True))
    else:
        checks.append(("Fish --help", False))

    # Check for --force option
    if 'if test "$argv[1]" = "--force"' in fish_content:
        checks.append(("Fish --force", True))
    else:
        checks.append(("Fish --force", False))

    # Check for bat usage
    if 'bat --style=auto --paging=always "$README_FILE"' in fish_content:
        checks.append(("Fish bat usage", True))
    else:
        checks.append(("Fish bat usage", False))

    all_ok = all(check[1] for check in checks)

    if all_ok:
        return True, "Fish helpf: OK"
    else:
        failed = [check[0] for check in checks if not check[1]]
        return False, f"Fish helpf: FAILED ({', '.join(failed)})"


def verify_no_floxhub_urls(content):
    """Verify no FloxHub URLs are present."""
    if 'floxhub.com' in content or 'hub.flox.dev' in content:
        return False, "FloxHub URLs: FOUND (should be removed)"
    return True, "FloxHub URLs: None found"


def verify_no_env_cache_readme(content):
    """Verify no $FLOX_ENV_CACHE/README.md references."""
    if '$FLOX_ENV_CACHE/README.md' in content:
        return False, "$FLOX_ENV_CACHE/README.md: FOUND (should use $FLOX_ENV_PROJECT)"
    return True, "$FLOX_ENV_CACHE/README.md: Not found"


def verify_environment(env_name):
    """Verify a single environment matches the pattern."""
    manifest_path = os.path.join(FLOXENVS_DIR, env_name, ".flox", "env", "manifest.toml")

    if not os.path.exists(manifest_path):
        return {
            'env': env_name,
            'status': 'ERROR',
            'issues': [f'Manifest not found: {manifest_path}']
        }

    # Read manifest
    with open(manifest_path, 'r') as f:
        content = f.read()

    issues = []
    all_ok = True

    # Run all verifications
    verifications = [
        verify_hook_readme_fetch(content, env_name),
        verify_bash_helpf(content, env_name),
        verify_zsh_helpf(content, env_name),
        verify_fish_helpf(content, env_name),
        verify_no_floxhub_urls(content),
        verify_no_env_cache_readme(content),
    ]

    for ok, msg in verifications:
        if not ok:
            all_ok = False
            issues.append(msg)

    return {
        'env': env_name,
        'status': 'OK' if all_ok else 'FAILED',
        'issues': issues
    }


def main():
    print("=" * 80)
    print("Verifying Category D environments match comfyui helpf pattern")
    print("=" * 80)
    print()

    results = []

    for env_name in CATEGORY_D_ENVS:
        result = verify_environment(env_name)
        results.append(result)

        if result['status'] == 'OK':
            print(f"✓ {env_name:30s} OK")
        else:
            print(f"✗ {env_name:30s} FAILED")
            for issue in result['issues']:
                print(f"  - {issue}")

    # Summary
    print()
    print("=" * 80)
    print("SUMMARY")
    print("=" * 80)

    ok = [r for r in results if r['status'] == 'OK']
    failed = [r for r in results if r['status'] == 'FAILED']
    errors = [r for r in results if r['status'] == 'ERROR']

    print(f"Total environments: {len(CATEGORY_D_ENVS)}")
    print(f"Passing: {len(ok)}")
    print(f"Failed: {len(failed)}")
    print(f"Errors: {len(errors)}")
    print()

    if failed:
        print("Failed environments:")
        for r in failed:
            print(f"  - {r['env']}")
            for issue in r['issues']:
                print(f"    • {issue}")

    if errors:
        print("\nEnvironments with errors:")
        for r in errors:
            print(f"  - {r['env']}")
            for issue in r['issues']:
                print(f"    • {issue}")

    if len(failed) == 0 and len(errors) == 0:
        print("🎉 All environments verified successfully!")
        return 0
    else:
        return 1


if __name__ == '__main__':
    sys.exit(main())
