-- m3 IPC keybinds (Hyprland Lua)
-- IPC calls: qs ipc -c ~/.config/quickshell/m3 call <target> <fn>
-- Left out on purpose: ui.unlock, ui.closeAll

local mainMod = "ALT"

local TERMINAL = "kitty"
local EXPLORER = "nautilus"
local BROWSER  = "zen-browser"

local M3 = "qs ipc -c ~/.config/quickshell/m3 call "

-- helper: "ui lock" -> runs `qs ipc ... call ui lock`
local function m3(call)
    return hl.dsp.exec_cmd(M3 .. call)
end

-- ── Window management ─────────────────────────────────────────────────────

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind("SHIFT + F11", hl.dsp.window.fullscreen())

-- ── Apps ──────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(TERMINAL))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(EXPLORER))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(BROWSER))
hl.bind("SUPER + D", hl.dsp.exec_cmd("qs -p ~/.config/quickshell/shell-switcher"))

-- ── Shell IPC: ui ─────────────────────────────────────────────────────────

hl.bind(mainMod .. " + D", m3("ui toggleLauncher"))
hl.bind(mainMod .. " + A", m3("m3 toggleSettings"))
hl.bind(mainMod .. " + C", m3("ui toggleCalendar"))
hl.bind(mainMod .. " + W", m3("ui toggleWallpaper"))
hl.bind(mainMod .. " + S", m3("ui toggleQuickSettings"))
hl.bind(mainMod .. " + M", m3("ui toggleMedia"))
hl.bind(mainMod .. " + O", m3("ui toggleOverview"))
hl.bind(mainMod .. " + CTRL + DELETE", m3("ui toggleSession"))
hl.bind(mainMod .. " + L", m3("ui lock"))
--hl.bind(mainMod .. " + K", m3("ui toggleKeybinds"))
hl.bind(mainMod .. " + N", m3("ui toggleNotifications"))

-- ── Shell IPC: m3 ─────────────────────────────────────────────────────────

hl.bind(mainMod .. " + SHIFT + R", m3("m3 reloadShell"))
hl.bind(mainMod .. " + CTRL + R", m3("m3 reload"))
hl.bind(mainMod .. " + SHIFT + B", m3("m3 toggleBarFloating"))
hl.bind(mainMod .. " + T", m3("m3 toggleMode"))

-- setMode takes "dark" / "light" (guessed values, check your m3 shell)
--hl.bind(mainMod .. " + CTRL + D", m3("m3 setMode dark"))
--hl.bind(mainMod .. " + CTRL + L", m3("m3 setMode light"))

-- ── Focus ─────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- ── Move windows ──────────────────────────────────────────────────────────

hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- ── Resize ────────────────────────────────────────────────────────────────

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
    "grim ~/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png && notify-send \"Screenshot\" \"Saved\""))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(
    "grim -g \"$(slurp)\" ~/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd(
    "grim -g \"$(slurp)\" - | wl-copy && notify-send \"Screenshot\" \"Copied\""))

-- ── Audio / brightness / media keys ───────────────────────────────────────

hl.bind("XF86AudioRaiseVolume", m3("audio up"), { repeating = true })
hl.bind("XF86AudioLowerVolume", m3("audio down"), { repeating = true })
hl.bind("XF86AudioMute", m3("audio mute"))
hl.bind("XF86MonBrightnessUp", m3("brightness up"), { repeating = true })
hl.bind("XF86MonBrightnessDown", m3("brightness down"), { repeating = true })

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

-- ── Mouse ─────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
