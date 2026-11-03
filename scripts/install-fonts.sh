#!/usr/bin/env bash
# Install Nerd Font builds used by the kitty config.
#
# Downloads the official nerd-fonts release archive for each requested font
# and installs only the "Nerd Font Mono" faces (fixed-width glyphs, which is
# what terminals expect). Defaults to GeistMono.
#
# Usage: ./scripts/install-fonts.sh [FontName ...]
#   e.g. ./scripts/install-fonts.sh GeistMono Lilex
#
# Linux: ~/.local/share/fonts/<Name>-NF/ (then fc-cache)
# macOS: ~/Library/Fonts/
#
# Safe to re-run: every step is idempotent.

set -euo pipefail

BASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"

log() { printf '%s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

# ── Preconditions ──────────────────────────────────────────────────────
command -v curl >/dev/null || die "curl not found"
command -v unzip >/dev/null || die "unzip not found"

OS="$(uname -s)"
case "$OS" in
    Linux)  command -v fc-cache >/dev/null || die "fc-cache not found (install fontconfig)" ;;
    Darwin) ;;
    *) die "unsupported OS: $OS" ;;
esac

if [ "$#" -eq 0 ]; then
    set -- GeistMono
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# ── Install each font ──────────────────────────────────────────────────
install_font() {
    local name="$1"
    local zip="$TMP_DIR/$name.zip"
    local stage="$TMP_DIR/$name"

    log "Downloading $name…"
    curl -fsSL -o "$zip" "$BASE_URL/$name.zip" \
        || die "could not download $BASE_URL/$name.zip (check the font name)"

    mkdir -p "$stage"
    # unzip exits non-zero when one of the patterns matches nothing (a font
    # ships either .ttf or .otf), so success is judged by the files found.
    unzip -qq -o -j "$zip" '*NerdFontMono-*.ttf' '*NerdFontMono-*.otf' -d "$stage" 2>/dev/null || true

    local files=()
    while IFS= read -r f; do files+=("$f"); done < <(find "$stage" -type f | sort)
    [ "${#files[@]}" -gt 0 ] || die "$name.zip has no *NerdFontMono-* files"

    local dest
    if [ "$OS" = "Darwin" ]; then
        dest="$HOME/Library/Fonts"
    else
        dest="$HOME/.local/share/fonts/$name-NF"
        rm -rf "$dest"
    fi
    mkdir -p "$dest"
    cp -f "${files[@]}" "$dest/"
    log "Installed ${#files[@]} files to $dest"
}

for font in "$@"; do
    install_font "$font"
done

# ── Refresh the font cache and report ──────────────────────────────────
if [ "$OS" = "Linux" ]; then
    log "Refreshing font cache…"
    fc-cache -f
    for font in "$@"; do
        log "Families matching '$font':"
        fc-list : family | grep -i "$font" | sort -u || log "  (none found)"
    done
else
    log "macOS picks up ~/Library/Fonts automatically; restart kitty."
fi

log "Done. Reload kitty with ctrl+shift+F5 (or restart it)."
