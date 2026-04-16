return{
"okuuva/auto-save.nvim",
  version = "^1.0.0", -- 锁定版本，确保稳定
  event = { "InsertLeave", "TextChanged" }, -- 懒加载，提升启动速度
  opts = {
      enabled = true, -- 启用插件
      -- 其他配置项...
  }
}
