# Flox CLI Authentication Framework

A modular and extensible authentication framework for securing CLI tool credentials in Flox environments.

## Overview

This framework provides secure credential management for CLI tools in Flox environments. It features:

- Secure storage of credentials using platform-native keychains
- Automatic authentication on environment activation
- Interactive configuration wizard
- Pluggable architecture for adding new CLI tools
- Built-in support for GitHub CLI and AWS CLI

## Key Features

### Secure Credential Storage

Credentials are stored securely using:
- macOS Keychain on macOS
- libsecret/Secret Service on Linux with GNOME
- Encrypted files as fallback

The framework never stores credentials in plaintext and respects platform security best practices.

### Configuration Management

The system maintains a simple JSON configuration file to track enabled providers. This file is stored in `$FLOX_ENV_CACHE/auth_config.json`.

### Multiple CLI Support

Pre-configured support for:
- GitHub CLI (`gh`)
- AWS CLI (`aws`)

Easily extensible to support other CLI tools like:
- Azure CLI
- Databricks CLI
- Google Cloud CLI
- Kubernetes configurations
- Any other API token-based CLI tools

## Usage

### Basic Usage

When activating your Flox environment, authentication happens automatically:

```bash
flox activate
# Automatically authenticates enabled CLI tools
```

If credentials are already stored securely, no prompts will appear. Otherwise, you'll be asked to provide credentials for enabled tools.

### Managing Authentication Providers

Use the configuration wizard to manage authentication providers:

```bash
flox-auth-configure
```

This interactive menu lets you:
- Enable/disable authentication providers
- Create new provider templates
- View currently enabled providers
- Run authentication manually

### Adding New CLI Tools

1. Run the configuration wizard:
   ```bash
   flox-auth-configure
   ```

2. Select "Create new provider template"

3. Enter a name for the CLI tool (e.g., "azure", "databricks")

4. Edit the generated template file at `$FLOX_ENV_CACHE/auth_plugins/[name].sh`

5. Enable the new provider through the configuration wizard

## Architecture

### Core Components

The framework consists of three main components:

1. **Core Authentication Logic** (`flox_auth_core.sh`)
   - Secure storage management
   - Plugin loading
   - Built-in providers
   - Authentication flow

2. **Configuration Wizard** (`flox_auth_wizard.sh`)
   - Interactive provider management
   - Plugin template generation
   - Admin interface

3. **Flox Manifest Integration**
   - Hook script for automatic authentication
   - Shell-specific functions

### Provider Interface

Each authentication provider implements a standardized interface:

```bash
provider_cli_auth() {
  local command="$1"
  
  case "$command" in
    check)
      # Check if already authenticated
      # Return 0 if authenticated, 1 if not
      ;;
    authenticate)
      # Authenticate using provided credentials
      # Args: $2, $3, etc. for credentials
      # Return 0 if successful, 1 if failed
      ;;
    bootstrap)
      # Full authentication flow:
      # 1. Check if already authenticated
      # 2. Get stored credentials or prompt
      # 3. Authenticate
      # 4. Store credentials if requested
      ;;
    describe)
      # Return description of this provider
      ;;
  esac
}
```

## Customizing and Extending

### Creating a New Provider

To add support for a new CLI tool, create a provider file:

1. Generate a template:
   ```bash
   flox-auth-configure
   # Select "Create new provider template"
   # Enter CLI tool name
   ```

2. Edit the generated template at `$FLOX_ENV_CACHE/auth_plugins/[name].sh`

3. Implement the provider interface (example for Databricks CLI):

