# load 1password session token - check env var first, then file
if test -z "$OP_SESSION_TOKEN"; and test -f "$HOME/.config/op/1password-session.token"
    set -gx OP_SESSION_TOKEN (cat "$HOME/.config/op/1password-session.token")
end

# aws wrapper function
function aws
    if test -n "$OP_SESSION_TOKEN"
        op run --session "$OP_SESSION_TOKEN" --env-file (echo -e "AWS_ACCESS_KEY_ID=op://$OP_AWS_VAULT/$OP_AWS_CREDENTIALS_ITEM/$OP_AWS_USERNAME_FIELD\nAWS_SECRET_ACCESS_KEY=op://$OP_AWS_VAULT/$OP_AWS_CREDENTIALS_ITEM/$OP_AWS_CREDENTIALS_FIELD" | psub) -- aws $argv
    else
        switch "$OP_STATE"
            case needs_setup
                echo "⚠️  1Password not configured. Run 'op-setup' for automated setup."
            case needs_login
                echo "⚠️  Not signed in to 1Password. Run 'op-login'"
            case '*'
                echo "⚠️  1Password unavailable. Run 'op-setup'"
        end
        echo "Falling back to standard aws authentication..."
        command aws $argv
    end
end
