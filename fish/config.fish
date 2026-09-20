# HyDE ARM — fish config
if status is-interactive
    # Starship prompt
    starship init fish | source
    # Zoxide
    zoxide init fish | source 2>/dev/null || true
    # Aliases
    alias ls='eza --icons=auto'
    alias ll='eza -la --icons=auto'
    alias lt='eza --tree --icons=auto'
    alias cat='bat'
    alias grep='grep --color=auto'
    set -U fish_greeting
end

# Show fastfetch on new terminal
if status is-interactive
    and not set -q FASTFETCH_SHOWN
    set -gx FASTFETCH_SHOWN 1
    fastfetch 2>/dev/null || true
end
