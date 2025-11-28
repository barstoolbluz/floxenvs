#!/usr/bin/env python3
"""
Fix all Category D environments to match comfyui helpf pattern exactly.
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


def get_bash_helpf(env_name):
    """Generate correct bash helpf function for environment."""
    return f'''  helpf() {{
    local README_FILE="$FLOX_ENV_PROJECT/README.md"
    local README_URL="https://raw.githubusercontent.com/barstoolbluz/floxenvs/main/{env_name}/README.md"

    if [ "$1" = "--help" ]; then
      echo "Usage: helpf [OPTIONS]"
      echo ""
      echo "View environment documentation"
      echo ""
      echo "Options:"
      echo "  --force    Force download fresh copy from GitHub"
      echo "  --help     Show this help message"
      echo ""
      echo "The README is cached locally and only downloaded if missing."
      return 0
    fi

    if [ "$1" = "--force" ]; then
      echo "Fetching latest README.md from GitHub..."
      if curl -fsSL "$README_URL" -o "$README_FILE"; then
        echo "✓ Downloaded README.md"
      else
        echo "✗ Failed to download README.md"
        return 1
      fi
    elif [ ! -f "$README_FILE" ]; then
      echo "README.md not found, downloading..."
      if curl -fsSL "$README_URL" -o "$README_FILE"; then
        echo "✓ Downloaded README.md"
      else
        echo "✗ Failed to download README.md"
        return 1
      fi
    fi

    if [ -f "$README_FILE" ]; then
      bat --style=auto --paging=always "$README_FILE"
    else
      echo "✗ README.md not found at $README_FILE"
      return 1
    fi
  }}'''


def get_zsh_helpf(env_name):
    """Generate correct zsh helpf function for environment (identical to bash)."""
    return get_bash_helpf(env_name)


def get_fish_helpf(env_name):
    """Generate correct fish helpf function for environment."""
    return f'''function helpf
    set README_FILE "$FLOX_ENV_PROJECT/README.md"
    set README_URL "https://raw.githubusercontent.com/barstoolbluz/floxenvs/main/{env_name}/README.md"

    if test "$argv[1]" = "--help"
        echo "Usage: helpf [OPTIONS]"
        echo ""
        echo "View environment documentation"
        echo ""
        echo "Options:"
        echo "  --force    Force download fresh copy from GitHub"
        echo "  --help     Show this help message"
        echo ""
        echo "The README is cached locally and only downloaded if missing."
        return 0
    end

    if test "$argv[1]" = "--force"
        echo "Fetching latest README.md from GitHub..."
        if curl -fsSL "$README_URL" -o "$README_FILE"
            echo "✓ Downloaded README.md"
        else
            echo "✗ Failed to download README.md"
            return 1
        end
    else if not test -f "$README_FILE"
        echo "README.md not found, downloading..."
        if curl -fsSL "$README_URL" -o "$README_FILE"
            echo "✓ Downloaded README.md"
        else
            echo "✗ Failed to download README.md"
            return 1
        end
    end

    if test -f "$README_FILE"
        bat --style=auto --paging=always "$README_FILE"
    else
        echo "✗ README.md not found at $README_FILE"
        return 1
    end
end'''


def get_hook_readme_fetch(env_name):
    """Generate correct hook README fetch pattern."""
    return f'''  # Fetch README.md if not present
  README_FILE="$FLOX_ENV_PROJECT/README.md"
  if [ ! -f "$README_FILE" ]; then
    if curl -fsSL https://raw.githubusercontent.com/barstoolbluz/floxenvs/main/{env_name}/README.md -o "$README_FILE" 2>/dev/null; then
      echo "✓ Downloaded README.md (use 'helpf' to view)"
    fi
  fi'''


def check_packages(content):
    """Check if bat and curl are in [install] section."""
    install_section = re.search(r'\[install\](.*?)(?=\n\[|\Z)', content, re.DOTALL)
    if not install_section:
        return False, "No [install] section found"

    install_text = install_section.group(1)
    has_bat = 'bat.pkg-path' in install_text
    has_curl = 'curl.pkg-path' in install_text

    if not has_bat and not has_curl:
        return False, "Missing both bat and curl"
    elif not has_bat:
        return False, "Missing bat package"
    elif not has_curl:
        return False, "Missing curl package"
    return True, "bat and curl present"


def fix_hook_section(content, env_name):
    """Fix the hook section README fetch pattern."""
    hook_section = re.search(r'\[hook\]\s*\non-activate\s*=\s*\'\'\'(.*?)\'\'\'', content, re.DOTALL)
    if not hook_section:
        return content, False, "No hook section found"

    hook_content = hook_section.group(1)

    # Check if there's already a README fetch section
    readme_patterns = [
        r'# Fetch README\.md.*?fi\s*\n',  # Standard pattern
        r'README_FILE=.*?fi\s*\n',  # Any README_FILE pattern
        r'if.*?README.*?fi\s*\n',  # Any README conditional
    ]

    has_readme_fetch = any(re.search(pattern, hook_content, re.DOTALL) for pattern in readme_patterns)

    correct_fetch = get_hook_readme_fetch(env_name)

    if has_readme_fetch:
        # Replace existing README fetch with correct pattern
        for pattern in readme_patterns:
            hook_content = re.sub(pattern, '', hook_content, flags=re.DOTALL)

    # Add correct README fetch at the end (before the closing ''')
    hook_content = hook_content.rstrip() + '\n\n' + correct_fetch + '\n'

    # Reconstruct the full content
    new_content = content[:hook_section.start(1)] + hook_content + content[hook_section.end(1):]

    return new_content, True, "Hook section fixed"


def fix_bash_profile(content, env_name):
    """Fix bash profile helpf function."""
    bash_section = re.search(r'bash\s*=\s*\'\'\'(.*?)(?=\'\'\')', content, re.DOTALL)
    if not bash_section:
        return content, False, "No bash profile found"

    bash_content = bash_section.group(1)

    # Remove any existing helpf function
    bash_content = re.sub(r'\s*helpf\(\)\s*\{.*?\n\s*\}\s*(?:export -f helpf)?', '', bash_content, flags=re.DOTALL)

    # Add correct helpf function at the end
    correct_helpf = '\n' + get_bash_helpf(env_name) + '\n  export -f helpf\n'
    bash_content = bash_content.rstrip() + '\n' + correct_helpf

    # Reconstruct
    new_content = content[:bash_section.start(1)] + bash_content + content[bash_section.end(1):]

    return new_content, True, "Bash profile fixed"


def fix_zsh_profile(content, env_name):
    """Fix zsh profile helpf function."""
    zsh_section = re.search(r'zsh\s*=\s*\'\'\'(.*?)(?=\'\'\')', content, re.DOTALL)
    if not zsh_section:
        return content, False, "No zsh profile found"

    zsh_content = zsh_section.group(1)

    # Remove any existing helpf function
    zsh_content = re.sub(r'\s*helpf\(\)\s*\{.*?\n\s*\}', '', zsh_content, flags=re.DOTALL)

    # Add correct helpf function at the end
    correct_helpf = '\n' + get_zsh_helpf(env_name) + '\n'
    zsh_content = zsh_content.rstrip() + '\n' + correct_helpf

    # Reconstruct
    new_content = content[:zsh_section.start(1)] + zsh_content + content[zsh_section.end(1):]

    return new_content, True, "Zsh profile fixed"


def fix_fish_profile(content, env_name):
    """Fix fish profile helpf function if it exists."""
    fish_section = re.search(r'fish\s*=\s*\'\'\'(.*?)(?=\'\'\')', content, re.DOTALL)
    if not fish_section:
        return content, False, "No fish profile found"

    fish_content = fish_section.group(1)

    # Remove any existing helpf function
    fish_content = re.sub(r'\s*function helpf.*?end\s*', '', fish_content, flags=re.DOTALL)

    # Add correct helpf function at the end
    correct_helpf = '\n' + get_fish_helpf(env_name) + '\n'
    fish_content = fish_content.rstrip() + '\n' + correct_helpf

    # Reconstruct
    new_content = content[:fish_section.start(1)] + fish_content + content[fish_section.end(1):]

    return new_content, True, "Fish profile fixed"


def fix_environment(env_name):
    """Fix a single environment."""
    manifest_path = os.path.join(FLOXENVS_DIR, env_name, ".flox", "env", "manifest.toml")

    if not os.path.exists(manifest_path):
        return {
            'env': env_name,
            'status': 'SKIP',
            'reason': f'Manifest not found: {manifest_path}'
        }

    # Read manifest
    with open(manifest_path, 'r') as f:
        original_content = f.read()

    content = original_content
    changes = []

    # 1. Check packages
    pkg_ok, pkg_msg = check_packages(content)
    if not pkg_ok:
        changes.append(f"WARN: {pkg_msg}")

    # 2. Fix hook section
    content, hook_fixed, hook_msg = fix_hook_section(content, env_name)
    if hook_fixed:
        changes.append(f"Hook: {hook_msg}")

    # 3. Fix bash profile
    content, bash_fixed, bash_msg = fix_bash_profile(content, env_name)
    if bash_fixed:
        changes.append(f"Bash: {bash_msg}")

    # 4. Fix zsh profile
    content, zsh_fixed, zsh_msg = fix_zsh_profile(content, env_name)
    if zsh_fixed:
        changes.append(f"Zsh: {zsh_msg}")

    # 5. Fix fish profile (if exists)
    content, fish_fixed, fish_msg = fix_fish_profile(content, env_name)
    if fish_fixed:
        changes.append(f"Fish: {fish_msg}")

    # Write back if changed
    if content != original_content:
        with open(manifest_path, 'w') as f:
            f.write(content)

        return {
            'env': env_name,
            'status': 'FIXED',
            'changes': changes
        }
    else:
        return {
            'env': env_name,
            'status': 'OK',
            'reason': 'Already matches pattern'
        }


def main():
    print("=" * 80)
    print("Fixing Category D environments to match comfyui helpf pattern")
    print("=" * 80)
    print()

    results = []

    for env_name in CATEGORY_D_ENVS:
        print(f"Processing {env_name}...", end=" ")
        result = fix_environment(env_name)
        results.append(result)

        if result['status'] == 'FIXED':
            print(f"✓ FIXED")
            for change in result['changes']:
                print(f"  - {change}")
        elif result['status'] == 'OK':
            print(f"✓ OK ({result['reason']})")
        else:
            print(f"✗ {result['status']}: {result['reason']}")
        print()

    # Summary
    print("=" * 80)
    print("SUMMARY")
    print("=" * 80)

    fixed = [r for r in results if r['status'] == 'FIXED']
    ok = [r for r in results if r['status'] == 'OK']
    skipped = [r for r in results if r['status'] == 'SKIP']

    print(f"Total environments: {len(CATEGORY_D_ENVS)}")
    print(f"Fixed: {len(fixed)}")
    print(f"Already OK: {len(ok)}")
    print(f"Skipped: {len(skipped)}")
    print()

    if fixed:
        print("Environments fixed:")
        for r in fixed:
            print(f"  - {r['env']}")

    if skipped:
        print("\nEnvironments skipped:")
        for r in skipped:
            print(f"  - {r['env']}: {r['reason']}")

    return 0 if len(skipped) == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
