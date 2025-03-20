# load 1password session token - check env var first, then file
[[ -z "$OP_SESSION_TOKEN" && -f "$HOME/.config/op/1password-session.token" ]] && export OP_SESSION_TOKEN=$(cat "$HOME/.config/op/1password-session.token")

# gh wrapper function
function gh() { 
  if [[ -n "$OP_SESSION_TOKEN" ]]; then
    op run --session "$OP_SESSION_TOKEN" --env-file =(echo "GITHUB_TOKEN=op://$OP_GITHUB_VAULT/$OP_GITHUB_TOKEN_ITEM/$OP_GITHUB_TOKEN_FIELD") -- gh "$@"
  else
    echo "Error: No 1Password session found. Please authenticate first."
    return 1
  fi
}

# git wrapper function
function git() {
  if [[ "$1" =~ ^(push|pull|fetch|clone|remote)$ ]] && [[ -n "$OP_SESSION_TOKEN" ]]; then
    token=$(op read "op://$OP_GITHUB_VAULT/$OP_GITHUB_TOKEN_ITEM/$OP_GITHUB_TOKEN_FIELD" --session "$OP_SESSION_TOKEN" 2>/dev/null)
    if [[ -n "$token" ]]; then
      askpass=$(mktemp)
      
      # Set up cleanup trap for the temporary file (zsh syntax)
      trap 'rm -f "$askpass"' EXIT INT TERM
      
      # Write token to file with more secure permissions
      print -n "#!/bin/sh\necho $token" > "$askpass"
      chmod 700 "$askpass"
      GIT_ASKPASS="$askpass" GIT_TERMINAL_PROMPT=0 command git -c credential.helper= "$@"
      status=$?
      
      # Manually remove the file and clear the trap
      rm -f "$askpass"
      trap - EXIT INT TERM
      
      return $status
    fi
  fi
  command git "$@"
}

# aws wrapper function
function aws() { 
  if [[ -n "$OP_SESSION_TOKEN" ]]; then
    op run --session "$OP_SESSION_TOKEN" --env-file =(echo "AWS_ACCESS_KEY_ID=op://$OP_AWS_VAULT/$OP_AWS_CREDENTIALS_ITEM/$OP_AWS_USERNAME_FIELD\nAWS_SECRET_ACCESS_KEY=op://$OP_AWS_VAULT/$OP_AWS_CREDENTIALS_ITEM/$OP_AWS_CREDENTIALS_FIELD") -- aws "$@"
  else
    echo "Error: No 1Password session found. Please authenticate first."
    return 1
  fi
}
