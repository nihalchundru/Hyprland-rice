# astra-dots 🌌

A modern Hyprland rice for Arch Linux ARM (aarch64), built on Apple Silicon via VMware Fusion. Pure Quickshell — no waybar, no rofi. Dynamic theming, animated bars, and a fully custom QML desktop.

---

## Screenshots

> Coming soon

---

## Features

### Bars
- **Pill Bar** — 5 floating pills: media, theme, clock, wallpaper, control center. Each expands downward into a full dropdown panel
- **Notch Bar** — Apple-style morphing notch, expands on hover
- **Islands Bar** — Three independent floating islands, wallpaper breathes through the gaps

### Theming
- 14 static themes — Catppuccin, Tokyo Night, Gruvbox, Gruvbox Material, Nord, Rosé Pine, Everforest, One Dark, Astra Bloom, Crimson, Solarized and more
- **Iris** — dynamic color extraction from wallpaper
- **Matugen** — Material You dynamic theming with 9 palette schemes
- Light/dark variants for Gruvbox, Nord, Solarized
- All colors propagate live to Quickshell, Kitty, Hyprlock, Swaync

### Quickshell Components
- Theme switcher with color swatch grid
- Wallpaper picker (iris/matugen aware — shows all wallpapers when dynamic theme active)
- App launcher with fuzzy search
- OSD — volume and brightness pill
- Keybinds popup
- Desktop overview — current workspace screenshot, others show number
- Settings app — bar settings, clock format, appearance, control center config
- Applets — transition style, night shift, corner style, idle timeout, lockscreen, matugen scheme

### NothingShell
- Separate Caelestia-inspired shell with animated mpvpaper wallpapers
- Switch via `ALT+CTRL+S` — copies keybinds and reloads Hyprland
- Seamless handoff back to awww wallpaper daemon on switch

### System
- Hyprland config in Lua (`hyprland.lua`)
- awww for wallpaper transitions
- Hyprlock with live theme colors
- Hypridle with configurable timeout
- Swaync notifications
- Cliphist clipboard history
- Fish shell

---

## Dependencies

```
hyprland quickshell awww hyprlock hypridle hyprpicker
swaync cliphist playerctl brightnessctl
kitty fish pipewire wireplumber
nerd-fonts (JetBrainsMono)
iris matugen python3
```

---

## Structure

```
.config/
├── hypr/
│   ├── hyprland.lua          # Main config (Lua)
│   ├── keybindings.lua       # Keybinds (Lua)
│   ├── themes/
│   │   ├── themes.sh         # All theme palettes
│   │   └── current-name      # Active theme
│   └── scripts/
│       ├── write-colors.sh   # Master color propagator
│       ├── iris-apply.sh     # Iris dynamic colors
│       ├── matugen-apply.sh  # Matugen dynamic colors
│       ├── set-wallpaper.sh  # awww wrapper
│       └── qs-layout-switch.sh # Bar layout switcher
├── quickshell/
│   ├── topbar/               # Pill bar
│   ├── notch/                # Notch bar
│   ├── islands/              # Islands bar
│   ├── applets/              # All switcher applets
│   ├── theme-switcher/       # Standalone theme picker
│   ├── wallpaper-picker/     # Standalone wallpaper picker
│   ├── launcher/             # App launcher
│   ├── osd/                  # Volume/brightness OSD
│   ├── keybinds/             # Keybinds popup
│   ├── overview/             # Desktop overview
│   └── settings/             # Settings app
├── kitty/                    # Terminal
├── waybar/                   # Waybar layouts (legacy)
└── rofi/                     # Rofi themes (legacy)
```

---

## Keybinds

| Key | Action |
|-----|--------|
| `ALT + D` | App Launcher |
| `ALT + T` | Theme Switcher |
| `ALT + W` | Wallpaper Switcher |
| `ALT + M` | Keybinds Popup |
| `ALT + O` | Desktop Overview |
| `ALT + L` | Lock Screen |
| `ALT + N` | Notifications |
| `ALT + V` | Clipboard History |
| `ALT + SHIFT + A` | Settings App |
| `ALT + SHIFT + T` | Transition Style |
| `ALT + SHIFT + L` | Transition Duration |
| `ALT + SHIFT + N` | Night Shift |
| `ALT + CTRL + S` | Shell Switcher (NothingShell) |
| `ALT + Return` | Terminal (Kitty) |
| `ALT + Q` | Close Window |
| `ALT + F` | Fullscreen |
| `PRINT` | Screenshot |
| `SHIFT + PRINT` | Area Screenshot |

---

## Platform

Built on **Arch Linux ARM (aarch64) (ALARM)**. All components are ARM-native. 

---

## Credits

https://github.com/sahibjotsaggu/San-Francisco-Pro-Fonts: For SF Pro fonts

https://github.com/Tsunami43/nothingshell: For alternate shell, make sure to go check out the repo!

https://github.com/doannc2212/quickshell-config: For insipiration of quickshell applets, theme picker, and wallpaper switcher

https://github.com/ilyamiro/serpantinum: For Alternate shell, please go check out his repo it a very nice rice

https://github.com/LUCKYS1NGHH/ChillPill-Shell: For Pill Shell
