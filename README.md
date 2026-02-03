# dotfiles

My personal configuration files for Linux and macOS.

## What's in here?

This repo has evolved over time as I've switched between different setups. Here's what's actively maintained:

### Wayland / Hyprland
- **hyprland** - Tiling compositor config, migrated from i3-gaps
- **waybar** - Status bar with emoji icons
- **foot** - Minimal terminal emulator
- **wofi** - Application launcher
- **mako** - Notification daemon
- **hyprlock** - Lock screen
- **hypridle** - Idle management

### X11 / i3 (legacy, but still there)
- **i3** / **i3-gaps** - Tiling window manager configs
- **polybar** - Status bar
- **picom** - Compositor for transparency and effects
- **X11** - Xresources and other X11 bits

### macOS
- **aerospace** - Tiling window manager for macOS

### Shell & Terminal
- **zsh** - Shell configuration
- **bash** - Bash configs (mostly unused now)
- **tmux** - Terminal multiplexer with project switcher scripts
- **neovim** - Text editor config

### Other stuff
- **git** - Git configuration
- **fonts** - Custom fonts
- **opencode** - OpenCode AI assistant config

## Installation

I use [GNU Stow](https://www.gnu.org/software/stow/) to manage symlinks for configurations I need.

```bash
# Install Hyprland configs
stow hyprland

# Install waybar
stow waybar

# Install multiple at once
stow zsh tmux neovim foot
```

### Unstow (remove symlinks)

```bash
stow -D hyprland
```

## Notes

### Hyprland setup

My Hyprland config is split into multiple files for organization:
- `hyprland.conf` - Main config, monitor settings, input devices
- `theme.conf` - Colors, gaps, borders, visual stuff
- `keybinds.conf` - All keyboard shortcuts (uses Alt as mod key, like i3)
- `rules.conf` - Window rules
- `autostart.conf` - Programs to launch on startup

### Touchpad vs Mouse scrolling

I use per-device input config to handle natural scroll differently:
- Touchpad: natural scroll ON (swipe down = scroll down)
- External mouse: natural scroll OFF (wheel down = scroll down)

Uses wildcard matching (`*touchpad*`, `*mouse*`) so it works across different hardware.

### Font setup

I use Liberation Mono as my primary terminal font, with Noto Color Emoji as fallback for emoji rendering. Waybar uses the same font stack so everything looks consistent.

### Project workflow with tmux

I have a couple of scripts that make working with tmux and projects way easier:

#### `proj` - Project switcher
Fuzzy-finds projects in `~/src` and opens them in tmux sessions. Each project gets its own named tmux session.

```bash
# Launch fzf to pick a project
proj

# Jump directly to a project (if there's only one match)
proj dotfiles

# Search with a query
proj hypr
```

In tmux, use `Ctrl-b Ctrl-p` to open the project switcher in a new window.

It's smart about session names - if you have multiple projects with the same name in different directories, it'll use abbreviated paths to keep them unique.

#### `tmux-loop` - Auto-attach to tmux
Put this in your shell config (zsh/bash) to automatically attach to a "main" tmux session when you open a terminal:

```bash
source tmux-loop
```

When you close the tmux session (kill the shell), it closes the terminal too. But if you detach manually with `Ctrl+b d`, you drop back to a normal shell. Basically makes tmux feel more integrated.

## Requirements

### Core Hyprland setup

```bash
sudo pacman -S hyprland waybar foot wofi mako hyprlock hypridle \
               swww polkit-gnome
```

### Fonts

```bash
sudo pacman -S noto-fonts-emoji ttf-liberation-mono ttf-dejavu
```

### System utilities

```bash
sudo pacman -S brightnessctl wireplumber pipewire pipewire-pulse \
               grim slurp wl-clipboard pavucontrol jq
```

### Shell and terminal

```bash
sudo pacman -S tmux zsh neovim fzf
```

### Optional

```bash
# Network manager applet
sudo pacman -S network-manager-applet
```

## Platform support

- **Arch Linux** - Primary platform, everything works
- **macOS** - Aerospace config for tiling, terminal stuff works
- **Other distros** - Should work but might need package name adjustments
