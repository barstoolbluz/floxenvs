# Secure Credentials Management for CLI Workflows with Flox and 1Password 🔐

## Table of Contents
- [Overview](#overview)
- [Security Benefits](#security-benefits-)
- [How It Works](#how-it-works)
- [Quick Start](#quick-start)
- [1Password Vault Configuration](#1password-vault-configuration)
- [Usage](#usage-)
- [Available Commands](#available-commands)
- [CI/CD Integration](#cicd-integration)
- [Shell Compatibility](#shell-compatibility)
- [Extensibility](#extensibility)
  - [Extending to Other CLI Tools](#extending-to-other-cli-tools)
  - [Extending to Other CI Environments](#extending-to-other-ci-environments)
- [Prerequisites](#prerequisites)
- [Notes](#notes)
- [Troubleshooting](#troubleshooting)
- [About Flox](#about-flox)

## Overview

This environment integrates with 1Password to create a more secure pattern for managing credentials in cross-platform workflows. Instead of storing credentials in unencrypted files on disk, it fetches them at runtime and keeps them only for the duration of the command.

**Built-in CLI Tools:**
- Git (`git`)
- GitHub CLI (`gh`)
- AWS CLI (`aws`)
- Additional packages (see [Installed Packages](#installed-packages))

The environment's manifest defines all tools declaratively in TOML format ([see About Flox](#about-flox)), and they install automatically when you activate the environment—no manual installation needed. Shell function wrappers intercept calls to these tools and handle credentials securely. You can easily extend this pattern to include other CLI tools ([see Extensibility](#extensibility)).

**Compatible systems:**
- Apple Silicon Macs (aarch64-darwin)
- Intel Macs (x86_64-darwin)
- Linux ARM (aarch64-linux)
- Linux x86 (x86_64-linux)

## Security Benefits ✅

Many popular CLI tools store credentials in unencrypted files:
- GitHub CLI stores tokens in `~/.config/gh/hosts.yml`;
- AWS CLI stores credentials in `~/.aws/credentials`;
- Git does not cache credentials by default, but some configurations store credentials in plaintext.

This environment mitigates these attack vectors by:
1. Fetching credentials from 1Password at runtime
2. Injecting them via environment variables in ephemeral subshells
3. Ensuring credentials exist only for the duration of the command
4. Preventing unencrypted credentials from persisting on disk

### Bootstrap Security Model

When you run `op-setup`, only device-specific data is stored persistently:
- **Secret Key** (designed by 1Password to be stored per-device) → `~/.config/op/config`
- **Session tokens** (expire after 30 minutes) → `~/.config/op/1password-session.token`
- **Master Password** is never stored and must be re-entered when sessions expire

This follows 1Password's security model: Secret Keys are device-specific cryptographic keys that are safe to persist, while Master Passwords must be kept only in memory.

## How It Works

The environment's wrapper functions for `git`, `gh`, and `aws`:

1. Extract credentials from 1Password at runtime;
2. Pass these credentials securely to the underlying commands;
3. Clean up any temporary files after execution.

### Authentication Methods

The environment uses two approaches for credential handling:

#### `op run` (for `gh` and `aws`)
- Executes commands in an ephemeral subshell;
- Retrieves secrets directly from 1Password and exports them as environment variables;
- Keeps credentials only within the subshell and destroys them when the command finishes.

#### `op read` (for `git`)
- Reads the token directly from 1Password;
- Creates a temporary script (via `GIT_ASKPASS`) that outputs the token when Git requests it;
- Uses trap-based cleanup mechanisms to remove temporary files.

### Environment-Aware Authentication Flow

The environment adapts its authentication method based on context:

- [Local Development](#local-development-setup) - Uses interactive authentication with persistent session tokens;
- [CI/CD](#cicd-integration) - Uses non-interactive authentication with service accounts.

### State Detection and Graceful Fallback

The environment continuously monitors your 1Password authentication state:

**Three states:**
- `authenticated` - Active session via desktop app or `op-login`
- `needs_login` - Account configured but session expired
- `needs_setup` - No 1Password account configured

**Graceful degradation:**
If 1Password is unavailable, CLI tools automatically fall back to standard authentication:

```bash
$ gh repo list
⚠️  Not signed in to 1Password. Run 'op-login'
Falling back to standard gh authentication...
# Command continues with standard gh auth
```

This ensures your tools **always work**, whether or not 1Password is available.

## Quick Start

1. [Install the Flox CLI](#prerequisites) (one-time Flox setup)
2. [Configure your 1Password vault structure](#1password-vault-configuration) (edit `manifest.toml`)
3. Activate the environment: `flox activate`
4. Run the setup wizard when prompted: `op-setup`
5. Use `git`, `gh`, and `aws` commands normally - credentials are managed automatically

## 1Password Vault Configuration

### Local Development Setup

You'll need to customize environment variables to match your 1Password vault structure:

```toml
[vars]
# 1Password GitHub config
OP_GITHUB_VAULT = "vault"                  # Name of 1Password vault containing GitHub tokens
OP_GITHUB_TOKEN_ITEM = "token_item"        # Name of the item storing GitHub token
OP_GITHUB_TOKEN_FIELD = "token_field"      # Field name containing the GitHub token

# 1Password AWS config
OP_AWS_VAULT = "vault"                     # Name of 1Password vault containing AWS credentials
OP_AWS_CREDENTIALS_ITEM = "aws_creds"      # Name of the item storing AWS credentials
OP_AWS_USERNAME_FIELD = "username"         # Field name for AWS access key ID
OP_AWS_CREDENTIALS_FIELD = "credentials"   # Field name for AWS secret access key
```

**Important:** Modify these environment variables in your `manifest.toml` to match your own 1Password vault structure.

## Usage 🛠️

### Activate the Environment
```sh
flox activate
```

Once activated, use the wrapped commands normally:

### GitHub CLI (gh)
```sh
# Check auth status
gh auth status

# List repositories
gh repo list

# Clone a repository
gh repo clone org/repo
```

### Git
```sh
# Push to a repository (auth handled automatically)
git push origin main

# Pull from a repository
git pull

# Clone a private repository
git clone https://github.com/organization/private-repo.git
```

### AWS CLI
```sh
# List S3 buckets
aws s3 ls

# Describe EC2 instances
aws ec2 describe-instances
```

### When 1Password is Unavailable

All CLI tools gracefully fall back to standard authentication if 1Password isn't configured or your session expires:

```bash
$ aws s3 ls
⚠️  Not signed in to 1Password. Run 'op-login'
Falling back to standard aws authentication...
# Uses standard AWS credential chain (~/.aws/credentials, env vars, IAM roles)
```

**State-aware guidance:**
- `needs_setup` → "Run 'op-setup' for automated setup"
- `needs_login` → "Run 'op-login' to sign in"
- Desktop app users → Works automatically when app is unlocked

This ensures your workflow continues even if 1Password is temporarily unavailable.

### Non-Interactive Shells ⚠️

For scripts, source the wrapper file before using the commands:

```sh
# Bash scripts
source "$FLOX_ENV_CACHE/shell/wrapper.bash"
git push origin main

# Zsh scripts
source "$FLOX_ENV_CACHE/shell/wrapper.zsh"
gh repo list

# Fish scripts
source "$FLOX_ENV_CACHE/shell/wrapper.fish"
aws s3 ls
```

## Available Commands

The environment provides these commands for 1Password management:

### `op-setup`

Smart setup dispatcher that detects your current state and takes appropriate action.

**Usage:**
```bash
op-setup
```

**Behavior:**
- **Not configured** → Runs interactive bootstrap wizard
- **Needs login** → Runs `op-login` automatically
- **Already authenticated** → Shows current authentication info

**When to use:** First-time setup or when unsure of your current state.

---

### `op-login`

Re-authenticate with an existing 1Password account.

**Usage:**
```bash
op-login
```

**Behavior:**
- Prompts for your Master Password (up to 3 attempts)
- Creates a new session token (30-minute expiry)
- Exports `OP_SESSION_TOKEN` for current shell

**When to use:** When your session expires (after 30 minutes of inactivity).

**Note:** If no account is configured, `op-login` will offer to run `op-setup` for you.

---

### State Variables

The environment exports `$OP_STATE` indicating your authentication state:

- `authenticated` - Active session available
- `needs_login` - Account configured, session expired
- `needs_setup` - No account configured

**Check your state:**
```bash
echo $OP_STATE
```

**Check in activation help:**
The help message shown during `flox activate` displays your current state and suggests the appropriate command to run.

## CI/CD Integration

For CI/CD environments:

1. **Create a 1Password Service Account**:
   - Follow [1Password's documentation](https://developer.1password.com/docs/service-accounts) to create a service account
   - Generate a service account token with appropriate access to your vaults

2. **Configure GitHub Actions**:
   - Add the service account token as a secret in your GitHub repository:
     ```
     OP_SERVICE_ACCOUNT_TOKEN=your-service-account-token
     ```

3. **GitHub Actions Workflow Example**:
   ```yaml
   name: CI with 1Password Integration
   
   on:
     push:
       branches: [ main ]
   
   jobs:
     build:
       runs-on: ubuntu-latest
       
       steps:
       - uses: actions/checkout@v3
       
       - name: Set up Flox
         uses: flox-examples/setup-flox@v1
       
       - name: Activate environment with credentials
         env:
           OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
         run: flox activate
       
       # Your other steps that use the secure credentials
   ```

When running in GitHub Actions, the environment automatically detects the CI platform and uses the service account token for non-interactive authentication.

## Shell Compatibility

The environment supports three shells, each with its own wrapper script:

- **Bash** – `wrapper.bash`
- **Zsh** – `wrapper.zsh`
- **Fish** – `wrapper.fish`

Each wrapper implements shell-specific trap-based cleanup mechanisms.

## Extensibility

You can extend this environment in two key dimensions:

### Extending to Other CLI Tools

You can apply this pattern to many other CLI tools that require credentials:

- Databricks CLI
- Snowflake CLI
- Azure CLI
- Google Cloud Platform SDK
- Terraform CLI
- OpenStack CLI

#### How to Extend CLI Tools

To support a new tool:

1. **Add environment variables** to your `manifest.toml`:

```toml
[vars]
# Existing vars
OP_GITHUB_VAULT = "vault"
# ...

# New vars for your tool (e.g., Databricks)
OP_DATABRICKS_VAULT = "vault"              # Vault containing Databricks credentials
OP_DATABRICKS_ITEM = "databricks_creds"    # Item storing Databricks credentials
OP_DATABRICKS_HOST_FIELD = "host"          # Field for Databricks host
OP_DATABRICKS_TOKEN_FIELD = "token"        # Field for Databricks token
```

2. **Write a wrapper function** in the `on-activate` hook:

```bash
# Example for Databricks CLI
databricks() {
  op run --session "$OP_SESSION_TOKEN" --env-file <(echo -e "DATABRICKS_HOST=op://$OP_DATABRICKS_VAULT/$OP_DATABRICKS_ITEM/$OP_DATABRICKS_HOST_FIELD\nDATABRICKS_TOKEN=op://$OP_DATABRICKS_VAULT/$OP_DATABRICKS_ITEM/$OP_DATABRICKS_TOKEN_FIELD") -- databricks "$@";
}
```

**Best Practice: Include Graceful Fallback**

For production use, add state-aware fallback logic like the built-in `gh()` and `aws()` wrappers:

```bash
databricks() {
  if [[ -n "$OP_SESSION_TOKEN" ]]; then
    op run --session "$OP_SESSION_TOKEN" --env-file <(echo -e "DATABRICKS_HOST=op://...\nDATABRICKS_TOKEN=op://...") -- databricks "$@"
  else
    case "$OP_STATE" in
      needs_setup) echo "⚠️  1Password not configured. Run 'op-setup'" ;;
      needs_login) echo "⚠️  Not signed in. Run 'op-login'" ;;
    esac
    echo "Falling back to standard databricks authentication..."
    command databricks "$@"
  fi
}
```

This ensures your tool works even when 1Password is unavailable.

3. **Add environment detection** to your wrapper function

### Extending to Other CI Environments

The environment already includes a modular `detect_environment()` function that can be extended to support additional CI platforms:

```bash
detect_environment() {
  # GitHub Actions detection
  if [[ -n "$GITHUB_ACTIONS" ]]; then
    echo "github_actions"
    return 0
  fi
  
  # Add detection for other CI platforms here if needed:
  # Example:
  # if [[ -n "$CIRCLECI" ]]; then
  #   echo "circle_ci"
  #   return 0
  # fi
  
  # No CI detected - we're local
  echo "local"
  return 0
}
```

#### How to Extend to Other CI Platforms

1. **Identify the environment variable** that uniquely identifies your CI platform:
   - CircleCI: `$CIRCLECI`
   - GitLab CI: `$GITLAB_CI`
   - Jenkins: `$JENKINS_URL`
   - Travis CI: `$TRAVIS`
   - Azure DevOps: `$TF_BUILD`
   - Buildkite: `$BUILDKITE`

2. **Modify the `detect_environment()` function** to recognize the new platform:

```bash
detect_environment() {
  # GitHub Actions detection
  if [[ -n "$GITHUB_ACTIONS" ]]; then
    echo "github_actions"
    return 0
  fi
  
  # CircleCI detection
  if [[ -n "$CIRCLECI" ]]; then
    echo "circle_ci"
    return 0
  fi
  
  # GitLab CI detection
  if [[ -n "$GITLAB_CI" ]]; then
    echo "gitlab_ci"
    return 0
  fi
  
  # Jenkins detection
  if [[ -n "$JENKINS_URL" ]]; then
    echo "jenkins"
    return 0
  fi
  
  # No CI detected - we're local
  echo "local"
  return 0
}
```

3. **Customize the authentication logic** for your CI platform if needed:

```bash
authenticate_1password() {
  SESSION_FILE="$HOME/.config/op/1password-session.token"
  
  # Check if we already have a valid session (file-based for local, env var for CI)
  local env=$(detect_environment)
  
  if [[ "$env" == "local" ]]; then
    # Local environment authentication logic...
  elif [[ "$env" == "github_actions" ]]; then
    # GitHub Actions authentication logic...
  elif [[ "$env" == "circle_ci" ]]; then
    # CircleCI-specific authentication logic
    echo "CircleCI environment detected"
    
    if [[ -z "$OP_SERVICE_ACCOUNT_TOKEN" ]]; then
      echo "Error: OP_SERVICE_ACCOUNT_TOKEN is not set. Required for CircleCI authentication."
      return 1
    fi
    
    # CircleCI may have specific requirements or optimizations
    echo "Authenticating with 1Password service account for CircleCI..."
    if OP_SESSION_TOKEN=$(op signin --raw --service-account-token "$OP_SERVICE_ACCOUNT_TOKEN" 2>/dev/null); then
      export OP_SESSION_TOKEN
      echo "Successfully authenticated with 1Password service account"
      return 0
    else
      echo "Failed to authenticate with 1Password service account"
      return 1
    fi
  elif [[ "$env" == "gitlab_ci" ]]; then
    # GitLab CI-specific authentication logic
    # ...
  fi
}
```

4. **Create CI platform-specific configuration** for your workflows:

**CircleCI:**
```yaml
version: 2.1
jobs:
  build:
    docker:
      - image: cimg/base:current
    steps:
      - checkout
      - run:
          name: Install Flox
          command: curl https://get.flox.dev/install | bash
      - run:
          name: Activate environment
          command: |
            export PATH="$HOME/.flox/bin:$PATH"
            export OP_SERVICE_ACCOUNT_TOKEN=$OP_SERVICE_ACCOUNT_TOKEN
            flox activate
      # Your other steps that use the secure credentials
```

**GitLab CI:**
```yaml
stages:
  - build

build:
  stage: build
  image: ubuntu:latest
  before_script:
    - apt-get update && apt-get install -y curl
    - curl https://get.flox.dev/install | bash
    - export PATH="$HOME/.flox/bin:$PATH"
  script:
    - export OP_SERVICE_ACCOUNT_TOKEN=$OP_SERVICE_ACCOUNT_TOKEN
    - flox activate
    # Your other steps that use the secure credentials
  variables:
    OP_SERVICE_ACCOUNT_TOKEN: ${OP_SERVICE_ACCOUNT_TOKEN}
```

By extending environment detection and auth logic this way, you get (more) secure credential management that works across virtually any CI/CD platform.

## Prerequisites

### Flox CLI

The only required dependency is the [Flox CLI](https://flox.dev/docs/).

**Installation:**

1. Visit the [Flox download page](https://flox.dev/get)
2. Download the appropriate package for your system:
   - Linux (Intel/ARM): Choose `.deb` or `.rpm` package
   - macOS (Intel/Apple Silicon): Download `.pkg` installer
3. Follow your OS's standard installation procedure

### 1Password CLI Setup

This environment includes **built-in automation** for 1Password CLI setup.

**Recommended: Automated Setup (Built-in)**

After activating the environment, simply run:

```bash
op-setup
```

The interactive wizard guides you through:
1. Collecting your credentials (sign-in address, email, Secret Key, Master Password)
2. Configuring your 1Password CLI account
3. Authenticating and creating a session token

**What you'll need:**
- Your 1Password sign-in address (e.g., `mycompany.1password.com`)
- Your email address
- Your Secret Key (starts with `A3-`, found in 1Password account settings)
- Your Master Password

**Advanced: Manual Setup**

If you prefer manual configuration, create `~/.config/op/config` with your account info:

```json
{
  "latest_signin": "your_organization",
  "device": "2xdzachbrog69jockvku6qshakeyerhips",
  "accounts": [
    {
      "shorthand": "your_org_shorthand",
      "accountUUID": "H4D9BhyE9WmS7-MbaG0qWDsaOi",
      "url": "https://your-team.1password.com",
      "email": "your.email@example.com",
      "accountKey": "Y6bXKI-Z6_9ONAkwYRbFnQRcn3lyIEY4DDpgkURh",
      "userUUID": "GR9EqmcQVmIGa6XCIpW8hue6Ef"
    }
  ]
}
```

Then run `op signin` manually.

**Note:** The automated `op-setup` wizard is strongly recommended for most users.

## Notes

### Session Token Handling

#### Local Environment
The environment caches 1Password session tokens under:

```sh
$HOME/.config/op/1password-session.token
```

#### CI Environment
In CI environments, session tokens are kept exclusively in memory as environment variables.

**Security considerations:**

- **Convenience vs. Security**: Caching tokens offers convenience but introduces potential vulnerabilities
- **Time-limited**: Session tokens expire after inactivity (typically 30 minutes)
- **Local storage only**: File permissions (chmod 600) protect tokens in local environments
- **CI security**: Tokens remain only in memory in CI environments, never written to disk

This approach balances security and usability. Consider avoiding token caching entirely for high-security environments.

### Installed Packages

This environment includes:

- **1Password CLI** (`op`): For secure credential management
- **AWS CLI 2** (`aws`): For interacting with AWS services
- **GitHub CLI** (`gh`): For interacting with GitHub repositories
- **Git** (`git`): For version control
- **Gum** (`gum`): A tool for glamorous shell scripts
- **Bat** (`bat`): A cat clone with syntax highlighting
- **Curl** (`curl`): Command-line tool for transferring data

Run `flox edit` to view or modify this environment's configuration, or add packages with `flox install <package_name>`.

## Troubleshooting

### Session Expired

**Symptom:** Commands show `⚠️  Not signed in to 1Password. Run 'op-login'`

**Solution:**
```bash
op-login
```

Re-enter your Master Password to create a new session.

---

### No Account Configured

**Symptom:** Activation shows `❌ Not configured - run op-setup`

**Solution:**
```bash
op-setup
```

Follow the interactive wizard to configure your account.

---

### Wrong Credentials or Account Switch

**Symptom:** Authentication fails or you need a different account

**Solution:**
```bash
# Remove existing configuration
rm ~/.config/op/config
rm ~/.config/op/1password-session.token

# Run setup wizard
op-setup
```

---

### Verify Current State

Check your authentication state anytime:

```bash
# Check state variable
echo $OP_STATE

# Check 1Password authentication
op whoami

# List configured accounts
op account list
```

---

### Desktop App Integration

If you have the 1Password desktop app installed and unlocked:
- The CLI automatically uses it for authentication
- You don't need to run `op-setup` or `op-login`
- The environment detects this and shows `authenticated` state

---

### Commands Work Without 1Password

All CLI tools (`gh`, `aws`, `git`) gracefully fall back to standard authentication if 1Password is unavailable. This is **by design** - your tools will always work.

## About Flox

[Flox](https://flox.dev) combines package and environment management, building on [Nix](https://github.com/NixOS/nix). It gives you Nix with a `git`-like syntax and an intuitive UX:

- **Declarative environments**. Software packages, variables, services, etc. are defined in simple, human-readable TOML format;
- **Content-addressed storage**. Multiple versions of packages with conflicting dependencies can coexist in the same environment;
- **Reproducibility**. The same environment can be reused across development, CI, and production;
- **Deterministic builds**. The same inputs always produce identical outputs for a given architecture, regardless of when or where builds occur;
- **World's largest collection of packages**. Access to over 150,000 packages—and millions of package-version combinations—from [Nixpkgs](https://github.com/NixOS/nixpkgs).
