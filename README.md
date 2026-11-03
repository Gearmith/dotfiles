# dotfiles

Personal configs for Neovim ([LazyVim](https://www.lazyvim.org/)), [fish](https://fishshell.com/),
[kitty](https://sw.kovidgoyal.net/kitty/) and [starship](https://starship.rs/). Both fish and Neovim's
theme (GitHub Dark) are matched with kitty's colors for a consistent look.

## Install

### 1. Prerequisites (macOS, via Homebrew)

```sh
brew install fish neovim kitty starship jq
```

### 2. Clone this repo

```sh
git clone https://github.com/Gearmith/dotfiles.git ~/dotfiles
```

### 3. Symlink the configs

```sh
mkdir -p ~/.config
for dir in nvim fish kitty; do
  rm -rf ~/.config/$dir
  ln -s ~/dotfiles/.config/$dir ~/.config/$dir
done
ln -sf ~/dotfiles/.config/starship.toml ~/.config/starship.toml
mkdir -p ~/.config/herdr
ln -sf ~/dotfiles/.config/herdr/config.toml ~/.config/herdr/config.toml
```

### 4. Install fish plugins

Install [fisher](https://github.com/jorgebucaran/fisher), then the plugins listed in `fish_plugins`
(currently just `nvm.fish`, for Node version management inside fish):

```fish
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
fisher install jorgebucaran/fisher
fisher update
```

### 5. Install fonts

kitty uses [Geist Mono](https://vercel.com/font) as a Nerd Font build
(`GeistMono Nerd Font Mono`). The script downloads the official
[nerd-fonts](https://github.com/ryanoasis/nerd-fonts) release archive and
installs only the `*NerdFontMono-*` faces:

```sh
./scripts/install-fonts.sh              # GeistMono (default)
./scripts/install-fonts.sh GeistMono Lilex
```

- Linux: files go to `~/.local/share/fonts/<Name>-NF/`, then `fc-cache -f` runs.
- macOS: files go to `~/Library/Fonts/`.
- Requires `curl` and `unzip`. Safe to re-run.

Verify the font is visible:

```sh
fc-list | rg -i geist            # Linux
kitty +list-fonts | rg -i geist  # Linux and macOS
```

`kitty.conf` sets `features="+ss02"` on the font. That OpenType stylistic set
gives Geist Mono a single-story `a`. To use
[Lilex](https://github.com/mishamyrt/Lilex) instead, install it with the script
and change the line to:

```conf
font_family family="Lilex Nerd Font Mono" features="+cv01"
```

Restart kitty or reload the config with `ctrl+shift+F5` to apply a change.

### 6. (GNOME only) Enable window blur

kitty's `background_blur` needs a compositor that implements a blur protocol
(macOS, KWin). GNOME's Mutter does not, so on GNOME the blur comes from the
[Blur my Shell](https://extensions.gnome.org/extension/3193/blur-my-shell/)
extension:

```sh
./scripts/setup-gnome-blur.sh
```

The script enables the extension and points its "applications" pipeline at
kitty. It is idempotent and exits quietly outside GNOME.

### 7. Set fish as your default shell

```sh
echo $(which fish) | sudo tee -a /etc/shells
chsh -s $(which fish)
```

### 8. Open kitty

`kitty.conf` already points `shell fish`, so a fresh kitty window starts in fish automatically —
no extra setup needed there.

### 9. Claude Code statusline (optional)

`.config/claude/statusline.sh` renders a GitHub Dark statusline with a
quiet hierarchy: muted-gray labels, foreground values, one blue accent for
identity (directory, git branch, model, output style), and color only for
state. Line 1 shows those identity items; line 2 shows context-window usage
(always with a bar), session cost, duration, 5h/7d rate limits and lines
changed. Rate limits are plain text (`5h 4% · 7d 4%`) and only grow a progress
bar at 50% or more; bars and percentages turn green/yellow/red at 50%/80%.
Segments are separated by a dim `·`. Needs `jq` (see prerequisites).

`~/.claude/settings.json` is per-machine (holds local plugin/hook config), so
it is not tracked here — wire this in by hand on each device:

```json
"statusLine": {
  "type": "command",
  "command": "bash \"$HOME/dotfiles/.config/claude/statusline.sh\""
}
```

### 10. herdr keybindings (optional)

`.config/herdr/config.toml` keeps the default prefix (`ctrl+b`). Herdr's
which-key equivalent is built in: press `prefix+?` for a live panel of every
active binding, no extra config needed.

## Structure

```
.config/
├── nvim/            LazyVim config (GitHub Dark, transparent background)
├── fish/
│   ├── config.fish  aliases, git abbreviations, PATH, starship init
│   └── fish_plugins fisher plugin list
├── kitty/
│   └── kitty.conf   GitHub Dark theme, Geist Mono Nerd Font
├── claude/
│   └── statusline.sh  Claude Code statusline (GitHub Dark)
├── herdr/
│   └── config.toml  terminal workspace manager (default prefix, terminal theme)
└── starship.toml    shared prompt config

scripts/
├── install-fonts.sh      Nerd Font installer (GeistMono default, Lilex optional)
└── setup-gnome-blur.sh   GNOME-only: window blur for kitty
```

## Machine-local overrides

`kitty.conf` ends with `globinclude local.conf`, so anything host-specific goes
in `.config/kitty/local.conf` (gitignored) instead of the tracked config. That
is where an absolute `shell` path or a per-machine font belongs:

```conf
shell /home/linuxbrew/.linuxbrew/bin/fish
font_family family="GeistMono Nerd Font Mono" features="+ss02"
font_size   11.0
```
