#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUTH_DIR="$SCRIPT_DIR/auth"
USERS_FILE="$AUTH_DIR/users"

usage() {
  echo "Usage: $0 <username> [password]"
  echo ""
  echo "Examples:"
  echo "  $0 stag-user"
  echo "  $0 stag-user 'StrongPassword123!'"
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 1
fi

USERNAME="$1"

if [[ "$USERNAME" == *":"* || -z "$USERNAME" ]]; then
  echo "Error: username must be non-empty and cannot contain ':'"
  exit 1
fi

if [[ $# -eq 2 ]]; then
  PASSWORD="$2"
else
  read -rsp "Password for $USERNAME: " PASSWORD
  echo
  read -rsp "Confirm password: " PASSWORD_CONFIRM
  echo

  if [[ "$PASSWORD" != "$PASSWORD_CONFIRM" ]]; then
    echo "Error: passwords do not match"
    exit 1
  fi
fi

if [[ -z "$PASSWORD" ]]; then
  echo "Error: password cannot be empty"
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker is required"
  exit 1
fi

HASH="$(docker run --rm mailhog/mailhog bcrypt "$PASSWORD" | tr -d '\r\n')"

mkdir -p "$AUTH_DIR"

TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

if [[ -f "$USERS_FILE" ]]; then
  awk -F: -v user="$USERNAME" '
    /^#/ { print; next }
    NF == 0 { print; next }
    $1 != user { print }
  ' "$USERS_FILE" > "$TMP_FILE"
fi

printf "%s:%s\n" "$USERNAME" "$HASH" >> "$TMP_FILE"
mv "$TMP_FILE" "$USERS_FILE"
chmod 600 "$USERS_FILE"

echo "User '$USERNAME' added/updated in $USERS_FILE"
echo "Restart MailHog to apply changes: docker compose up -d"
