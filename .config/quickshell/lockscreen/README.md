# Material 3 Quickshell Lockscreen for Hyprland

A state-of-the-art Material 3 lockscreen built with [Quickshell](https://outfoxxed.me/quickshell/) for Hyprland and Wayland compositors.

![Lockscreen Showcase](lockscreen_showcase.png)

---

## Features

- **Analog + Digital Clock (`Clock.qml`)**: 9-sided cookie shape with smooth, drift-free seconds hand and bold stacked 12h digital time inside.
- **Dynamic Weather & Date (`DateBadge.qml`)**: Sub-header pill showing current date and live weather condition using official Google Weather `set-6/dark` gradient SVGs and temperature via `wttr.in`.
- **M3 Password Field (`PasswordPill.qml`)**:
  - Each keystroke renders a random Material 3 shape character with entry/exit scale and rotation overshoot.
  - Horizontal haptic shake on failed PAM authentication.
  - Circular accent proceed button for mouse or touch unlock.
- **Animated Caps Lock Warning (`LockSurface.qml`)**: Smoothly expands below the password field when Caps Lock is active, synced with hardware and typed keystroke casing.
- **Now Playing MPRIS Card (`MediaCard.qml`)**:
  - Album art masked into the 9-sided cookie shape matching the clock.
  - Interactive track scrubber line with seek support.
  - Previous, Play/Pause, and Next controls.
  - Gracefully expands when music is active and collapses to 0 height when idle.
- **4-Corner Symmetry**:
  - **Top-Left (`UserBadge.qml`)**: User avatar (`~/.face`) cropped into an M3 cookie with personal greeting.
  - **Top-Right (`StatusPill.qml`)**: Battery (with charging bolt), volume (mouse wheel to scroll volume, click to mute via `wpctl`), and network status.
  - **Bottom-Left (`NotificationPill.qml`)**: Privacy-conscious notification count.
  - **Bottom-Right (`PowerActions.qml`)**: Suspend, Reboot, and Power Off with 2-step confirmation to prevent accidental clicks.
- **Ambient Idle Mode (`LockSurface.qml`)**: After 25s of inactivity, background and secondary items softly dim into an ambient smart clock display. Typing or moving mouse wakes instantly.

---

## File Structure

```
lockscreen/
├── shell.qml              # Session lock root (WlSessionLock)
├── LockContext.qml        # PAM authentication, state management, transitions
├── LockSurface.qml        # Screen layout, ambient idle timer, keyboard input
├── Background.qml         # Wallpaper blurred with MultiEffect + contrast scrim
├── Clock.qml              # 9-sided cookie analog clock with stacked digital digits
├── DateBadge.qml          # Date pill + live Google Weather set-6 dark icon
├── MediaCard.qml          # Now Playing MPRIS card with 9-sided cookie album art
├── PasswordPill.qml       # Animated pill container with failure shake
├── PasswordChar.qml       # Animated Material 3 shape character glyph
├── UserBadge.qml          # Top-left avatar + greeting
├── StatusPill.qml         # Top-right battery, scrollable volume, network
├── NotificationPill.qml   # Bottom-left privacy notification badge
├── PowerActions.qml       # Bottom-right session buttons (suspend, reboot, poweroff)
├── MShape.qml             # Shape wrapper sizing ShapeCanvas
├── ShapeList.js           # List of 35 Material 3 shape names
├── weather-icons/         # 22 Google Weather set-6 dark SVGs
├── rounded-polygon-qmljs/ # Polygon bezier drawing library
└── pam/
    └── password.conf      # Password-only PAM config (pam_unix)
```

---

## System Requirements & Dependencies

- **Quickshell** (v0.1.0+) with Wayland session lock support
- **Pipewire & Wireplumber** (`wpctl`) for audio volume and mute control
- **NetworkManager** (`nmcli`) for WiFi/network status detection
- **curl** for weather updates
- **systemd** (`systemctl`) for suspend/reboot/poweroff actions
- **PAM** (`pam_unix.so`) for user authentication

---

## Configuration & Integration

### 1. Test Lockscreen
```bash
qs -p ~/.config/quickshell/lockscreen/shell.qml
```

### 2. Hyprland Keybinding (`~/.config/hypr/hyprland.conf`)
Bind your desired lock shortcut (e.g. `Super + L`):
```ini
bind = $mainMod, L, exec, qs -p ~/.config/quickshell/lockscreen/shell.qml
```

### 3. Hypridle Auto-Lock (`~/.config/hypr/hypridle.conf`)
Lock before suspend and on idle timeout:
```ini
general {
    lock_cmd = qs -p ~/.config/quickshell/lockscreen/shell.qml
    before_sleep_cmd = qs -p ~/.config/quickshell/lockscreen/shell.qml
}

listener {
    timeout = 300 # 5 minutes
    on-timeout = qs -p ~/.config/quickshell/lockscreen/shell.qml
}
```

---

## Customization

- **Wallpaper**: Change the path in `Background.qml` (defaults to `~/.config/rofi/images/a.png`).
- **Colors**: Automatically live-reloads from `~/.config/quickshell/topbar/colors.json`, or configure default fallbacks in `Colors.qml`.
- **Avatar**: Place your profile picture at `~/.face` or `~/.face.icon`.
