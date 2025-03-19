### 1Password Vault Configuration

Once you have the 1Password CLI set up, you'll need to customize the environment variables to match your specific 1Password vault structure. The default values in the `manifest.toml` are examples and will need to be modified:

```toml
[vars]
# 1password github config
OP_GITHUB_VAULT = "1password"           # Name of 1Password vault containing GitHub tokens
OP_GITHUB_TOKEN_ITEM = "repo"           # Name of the item storing GitHub token
OP_GITHUB_TOKEN_FIELD = "token"         # Field name containing the GitHub token

# 1password aws config
OP_AWS_VAULT = "1password"              # Name of 1Password vault containing AWS credentials
OP_AWS_CREDENTIALS_ITEM = "awskeyz"     # Name of the item storing AWS credentials
OP_AWS_USERNAME_FIELD = "username"      # Field name for AWS access key ID
OP_AWS_CREDENTIALS_FIELD = "credential" # Field name for AWS secret access key
```

**Important:** You must modify these environment variables to match your own 1Password vault structure:

1. **For GitHub access**: 
   - Set `OP_GITHUB_VAULT` to the name of your vault containing GitHub tokens
   - Set `OP_GITHUB_TOKEN_ITEM` to the name of your item storing the GitHub token
   - Set `OP_GITHUB_TOKEN_FIELD` to the field name containing your GitHub token

2. **For AWS access**:
   - Set `OP_AWS_VAULT` to the name of your vault containing AWS credentials
   - Set `OP_AWS_CREDENTIALS_ITEM` to the name of your item storing AWS credentials
   - Set `OP_AWS_USERNAME_FIELD` to the field name for your AWS access key ID
   - Set `OP_AWS_CREDENTIALS_FIELD` to the field name for your AWS secret access key

The path format used by the wrapper functions will be: `op://[VAULT]/[ITEM]/[FIELD]`# Flox Environment: Secure Credentials Management with 1Password 🔐

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
flox activate -r barstoolbluz/1pass
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

### Session Token Caching

The environment caches 1Password session tokens under:

```sh
$HOME/.config/op/1password-session.token
```

#### About 1Password Session Tokens

A session token is a temporary authentication credential that allows the 1Password CLI to access your vault without requiring you to enter your password for every operation.

**Security considerations:**

- **Convenience vs. Security**: Caching the token provides convenience by allowing you to use 1Password-integrated commands without re-authenticating, even if you temporarily exit the Flox environment.
- **Time-limited**: Session tokens are temporary and expire after a period of inactivity (typically 30 minutes), limiting exposure.
- **Local storage only**: The token is stored only on your local machine and is protected with file permissions (chmod 600).
- **Risk awareness**: If your system is compromised while a valid session token exists, an attacker could potentially access your 1Password vault until the token expires.

This approach balances security and usability. For higher security environments, you may want to modify the environment to avoid caching the token, though this will require re-authentication more frequently.

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
