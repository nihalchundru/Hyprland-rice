-- ~/.config/nvim/lua/plugins/theme.lua
return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true, -- Removes solid colors from the code editor canvas
      styles = {
        sidebars = "transparent", -- Makes sidebars transparent
        floats = "transparent",   -- Makes modal menus transparent
      },
    },
  },
}
