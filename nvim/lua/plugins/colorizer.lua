-- ~/.config/nvim/lua/plugins/colorizer.lua
return {
  {
    "brenoprata10/nvim-highlight-colors",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      render = "virtual",          -- Renders a stand-alone square instead of text coloring
      virtual_symbol = "■",        -- The solid square shape
      enable_named_colors = false, -- Skips words like "red" to prevent spacing glitches
      enable_tailwind = false,
    }
  }
}
