# load 1password session token - check env var first, then file
if test -z "$OP_SESSION_TOKEN"; and test -f "$HOME/.config/op/1password-session.token"
    set -gx OP_SESSION_TOKEN (cat "$HOME/.config/op/1password-session.token")
end

# gh wrapper function
function gh
    if test -n "$OP_SESSION_TOKEN"
        op run --session "$OP_SESSION_TOKEN" --env-file (echo "GITHUB_TOKEN=op://$OP_GITHUB_VAULT/$OP_GITHUB_TOKEN_ITEM/$OP_GITHUB_TOKEN_FIELD" | psub) -- gh $argv
    else
        echo "Error: No 1Password session found. Please authenticate first."
        return 1
    end
end

# git wrapper function
function git
    if contains -- $argv[1] push pull fetch clone remote; and test -n "$OP_SESSION_TOKEN"
        set -l token (op read "op://$OP_GITHUB_VAULT/$OP_GITHUB_TOKEN_ITEM/$OP_GITHUB_TOKEN_FIELD" --session "$OP_SESSION_TOKEN" 2>/dev/null)
        if test -n "$token"
            # Create temporary file
            set -l askpass (mktemp)
            
            # Define cleanup function
            function cleanup --on-event fish_exit --on-signal INT --on-signal TERM
                rm -f $askpass
            end
            
            echo -e "#!/bin/sh\necho $token" > "$askpass"
            chmod 700 "$askpass"
            env GIT_ASKPASS="$askpass" GIT_TERMINAL_PROMPT=0 command git -c credential.helper= $argv
            set -l git_status $status
            
            # Cleanup temporary file and function
            rm -f "$askpass"
            functions -e cleanup
            
            return $git_status
        end
    end
    command git $argv
end

# aws wrapper function
function aws
    if test -n "$OP_SESSION_TOKEN"
        op run --session "$OP_SESSION_TOKEN" --env-file (echo -e "AWS_ACCESS_KEY_ID=op://$OP_AWS_VAULT/$OP_AWS_CREDENTIALS_ITEM/$OP_AWS_USERNAME_FIELD\nAWS_SECRET_ACCESS_KEY=op://$OP_AWS_VAULT/$OP_AWS_CREDENTIALS_ITEM/$OP_AWS_CREDENTIALS_FIELD" | psub) -- aws $argv
    else
        echo "Error: No 1Password session found. Please authenticate first."
        return 1
    end
end
