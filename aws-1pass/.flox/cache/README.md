# 🔐 A Flox Environment for AWS CLI with 1Password Integration

This environment integrates AWS CLI with 1Password to eliminate local credential storage. It fetches AWS credentials from your 1Password vault and injects them at runtime, without persisting plain-text creds to disk.

## ✨ What This Does

- Keeps your AWS credentials in 1Password where they belong
- Zero credential files on your local system
- Automatic auth and credential retrieval
- Secure session management
- Cross-platform support for macOS and Linux

## 🧰 What's Inside

- `AWS CLI v2` - Latest AWS command-line interface
- `1Password CLI` - Command-line access to your vaults
- `gum` - Clean terminal UI components
- `bat` - Powers the built-in `readme` function

## 🚀 Getting Started

### Prerequisites

- [Flox](https://flox.dev/get) installed
- A 1Password account with your AWS credentials stored
- That's it

### Setup in One Command

```sh
flox activate
```

This triggers a guided setup that:
1. Configures 1Password CLI
2. Sets session persistence preferences
3. Links to your AWS credentials in 1Password
4. Sets your default AWS region

## 📝 What You'll Need

During setup, have these ready:
- Your 1Password account URL
- Email address
- Secret key (34-character code)
- Password (you'll be prompted)
- Vault name containing AWS credentials
- Item name containing the credentials
- Field names for access key and secret key

## 🔧 How It Works

Every time you run `aws`:

1. The environment checks if you're authenticated with 1Password
2. If not, it prompts for your password
3. It pulls your credentials directly from 1Password
4. It passes them to AWS CLI via environment variables
5. No AWS creds stored on disk
6. 1Password session token can be enabled / disabled; if enabled, a temporary (<30 minutes) session token is persisted to disk.

## 🔥 Troubleshooting

1. **Authentication failures**:
   - Check that your 1Password vault and item names match exactly
   - Verify field names for credentials
   - Run setup again with `flox activate` after exiting

2. **AWS CLI errors**:
   - Ensure your AWS credentials in 1Password are valid
   - Check region settings in `~/.aws/config`
   - Run with `--debug` flag to see detailed error info

3. **Session token issues**:
   - 1Password sessions expire after 30 minutes of inactivity
   - If persistence is enabled, tokens are saved between sessions
   - If not, you'll need to re-authenticate on each new session

## 💻 System Support

Works on:
- macOS (ARM/Intel)
- Linux (ARM/x86)

## 🔍 Security Notes

- Session persistence keeps a token in `~/.config/op/1password-aws.session`
- This token expires after 30 minutes of inactivity 
- AWS credentials are never stored on disk, only passed via env vars
- All config files have 600 permissions (user-only read/write)

## About Flox

[Flox](https://flox.dev/docs) combines package and environment management, building on [Nix](https://github.com/NixOS/nix). It gives you Nix with a `git`-like syntax and an intuitive UX:

- **Declarative environments**. Software packages, variables, services, etc. are defined in simple, human-readable TOML format;
- **Content-addressed storage**. Multiple versions of packages with conflicting dependencies can coexist in the same environment;
- **Reproducibility**. The same environment can be reused across development, CI, and production;
- **Deterministic builds**. The same inputs always produce identical outputs for a given architecture, regardless of when or where builds occur;
- **World's largest collection of packages**. Access to over 150,000 packages—and millions of package-version combinations—from [Nixpkgs](https://github.com/NixOS/nixpkgs).
