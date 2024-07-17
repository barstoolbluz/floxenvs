#!/bin/bash

# This script requires gum. I recognize that you might not want to install
# gum. So I have a pragmatic solution! Remote activate my gum-ified Flox env
# from FloxHub: flox pull barstoolbluz/gum. Or just install on your own via Flox!

# Bootstrap configuration of ~/.config/op/config and ~/1password.session
setup_1password_cli() {
    # Here we check to see if the config file exists and contains required strings
    check_config() {
        local config_file="$HOME/.config/op/config"
        if [[ -f "$config_file" ]]; then
            if grep -q "url" "$config_file" && grep -q "email" "$config_file" && grep -q "accountKey" "$config_file"; then
                return 0
            fi
        fi
        return 1
    }

    # Exit gracefully if the user opts not to continue/maxes out authentication attempts
    exit_shell() {
        echo "Exiting the shell. Please run 'flox activate' to restart the wizard."
        exit 1
    }

    # Check to see if ~/.config/op/config (a) exists and (b) is valid
    if check_config; then
        return 0
    fi

    # Run the Flox/1Password CLI Setup Wizard
    clear
    gum style \
        --border normal \
        --margin "1" \
        --padding "1" \
        --border-foreground 141 \
        "
    Welcome to the 1Password CLI Setup Wizard!

    We didn't find an existing 1Password configuration on your system. So let's set one up now.

    You will need to provide the following information:

    1. Your 1Password account URL (e.g., https://your-team.1password.com)
    2. Your email address associated with the 1Password account
    3. Your 1Password Secret Key (a 34-character code)
    4. The specific field names for the AWS credentials in your 1Password vault (optional)

    We'll use this information to authenticate with 1Password and bootstrap your local environment.
"

    # Prompt you Yes/No to continue with the 1Password CLI Bootstrapping / Setup Wizard
    if ! gum confirm "Do you want to continue?" --default=true; then
        exit_shell
    fi

    echo "Type 'exit' or 'quit' at any prompt to exit the wizard."

    term_width=$(tput cols)

    # You can type 'exit' at any time to quit the wizard
    check_exit() {
        if [[ "$1" == "exit" || "$1" == "quit" ]]; then
            echo "Exiting the wizard. You can run 'flox activate' again to restart."
            exit 0
        fi
    }

    # Let's collect the infos we need to bootstrap 1Password's ~/.config/op/config
    address=$(gum input --prompt "Enter your 1Password account URL (or type 'exit' to quit): " --placeholder "https://" --width "$term_width")
    check_exit "$address"

    email=$(gum input --prompt "Enter your email address (or type 'exit' to quit): " --width "$term_width")
    check_exit "$email"

    secret_key=$(gum input --prompt "Enter your Secret Key (or type 'exit' to quit): " --width "$term_width")
    check_exit "$secret_key"

    # Prompt for the field names associated with the object/item you use to store AWS creds in your vault
    gum style \
        --border normal \
        --margin "1" \
        --padding "1" \
        --border-foreground 141 \
        "
    In your 1Password vault, you have an "item" (i.e. object) that stores your AWS credentials. This
    item typically has fields for your AWS access key ID and secret access key.
    
    We need to know what you've named these fields in your 1Password item.

    By default, we assume:
    - 'username' for the field containing your AWS access key ID
    - 'credentials' for the field containing your AWS secret access key

    If you've used different field names, please specify them below.
    If you've used the default names, just press Enter to accept them.
    "

    username_field=$(gum input --prompt "Enter field name for AWS access key ID (default: username): " --placeholder "username" --width "$term_width")
    check_exit "$username_field"
    username_field=${username_field:-username}

    credentials_field=$(gum input --prompt "Enter field name for AWS secret access key (default: credentials): " --placeholder "credentials" --width "$term_width")
    check_exit "$credentials_field"
    credentials_field=${credentials_field:-credentials}

    # Attempt to sign in (max 5 retries)
    for attempt in {1..5}; do
        echo "Signing in to 1Password (Attempt $attempt of 5)..."
        if output=$(op account add --address "$address" --email "$email" --secret-key "$secret_key" 2>/dev/null); then
            echo "Successfully signed in to 1Password!"
            break
        else
            if [[ $attempt -eq 5 ]]; then
                echo "Maximum number of attempts reached. Authentication failed."
                exit_shell
            fi
            echo "Authentication failed. Please try again."
        fi
    done

    # Write field names (if other than defaults) to ~/.config/flox/1password.session file
    session_file="$HOME/.config/flox/1password.session"
    mkdir -p "$(dirname "$session_file")"
    
    {
        echo "# BEGIN 1PASSWORD AWSCLI2 BOOTSTRAP CONFIGURATION"
        echo "export OP_AWS_USERNAME_FIELD=\"$username_field\""
        echo "export OP_AWS_CREDENTIALS_FIELD=\"$credentials_field\""
        echo "# END 1PASSWORD AWSCLI2 BOOTSTRAP CONFIGURATION"
    } >> "$session_file"

    echo "1Password CLI setup completed successfully."
    echo "Custom field names have been saved to $session_file"
}


# Enable (=true) or Disable (=false) 1Password session persistence
configure_1password_persistence() {
    local config_file="$HOME/.config/flox/1password.session"
    
    # Check if session persistence is already configured
    if grep -q "BEGIN 1PASSWORD SESSION PERSISTENCE CONFIGURATION" "$config_file" 2>/dev/null; then
#        echo "1Password session persistence is already configured."
        return 0
    fi

    # Wizard to enable (=true) or disable (=false) 1Password session persistence
    gum style --border double --padding "1 1" --margin "1 1" --border-foreground 141 --foreground 255 "
    Would you like to enable 1Password session persistence? This will enable you to remain logged in to
    1Password between terminal sessions for a limited period of time.

    About 1Password Session Persistence:
    - We store a short-term session token for automatic logins;
    - If you exit and re-enter your Flox env, you needn't log in again;
    - There's no need to re-authenticate when you create new sessions;

    Security Considerations:
    - Your session token is stored locally, IN PLAIN TEXT, in '~/.config/1password.session';
    - Your session token expires after 30 minutes of inactivity.
    "

    gum style --foreground 255 "Do you want to enable 1Password session persistence?"
    local user_choice=$(gum choose "Yes" "No")

    if [[ "$user_choice" == "Yes" ]]; then
        ENABLE_1PASSWORD_PERSISTENCE="true"
    else
        ENABLE_1PASSWORD_PERSISTENCE="false"
    fi

    # Here we append a session persistence flag to 1password.session in ~/config/flox
    {
        echo
        echo "# BEGIN 1PASSWORD SESSION PERSISTENCE CONFIGURATION"
        echo "ENABLE_1PASSWORD_PERSISTENCE=\"${ENABLE_1PASSWORD_PERSISTENCE}\""
        echo "# END 1PASSWORD SESSION PERSISTENCE CONFIGURATION"
    } >> "$config_file"

    # Set the correct file permissions
    chmod 600 "$config_file"

    echo "1Password session persistence configuration has been appended to $config_file"
}


# Configure 1Password and AWSCLI2 interoperability
configure_1password_aws_cli() {
    local config_file="$HOME/.config/flox/1password.session"

    # Check if configuration already exists
    if grep -q "BEGIN 1PASSWORD AWSCLI2 CONFIGURATION" "$config_file" 2>/dev/null; then
#        echo "AWS CLI configuration for 1Password is already set up."
        return 0
    fi

    clear
    gum style \
        --foreground 141 \
        --border "rounded" \
        --border-foreground 255 \
        --margin "1" \
        --padding "1 2" \
        "Use this wizard to configure your 1Password environment for seamless integration with AWSCLI2.
It will guide you through the process of specifying the names of your 1Password vault and
AWS credentials, and (if required) providing your AWS region, too.

- We DO NOT store AWS credentials anywhere on your local system;

- We obtain long-term secrets from your 1Password Vault and use these to obtain
  short-term secrets from the AWS Secure Token Service;

- We use \`op run\` to run AWSCLI2 commands inside an ephemeral environment;

- Your AWS secrets live as variables in this ephemeral environment for the duration of
  your AWSCLI2 commands. This lets us securely pass secrets to AWS.

You can type 'exit' at any prompt to quit the wizard.
"

    # You can exit this wizard at any time
    check_exit() {
        if [[ "$1" == "exit" ]]; then
            echo "Exiting the wizard. You can run 'flox activate' again to restart."
            exit 0
        fi
    }

    while [[ -z "${OP_VAULT}" ]]; do
        gum style --foreground 255 "Please enter the name of the 1Password vault containing your AWS credentials."
        OP_VAULT=$(gum input --placeholder "Vault name")
        check_exit "$OP_VAULT"
    done

    while [[ -z "${OP_AWS_CREDENTIALS}" ]]; do
        gum style --foreground 255 "Please enter the item name you gave to the AWS credentials stored in the 1Password vault."
        OP_AWS_CREDENTIALS=$(gum input --placeholder "Credentials name")
        check_exit "$OP_AWS_CREDENTIALS"
    done

    if [[ ! -f ~/.aws/config ]] || ! grep -q "^[[:space:]]*region[[:space:]]*=" ~/.aws/config; then
        while true; do
            gum style --foreground 255 "Please enter your AWS region (e.g., us-east-1)."
            AWS_REGION=$(gum input --placeholder "AWS region")
            check_exit "$AWS_REGION"
            if [[ $AWS_REGION =~ ^[a-z]{2}-[a-z]+-[0-9]+$ ]]; then
                break
            else
                gum style --foreground 9 "Invalid region format. Please try again."
            fi
        done
        mkdir -p ~/.aws
        if [[ -f ~/.aws/config ]]; then
            sed -i '/^\[default\]/,/^$/d' ~/.aws/config
        fi
        echo -e "[default]\nregion = ${AWS_REGION}" >> ~/.aws/config
        chmod 600 ~/.aws/config
    fi

    # Write configuration data to the file
    {
        echo
        echo "# BEGIN 1PASSWORD AWSCLI2 CONFIGURATION"
        echo "OP_VAULT=${OP_VAULT}"
        echo "OP_AWS_CREDENTIALS=${OP_AWS_CREDENTIALS}"
        echo "# END 1PASSWORD AWSCLI2 CONFIGURATION"
    } >> "$config_file"

    gum style --foreground 141 "AWS CLI configuration for 1Password completed successfully."
}

# Function to authenticate with 1Password; this is called by the 'aws' alias in [profile]
authenticate_1password() {
    local config_file="$HOME/.config/flox/1password.session"

    [[ -f "$config_file" ]] && source "$config_file"

    if [[ "${ENABLE_1PASSWORD_PERSISTENCE}" != "true" ]]; then
        echo "1Password session persistence is not enabled. Skipping authentication."
        return 0
    fi

    # Check if the token exists and is valid
    if [[ -n "${OP_SESSION_TOKEN}" ]]; then
        if op whoami --session "${OP_SESSION_TOKEN}" >/dev/null 2>&1; then
            echo "Existing 1Password session is valid."
            return 0
        else
            echo "Existing 1Password session is invalid. Re-authenticating..."
            unset OP_SESSION_TOKEN
        fi
    else
        echo "No existing 1Password session found. Authenticating..."
    fi

    max_retries=5
    retry_count=0
    while true; do
        OP_SESSION_TOKEN=$(op signin --raw 2>&1)
        if [[ $? -eq 0 ]]; then
            sed -i '/# BEGIN 1PASSWORD SESSION TOKEN/,/# END 1PASSWORD SESSION TOKEN/c\
# BEGIN 1PASSWORD SESSION TOKEN\
OP_SESSION_TOKEN='"${OP_SESSION_TOKEN}"'\
# END 1PASSWORD SESSION TOKEN' "$config_file"

            # If the session token section doesn't exist, it must be invented/appended
            if ! grep -q "# BEGIN 1PASSWORD SESSION TOKEN" "$config_file"; then
                echo >> "$config_file"
                echo "# BEGIN 1PASSWORD SESSION TOKEN" >> "$config_file"
                echo "OP_SESSION_TOKEN=${OP_SESSION_TOKEN}" >> "$config_file"
                echo "# END 1PASSWORD SESSION TOKEN" >> "$config_file"
            fi
            
            echo "Authentication successful."
            break
        else
            retry_count=$((retry_count + 1))
            if [[ ${retry_count} -ge ${max_retries} ]]; then
                echo "Maximum number of retries exceeded. Please check your 1Password credentials and try again."
                return 1
            else
                echo "Invalid password. Please try again."
            fi
        fi
    done

    # Here we export the OP_SESSION_TOKEN for use in the current session
    export OP_SESSION_TOKEN
}

# Call the 1Password bootstrapping function
setup_1password_cli

# Call the 1Password session persistence function
configure_1password_persistence

# Call the configure_1password_aws_cli function
configure_1password_aws_cli

# Call the 1Password authentication function
authenticate_1password

# Export the OP_SESSION_TOKEN for use in the profile scripts
export OP_SESSION_TOKEN
