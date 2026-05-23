#!/usr/bin/env bash
# Based on https://unix.stackexchange.com/a/602935

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Skip if already unlocked
if "${SCRIPT_DIR}/is_unlocked.sh"; then
    exit 1
fi

# Prompt for password if not provided
if [[ -z "${UNLOCK_PASSWORD}" ]]; then
    echo -n 'Login password: ' >&2
    read -s UNLOCK_PASSWORD || return
fi

# Kill the broken PAM-started daemon and start a fresh one with the password
killall -q -u "$(whoami)" gnome-keyring-daemon
sleep 0.2
echo -n "${UNLOCK_PASSWORD}" | gnome-keyring-daemon --replace --daemonize --login
unset UNLOCK_PASSWORD
