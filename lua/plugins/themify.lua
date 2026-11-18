return {
  -- themify.nvim: 主题管理器插件
  "LmanTW/themify.nvim",
  lazy = false,
  priority = 1000,
  dependencies = {
    -- Cyberdream: 官方支持的高饱和赛博粉紫
    {
      "scottmckendry/cyberdream.nvim",
      opts = {
        transparent = true,
        italic_comments = true,
      },
    },
    -- 3. Rose Pine: 经典暗黑玫瑰粉
    {
      "rose-pine/neovim",
      name = "rose-pine",
      opts = {
        variant = "main", -- main 模式的粉紫感最浓
        styles = {
          bold = true,
          italic = true,
          transparency = true,
        },
      },
    },
    -- 4. Tokyo Dark: 极其炫酷的深色荧光粉
    { "tiagovla/tokyodark.nvim" },
  },
  config = function()
    require("themify").setup({
      -- 🌸 粉色 / 霓虹粉 🌸
      "catppuccin/nvim",               -- 配置统一定义在 plugins/ui.lua
      "avoonix/pink-as-fox.nvim",      -- 纯正粉狐狸
      "tiagovla/tokyodark.nvim",       -- 赛博荧光粉
      "rose-pine/neovim",              -- 暗黑玫瑰粉
      "scottmckendry/cyberdream.nvim", -- 霓虹赛博粉紫

      -- 🖤 极简黑白 🖤
      "kdheepak/monochrome.nvim",      -- 只用黑白灰，高对比
      "amedoeyes/eyes.nvim",           -- 纯单色，明暗两套

      -- 其他高质量备选
      "EdenEast/nightfox.nvim", -- 切到 duskfox 模式也是满满粉紫感
      "sponkurtus2/angelic.nvim",
      "rijulpaul/nightblossom.nvim",
      "folke/tokyonight.nvim",
      "rebelot/kanagawa.nvim",
      "comfysage/cuddlefish.nvim",
      "tan-wei/zimablue.nvim",
      "sainnhe/gruvbox-material",

      -- 配置项
      activity = {
        enabled = true,
      },
      livePreview = true,
    })
  end,
}
