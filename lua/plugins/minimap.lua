return {
  "Isrothy/neominimap.nvim",
  version = "v3.x.x",
  event = { "BufReadPost", "BufNewFile" },
  -- Optional. You can also set your own keybindings
  keys = {
    -- Global Minimap Controls
    { "<leader>m", desc = "列表地图" },
    { "<leader>mm", "<cmd>Neominimap Toggle<cr>", desc = "切换全局迷你地图" },
    { "<leader>mo", "<cmd>Neominimap Enable<cr>", desc = "启用全局迷你地图" },
    { "<leader>mc", "<cmd>Neominimap Disable<cr>", desc = "禁用全局迷你地图" },
    { "<leader>mr", "<cmd>Neominimap Refresh<cr>", desc = "刷新全局迷你地图" },

    -- Window-Specific Minimap Controls
    { "<leader>mwt", "<cmd>Neominimap WinToggle<cr>", desc = "切换当前窗口的迷你地图" },
    { "<leader>mwr", "<cmd>Neominimap WinRefresh<cr>", desc = "刷新当前窗口的迷你地图" },
    { "<leader>mwo", "<cmd>Neominimap WinEnable<cr>", desc = "启用当前窗口的迷你地图" },
    { "<leader>mwc", "<cmd>Neominimap WinDisable<cr>", desc = "禁用当前窗口的迷你地图" },

    -- Tab-Specific Minimap Controls
    { "<leader>mtt", "<cmd>Neominimap TabToggle<cr>", desc = "切换当前标签页的迷你地图" },
    { "<leader>mtr", "<cmd>Neominimap TabRefresh<cr>", desc = "刷新当前标签页的迷你地图" },
    { "<leader>mto", "<cmd>Neominimap TabEnable<cr>", desc = "启用当前标签页的迷你地图" },
    { "<leader>mtc", "<cmd>Neominimap TabDisable<cr>", desc = "禁用当前标签页的迷你地图" },

    -- Buffer-Specific Minimap Controls
    { "<leader>mbt", "<cmd>Neominimap BufToggle<cr>", desc = "切换当前缓冲区的迷你地图" },
    { "<leader>mbr", "<cmd>Neominimap BufRefresh<cr>", desc = "刷新当前缓冲区的迷你地图" },
    { "<leader>mbo", "<cmd>Neominimap BufEnable<cr>", desc = "启用当前缓冲区的迷你地图" },
    { "<leader>mbc", "<cmd>Neominimap BufDisable<cr>", desc = "禁用当前缓冲区的迷你地图" },

    ---Focus Controls
    { "<leader>mf", "<cmd>Neominimap Focus<cr>", desc = "聚焦到迷你地图" },
    { "<leader>mu", "<cmd>Neominimap Unfocus<cr>", desc = "取消聚焦迷你地图" },
    { "<leader>ms", "<cmd>Neominimap ToggleFocus<cr>", desc = "切换迷你地图聚焦" },
  },
  init = function()
    -- The following options are recommended when layout == "float"
    vim.opt.wrap = false
    vim.opt.sidescrolloff = 36 -- Set a large value

    --- Put your configuration here
    ---@type Neominimap.UserConfig
    vim.g.neominimap = {
      auto_enable = true,
    }
  end,
}
