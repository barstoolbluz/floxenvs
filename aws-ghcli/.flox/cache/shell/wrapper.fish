# load 1password session token
test -f "$HOME/.config/op/1password-session.token" && set -gx OP_SESSION_TOKEN (cat "$HOME/.config/op/1password-session.token")

# gh wrapper function
function gh
    op run --session "$OP_SESSION_TOKEN" --env-file (echo "GITHUB_TOKEN=op://$OP_GITHUB_VAULT/$OP_GITHUB_TOKEN_ITEM/$OP_GITHUB_TOKEN_FIELD" | psub) -- gh $argv
end

# git wrapper function
function git
    if contains -- $argv[1] push pull fetch clone remote
        set -l token (op read "op://$OP_GITHUB_VAULT/$OP_GITHUB_TOKEN_ITEM/$OP_GITHUB_TOKEN_FIELD" --session "$OP_SESSION_TOKEN" 2>/dev/null)
        if test $status -eq 0
            set -l askpass (mktemp)
            echo -e "#!/bin/sh\necho $token" > "$askpass"
            chmod +x "$askpass"
            env GIT_ASKPASS="$askpass" GIT_TERMINAL_PROMPT=0 command git -c credential.helper= $argv
            rm -f "$askpass"
        else
            command git $argv
        end
    else
        command git $argv
    end
end

# aws wrapper function
function aws
    op run --session "$OP_SESSION_TOKEN" --env-file (echo -e "AWS_ACCESS_KEY_ID=op://$OP_AWS_VAULT/$OP_AWS_CREDENTIALS_ITEM/$OP_AWS_USERNAME_FIELD\nAWS_SECRET_ACCESS_KEY=op://$OP_AWS_VAULT/$OP_AWS_CREDENTIALS_ITEM/$OP_AWS_CREDENTIALS_FIELD" | psub) -- aws $argv
end
