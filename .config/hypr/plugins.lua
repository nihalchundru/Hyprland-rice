-- HyprGlass plugin configuration
-- ~/.config/hypr/plugins.lua

if hl.plugin.hyprglass then
    local hg = hl.plugin.hyprglass

    -- ============================================
    -- Apple / Liquid Glass preset
    -- ============================================

    hg.preset("apple", {
        blur_strength = 2.2,
        blur_iterations = 3,

        refraction_strength = 0.55,
        chromatic_aberration = 0.3,
        fresnel_strength = 0.5,
        specular_strength = 0.75,

        edge_thickness = 0.05,
        lens_distortion = 0.3,

        dark = {
            brightness = 0.82,
            contrast = 0.90,
            saturation = 0.80,
            vibrancy = 0.15,
            adaptive_dim = 0.4,
        },

        light = {
            brightness = 1.12,
            contrast = 0.92,
            saturation = 0.85,
            vibrancy = 0.12,
            adaptive_boost = 0.4,
        },
    })

    -- ============================================
    -- HyprGlass configuration
    -- ============================================

    hg.config({
        enabled = true,

        default_theme = "light",
        default_preset = "glass",

        layers = {
            enabled = false,
        },
    })
end
