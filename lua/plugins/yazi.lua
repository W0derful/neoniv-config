return {
  "mikavilpas/yazi.nvim",
  version = "*",
  event = "VeryLazy",
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },
  keys = {
    { "<leader>-", "<cmd>Yazi<cr>", desc = "Yazi: 在当前文件目录打开" },
    { "<leader>cw", "<cmd>Yazi cwd<cr>", desc = "Yazi: 在 nvim cwd 打开" },
    { "<c-up>", "<cmd>Yazi toggle<cr>", desc = "Yazi: 恢复上次会话" },
  },
  opts = {
    open_for_directories = false,
  },
}
