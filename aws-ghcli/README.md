### 1Password Vault Configuration

Once you have the 1Password CLI set up, you need to configure the following items in your 1Password vault:

#### GitHub Configuration
- Vault: `1password` (configurable via `OP_GITHUB_VAULT`)
- Item name: `repo` (configurable via `OP_GITHUB_TOKEN_ITEM`)
- Field containing token: `token` (configurable via `OP_GITHUB_TOKEN_FIELD`)

#### AWS Configuration
- Vault: `1password` (configurable via `OP_AWS_VAULT`)
- Item name: `awskeyz` (configurable via `OP_AWS_CREDENTIALS_ITEM`)
- Field for access key ID: `username` (configurable via `OP_AWS_USERNAME_FIELD`)
- Field for secret access key: `credential` (configurable via `OP_AWS_CREDENTIALS_FIELD`)# Flox Environment: Secure Credentials Management with 1Password 🔐

This Flox environment provides a secure way to manage credentials for common developer tools by integrating with 1Password. It prevents credentials from being stored in unencrypted files on disk, significantly reducing the risk of credential leakage.

## Installed Tools

- **1Password CLI** (`op`): Used for secure credential management
- **AWS CLI 2** (`aws`): For interacting with AWS services
- **GitHub CLI** (`gh`): For interacting with GitHub repositories
- **Git** (full version): For version control
- **Gum**: A tool for glamorous shell scripts
- **Bat**: A cat clone with syntax highlighting and Git integration
- **Curl**: Command-line tool for transferring data with URLs

## Security Benefits ✅

Many development tools store credentials in unencrypted files:
- GitHub CLI stores tokens in `~/.config/gh/hosts.yml`
- AWS CLI stores credentials in `~/.aws/credentials`
- Git may cache credentials in plaintext in some configurations

This environment wraps these tools to avoid persistent credential storage by:
1. Fetching credentials from 1Password at runtime
2. Injecting them into commands via environment variables in ephemeral subshells
3. Ensuring credentials are never written to disk and exist only for the duration of the command

## How It Works

This environment implements wrapper functions for `git`, `gh`, and `aws` that:

1. Extract credentials from 1Password at runtime
2. Pass these credentials to the underlying commands securely
3. Clean up any temporary files after execution

Credentials are available only for the duration of the command and never written to unencrypted files.

### Authentication Methods

The wrapper functions use two different approaches for credential handling:

#### `op run` (for `gh` and `aws`)
- Used by the `gh` and `aws` wrappers
- Executes commands in an ephemeral subshell
- Retrieves secrets directly from 1Password and exports them as environment variables
- Credentials exist only within this ephemeral subshell
- When the command finishes executing, the subshell is destroyed, along with any credentials

#### `op read` (for `git`)
- Used by the `git` wrapper for operations requiring authentication
- Directly reads the token from 1Password
- Creates a temporary script (via `GIT_ASKPASS`) that outputs the token when Git requests it
- The token is never written to disk in plaintext (only to a temporary file that is immediately deleted)
- Benefits from the process isolation of the subshell, though this is not as strong as container isolation
- The temporary file and token are cleaned up when the command completes

Both methods ensure credentials are never persistently stored in unencrypted files and exist only for the duration needed to complete the command.

### Authentication Flow

1. On environment activation, you'll authenticate with 1Password
2. Your 1Password session token is stored for subsequent commands
3. When you run a wrapped command, it fetches the required credentials from 1Password
4. The credentials exist only for the duration of the command execution

## Prerequisites

### 1Password CLI Setup

This environment expects the 1Password CLI to be already set up on your system. Specifically, it looks for a config file at `~/.config/op/config`.

#### Option 1: Automatic Setup

You can use the provided wizard to set up 1Password CLI automatically:

```sh
flox activate -r barstoolbluz/setup-1pass
```

This wizard will guide you through the process of creating the necessary configuration.

#### Option 2: Manual Setup

Alternatively, you can set up the 1Password CLI manually by creating the config file yourself. The file should be structured like this:

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

You'll need to replace the example values with your actual 1Password account information.

## Usage 🛠️

### Activate the Environment
```sh
flox activate
```

Once the environment is activated, you can use `git`, `gh`, and `aws` commands as you normally would. The wrapper functions will handle credential management transparently:

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

## Compatible Systems

This environment is compatible with:
- aarch64-darwin (Apple Silicon Macs)
- aarch64-linux
- x86_64-darwin (Intel Macs)
- x86_64-linux

## Non-Interactive Shells ⚠️

The wrapper functions for `git`, `gh`, and `aws` are written to `$FLOX_ENV_CACHE/shell/`. This is necessary because:

- Wrapper functions defined interactively aren't available in non-interactive scripts
- `bash -i` doesn't always work as expected for sourcing interactive functions
- Scripts running in this Flox environment **must source** the relevant wrapper script before calling `git`, `gh`, or `aws`

For example, in a non-interactive bash or zsh script:

```sh
source "$FLOX_ENV_CACHE/shell/wrapper.sh"
git push origin main
```

For fish scripts:

```sh
source "$FLOX_ENV_CACHE/shell/wrapper.fish"
aws s3 ls
```

## Shell Compatibility

- **Bash** – `wrapper.sh`
- **Zsh** – `wrapper.sh`
- **Fish** – `wrapper.fish`

Flox automatically sources the appropriate wrapper script depending on which shell it's running in.

## Notes

The environment caches session tokens under:

```sh
$HOME/.config/op/1password-session.token
```

## Extensibility

This pattern can be extended to other CLI tools that require credentials. For example, you could add similar wrappers for:
- Databricks CLI
- Snowflake CLI
- Azure CLI
- Google Cloud Platform SDK
- Terraform CLI
- OpenStack CLI

## How to Extend

To wrap additional tools, follow this pattern:

```bash
toolname() { 
  op run --session "$OP_SESSION_TOKEN" --env-file <(echo -e "ENV_VAR1=op://vault/item/field1\nENV_VAR2=op://vault/item/field2") -- toolname "$@"; 
}
```

For tools that don't accept environment variables, you may need a custom approach similar to the Git wrapper.
