# Firecrust — a Quickshell bar for Hyprland

A status bar written in QML for [Quickshell](https://quickshell.org), themed to
match the Firecrust pizza hero page (charcoal, tomato, cheese, basil).

Targets **Quickshell v0.3.x** and **Hyprland**. Everything else degrades gracefully.

## What it does

| Zone | Widget | Source |
| --- | --- | --- |
| left | workspace chips, click to switch | `Quickshell.Hyprland` |
| left | focused window title, elided | `Hyprland.activeToplevel` |
| centre | now playing, click to play/pause | `Quickshell.Services.Mpris` |
| centre | clock | `SystemClock` |
| right | volume, scroll to change, click to mute | `Quickshell.Services.Pipewire` |
| right | battery, click to suspend | `Quickshell.Services.UPower` |
| right | system tray, right-click for menu | `Quickshell.Services.SystemTray` |

One bar is created per connected monitor, and monitor hotplug is handled for free
because `Quickshell.screens` is reactive.

## Dependencies

```bash
# Quickshell itself (check your repos first — package name varies)
sudo pacman -S quickshell        # or: yay -S quickshell-git

# Runtime services the widgets talk to
sudo pacman -S upower pipewire    # upower is needed for Battery.qml
systemctl --user enable --now pipewire

# A Nerd Font, for the small glyphs in Volume.qml / Battery.qml
sudo pacman -S ttf-jetbrains-mono-nerd
```

Quickshell is not in the official Arch `extra` repo on every mirror — if
`pacman -S quickshell` misses, use the AUR package `quickshell` or `quickshell-git`.

## Install

Quickshell looks in `~/.config/quickshell/` for configs. Each **named subfolder**
containing a `shell.qml` is one config:

```bash
scp -r quickshell/ arch-vm:~/.config/quickshell/firecrust/
```

That gives `~/.config/quickshell/firecrust/shell.qml`.

> If `~/.config/quickshell/shell.qml` exists directly, Quickshell ignores the
> subfolders. Delete it if you have a leftover one.

## Run

```bash
qs -c firecrust          # pick the config by name
# or, for a one-off file without touching your config dir:
qs -p ~/.config/quickshell/firecrust/shell.qml
```

Autostart it from Hyprland:

```ini
# ~/.config/hypr/hyprland.conf
exec-once = qs -c firecrust
```

Editing any file reloads the bar live — there's no build step.

## IPC

```bash
qs ipc show                    # list registered targets
qs ipc call bar reload         # reload the shell (soft, windows reused)
qs ipc call bar togglePlay     # toggle the first MPRIS player
qs log                         # tail the shell's logs
```

## Files

```
shell.qml        entry point: one Bar per screen, IPC handlers
Theme.qml        pragma Singleton — palette and metrics, the only place to restyle
Bar.qml          the PanelWindow: anchors, exclusive zone, three-zone layout
Workspaces.qml   Hyprland workspace chips, filtered to this monitor
ActiveWindow.qml focused window title
Media.qml        MPRIS now-playing pill
Clock.qml        SystemClock
Volume.qml       Pipewire default sink
Battery.qml      UPower displayDevice
Tray.qml         SystemTray + QsMenuAnchor for menus
```

Everything lives in one flat folder on purpose. QML implicitly imports types from
neighbouring files, so `Theme` and all the components are usable by name from any
file here without a single import statement — and it keeps the LSP happy.

## Gotchas

- **Fonts.** `Theme.sans` is `Inter` and `Theme.mono` is `JetBrainsMono Nerd Font`.
  If you don't have them, Qt substitutes and the layout still holds — but the two
  PUA glyphs in `Volume.qml` and `Battery.qml` will render as boxes. Either install
  a Nerd Font or edit those `Text` elements to taste.
- **Battery** is hidden unless `UPower.displayDevice.isLaptopBattery` is true, so a
  desktop shows nothing rather than an empty slot.
- **Volume** needs `pipewire` running. The `audio.*` properties are only valid
  because `PwObjectTracker` binds the sink — remove that and the volume reads 0.
- **Suspend on battery click** shells out to `systemctl suspend`. Change the
  `onClicked` in `Battery.qml` if you have a power menu.

## Restyling in one place

`Theme.qml` is the whole design system:

```qml
readonly property color base:      "#140d0a"
readonly property color surface:   "#1e1310"
readonly property color tomato:    "#ff4d2e"
readonly property color cheese:    "#ffc24b"
readonly property color basil:     "#6ec04a"
readonly property int   barHeight: 34
readonly property int   radius:    10
readonly property int   gap:       6
```

Change `barHeight` and the bar, its `exclusiveZone`, and every widget's vertical
centring all follow.
