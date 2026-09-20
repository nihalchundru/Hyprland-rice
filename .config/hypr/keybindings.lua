-- Generated/fixed from hyprconf2lua v1.4.0
-- Original: HyDE ARM keybindings
-- Converted to valid Hyprland Lua syntax.

local mainMod = "ALT"

local TERMINAL = "kitty"
local EXPLORER = "thunar"
local BROWSER = "zen-browser"

-- ── Window management ─────────────────────────────────────────────────────

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float())
-- bind = $mainMod, G, togglegroup
hl.bind("SHIFT + F11", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

-- ── Apps ──────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(TERMINAL))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(EXPLORER))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(BROWSER))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/launcher.sh"))

-- bind = $mainMod SHIFT, N, exec, flatpak run com.logseq.Logseq
-- bind = $mainMod SHIFT, M, exec, missioncenter
-- bind = $mainMod SHIFT, M, exec, btop

hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd("snappy-switcher toggle"))

-- ── HyDE controls ─────────────────────────────────────────────────────────

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/theme-switch.sh"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/wallpaper-switcher.sh"))

hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(
    "bash -c 'THEME=$(cat ~/.config/hypr/themes/current-name); WALL=$(find ~/.config/hypr/wallpapers/$THEME -type f \\( -iname \"*.png\" -o -iname \"*.jpg\" \\) | shuf -n 1); bash ~/.config/hypr/scripts/swww.sh \"$WALL\"'"
))

hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/lock.sh"))
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/powermenu.sh"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t"))
hl.bind(mainMod .. " + bracketleft", hl.dsp.exec_cmd("qs"))
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/hypridle-timeout-switcher.sh"))

-- ── Focus ─────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

hl.bind("ALT + Tab", hl.dsp.exec_cmd(
    "hyprctl --batch \"dispatch cyclenext ; dispatch alterzorder top\""
))

-- ── Move windows ──────────────────────────────────────────────────────────

hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- ── Resize ────────────────────────────────────────────────────────────────
-- The old resizeactive dispatcher is not directly used by the converter.
-- These are the Lua equivalents for resizing the active window.

hl.bind(mainMod .. " + CTRL + right",
    hl.dsp.window.resize({ x = 30, y = 0, relative = true }),
    { repeating = true })

hl.bind(mainMod .. " + CTRL + left",
    hl.dsp.window.resize({ x = -30, y = 0, relative = true }),
    { repeating = true })

hl.bind(mainMod .. " + CTRL + up",
    hl.dsp.window.resize({ x = 0, y = -30, relative = true }),
    { repeating = true })

hl.bind(mainMod .. " + CTRL + down",
    hl.dsp.window.resize({ x = 0, y = 30, relative = true }),
    { repeating = true })

-- ── Workspaces ────────────────────────────────────────────────────────────

for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- ── Screenshots ───────────────────────────────────────────────────────────

hl.bind("Print", hl.dsp.exec_cmd(
    "grim ~/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png && notify-send \"HyDE\" \"Screenshot saved\""
))

hl.bind("SHIFT + Print", hl.dsp.exec_cmd(
    "grim -g \"$(slurp)\" ~/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png"
))

hl.bind("CTRL + Print", hl.dsp.exec_cmd(
    "grim -g \"$(slurp)\" - | wl-copy && notify-send \"HyDE\" \"Screenshot copied\""
))

-- ── Volume ─────────────────────────────────────────────────────────────────

hl.bind("XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/volume.sh --inc"))

hl.bind("XF86AudioLowerVolume",
    hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/volume.sh --dec"))

hl.bind("XF86AudioMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))

hl.bind("XF86AudioPlay",
    hl.dsp.exec_cmd("playerctl play-pause"))

hl.bind("XF86AudioNext",
    hl.dsp.exec_cmd("playerctl next"))

hl.bind("XF86AudioPrev",
    hl.dsp.exec_cmd("playerctl previous"))

-- ── Mouse ─────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Layout switcher
hl.bind(mainMod .. " + P",
    hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/layout-switcher.sh"))

--hl.bind(mainMod .. " + SHIFT + B",
   -- hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/bar-switch.sh"))

hl.bind(mainMod .. " + SHIFT + C",
    hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/corner-switcher.sh"))

-- Quickshell sidebar
hl.bind(mainMod .. " + A",
    hl.dsp.exec_cmd("qs ipc call sidebar toggle"))

hl.bind(mainMod .. " + X",
    hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/control-panel.sh"))

--hl.bind(mainMod .. " + SHIFT + D",
  --  hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/rofi-layout-switcher.sh"))

hl.bind(mainMod .. " + SHIFT + P",
    hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/powermenu-layout-switcher.sh"))

--hl.bind(mainMod .. " + SHIFT + S",
  --  hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/picker-style-switcher.sh"))

hl.bind(mainMod .. " + SHIFT + T",
    hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/transition-switcher.sh"))

-- Keybinds popup
hl.bind(mainMod .. " + M",
    hl.dsp.exec_cmd("qs ipc -c ~/.config/quickshell/keybinds call keybinds toggle"))

-- Transition length switcher
hl.bind(mainMod .. " + SHIFT + L",
    hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/transition-length-switcher.sh"))

hl.bind(mainMod .. " + SHIFT + N",
    hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/night-shift.sh"))

-- Clipboard history
hl.bind(mainMod .. " + V",
    hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/clipboard-picker.sh"))

hl.bind(mainMod .. " + SHIFT + V",
    hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/clipboard-delete.sh"))

-- Shell switcher
--hl.bind(mainMod .. " + CTRL + S",
  --  hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/shell-switch.sh"))

-- ScrollOverview
-- bind = SUPER, g, scrolloverview:overview, toggle

-- Scratchpad terminal
-- bind = $mainMod, grave, exec, bash ~/.config/hypr/scripts/scratchpad.sh

hl.bind(mainMod .. " + O",
    hl.dsp.exec_cmd("qs ipc -c overview call overview toggle"))

-- bind = $mainMod, O, exec, qs ipc -c ~/.config/quickshell/overview call overview toggle

hl.bind(mainMod .. " + SHIFT + O",
    hl.dsp.exec_cmd("qs ipc -c ~/.config/quickshell/settings call settings toggle"))

hl.bind(mainMod .. " + SHIFT + M",
    hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/theme-mode-switcher.sh"))

hl.bind(mainMod .. " + SHIFT + A",
    hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/applet.sh"))

hl.bind(mainMod .. " + SHIFT + G",
    hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/matugen-mode-switcher.sh"))

hl.bind(mainMod .. " + SHIFT + K",
    hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/lockscreen-switcher.sh"))

hl.bind("SUPER + D",
    hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/rofi-shell-switch.sh"))
