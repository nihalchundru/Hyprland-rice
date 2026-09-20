-- ~/.config/nvim/lua/plugins/statusline.lua
return {
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      -- Custom transparent theme overrides
      local transparent_theme = {
        normal = {
          a = { fg = "#040e0d", bg = "#5fc8d4", gui = "bold" }, -- Pill mode color
          b = { fg = "#ffffff", bg = "NONE" },
          c = { fg = "#f5e2c5", bg = "NONE" },                -- Transparent center line
        },
        insert = { a = { fg = "#040e0d", bg = "#7ad9a8", gui = "bold" } },
        visual = { a = { fg = "#040e0d", bg = "#ffa478", gui = "bold" } },
        replace = { a = { fg = "#040e0d", bg = "#ff6048", gui = "bold" } },
        command = { a = { fg = "#040e0d", bg = "#f5cd5b", gui = "bold" } },
      }

      require("lualine").setup({
        options = {
          theme = transparent_theme, -- Forces our transparent theme rule
          globalstatus = true,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { 
            { "mode", icon = "  ", separator = { right = " " } } 
          },
          lualine_b = {},
          lualine_c = { 
            { "filetype", icon_only = true },
            { "filename", path = 0 } 
          },
          lualine_x = {},
          lualine_y = {},
          lualine_z = { 
            { "location", icon = "  ", separator = { left = " " } } 
          }
        }
      })

      -- Clear the base background line entirely so Kitty's blur shows through
      vim.cmd([[
        highlight! LualineBackground guibg=NONE ctermbg=NONE
        highlight! StatusLine guibg=NONE ctermbg=NONE
        highlight! StatusLineNC guibg=NONE ctermbg=NONE
      ]])
    end
  }
}
