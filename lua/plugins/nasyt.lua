return {
  {
    dir = vim.fn.stdpath("config") .. "/lua",
    lazy = false,   -- 启动时加载
    config = function()
      require("nasyt").setup()
    end,
  },
}