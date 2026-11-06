# cava-visualizer

A modern, cava-style music visualizer for **Quickshell** running on **Hyprland**.

Smooth gradient "pill" bars, a center-mirrored spectrum, and floating peak caps
that fall behind the bars — drawn as a click-through layer-shell strip docked to
the bottom of the screen. It syncs to whatever your speakers are playing.

```
        ▁ ▃ ▅ ▇ █ ▇ ▅ ▃ ▁ ▃ ▅ ▇ █ ▇ ▅ ▃ ▁
```

## How it works

Quickshell has no built-in Cava service (as of v0.3.x), so this config drives the
`cava` binary directly:

```
cava  --raw ascii frames-->  SplitParser  -->  Cava.qml  -->  Visualizer.qml
                                                  (0..1 values)   (bars)
```

`cava.ini` puts cava in `method = raw` mode, where it prints one frame per line
as `v0;v1;v2;…;` (see [cava's raw output]). `Cava.qml` runs it through a
`Process`, splits each line with a `SplitParser`, and normalizes the values to
`0..1`. `Visualizer.qml` renders them.

## Requirements

- **Quickshell** ≥ 0.2 — `qs`
- **cava** (the real thing; it does the audio capture + FFT)
  - Arch: `sudo pacman -S cava quickshell`
  - Fedora: `sudo dnf install cava quickshell`
  - Nix: `nix-shell -p cava quickshell`
- A PipeWire/PulseAudio system (cava uses it by default)

Check both are on your `PATH`:

```sh
cava --version && qs --version
```

## Install

```sh
# from this directory
./install.sh
```

or manually:

```sh
mkdir -p ~/.config/quickshell
cp -r cava-visualizer ~/.config/quickshell/cava-visualizer
qs -c cava-visualizer
```

`qs -c <dir>` runs the shell in `~/.config/quickshell/<dir>`.

## Run on login (Hyprland)

Add to `~/.config/hypr/hyprland.conf`:

```ini
exec-once = qs -c cava-visualizer
```

If you already run another Quickshell config as your bar, start this one
alongside it with a unique `-c` name as above — Quickshell supports multiple
instances.

## Tuning

Everything you'll normally tweak is at the top of [`shell.qml`](shell.qml):

| property          | meaning                                             |
| ----------------- | --------------------------------------------------- |
| `gradientTop`     | top colour of every bar                             |
| `gradientBottom`  | bottom colour of every bar                          |
| `stripHeight`     | height of the visualizer strip                      |
| `mirrored`        | symmetric center-out spectrum (default `true`)      |
| `peakCaps`        | floating falling peak dots                          |
| `showPanel`       | translucent rounded backdrop                        |
| `barSpacing`      | gap between bars                                    |
| `barSmoothing`    | bar easing in ms (lower = snappier)                 |
| `aboveWindows`    | `false` pins it to the desktop layer (behind windows)|
| `showOnAllScreens`| draw on every monitor vs. only the first             |

Bar **count** and frequency response live in [`cava.ini`](cava.ini):

```ini
[general]
bars = 48          # more bars = finer spectrum
autosens = 1       # auto-gain, keeps bars lively

[output]
ascii_max_range = 1000   # keep in sync with Cava.qml maxValue
```

> The renderer adapts to however many bars cava emits, so changing `bars` needs
> no QML edit. Only change `Cava.qml`'s `maxValue` if you change
> `ascii_max_range`.

### Visualizing *system output* instead of the mic

cava follows your default sink by default. To force a source, edit the `[input]`
section of `cava.ini`:

```ini
[input]
method = pulse
source = auto
# or pin an explicit monitor, e.g.:
# source = alsa_output.pci-0000_00_1f.3.analog-stereo.monitor
```

List candidates with `pactl list short sources`.

## Design preview

[`preview/index.html`](preview/index.html) is a standalone browser mockup that
reproduces the exact colors, spacing, mirroring, easing and peak-cap math with
synthetic audio. Open it in a browser to see the look without a Linux session.

## Troubleshooting

- **Nothing moves / bars stay flat** — the wrong audio source. Try the explicit
  `source` above, and run `cava` in a terminal to confirm it reacts.
- **`cava exited (…)` in the logs** — `cava` isn't installed or `cava.ini` isn't
  being found. Confirm `which cava` and that `cava.ini` sits next to `shell.qml`.
- **Strip not visible** — a fullscreen window may cover it; set
  `aboveWindows: true`, or check your Hyprland layer rules aren't hiding the
  `quickshell` namespace.
- **Want blur behind the panel** — Hyprland users can add a layer rule:
  `layerrule = blur, quickshell`. Then raise `panelOpacity` for a frosted look.

[cava's raw output]: https://github.com/karlstav/cava/blob/master/output/raw.c
