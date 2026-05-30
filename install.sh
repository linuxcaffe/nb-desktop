#!/usr/bin/env bash
# nb-desktop install — copies nb-import into place and wires up file manager integration.
# Supports: Nemo (Linux Mint Cinnamon), Caja (Linux Mint MATE / Ubuntu MATE)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BIN="$HOME/.local/bin/nb-import"
NEMO_ACTIONS="$HOME/.local/share/nemo/actions"
CAJA_SCRIPTS="$HOME/.config/caja/scripts"
CAJA_SCRIPTS_ALT="$HOME/.local/share/caja/scripts"

echo "nb-desktop install"
echo "------------------"

# ── Main script ───────────────────────────────────────────────────────────────
mkdir -p "$(dirname "$BIN")"
cp "$SCRIPT_DIR/bin/nb-import" "$BIN"
chmod +x "$BIN"
echo "✓ nb-import → $BIN"

# ── Nemo ─────────────────────────────────────────────────────────────────────
if command -v nemo &>/dev/null; then
    mkdir -p "$NEMO_ACTIONS"
    # Patch Exec line to use the installed script path
    sed "s|/home/djp|$HOME|g" \
        "$SCRIPT_DIR/nemo/nb-import.nemo_action" \
        > "$NEMO_ACTIONS/nb-import.nemo_action"
    echo "✓ Nemo action → $NEMO_ACTIONS/nb-import.nemo_action"
    echo "  (no restart needed — Nemo loads actions live)"
else
    echo "  Nemo not found, skipping"
fi

# ── Caja ─────────────────────────────────────────────────────────────────────
if command -v caja &>/dev/null; then
    # Prefer ~/.config/caja/scripts if it exists, otherwise ~/.local/share/caja/scripts
    if [[ -d "$CAJA_SCRIPTS" ]]; then
        DEST="$CAJA_SCRIPTS"
    else
        DEST="$CAJA_SCRIPTS_ALT"
        mkdir -p "$DEST"
    fi
    cp "$SCRIPT_DIR/caja/Import to nb" "$DEST/Import to nb"
    chmod +x "$DEST/Import to nb"
    echo "✓ Caja script → $DEST/Import to nb"
    echo "  Right-click a file → Scripts → Import to nb"
else
    echo "  Caja not found, skipping"
fi

echo ""
echo "Done. Try right-clicking a file in your file manager."
