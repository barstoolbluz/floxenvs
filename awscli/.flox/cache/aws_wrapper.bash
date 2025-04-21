# detect operating system
_aws_wrapper_detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unsupported"
    fi
}

# derive an encryption password from system information
_aws_wrapper_derive_password() {
    # combine username, hostname and machine id for a unique but deterministic password
    local user_info="$USER"
    local host_info=$(hostname)
    local machine_id=""
    
    if [[ -f "/etc/machine-id" ]]; then
        machine_id=$(cat /etc/machine-id)
    elif [[ -f "/var/lib/dbus/machine-id" ]]; then
        machine_id=$(cat /var/lib/dbus/machine-id)
    elif [[ "$(_aws_wrapper_detect_os)" == "macos" ]]; then
        machine_id=$(ioreg -rd1 -c IOPlatformExpertDevice | grep -E '(UUID)' | awk '{print $3}' | tr -d \")
    fi
    
    # combine and hash the information
    echo -n "${user_info}${host_info}${machine_id}flox-aws-credentials" | openssl dgst -sha256 | awk '{print $2}'
}

# retrieve credentials from system keyring
_aws_wrapper_retrieve_credentials_keyring() {
    local os=$(_aws_wrapper_detect_os)
    
    if [[ "$os" == "macos" ]]; then
        security find-generic-password -s "flox-aws" -a "$USER" -w 2>/dev/null
    elif [[ "$os" == "linux" ]]; then
        secret-tool lookup service flox-aws user "$USER" 2>/dev/null
    fi
}

# retrieve credentials from encrypted file
_aws_wrapper_retrieve_credentials_encrypted() {
    local password=$(_aws_wrapper_derive_password)
    local creds_file="${FLOX_ENV_CACHE:-$HOME/.cache/flox}/aws_credentials.enc"
    
    if [[ -f "$creds_file" ]]; then
        openssl enc -aes-256-cbc -d -salt -pbkdf2 -pass pass:"$password" -in "$creds_file" 2>/dev/null
        return $?
    fi
    return 1
}

# retrieve aws credentials
_aws_wrapper_retrieve_credentials() {
    local config_file="${FLOX_ENV_CACHE:-$HOME/.cache/flox}/aws_config"
    
    if [[ -f "$config_file" ]]; then
        source "$config_file"
        if [[ "$STORAGE_METHOD" == "keyring" ]]; then
            _aws_wrapper_retrieve_credentials_keyring
        elif [[ "$STORAGE_METHOD" == "encrypted_file" ]]; then
            _aws_wrapper_retrieve_credentials_encrypted
        fi
    fi
}

# extract credential field from JSON using jq
_aws_wrapper_extract_credential() {
    local json="$1"
    local field="$2"
    echo "$json" | jq -r ".$field // \"\"" 2>/dev/null
}

# wrapper function for aws
aws() {
    local creds_json=$(_aws_wrapper_retrieve_credentials)
    if [[ -n "$creds_json" ]]; then
        local aws_access_key_id=$(_aws_wrapper_extract_credential "$creds_json" "aws_access_key_id")
        local aws_secret_access_key=$(_aws_wrapper_extract_credential "$creds_json" "aws_secret_access_key")
        local aws_session_token=$(_aws_wrapper_extract_credential "$creds_json" "aws_session_token")
        local aws_region=$(_aws_wrapper_extract_credential "$creds_json" "aws_region")
        
        # Set environment variables for the aws command
        if [[ -n "$aws_session_token" ]]; then
            AWS_ACCESS_KEY_ID="$aws_access_key_id" \
            AWS_SECRET_ACCESS_KEY="$aws_secret_access_key" \
            AWS_SESSION_TOKEN="$aws_session_token" \
            AWS_REGION="${aws_region:-us-east-1}" \
            command aws "$@"
        else
            AWS_ACCESS_KEY_ID="$aws_access_key_id" \
            AWS_SECRET_ACCESS_KEY="$aws_secret_access_key" \
            AWS_REGION="${aws_region:-us-east-1}" \
            command aws "$@"
        fi
    else
        echo "Error: Unable to retrieve AWS credentials. Please run 'flox activate' to set up AWS integration."
        return 1
    fi
}
