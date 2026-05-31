#!/usr/bin/env bash
# Based on https://unix.stackexchange.com/a/602935

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { echo "[unlock-keyring] $*" | systemd-cat -t unlock-keyring; }

# Skip if already unlocked
if "${SCRIPT_DIR}/is_unlocked.sh"; then
    log "already unlocked, skipping"
    exit 1
fi

# Prompt for password if not provided
if [[ -z "${UNLOCK_PASSWORD}" ]]; then
    echo -n 'Login password: ' >&2
    read -s UNLOCK_PASSWORD || return
fi

log "which gnome-keyring-daemon: $(which gnome-keyring-daemon 2>&1)"
log "capabilities of this shell: $(getpcaps $$ 2>&1)"
log "wrapper exists: $(ls /run/wrappers/bin/gnome-keyring-daemon 2>&1)"
log "killing existing gnome-keyring-daemon"
killall -q -u "$(whoami)" gnome-keyring-daemon
sleep 0.5

log "starting fresh daemon with --replace --daemonize --login"
OUTPUT=$(echo -n "${UNLOCK_PASSWORD}" | gnome-keyring-daemon --replace --daemonize --login 2>&1)
EXIT_CODE=$?
log "daemon exit code: ${EXIT_CODE}, output: ${OUTPUT}"
unset UNLOCK_PASSWORD

log "checking lock state after daemon start"
LOCKED=$(busctl --user get-property org.freedesktop.secrets \
    /org/freedesktop/secrets/collection/login \
    org.freedesktop.Secret.Collection Locked 2>&1)
log "lock state: ${LOCKED}"
