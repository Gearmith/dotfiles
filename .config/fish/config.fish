# ~/.config/fish/config.fish
# Fish equivalent of the zsh setup (oh-my-zsh + starship + zsh-autosuggestions +
# zsh-syntax-highlighting). Autosuggestions and syntax highlighting are native
# to fish, so no plugins are needed for those.

# ── Homebrew ───────────────────────────────────────────────────────────
# Must run first: everything below resolves tools through PATH, and a desktop
# launch does not inherit a login shell's environment.
for brew_bin in /home/linuxbrew/.linuxbrew/bin/brew /opt/homebrew/bin/brew /usr/local/bin/brew
    if test -x $brew_bin
        $brew_bin shellenv | source
        break
    end
end

# ── PATH ───────────────────────────────────────────────────────────────
fish_add_path $HOME/.local/bin

# ── Secrets (never committed) ──────────────────────────────────────────
test -f $HOME/.config/fish/secrets.fish; and source $HOME/.config/fish/secrets.fish

# ── nvm (requires fisher + jorgebucaran/nvm.fish, see fish_plugins) ─────
set -gx NVM_DIR $HOME/.nvm

# ── Pager / bat ────────────────────────────────────────────────────────
set -gx BAT_THEME OneHalfDark
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -gx MANROFFOPT -c

# ── fzf look & feel (One Dark) ─────────────────────────────────────────
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
set -gx FZF_DEFAULT_OPTS "--height=60% --layout=reverse --border=rounded --info=inline --color=bg+:#3e4451,bg:#282c34,spinner:#56b6c2,hl:#e06c75 --color=fg:#abb2bf,header:#e06c75,info:#c678dd,pointer:#56b6c2 --color=marker:#98c379,fg+:#ffffff,prompt:#61afef,hl+:#e06c75"
set -gx FZF_CTRL_T_OPTS "--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
set -gx FZF_CTRL_R_OPTS "--layout=default --info=inline-right"
set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --icons --level=2 --color=always {}'"

if status is-interactive
    # ── Aliases ──────────────────────────────────────────────────────
    alias py="python3"
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first --git --time-style=long-iso'
    alias la='eza -la --icons --group-directories-first --git'
    alias lt='eza --tree --icons --level=2'
    alias tree='eza --tree --icons'
    alias cat='bat'
    alias catp='bat --plain'
    alias lg='lazygit'
    alias v='nvim'
    alias gs='git status -sb'
    alias ff='fastfetch'

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

    # ── Tool integrations (starship must stay last) ──────────────────
    type -q zoxide; and zoxide init fish --cmd cd | source
    type -q fzf; and fzf --fish | source
    type -q starship; and starship init fish | source
end
