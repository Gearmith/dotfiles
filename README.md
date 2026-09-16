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

### 5. Set fish as your default shell

```sh
echo $(which fish) | sudo tee -a /etc/shells
chsh -s $(which fish)
```

### 6. Open kitty

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
```
