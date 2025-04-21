# detect operating system
function _gh_wrapper_detect_os
    switch (uname)
        case Darwin
            echo "macos"
        case Linux
            echo "linux"
        case '*'
            echo "unsupported"
    end
end

# derive an encryption password from system information
function _gh_wrapper_derive_password
    # combine username, hostname and machine id for a unique but deterministic password
    set -l user_info $USER
    set -l host_info (hostname)
    set -l machine_id ""
    
    if test -f "/etc/machine-id"
        set machine_id (cat /etc/machine-id)
    else if test -f "/var/lib/dbus/machine-id"
        set machine_id (cat /var/lib/dbus/machine-id)
    else if test (_gh_wrapper_detect_os) = "macos"
        set machine_id (ioreg -rd1 -c IOPlatformExpertDevice | grep -E '(UUID)' | awk '{print $3}' | tr -d \")
    end
    
    # combine and hash the information
    echo -n "$user_info$host_info$machine_idflox-github-token" | openssl dgst -sha256 | awk '{print $2}'
end

# retrieve token from system keyring
function _gh_wrapper_retrieve_github_token_keyring
    set -l os (_gh_wrapper_detect_os)
    
    if test $os = "macos"
        security find-generic-password -s "flox-github" -a "$USER" -w 2>/dev/null
    else if test $os = "linux"
        secret-tool lookup service flox-github user "$USER" 2>/dev/null
    end
end

# retrieve token from encrypted file
function _gh_wrapper_retrieve_github_token_encrypted
    set -l password (_gh_wrapper_derive_password)
    set -l token_file "$FLOX_ENV_CACHE/github_token.enc"
    test -z "$FLOX_ENV_CACHE"; and set token_file "$HOME/.cache/flox/github_token.enc"
    
    if test -f "$token_file"
        openssl enc -aes-256-cbc -d -salt -pbkdf2 -pass pass:"$password" -in "$token_file" 2>/dev/null
        return $status
    end
    return 1
end

# retrieve github token
function _gh_wrapper_retrieve_github_token
    set -l config_file "$FLOX_ENV_CACHE/github_config"
    test -z "$FLOX_ENV_CACHE"; and set config_file "$HOME/.cache/flox/github_config"
    
    if test -f "$config_file"
        set -l storage_method (grep "STORAGE_METHOD" "$config_file" | cut -d '=' -f2)
        
        if test "$storage_method" = "keyring"
            _gh_wrapper_retrieve_github_token_keyring
        else if test "$storage_method" = "encrypted_file"
            _gh_wrapper_retrieve_github_token_encrypted
        end
    end
end

# wrapper function for gh
function gh
    set -l token (_gh_wrapper_retrieve_github_token)
    if test -n "$token"
        env GITHUB_TOKEN="$token" command gh $argv
    else
        echo "Error: Unable to retrieve GitHub token. Please run 'flox activate' to set up GitHub integration."
        return 1
    end
end
