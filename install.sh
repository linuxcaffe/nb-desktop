#!/usr/bin/env bash
# nb-desktop install — installs the nb import plugin and wires up file manager integration.
# Supports: Nemo (Linux Mint Cinnamon), Caja (Linux Mint MATE / Ubuntu MATE)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NB_PLUGINS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../nb-plugins" && pwd 2>/dev/null || true)"

NEMO_ACTIONS="$HOME/.local/share/nemo/actions"
CAJA_SCRIPTS="$HOME/.config/caja/scripts"
CAJA_SCRIPTS_ALT="$HOME/.local/share/caja/scripts"

echo "nb-desktop install"
echo "------------------"

# ── nb import plugin ──────────────────────────────────────────────────────────
NB_BIN="$(command -v nb 2>/dev/null || echo "/usr/local/bin/nb")"

if [[ ! -x "$NB_BIN" ]]; then
    echo "ERROR: nb not found. Install nb first: https://xwmx.github.io/nb/"
    exit 1
fi

PLUGIN_SRC="${NB_PLUGINS_DIR}/send.nb-plugin"
if [[ ! -f "$PLUGIN_SRC" ]]; then
    echo "ERROR: send.nb-plugin not found at $PLUGIN_SRC"
    echo "  Clone nb-plugins alongside nb-desktop and re-run."
    exit 1
fi

"$NB_BIN" plugin install "$PLUGIN_SRC" --force
echo "✓ nb import plugin installed"

# ── Nemo ─────────────────────────────────────────────────────────────────────
if command -v nemo &>/dev/null; then
    mkdir -p "$NEMO_ACTIONS"
    sed "s|/home/djp|$HOME|g" \
        "$SCRIPT_DIR/nemo/nb-import.nemo_action" \
        > "$NEMO_ACTIONS/nb-import.nemo_action"
    echo "✓ Nemo action → $NEMO_ACTIONS/nb-import.nemo_action"
    echo "  (no restart needed — Nemo loads actions live)"
else
    echo "  Nemo not found, skipping"
fi

# ── Caja ─────────────────────────────────────────────────────────────────────
# Symlinked, not copied -- one copy of the code lives in this repo; editing
# it here takes effect immediately, nothing to fall out of sync or get lost.
if command -v caja &>/dev/null; then
    if [[ -d "$CAJA_SCRIPTS" ]]; then
        DEST="$CAJA_SCRIPTS"
    else
        DEST="$CAJA_SCRIPTS_ALT"
        mkdir -p "$DEST"
    fi
    chmod +x "$SCRIPT_DIR/caja/Import to nb" "$SCRIPT_DIR/caja/Add New Item"
    ln -sf "$SCRIPT_DIR/caja/Import to nb" "$DEST/Import to nb"
    echo "✓ Caja script → $DEST/Import to nb (symlink)"

    ln -sf "$SCRIPT_DIR/caja/Add New Item" "$DEST/Add New Item"
    echo "✓ Caja script → $DEST/Add New Item (symlink)"
    echo "  Right-click image(s) → Scripts → Add New Item"
else
    echo "  Caja not found, skipping"
fi

echo ""
echo "Done. Try right-clicking a file in your file manager."

# ── PATH binaries ─────────────────────────────────────────────────────────────
mkdir -p "$HOME/.local/bin"
chmod +x "$SCRIPT_DIR/bin/nb-new-item"
ln -sf "$SCRIPT_DIR/bin/nb-new-item" "$HOME/.local/bin/nb-new-item"
echo "✓ nb-new-item → $HOME/.local/bin/nb-new-item (symlink)"
