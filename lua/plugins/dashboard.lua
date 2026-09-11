-- dashboard-nvim: 启动界面插件
return {
 {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "Mirsmog/real-icons.nvim" },
    opts = {
      theme = "doom",
      config = {
        header = {
        "",
        "",
        "",
        "",
        "███╗   ██╗   █████╗   ███████╗",
        "████╗  ██║  ██╔══██╗  ██╔════╝",
        "██╔██╗ ██║  ███████║  ███████╗",
        "██║╚██╗██║  ██╔══██║  ╚════██║",
        "██║ ╚████║  ██║  ██║  ███████║",
        "╚═╝  ╚═══╝  ╚═╝  ╚═╝  ╚══════╝",
        "",
        "",
        },
        center = {
          { icon = "  ", key = "n", desc = "N-新建文件", action = "enew" },
          { icon = "  ", key = "f", desc = "F-查找文件", action = "Telescope find_files" },
          { icon = "  ", key = "r", desc = "R-最近文件", action = "Telescope oldfiles" },
          { icon = "  ", key = "G", desc = "G-全局搜索", action = "Telescope live_grep" },
          { icon = "  ", key = "t", desc = "T-脚本工具", action = "terminal nasyt" },
          { icon = "  ", key = "l", desc = "L-插件管理", action = "Lazy" },
          { icon = "  ", key = "q", desc = "Q-退出菜单", action = "qa" },
        },
        footer = { "   欢迎使用 NAS油条 nvim配置！" },
      },
    },
  },
}