# Flox Environment: GitHub + AWS with 1Password Integration

## Overview

This Flox environment sets up a development workspace with `git`, `gh`, and `awscli2`, integrating with 1Password for secure credential management. It ensures seamless authentication for GitHub and AWS by wrapping CLI commands to retrieve tokens and keys dynamically from 1Password.

## Installed Packages

- `gitFull`: Full Git installation.
- `gh`: GitHub CLI.
- `awscli2`: AWS CLI v2.
- `_1password`: Required for credential retrieval.
- `gum`: Lightweight interactive shell utilities.

## How It Works

- On activation, the environment checks for an active 1Password session.
- If not authenticated, it prompts for 1Password login and stores the session token.
- Wrapper functions redefine `git`, `gh`, and `aws` to pull credentials from 1Password dynamically:
  - `git` auto-injects GitHub tokens for operations like `push`, `pull`, `clone`, etc.
  - `gh` runs with GitHub authentication from 1Password.
  - `aws` retrieves AWS credentials from 1Password and injects them as environment variables.

### Non-Interactive Shells

The wrapper functions for `git`, `gh`, and `aws` are written to `$FLOX_ENV_CACHE/shell/`. This is necessary because:

- Wrapper functions defined interactively aren't available in non-interactive scripts.
- `bash -i` doesn’t always work as expected for sourcing interactive functions.
- Scripts running in this Flox environment **must source** the relevant wrapper script before calling `git`, `gh`, or `aws`.

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

## Usage

### Activate the Environment
```sh
flox activate
```

### GitHub CLI (gh)
Runs with GitHub authentication from 1Password:

```sh
gh auth status
gh repo clone org/repo
```

### Git
Automatically retrieves and injects GitHub tokens for authentication:

```sh
git push origin main
```

### AWS CLI
Fetches AWS credentials dynamically:

```sh
aws s3 ls
```

## Shell Compatibility
Bash – `wrapper.sh`
Zsh – `wrapper.sh`
Fish – `wrapper.fish`

Wrapper scripts are automatically sourced on activation in Flox shells.

## Supported Systems

Linux – `aarch64-linux`, `x86_64-linux`
macOS – `aarch64-darwin`, `x86_64-darwin`


## Notes
The environment caches session tokens under:

```sh
$HOME/.config/op/1password-session.token
```

For non-interactive scripts, source the relevant wrapper script before using `git`, `gh`, or `aws`.
