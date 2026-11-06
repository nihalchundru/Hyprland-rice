# Firecrust Lock — a Material 3 lock screen for Hyprland

A session lock screen written in QML for [Quickshell](https://quickshell.org),
built entirely from the Material 3 shape vocabulary. Real PAM authentication, so
it actually locks and actually unlocks.

Targets **Quickshell v0.3.x** and any compositor implementing
`ext_session_lock_v1` (Hyprland does).

## What's on screen

| Element | Shape | Notes |
| --- | --- | --- |
| Analogue clock | **sunny** casing | smooth sweeping seconds hand |
| Digital time | **clamshell** | `HH:mm:ss` plus the date, tabular-centred |
| Weather | **pill** | condition icon is itself an M3 shape |
| Now playing | **very sunny** disc | artwork inset, controls each in their own **pill** |
| Password | **all 20 shapes** | one shape per typed character |
| User badge | **pill** | |

The password field is the centrepiece: every character you type becomes a shape,
morphing in from a neighbouring shape on the sheet, and morphing back out and
spinning away when you delete it. The shape is derived from the character, so the
same password always looks the same — and because the mapping walks the whole
sheet, typing anything long enough shows off all twenty shapes.

The weather icon is driven by the WMO weather code, so a clear day is a **sunny**
shape and a thunderstorm is a **star** — the data drives the same visual language
as everything else.

## Dependencies

```bash
sudo pacman -S quickshell          # or the AUR: quickshell / quickshell-git
sudo pacman -S qt6-declarative     # QtQuick.Shapes, which draws all the shapes
sudo pacman -S curl                # weather widget only
```

`quickshell` is not guaranteed to be in `extra` on every mirror; fall back to the
AUR package if `pacman -S quickshell` misses.

## Install

```bash
scp -r quickshell-lock/ arch-vm:~/.config/quickshell/firecrust-lock/
```

That gives `~/.config/quickshell/firecrust-lock/shell.qml`, with the `pam`
subfolder alongside it. Copy the **whole** folder — the PAM config lives in
`pam/quickshell` and is found relative to `Auth.qml`.

## Run

The lock runs as a background daemon that sits idle until you engage it. While
unlocked it has no surfaces and its clock timer is stopped, so it costs nothing.

```bash
qs -c firecrust-lock &
```

Then lock on demand:

```bash
qs ipc call lock lock      # engage
qs ipc call lock unlock    # release
qs ipc call lock toggle
qs ipc call lock isSecure  # true once the compositor has painted every screen
```

Bind it in Hyprland:

```ini
# ~/.config/hypr/hyprland.conf
exec-once = qs -c firecrust-lock
bind = SUPER, L, exec, qs ipc call lock lock
```

> If you run the bar config at the same time, `qs ipc call` may need to be told
> which config to talk to. I haven't verified the exact flag placement for that
> case, so test it before binding it to a key you rely on.

## ⚠️ Read this before you lock yourself out

A session lock is secure *by design*: if the locking process dies while the
session is locked, **the compositor keeps the screen locked and painted with a
solid colour**. That is the whole point — a crashing locker must not expose your
session — but it also means a bug in this config can leave you staring at a
blank screen.

Before binding it to a key:

1. Run the daemon and `qs ipc call lock lock` from a terminal you still have open.
2. Confirm you can type your password and that it unlocks.
3. Only then add the Hyprland keybind.

If it does lock you out, your escape hatches are:

```bash
# switch to another TTY with Ctrl+Alt+F2, log in, then:
pkill -f quickshell        # kills the locker
# ...or from another machine:
ssh arch-vm 'pkill -f quickshell'
```

`Config.lockOnStart` defaults to `false` for exactly this reason. In a VM the
stakes are low; on bare metal they are not.

## Authentication

`PamContext` only uses the `auth` facility, so a user-owned PAM file is enough —
no root and no `/etc/pam.d` edit. `pam/quickshell` ships with:

```
auth required pam_unix.so
```

For fingerprint, with password fallback:

```
auth sufficient pam_fprintd.so
auth required   pam_unix.so
```

PAM's own messages (including "Password incorrect") are surfaced under the
password field, so a failure tells you why rather than just shaking.

## Configuration

Everything tunable is in `Config.qml`:

```qml
property string wallpaper: home + "/.config/rofi/images/a.png"
property real   wallpaperScrim: 0.45     // dims the wallpaper for legibility
property bool   weatherEnabled: true
property real   latitude: 51.5072        // <- set these to your location
property real   longitude: -0.1276
property bool   lockOnStart: false
property int    maxPasswordLength: 24
```

Weather comes from Open-Meteo (no API key) and refreshes every 15 minutes. If the
fetch fails it keeps the last good reading rather than blanking; if it never
succeeds it shows `—°` and the field stays usable.

## How the shapes work

`M3Shapes.js` defines each shape as a **signed distance function** in a
normalised space, then recovers the outline by bisecting along 96 evenly spaced
angles. Because every shape is sampled at the *same* angles, morphing between any
two is a component-wise lerp of two radius arrays — which is what makes the
character animations possible. `M3Shape.qml` turns those radii into an SVG path
inside a `Shape`.

The geometry is plain JavaScript, so it is testable outside QML:

```bash
node test_shapes.js              # all 20 shapes
node test_shapes.js sunny star   # just these, as ASCII art
```

That renders every shape as ASCII and asserts the radius arrays are normalised,
finite and positive, and that each scalloped shape has the right number of lobes.
It is how the 4-sided cookie was confirmed to actually have four lobes.

## Files

```
shell.qml          entry point: WlSessionLock, IPC to lock/unlock
LockSurface.qml    per-monitor surface, wallpaper + layout
Auth.qml           pragma Singleton — the PAM conversation
Config.qml         pragma Singleton — user-tunable values
TimeSource.qml     pragma Singleton — one 16ms clock for every widget
M3Theme.qml        pragma Singleton — M3 colour roles, type scale, motion
M3Shapes.js        the shape geometry engine
M3Shape.qml        draws one shape, or morphs between two
AnalogClock.qml    sunny casing, sweeping hands
DigitalTime.qml    clamshell
WeatherWidget.qml  pill
MediaWidget.qml    very-sunny disc + pill controls
ShapeButton.qml    pill icon button
PasswordField.qml  the shape characters
pam/quickshell     PAM auth config
```

## Retheming

`M3Theme.qml` holds the stock Material 3 **baseline dark** roles, so the colours
are the real M3 tonal values rather than an approximation. Change them there and
the whole lock screen follows.

Dynamic colour from the wallpaper would need an HCT/CAM16 tonal palette; rather
than approximate it badly, the roles are hand-set. Generating a scheme externally
and pasting the values in keeps the tonal relationships exactly right.

## Known limitations

- **Not executed on the machine it was written on.** It was authored on macOS,
  where there is no Qt or Wayland, so it was validated statically and against the
  Quickshell v0.3.1 type reference — not run. Expect a first-load round trip.
- The 16ms clock timer runs while locked. That is what makes the seconds hand
  sweep; if you prefer battery life over smoothness, raise the interval in
  `TimeSource.qml` to 1000 and the hand will tick instead.
- Album art is not clipped to the shape. Qt 6 has no simple way to clip an item
  to a `Shape`, so the artwork is inscribed inside a circle instead, which fits
  without overflowing. `MultiEffect` with `maskSource` (Qt 6.5+) could do a true
  mask if you want the scallops to bite into the artwork.
- Tabular figures on the digital clock need `font.features`, which only exists on
  Qt 6.6+. The clock uses centred alignment instead, which is stable enough, but
  digits are not perfectly fixed-width.
