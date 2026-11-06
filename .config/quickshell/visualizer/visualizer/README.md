# Quickshell Visualizer

An audio visualizer panel for Quickshell that runs [cava](https://github.com/karlstav/cava)
in raw ASCII mode and renders 10 styles with a full in-session settings panel.

## Files
- `shell.qml` – entry point: strip PanelWindow per screen (Variants) + settings popup window
- `Visualizer.qml` – canvas renderer (all styles)
- `Cava.qml` – singleton that spawns cava and parses its output
- `Colors.qml` – singleton that reads `~/.config/quickshell/topbar/colors.json` live
- `Config.qml` – singleton holding the settings model (saved to `settings.json`)
- `components/` – reusable panel controls (slider, switch, choice, text, section)
- `cava.conf` – generated on the fly; a static example is also committed

## Install
1. Copy the whole folder to `~/.config/quickshell/visualizer/visualizer/` on the Linux machine (the folder you run `qs -p` from).
2. Make sure `cava` is installed (`sudo apt install cava` / `pacman -S cava`).
3. Add the visualizer to a Quickshell config (e.g. append to your `quickshell.toml`):
   ```toml
   include = "~/.config/quickshell/visualizer/visualizer/shell.qml"
   ```
4. Reload Quickshell. The visualizer appears as a layer-shell surface.

## Settings
Open the panel via the ⚙ button in the top-left corner of the visualizer.
Everything is saved to `~/.config/quickshell/visualizer/visualizer/settings.json` and hot-applied:
style, position, size, bars, colors, smoothing, sensitivity, audio input, etc.

## Colors
`Colors.qml` watches `~/.config/quickshell/topbar/colors.json` and picks color keys
by common names (`background`, `primary`, `secondary`, `tertiary`, `error`, ...),
falling back to sane defaults when a key is missing. Any flat or nested JSON works.
It also falls back to cava's own background if the file can't be read.

## Notes
- Requires `cava` and a working audio input (pulse/pipewire/alsa).
- The panel uses a second overlay window; on layer-shell, clicking the ⚙ toggles it.

## Keybind (optional)
The panel can be toggled from a keybind without touching the gear button, e.g. in Hyprland:
```
bind = SUPER, V, exec, qs ipc call visualizer toggleSettings
```
IPC also exposes `setStyle`, `setPosition` and `setEnabled`, e.g. `qs ipc call visualizer setStyle circle`.
