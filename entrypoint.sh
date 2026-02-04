#!/bin/bash
set -e

# Get the UID/GID from environment or use defaults
USER_ID=${USER_ID:-1000}
GROUP_ID=${GROUP_ID:-1000}

# Update devuser UID/GID if different from build time
if [ "$(id -u devuser)" != "$USER_ID" ]; then
    usermod -u $USER_ID devuser 2>/dev/null || true
fi

if [ "$(id -g devuser)" != "$GROUP_ID" ]; then
    groupmod -g $GROUP_ID devgroup 2>/dev/null || true
fi

# Fix ownership of go directories
chown -R devuser:devgroup /go 2>/dev/null || true

# Execute command as devuser
exec su-exec devuser:devgroup "$@"
