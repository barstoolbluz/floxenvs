# 🔐 A Flox Environment for GitHub CLI Auth Using a Local Keyring

This Flox environment permits (more) secure GitHub CLI auth by storing GitHub tokens and Git credentials locally using standard methods. It gives you two storage options:

1. **System keyring/keychain** (preferred) - Uses OS security infrastructure;
2. **Encrypted local file** (fallback) - Encrypts your credentials with a system-derived key.

## ✨ Features

- Stores GitHub tokens and Git credentials in your system keyring or in encrypted files;
- Handles GitHub CLI & Git auth automatically without manually entering credentials;
- Works across platforms (macOS, Linux, Windows/WSL2);
- Hooks into Bash, Zsh, and Fish shells;
- Includes a clean, elegant setup wizard that walks you through the config;
- Also configures Git user identity information if needed.

## 🧰 Included Tools

The environment packs these essential tools:

- `gh` - GitHub CLI for interacting with GitHub repositories
- `git` - Version control system
- `gum` - Terminal UI toolkit powering the setup wizard
- `bat` - Better `cat` with syntax highlighting
- `curl` - Solid HTTP client for API testing
- `openssl` - Cryptography toolkit backing the security layer
- `coreutils` - Includes required GNU tools # included for macOS compatibility
- `gnused` - GNU `sed` editor # included for macOS compatibility
- `gawk` - GNU implementation of `awk` # included for macOS compatibility
- `gnugrep` - GNU implementation of `grep` # included for macOS compatibility

## 🏁 Getting Started

### 📋 Prerequisites

- GitHub account
- GitHub Personal Access Token with appropriate permissions
- [Flox](https://flox.dev/get) installed on your system

### 💻 Installation & Activation

Jump in with:

1. Clone this repo

```sh
git clone https://github.com/yourusername/ghcli && cd ghcli
```

2. Run:

```sh
flox activate
```

This command:
- Pulls in all dependencies;
- Fires up the auth setup wizard;
- Drops you into the Flox env with GitHub CLI ready to go.

### 🧙 Setup Wizard

First-time activation triggers a wizard that:

1. Walks you through GitHub token creation if needed;
2. Locks your token in the system keyring or encrypted file;
3. Sets up shell wrapper functions for transparent auth;
4. Configures Git credentials for GitHub;
5. Sets up Git `user.name` and `user.email` if not already configured;

## 📝 Usage

After setup, you can directly run GitHub CLI commands:

```bash
# List repositories
gh repo list

# Create a pull request
gh pr create

# View issues
gh issue list
```

You can also use Git commands without credential prompts:

```bash
# Clone a repository
git clone https://github.com/username/repo.git

# Push changes
git push

# Pull updates
git pull
```

Auth happens automatically via your configured mechanism.

## 🔍 How It Works

### 🛡️ Security Approach

We implement a two-tiered storage strategy:

1. **Primary Storage**: System keyring/keychain
   - Uses OS security mechanisms
   - Gets the same protection as your system credentials

2. **Fallback Storage**: Encrypted file
   - Implements AES-256-CBC encryption
   - Derives keys from unique system attributes:
     - Username
     - Hostname
     - Machine ID
   - Creates deterministic but unique keys for each system

### 🐚 Shell Integration

The environment builds shell-specific wrappers that:

1. Pull your credentials from secure storage;
2. Inject them as environment variables for GitHub CLI;
3. Configure Git to use appropriate credential helpers.

### 🔧 Git Credential Management

The environment configures Git's credential system to:

- Use macOS Keychain on macOS systems;
- Use the system keyring (secret-tool) on Linux when available;
- Fall back to encrypted files when system keyring is unavailable;
- Set up `git` `user.name` and `user.email` for commit attribution.

## 🔧 Troubleshooting

If GitHub auth breaks:

1. **Auth fails in environment**: 
   - Exit the environment;
   - Run `flox activate` again; if config is corrupted, this should re-trigger setup
   
2. **Persistent failures**:
   - Exit the environment;
   - Nuke the `~/.cache/flox/ghcli/` folder;
   - Either:
     - Clone the repo again; or
     - Create (`mkdir`) a new repo folder and run `flox pull --copy yourusername/ghcli`;
   - Enter clean environment with `flox activate`.

3. **Keyring issues**: 
   - If no system keyring is available / detected, the wizard falls back to encrypted file storage.

## 💻 System Compatibility

This works on:
- macOS (ARM64, x86_64)
- Linux (ARM64, x86_64)

## 🔒 Security Considerations

- Tokens and credentials never exist as plaintext files;
- System keyring implements OS-native security;
- Encrypted files use system-derived keys that can't be easily guessed;
- Network traffic only occurs during GitHub API validation;
- All sensitive files receive restricted permissions (600).

**Linux Keyring Note**: 
On Linux, with both GNOME Keyring and KWallet it is possible to dump credentials if an attacker gains access to your active, unlocked session. While sufficient for most use cases, they don't match the security of dedicated password managers.

For hardened environments:
- Consider dedicated password managers for credential storage;
- Lock your system when you step away? (d'uh and/or d'uh?)

## 📚 Additional Resources

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [Git Credential Storage](https://git-scm.com/docs/gitcredentials)
- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [Git Configuration](https://git-scm.com/docs/git-config)

## 🔗 Key Features of Flox

[Flox](https://flox.dev/docs) builds on [Nix](https://github.com/NixOS/nix) to provide:

- **Declarative environments** - Software, variables, services defined in TOML
- **Content-addressed storage** - Multiple package versions coexist without conflicts
- **Reproducibility** - Same environment across dev, CI, and production
- **Deterministic builds** - Same inputs always produce identical outputs
- **Huge package collection** - Access to 150,000+ packages from Nixpkgs

## 📝 License

MIT
