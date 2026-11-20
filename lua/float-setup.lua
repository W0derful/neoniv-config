-- =============================================================================
-- float-setup.lua - 浮动窗口统一边框
-- 用法：在 ~/.config/nvim/lua/config/options.lua 末尾（或 init.lua 里）
--       加一行：require("float-setup")
-- 说明：lazy.nvim 只接受插件 spec，不接受裸配置表，所以单独做成模块。
-- =============================================================================

-- =============================================================================
-- float-setup.lua - 给浮动窗口加边框
-- 只负责「有没有边框」和边框颜色，不改框内文字配色。
-- =============================================================================

local M = {}

function M.setup()
  local border = "rounded"

  -- 边框颜色：monochrome 把 FloatBorder 链到空的 NormalFloat，
  -- 结果边框和正文同色，所以必须显式给一个亮色并打断 link。
  local function paint_border()
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#FFFFFF", bg = "NONE" })
  end
  paint_border()

  -- LSP 浮窗：K 悬浮文档、签名帮助、诊断浮窗
  -- （noice 接管了 hover，见 ui.lua 的 views 覆盖；这里只兜底非 noice 的情况）
  local orig_hover = vim.lsp.handlers["textDocument/hover"]
  vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
    return orig_hover(err, result, ctx, vim.tbl_deep_extend("force", config or {}, {
      border = border,
      border_hl = "FloatBorder",
    }))
  end

  local orig_sig = vim.lsp.handlers["textDocument/signatureHelp"]
  vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
    return orig_sig(err, result, ctx, vim.tbl_deep_extend("force", config or {}, {
      border = border,
      border_hl = "FloatBorder",
    }))
  end

  vim.diagnostic.config({
    float = { border = border, border_hl = "FloatBorder" },
  })

  -- dressing.nvim：输入框 / vim.ui.select
  local ok_d, dressing = pcall(require, "dressing")
  if ok_d then
    dressing.setup({
      input = { border = border },
      select = { border = border },
    })
  end

  -- nvim-notify：消息通知浮层
  local ok_n, notify = pcall(require, "notify")
  if ok_n then
    notify.setup({ border = border })
  end

  -- 主题切换后重刷边框颜色
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = paint_border,
  })
end

return M
