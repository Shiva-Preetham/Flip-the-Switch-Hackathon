#!/usr/bin/env bash
# Creates (or resets) the ShopLite workspace the Switch agents work in.
# Usage: scripts/setup-workspace.sh [dir]   (default: ~/switch-demo/shoplite)
set -euo pipefail

DEST="${1:-$HOME/switch-demo/shoplite}"
SRC="$(cd "$(dirname "$0")/../demo-app/shoplite" && pwd)"

rm -rf "$DEST"
mkdir -p "$DEST"
cp -R "$SRC"/. "$DEST"/

cd "$DEST"
git init -q -b main
git add -A
git -c user.name='ShopLite Bot' -c user.email='shoplite@example.com' commit -q -m 'ShopLite 1.4.0'

echo
echo "Workspace ready: $DEST"
echo 'Paste this path into the "Workspace" field when you create the Support-to-Ship template.'
