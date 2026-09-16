# dotfiles

Personal configs for Neovim ([LazyVim](https://www.lazyvim.org/)), [fish](https://fishshell.com/),
[kitty](https://sw.kovidgoyal.net/kitty/) and [starship](https://starship.rs/). Both fish and Neovim's
theme (Catppuccin Mocha) are matched with kitty's colors for a consistent look.

## Install

### 1. Prerequisites (macOS, via Homebrew)

```sh
brew install fish neovim kitty starship
brew install --cask font-jetbrains-mono-nerd-font
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
```

### 4. Install fish plugins

Install [fisher](https://github.com/jorgebucaran/fisher), then the plugins listed in `fish_plugins`
(currently just `nvm.fish`, for Node version management inside fish):

```fish
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
fisher install jorgebucaran/fisher
fisher update
```

### 5. (GNOME only) Enable window blur

kitty's `background_blur` needs a compositor that implements a blur protocol
(macOS, KWin). GNOME's Mutter does not, so on GNOME the blur comes from the
[Blur my Shell](https://extensions.gnome.org/extension/3193/blur-my-shell/)
extension:

```sh
./scripts/setup-gnome-blur.sh
```

The script enables the extension and points its "applications" pipeline at
kitty. It is idempotent and exits quietly outside GNOME.

### 6. Set fish as your default shell

```sh
echo $(which fish) | sudo tee -a /etc/shells
chsh -s $(which fish)
```

### 7. Open kitty

`kitty.conf` already points `shell fish`, so a fresh kitty window starts in fish automatically —
no extra setup needed there.

## Structure

```
.config/
├── nvim/            LazyVim config (Catppuccin Mocha, transparent background)
├── fish/
│   ├── config.fish  aliases, git abbreviations, PATH, starship init
│   └── fish_plugins fisher plugin list
├── kitty/
│   └── kitty.conf   Catppuccin Mocha theme, JetBrainsMono Nerd Font
└── starship.toml    shared prompt config

scripts/
└── setup-gnome-blur.sh   GNOME-only: window blur for kitty
```

## Machine-local overrides

`kitty.conf` ends with `globinclude local.conf`, so anything host-specific goes
in `.config/kitty/local.conf` (gitignored) instead of the tracked config. That
is where an absolute `shell` path or a per-machine font belongs:

```conf
shell /home/linuxbrew/.linuxbrew/bin/fish
font_family SFMono Nerd Font Mono
font_size   11.0
```
