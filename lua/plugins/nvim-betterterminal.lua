return {
    "CRAG666/betterTerm.nvim",
    event = "VeryLazy",
    keys = {
        { "<C-t>", "<cmd>lua require('betterTerm').open()<CR>", desc = "打开终端" },
    },
    config = function()
        require('betterTerm').setup({
            position = "bot",
            size = 15,
            startInserted = true,
            show_tabs = false,
        })
    end,
}