```bash
#!/usr/bin/env bash
# description: authentication for Databricks CLI

databricks_cli_auth() {
  local command="$1"
  
  case "$command" in
    check)
      # Check if databricks CLI is authenticated
      databricks workspace ls &> /dev/null
      ;;
    authenticate)
      local host="$2" token="$3"
      
      # Configure databricks CLI
      local config_dir="$HOME/.databrickscfg"
      echo -e "[DEFAULT]\nhost = $host\ntoken = $token" > "$config_dir"
      chmod 600 "$config_dir"
      
      # Verify configuration
      if databricks workspace ls &> /dev/null; then
        export DATABRICKS_HOST="$host" DATABRICKS_TOKEN="$token"
        return 0
      else
        return 1
      fi
      ;;
    bootstrap)
      # Skip if already authenticated
      if databricks_cli_auth check; then
        show_message "✓" "Databricks already authenticated" "114"
        return 0
      fi
      
      # Get stored credentials
      local host=$(get_secret "databricks" "${USER}_host")
      local token=$(get_secret "databricks" "${USER}_token")
      
      # Prompt for credentials if needed
      if [[ -z "$host" || -z "$token" ]]; then
        show_message "i" "Databricks authentication required" "212"
        host=$(gum input --placeholder "Databricks workspace URL")
        token=$(gum input --password --placeholder "Enter Databricks token")
      fi
      
      # Attempt authentication
      if [[ -n "$host" && -n "$token" ]]; then
        if databricks_cli_auth authenticate "$host" "$token"; then
          # Store credentials if requested
          if gum confirm "Store Databricks credentials securely?"; then
            store_secret "databricks" "${USER}_host" "$host"
            store_secret "databricks" "${USER}_token" "$token"
          fi
          show_message "✓" "Databricks CLI authentication successful" "114"
          return 0
        else
          show_message "✗" "Databricks authentication failed" "160"
          return 1
        fi
      else
        show_message "✗" "No Databricks credentials provided" "160"
        return 1
      fi
      ;;
    describe)
      echo "Authenticate with Databricks CLI"
      ;;
  esac
}
```

4. Enable the provider:
   ```bash
   flox-auth-configure
   # Select "Configure authentication providers"
   # Select your new provider
   # Confirm enabling it
   ```

### Advanced Customization

The framework is designed to be easily extended. Here are some customization opportunities:

#### Adding New Storage Backends

Modify the `get_secure_storage_provider()`, `store_secret()`, and `get_secret()` functions in `flox_auth_core.sh` to add support for alternative secure storage systems.

#### Custom Authentication Logic

Each provider can implement arbitrary authentication logic in its `authenticate()` method, allowing for complex credential handling, MFA support, or integration with external identity providers.

#### Environment Variables

Providers can set environment variables as part of authentication, making credentials available to all processes in the environment.

## Troubleshooting

### Common Issues

**Authentication fails even with correct credentials:**
- Check system clock synchronization (especially for AWS)
- Verify network connectivity
- Ensure credentials haven't expired

**"Failed to load provider" error:**
- Check that provider is properly enabled 
- Verify plugin file exists and is executable
- Check JSON syntax in config file

**Credentials not persisting:**
- Verify keychain/libsecret is working correctly
- Check file permissions on credential storage
- Ensure `$FLOX_ENV_CACHE` is writable

### Debugging

For troubleshooting, you can:

1. Inspect the configuration file:
   ```bash
   cat $FLOX_ENV_CACHE/auth_config.json
   ```

2. Check enabled providers:
   ```bash
   source $FLOX_ENV_CACHE/flox_auth_core.sh
   get_enabled_providers
   ```

3. Manually run authentication for a specific provider:
   ```bash
   source $FLOX_ENV_CACHE/flox_auth_core.sh
   github_cli_auth bootstrap
   ```

## Security Considerations

- Credentials are stored securely using platform-native keychains when available
- File-based storage uses strong encryption (AES-256)
- Authentication scripts run in the user's context and don't require elevated privileges
- No credentials are stored in environment files or source control
- The framework follows the principle of least privilege

## Contributing

To contribute improvements:

1. Fork the repository
2. Create a new provider or enhance existing functionality
3. Test thoroughly
4. Submit a pull request with clear documentation

## License

This framework is released under the MIT License. See LICENSE file for details.
