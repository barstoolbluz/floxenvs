# load 1password session token
[[ -f "$HOME/.config/op/1password-session.token" ]] && export OP_SESSION_TOKEN=$(cat "$HOME/.config/op/1password-session.token")

# gh wrapper function
gh() { op run --session "$OP_SESSION_TOKEN" --env-file <(echo "GITHUB_TOKEN=op://$OP_GITHUB_VAULT/$OP_GITHUB_TOKEN_ITEM/$OP_GITHUB_TOKEN_FIELD") -- gh "$@"; }

# git wrapper function
git() {
  if [[ "$1" =~ ^(push|pull|fetch|clone|remote)$ ]] && token=$(op read "op://$OP_GITHUB_VAULT/$OP_GITHUB_TOKEN_ITEM/$OP_GITHUB_TOKEN_FIELD" --session "$OP_SESSION_TOKEN" 2>/dev/null); then
    askpass=$(mktemp)
    echo -e "#!/bin/sh\necho $token" > "$askpass"
    chmod +x "$askpass"
    GIT_ASKPASS="$askpass" GIT_TERMINAL_PROMPT=0 command git -c credential.helper= "$@"
    rm -f "$askpass"
  else
    command git "$@"
  fi
}

# aws wrapper function
aws() { op run --session "$OP_SESSION_TOKEN" --env-file <(echo -e "AWS_ACCESS_KEY_ID=op://$OP_AWS_VAULT/$OP_AWS_CREDENTIALS_ITEM/$OP_AWS_USERNAME_FIELD\nAWS_SECRET_ACCESS_KEY=op://$OP_AWS_VAULT/$OP_AWS_CREDENTIALS_ITEM/$OP_AWS_CREDENTIALS_FIELD") -- aws "$@"; }
