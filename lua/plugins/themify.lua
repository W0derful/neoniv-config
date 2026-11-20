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
      { -- 只用黑白灰；类型名 gray4 太暗，加载后提亮
        "kdheepak/monochrome.nvim",
        after = function()
          -- 纯明度分层，全部常规字重（不加粗）
          -- 普通文本不要纯白，给关键字留出最亮那档
          -- 必须连 bg 一起写，否则 nvim_set_hl 会把背景清成透明
          vim.api.nvim_set_hl(0, "Normal", { fg = "#E4E4E4", bg = "#0B0B0B" })
          vim.api.nvim_set_hl(0, "NormalFloat", { fg = "#E4E4E4", bg = "#0B0B0B" })

          -- 关键字：if / for / while / return / let / impl —— 最亮 #FFFFFF
          vim.api.nvim_set_hl(0, "TSKeyword", { fg = "#FFFFFF" })
          vim.api.nvim_set_hl(0, "TSKeywordFunction", { fg = "#FFFFFF" })
          vim.api.nvim_set_hl(0, "TSKeywordReturn", { fg = "#FFFFFF" })
          vim.api.nvim_set_hl(0, "TSConditional", { fg = "#FFFFFF" })
          vim.api.nvim_set_hl(0, "TSRepeat", { fg = "#FFFFFF" })
          vim.api.nvim_set_hl(0, "TSInclude", { fg = "#FFFFFF" })

          -- 类型名：int / size_t / u32 —— 最暗一档但依然清楚 #A8A8A8
          vim.api.nvim_set_hl(0, "TSType", { fg = "#A8A8A8" })
          vim.api.nvim_set_hl(0, "TSTypeBuiltin", { fg = "#A8A8A8" })
          vim.api.nvim_set_hl(0, "TSTypeDefinition", { fg = "#A8A8A8" })
          vim.api.nvim_set_hl(0, "Typedef", { fg = "#A8A8A8" })

          -- 字符串 / 函数 / 运算符：中间三档，互不重叠
          vim.api.nvim_set_hl(0, "TSString", { fg = "#C6C6C6" })
          vim.api.nvim_set_hl(0, "TSStringEscape", { fg = "#DDDDDD" })
          vim.api.nvim_set_hl(0, "TSFunction", { fg = "#D4D4D4" })
          vim.api.nvim_set_hl(0, "TSOperator", { fg = "#BEBEBE" })
          vim.api.nvim_set_hl(0, "TSKeywordOperator", { fg = "#BEBEBE" })
          -- 注释原来只有 2.2:1，太费眼，抬到约 6:1
          vim.api.nvim_set_hl(0, "TSComment", { fg = "#8A8A8A", italic = true })
          vim.api.nvim_set_hl(0, "Comment", { fg = "#8A8A8A", italic = true })
        end,
      },
      "amedoeyes/eyes.nvim",           -- 纯单色，明暗两套
      { -- 灰阶，仅用颜色区分高亮；作者漏了初始化，切换前先 setup 一次
        "https://codeberg.org/matschi2/black-white.nvim",
        before = function()
          require("blackwhite").setup({})
        end,
      },

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
