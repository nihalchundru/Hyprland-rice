# Quickshell Lock Screen Style Switcher

An aesthetic style switcher for Quickshell lockscreens based on the Caelestia / Hyprland design system.

---

### Features

- **Live Sandbox Previews:** Instant interactive rendering of both **Veil** (Material 3 • Iris) and **Tessera** (Cyberpunk Bento).
- **Seamless Switching:** Updates `~/.config/quickshell/current_lockscreen` symlink and `lockscreen.json` without needing to reload or edit Hyprland configs.
- **Carousel Navigation:** 6 style cards matching the reference design (Veil, Bloom, Orbit, Darkroom, Deck, Tessera) with "In use" indicator and selection glowing borders.
- **Keyboard Shortcuts:**
  - `←` / `→` : Cycle between available styles
  - `Enter` / `Return` : Apply chosen style
  - `Escape` : Dismiss switcher

---

### Setup & Testing

1. **Deploy to Linux machine:**
   ```bash
   scp -r /Users/nihal/qs/lockscreen-switcher nihal@172.16.19.129:~/.config/quickshell/
   ```

2. **Open the Switcher:**
   ```bash
   qs -p ~/.config/quickshell/lockscreen-switcher/shell.qml
   ```

3. **Lockscreen Keybind in `hyprland.conf`:**
   Bind your lock key to the dynamic symlink:
   ```ini
   bind = $mainMod, L, exec, qs -p ~/.config/quickshell/current_lockscreen/shell.qml
   bind = $mainMod, O, exec, qs -p ~/.config/quickshell/lockscreen-switcher/shell.qml
   ```
