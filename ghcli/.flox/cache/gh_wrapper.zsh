# detect operating system
_gh_wrapper_detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unsupported"
    fi
}

# derive an encryption password from system information
_gh_wrapper_derive_password() {
    # combine username, hostname and machine id for a unique but deterministic password
    local user_info="$USER"
    local host_info=$(hostname)
    local machine_id=""
    
    if [[ -f "/etc/machine-id" ]]; then
        machine_id=$(cat /etc/machine-id)
    elif [[ -f "/var/lib/dbus/machine-id" ]]; then
        machine_id=$(cat /var/lib/dbus/machine-id)
    elif [[ "$(_gh_wrapper_detect_os)" == "macos" ]]; then
        machine_id=$(ioreg -rd1 -c IOPlatformExpertDevice | grep -E '(UUID)' | awk '{print $3}' | tr -d \")
    fi
    
    # combine and hash the information
    echo -n "${user_info}${host_info}${machine_id}flox-github-token" | openssl dgst -sha256 | awk '{print $2}'
}

# retrieve token from system keyring
_gh_wrapper_retrieve_github_token_keyring() {
    local os=$(_gh_wrapper_detect_os)
    
    if [[ "$os" == "macos" ]]; then
        security find-generic-password -s "flox-github" -a "$USER" -w 2>/dev/null
    elif [[ "$os" == "linux" ]]; then
        secret-tool lookup service flox-github user "$USER" 2>/dev/null
    fi
}

# retrieve token from encrypted file
_gh_wrapper_retrieve_github_token_encrypted() {
    local password=$(_gh_wrapper_derive_password)
    local token_file="${FLOX_ENV_CACHE:-$HOME/.cache/flox}/github_token.enc"
    
    if [[ -f "$token_file" ]]; then
        openssl enc -aes-256-cbc -d -salt -pbkdf2 -pass pass:"$password" -in "$token_file" 2>/dev/null
        return $?
    fi
    return 1
}

# retrieve github token
_gh_wrapper_retrieve_github_token() {
    local config_file="${FLOX_ENV_CACHE:-$HOME/.cache/flox}/github_config"
    
    if [[ -f "$config_file" ]]; then
        source "$config_file"
        if [[ "$STORAGE_METHOD" == "keyring" ]]; then
            _gh_wrapper_retrieve_github_token_keyring
        elif [[ "$STORAGE_METHOD" == "encrypted_file" ]]; then
            _gh_wrapper_retrieve_github_token_encrypted
        fi
    fi
}

# wrapper function for gh
gh() {
    local token=$(_gh_wrapper_retrieve_github_token)
    if [[ -n "$token" ]]; then
        GITHUB_TOKEN="$token" command gh "$@"
    else
        echo "Error: Unable to retrieve GitHub token. Please run 'flox activate' to set up GitHub integration."
        return 1
    fi
}
