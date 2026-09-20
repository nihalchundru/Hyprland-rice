#!/usr/bin/env python3
import math
import time
import cairo
import os

OUT = "/tmp/hyprlock-clock.png"
TMP = "/tmp/hyprlock-clock.tmp.png"

W, H = 160, 160
CX, CY = W // 2, H // 2
R = 60

# Theme (glass style)
BG = (30/255, 30/255, 46/255, 0.55)
ACCENT = (203/255, 166/255, 247/255, 1.0)
FG = (245/255, 245/255, 245/255, 0.9)

def xy(angle, length):
    a = math.radians(angle - 90)
    return (
        CX + length * math.cos(a),
        CY + length * math.sin(a)
    )

def draw(ctx):
    ctx.set_antialias(cairo.ANTIALIAS_BEST)

    # soft shadow
    ctx.set_source_rgba(0, 0, 0, 0.25)
    ctx.arc(CX, CY + 2, R + 2, 0, 2 * math.pi)
    ctx.fill()

    # glass face
    ctx.set_source_rgba(*BG)
    ctx.arc(CX, CY, R, 0, 2 * math.pi)
    ctx.fill()

    # bezel
    ctx.set_source_rgba(*ACCENT)
    ctx.set_line_width(2)
    ctx.arc(CX, CY, R, 0, 2 * math.pi)
    ctx.stroke()

    # ticks
    for i in range(12):
        a = i * 30
        x1, y1 = xy(a, R - 8)
        x2, y2 = xy(a, R - 2)

        ctx.set_source_rgba(1, 1, 1, 0.5)
        ctx.set_line_width(2)
        ctx.move_to(x1, y1)
        ctx.line_to(x2, y2)
        ctx.stroke()

    # time
    t = time.localtime()

    h = (t.tm_hour % 12) * 30 + t.tm_min * 0.5
    m = t.tm_min * 6 + t.tm_sec * 0.1
    s = t.tm_sec * 6

    # hour
    hx, hy = xy(h, 32)
    ctx.set_source_rgba(*FG)
    ctx.set_line_width(5)
    ctx.set_line_cap(cairo.LineCap.ROUND)
    ctx.move_to(CX, CY)
    ctx.line_to(hx, hy)
    ctx.stroke()

    # minute
    mx, my = xy(m, 46)
    ctx.set_line_width(3)
    ctx.move_to(CX, CY)
    ctx.line_to(mx, my)
    ctx.stroke()

    # second
    sx, sy = xy(s, 54)
    ctx.set_source_rgba(*ACCENT)
    ctx.set_line_width(1.5)
    ctx.move_to(CX, CY)
    ctx.line_to(sx, sy)
    ctx.stroke()

    # center dot
    ctx.set_source_rgba(*ACCENT)
    ctx.arc(CX, CY, 4, 0, 2 * math.pi)
    ctx.fill()

def render():
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, W, H)
    ctx = cairo.Context(surface)

    draw(ctx)

    # atomic write (THIS fixes Hyprlock update issue)
    surface.write_to_png(TMP)
    os.replace(TMP, OUT)

if __name__ == "__main__":
    render()
