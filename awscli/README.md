# 🔐 A Flox Environment for AWS CLI Auth Using a Local Keyring

This Flox environment enables secure AWS CLI authentication by storing AWS credentials locally using standard methods. It gives you two storage options:

1. **System keyring/keychain** (preferred) - Uses OS security infrastructure
2. **Encrypted local file** (fallback) - Encrypts your credentials with a system-derived key

## ✨ Features

- Locks down AWS credentials in your system keyring or in an encrypted file
- Handles AWS CLI auth automatically without manual credential entry
- Works across platforms (macOS, Linux)
- Hooks into Bash, Zsh, and Fish shells
- Includes a no-nonsense setup wizard that doesn't waste your time

## 🧰 Included Tools

The environment packs these essential tools:

- `awscli2` - AWS CLI for interacting with AWS services
- `gum` - Terminal UI toolkit powering the setup wizard
- `bat` - Better `cat` with syntax highlighting
- `curl` - Solid HTTP client for API testing
- `openssl` - Cryptography toolkit backing the security layer
- `jq` - Pretty JSON parser

## 🏁 Getting Started

### 📋 Prerequisites

- AWS account
- AWS Access Key ID and Secret Access Key
- [Flox](https://flox.dev/get) installed on your system

### 💻 Installation & Activation

Jump in with:

1. Clone this repo

```sh
git clone https://github.com/barstoolbluz/awscli && cd awscli
```

2. Run:

```sh
flox activate
```

This command:
- Pulls in all dependencies
- Fires up the auth setup wizard
- Drops you into the Flox env with AWS CLI ready to go

### 🧙 Setup Wizard

First-time activation triggers a wizard that:

1. Walks you through AWS credential creation if needed
2. Locks your credentials in the system keyring or encrypted file
3. Sets up shell wrapper functions for transparent authentication

## 📝 Usage

After setup, you can directly run AWS CLI commands:

```bash
# List S3 buckets
aws s3 ls

# Describe EC2 instances
aws ec2 describe-instances

# List IAM users
aws iam list-users
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

1. Pull your credentials from secure storage
2. Inject them as environment variables for AWS CLI
3. Clean up after command execution

### 🔄 Session Token Support

The environment fully supports:
- Long-term IAM user credentials
- Short-term session tokens for temporary access
- Multi-factor authentication workflows

## 🔧 Troubleshooting

If AWS auth breaks:

1. **Auth fails in environment**: 
   - Exit the environment
   - Run `flox activate` again; if config is FUBAR, this will re-trigger setup
   
2. **Persistent failures**:
   - Exit the environment
   - Nuke the local repo folder
   - Either:
     - Clone the repo again, or
     - Create (`mkdir`) a new repo folder and run `flox pull --copy barstoolbluz/awscli`
   - Enter clean environment with `flox activate`

3. **Keyring issues**: 
   - The wizard will fall back to encrypted file storage

## 💻 System Compatibility

This works on:
- macOS (ARM64, x86_64)
- Linux (ARM64, x86_64)

## 🔒 Security Considerations

- Credentials never exist as plaintext files
- System keyring implements OS-native security
- Encrypted files use system-derived keys that can't be easily guessed
- Network traffic only occurs during AWS API validation
- All sensitive files receive restricted permissions (600)

**Linux Keyring Note**: 
On Linux, with both GNOME Keyring and KWallet it is possible to dump credentials if an attacker gains access to your active, unlocked session. While sufficient for most use cases, they don't match the security of dedicated password managers.

For hardened environments:
- Consider dedicated password managers or AWS SSO for credential storage
- Lock your system when you step away

## 📚 Additional Resources

- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [AWS Credential Management](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
