#!/usr/bin/env bash
# Configure background blur for kitty on GNOME.
#
# kitty's own `background_blur` only works where the compositor implements a
# blur protocol (macOS, KWin). GNOME's Mutter does not, so on GNOME the blur
# comes from the Blur my Shell extension instead. This script enables that
# extension and points its "applications" pipeline at kitty.
#
# Safe to re-run: every step is idempotent.

set -euo pipefail

EXTENSION="blur-my-shell@aunetx"
SCHEMA="org.gnome.shell.extensions.blur-my-shell.applications"

log() { printf '%s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

# ── Preconditions ──────────────────────────────────────────────────────
case "${XDG_CURRENT_DESKTOP:-}" in
    *GNOME*) ;;
    *) log "Not a GNOME session (XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP:-unset}); nothing to do."
       exit 0 ;;
esac

command -v gnome-extensions >/dev/null || die "gnome-extensions not found"
command -v gsettings >/dev/null || die "gsettings not found"

if ! gnome-extensions list | grep -qx "$EXTENSION"; then
    die "$EXTENSION is not installed. Install it from https://extensions.gnome.org/extension/3193/blur-my-shell/ and re-run."
fi

# ── Enable the extension ───────────────────────────────────────────────
if gnome-extensions info "$EXTENSION" | grep -q 'State: ACTIVE'; then
    log "$EXTENSION already active."
else
    log "Enabling $EXTENSION…"
    gnome-extensions enable "$EXTENSION"
fi

# The extension ships its own schema outside the system schema path, so
# gsettings needs to be pointed at it explicitly.
SCHEMA_DIR="$HOME/.local/share/gnome-shell/extensions/$EXTENSION/schemas"
[ -d "$SCHEMA_DIR" ] || SCHEMA_DIR="/usr/share/gnome-shell/extensions/$EXTENSION/schemas"
[ -d "$SCHEMA_DIR" ] || die "cannot find the schema directory for $EXTENSION"

export GSETTINGS_SCHEMA_DIR="$SCHEMA_DIR"

# ── Configure the applications pipeline ────────────────────────────────
# dynamic-opacity must stay off: it makes the focused window opaque, which
# hides the blur exactly when you are looking at it.
log "Configuring blur for kitty…"
gsettings set "$SCHEMA" blur true
gsettings set "$SCHEMA" whitelist "['kitty']"
gsettings set "$SCHEMA" enable-all false
gsettings set "$SCHEMA" customize true
gsettings set "$SCHEMA" dynamic-opacity false
gsettings set "$SCHEMA" static-blur false
gsettings set "$SCHEMA" sigma 30
gsettings set "$SCHEMA" brightness 0.85
gsettings set "$SCHEMA" opacity 230

log "Done. kitty needs background_opacity below 1.0 for the blur to show."
