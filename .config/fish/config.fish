# ~/.config/fish/config.fish
# Fish equivalent of the zsh setup (oh-my-zsh + starship + zsh-autosuggestions +
# zsh-syntax-highlighting). Autosuggestions and syntax highlighting are native
# to fish, so no plugins are needed for those.

if status is-interactive
    # ── Aliases ──────────────────────────────────────────────────────
    alias py="python3"

    # ── Git shortcuts (mirrors oh-my-zsh's git plugin) ─────────────────
    abbr -a g    git
    abbr -a gst  'git status'
    abbr -a ga   'git add'
    abbr -a gaa  'git add --all'
    abbr -a gc   'git commit -v'
    abbr -a gcm  'git commit -m'
    abbr -a gco  'git checkout'
    abbr -a gcb  'git checkout -b'
    abbr -a gb   'git branch'
    abbr -a gd   'git diff'
    abbr -a gds  'git diff --staged'
    abbr -a gl   'git pull'
    abbr -a gp   'git push'
    abbr -a glog 'git log --oneline --graph --decorate'
end

# ── PATH ───────────────────────────────────────────────────────────────
fish_add_path $HOME/.local/bin

# ── nvm (requires fisher + jorgebucaran/nvm.fish, see fish_plugins) ─────
set -gx NVM_DIR $HOME/.nvm

# ── Prompt (starship, same config as zsh) ───────────────────────────────
if type -q starship
    starship init fish | source
end
