#!/usr/bin/env sh

# Generate host keys on first run
if [ ! -f "/etc/ssh/hostkeys/ssh_host_rsa_key" ]; then
    if [ ! -f "/host_keys.d/ssh_host_ed25519_key" ]; then
        ssh-keygen -q -N "" -t ed25519 -f /host_keys.d/ssh_host_ed25519_key
    fi
    if [ ! -f "/host_keys.d/ssh_host_rsa_key" ]; then
        ssh-keygen -q -N "" -t rsa -b 4096 -f /host_keys.d/ssh_host_rsa_key
    fi
    if [ ! -f "/host_keys.d/ssh_host_ecdsa_key" ]; then
        ssh-keygen -q -N "" -t ecdsa -f /host_keys.d/ssh_host_ecdsa_key
    fi
fi

# Values from env or defaults
BIND="${SSHD_BIND:-0.0.0.0}"
PORT="${SSHD_PORT:-2022}"

# Ensure sshd_config exists
SSHD_CONFIG="/etc/ssh/sshd_config"

# Remove existing Port and ListenAddress lines
sed -i '/^Port /d' "$SSHD_CONFIG"
sed -i '/^ListenAddress /d' "$SSHD_CONFIG"

# Append ours
echo "ListenAddress ${BIND}:${PORT}" >> "$SSHD_CONFIG"

# Configure sshd options
if [ -n "${ALLOW_X11_FORWARDING}" ]; then
    OPT_X11_FORWARDING="-o X11Forwarding=yes"
else
    OPT_X11_FORWARDING="-o X11Forwarding=no"
fi

# Start sshd
/usr/sbin/sshd -D -e \
    $OPT_X11_FORWARDING \
