return {
   -- "folke/tokyonight.nvim",
   "catppuccin/nvim",
   --"rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            style = "Mocha",
            transparent = true,   -- 如果主题支持
        })
        vim.cmd.colorscheme("catppuccin")

        -- ⭐ 在这里添加透明背景强制覆盖
        vim.cmd.highlight({ "Normal", "guibg=NONE" })
        vim.cmd.highlight({ "NormalFloat", "guibg=NONE" })  -- 浮动窗口也透明
    end,
}
