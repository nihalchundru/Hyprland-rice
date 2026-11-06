hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 0,
        layout = "dwindle",
        resize_on_border = true,
        col = {
            active_border = { colors = { "rgba(CBA6F7ff)", "rgba(89B4FAff)" }, angle = 45 },
            inactive_border = { colors = { "rgba(313244cc)", "rgba(1E1E2Ecc)" }, angle = 45 },
        },
    },
})

hl.config({
    group = {
        col = {
            border_active = { colors = { "rgba(CBA6F7ff)", "rgba(89B4FAff)" }, angle = 45 },
            border_inactive = { colors = { "rgba(313244cc)", "rgba(1E1E2Ecc)" }, angle = 45 },
        },
    },
})

hl.config({
    decoration = {
        rounding = 25,
        shadow = {
            enabled = true,
        },
	glow = {
    	    enabled = true,
            range = 30,
            render_power = 4,
            color = { colors = { "rgb(1d3631)", "rgb(152a26)" }, angle = 45 },
            color_inactive = "rgba(00000000)",
        },

        blur = {
            enabled = true,
            size = 12,
            passes = 3,
            new_optimizations = true,
            ignore_opacity = true,
            xray = false,
        },
    },
})
