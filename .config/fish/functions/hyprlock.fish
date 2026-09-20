function hyprlock --description 'Theme-aware hyprlock launcher with precise Rofi color mapping'
    set -l hyde_wp "$HOME/.config/rofi/images/a.png"
    set -l lock_wp "$HOME/.config/hypr/assets/current_wallpaper.png"
    set -l rasi_colors "$HOME/.config/rofi/colors.rasi"
    set -l lock_colors "$HOME/.config/hypr/assets/extracted_colors.conf"

    mkdir -p "$HOME/.config/hypr/assets"

    # 1. High-Speed Software Blur Engine
    if test -f "$hyde_wp"
        convert "$hyde_wp" -scale 25% -blur 0x5 -scale 400% +depth "$lock_wp"
    end

    # 2. Strict Awk Pattern Extractor (Guarantees matching ONLY single clean hex values)
    if test -f "$rasi_colors"
        set -l bg (awk -F'[:;#]' '/^[[:space:]]*background:/ {gsub(/[[:space:]]/,"",$3); print $3; exit}' "$rasi_colors")
        set -l fg (awk -F'[:;#]' '/^[[:space:]]*on-background:/ {gsub(/[[:space:]]/,"",$3); print $3; exit}' "$rasi_colors")
        set -l acc (awk -F'[:;#]' '/^[[:space:]]*primary:/ {gsub(/[[:space:]]/,"",$3); print $3; exit}' "$rasi_colors")

        # Fallbacks if properties parsed weirdly
        if test -z "$bg"; set bg "1D2021"; end
        if test -z "$fg"; set fg "EBDBB2"; end
        if test -z "$acc"; set acc "D79921"; end

        # Write clean Hyprland variable strings directly to the target configuration file
        printf "\$lock_bg = rgb(%s)\n" "$bg" > "$lock_colors"
        printf "\$lock_fg = rgb(%s)\n" "$fg" >> "$lock_colors"
        printf "\$lock_acc = rgb(%s)\n" "$acc" >> "$lock_colors"
    else
        # Gruvbox hardcoded fallback values if the file is missing
        printf "\$lock_bg = rgb(1D2021)\n" > "$lock_colors"
        printf "\$lock_fg = rgb(EBDBB2)\n" >> "$lock_colors"
        printf "\$lock_acc = rgb(D79921)\n" >> "$lock_colors"
    end

    # 3. Stable VMware CPU Bypass Pipeline
    set -lx MESA_LOADER_DRIVER_OVERRIDE llvmpipe
    set -lx LIBGL_ALWAYS_SOFTWARE 1
    command hyprlock --immediate-render $argv
end
