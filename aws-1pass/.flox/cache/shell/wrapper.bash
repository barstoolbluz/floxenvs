# load 1password session token - check env var first, then file
[[ -z "$OP_SESSION_TOKEN" && -f "$HOME/.config/op/1password-session.token" ]] && export OP_SESSION_TOKEN=$(cat "$HOME/.config/op/1password-session.token")

# aws wrapper function
aws() {
  if [[ -n "$OP_SESSION_TOKEN" ]]; then
    op run --session "$OP_SESSION_TOKEN" --env-file <(echo -e "AWS_ACCESS_KEY_ID=op://$OP_AWS_VAULT/$OP_AWS_CREDENTIALS_ITEM/$OP_AWS_USERNAME_FIELD\nAWS_SECRET_ACCESS_KEY=op://$OP_AWS_VAULT/$OP_AWS_CREDENTIALS_ITEM/$OP_AWS_CREDENTIALS_FIELD") -- aws "$@"
  else
    case "$OP_STATE" in
      needs_setup)
        echo "⚠️  1Password not configured. Run 'op-setup' for automated setup."
        ;;
      needs_login)
        echo "⚠️  Not signed in to 1Password. Run 'op-login'"
        ;;
      *)
        echo "⚠️  1Password unavailable. Run 'op-setup'"
        ;;
    esac
    echo "Falling back to standard aws authentication..."
    command aws "$@"
  fi
}
