# detect operating system
function _aws_wrapper_detect_os
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
function _aws_wrapper_derive_password
    # combine username, hostname and machine id for a unique but deterministic password
    set -l user_info $USER
    set -l host_info (hostname)
    set -l machine_id ""
    
    if test -f "/etc/machine-id"
        set machine_id (cat /etc/machine-id)
    else if test -f "/var/lib/dbus/machine-id"
        set machine_id (cat /var/lib/dbus/machine-id)
    else if test (_aws_wrapper_detect_os) = "macos"
        set machine_id (ioreg -rd1 -c IOPlatformExpertDevice | grep -E '(UUID)' | awk '{print $3}' | tr -d \")
    end
    
    # combine and hash the information
    echo -n "$user_info$host_info$machine_idflox-aws-credentials" | openssl dgst -sha256 | awk '{print $2}'
end

# retrieve credentials from system keyring
function _aws_wrapper_retrieve_credentials_keyring
    set -l os (_aws_wrapper_detect_os)
    
    if test $os = "macos"
        security find-generic-password -s "flox-aws" -a "$USER" -w 2>/dev/null
    else if test $os = "linux"
        secret-tool lookup service flox-aws user "$USER" 2>/dev/null
    end
end

# retrieve credentials from encrypted file
function _aws_wrapper_retrieve_credentials_encrypted
    set -l password (_aws_wrapper_derive_password)
    set -l creds_file "$FLOX_ENV_CACHE/aws_credentials.enc"
    test -z "$FLOX_ENV_CACHE"; and set creds_file "$HOME/.cache/flox/aws_credentials.enc"
    
    if test -f "$creds_file"
        openssl enc -aes-256-cbc -d -salt -pbkdf2 -pass pass:"$password" -in "$creds_file" 2>/dev/null
        return $status
    end
    return 1
end

# retrieve aws credentials
function _aws_wrapper_retrieve_credentials
    set -l config_file "$FLOX_ENV_CACHE/aws_config"
    test -z "$FLOX_ENV_CACHE"; and set config_file "$HOME/.cache/flox/aws_config"
    
    if test -f "$config_file"
        set -l storage_method (grep "STORAGE_METHOD" "$config_file" | cut -d '=' -f2)
        
        if test "$storage_method" = "keyring"
            _aws_wrapper_retrieve_credentials_keyring
        else if test "$storage_method" = "encrypted_file"
            _aws_wrapper_retrieve_credentials_encrypted
        end
    end
end

# extract credential field from JSON using jq
function _aws_wrapper_extract_credential
    set -l json "$argv[1]"
    set -l field "$argv[2]"
    echo "$json" | jq -r ".$field // \"\"" 2>/dev/null
end

# wrapper function for aws
function aws
    set -l creds_json (_aws_wrapper_retrieve_credentials)
    if test -n "$creds_json"
        set -l aws_access_key_id (_aws_wrapper_extract_credential "$creds_json" "aws_access_key_id")
        set -l aws_secret_access_key (_aws_wrapper_extract_credential "$creds_json" "aws_secret_access_key")
        set -l aws_session_token (_aws_wrapper_extract_credential "$creds_json" "aws_session_token")
        set -l aws_region (_aws_wrapper_extract_credential "$creds_json" "aws_region")
        test -z "$aws_region"; and set aws_region "us-east-1"
        
        if test -n "$aws_session_token"
            env AWS_ACCESS_KEY_ID="$aws_access_key_id" AWS_SECRET_ACCESS_KEY="$aws_secret_access_key" AWS_SESSION_TOKEN="$aws_session_token" AWS_REGION="$aws_region" command aws $argv
        else
            env AWS_ACCESS_KEY_ID="$aws_access_key_id" AWS_SECRET_ACCESS_KEY="$aws_secret_access_key" AWS_REGION="$aws_region" command aws $argv
        end
    else
        echo "Error: Unable to retrieve AWS credentials. Please run 'flox activate' to set up AWS integration."
        return 1
    end
end
