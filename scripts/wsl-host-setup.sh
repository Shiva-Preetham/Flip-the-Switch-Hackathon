#!/usr/bin/env bash
# Turns WSL Ubuntu into the POSIX SSH host Switch Console needs on Windows
# ("SDK sessions require a POSIX SSH execution host").
#
# Run as root from Windows PowerShell, in the repo folder:
#   wsl -d Ubuntu -u root -- bash scripts/wsl-host-setup.sh <linux-user> "<ssh public key>" [port]
#
# What it does:
#   - installs openssh-server, Node.js, git and curl
#   - SSH: key-only login, no root login, only <linux-user>, on <port> (default 2222)
#   - adds the given public key to <linux-user>'s authorized_keys
#   - installs Claude Code for <linux-user> (you still sign in once: run `claude` in WSL)
#
# Also needed on the Windows side (the agent controller in WSL must reach the local
# Switch server, which only listens on 127.0.0.1):
#   - %USERPROFILE%\.wslconfig  ->  [wsl2]  networkingMode=mirrored   then `wsl --shutdown`
#   - %USERPROFILE%\.ssh\config ->  Host wsl-switch / HostName localhost / Port 2222 /
#                                   User <linux-user> / IdentityFile <your key>
#   - Node.js 20+ on the host: Ubuntu's apt Node 18 is too old for Switch; install a
#     current Node into ~/.local and link node, npm, npx and claude into /usr/local/bin
#     so non-interactive SSH sessions find them.
set -euo pipefail

USER_NAME="${1:?linux user name}"
PUBKEY="${2:?ssh public key}"
PORT="${3:-2222}"
HOME_DIR="$(getent passwd "$USER_NAME" | cut -d: -f6)"
[ -n "$HOME_DIR" ] || { echo "No such user: $USER_NAME" >&2; exit 1; }

echo "==> Installing packages"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq openssh-server nodejs git curl ca-certificates >/dev/null

echo "==> Configuring sshd on port $PORT (key-only, user $USER_NAME)"
cat > /etc/ssh/sshd_config.d/10-switch.conf <<EOF
Port $PORT
ListenAddress 127.0.0.1
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
AllowUsers $USER_NAME
EOF

install -d -m 700 -o "$USER_NAME" -g "$USER_NAME" "$HOME_DIR/.ssh"
touch "$HOME_DIR/.ssh/authorized_keys"
grep -qxF "$PUBKEY" "$HOME_DIR/.ssh/authorized_keys" || echo "$PUBKEY" >> "$HOME_DIR/.ssh/authorized_keys"
chown "$USER_NAME:$USER_NAME" "$HOME_DIR/.ssh/authorized_keys"
chmod 600 "$HOME_DIR/.ssh/authorized_keys"

echo "==> Starting sshd"
if [ "$(ps -p 1 -o comm=)" = "systemd" ]; then
  mkdir -p /etc/systemd/system/ssh.service.d
  printf '[Service]\nRestart=on-failure\nRestartSec=5\n' > /etc/systemd/system/ssh.service.d/restart.conf
  systemctl daemon-reload
  systemctl disable --now ssh.socket >/dev/null 2>&1 || true
  systemctl enable ssh.service >/dev/null 2>&1
  systemctl restart ssh.service
else
  mkdir -p /run/sshd
  pkill -x sshd 2>/dev/null || true
  /usr/sbin/sshd
fi

echo "==> Installing Claude Code for $USER_NAME"
if ! su - "$USER_NAME" -c 'test -x "$HOME/.local/bin/claude"'; then
  su - "$USER_NAME" -c 'curl -fsSL https://claude.ai/install.sh | bash' >/dev/null
fi
grep -q '.local/bin' "$HOME_DIR/.profile" 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME_DIR/.profile"

echo
echo "Done."
echo "  node:   $(node --version)"
echo "  claude: $(su - "$USER_NAME" -c '$HOME/.local/bin/claude --version' 2>/dev/null || echo 'not found')"
echo "  sshd:   listening on $(ss -ltn | awk -v p=":$PORT" '$4 ~ p {print $4}' | head -1)"
echo "Next: run 'wsl -d Ubuntu' then 'claude' and sign in once."
