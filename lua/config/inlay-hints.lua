-- 行内类型提示（inlay hints）—— 用 Neovim 0.10+ 内置实现
--
-- 背景：上游配置依赖 MysticalDevil/inlay-hints.nvim，但该仓库已 404
-- （被删除或改名）。lazy.nvim 每次启动都会重试克隆，最终抛出
-- "Too many rounds of missing plugins" 并中断配置加载。
-- 这里改用内置的 vim.lsp.inlay_hint，并保留上游文档里承诺的三个命令，
-- 行为与原来一致：LSP 挂载时自动开启，可随时临时开关。

local function each_hint_client(cb)
  for _, client in ipairs(vim.lsp.get_clients()) do
    local ok, supports = pcall(function()
      return client:supports_method("textDocument/inlayHint")
    end)
    if ok and supports then
      cb(client)
    end
  end
end

local function enable(bufnr, on)
  if bufnr and bufnr ~= 0 then
    vim.lsp.inlay_hint.enable(on, { bufnr = bufnr })
  else
    each_hint_client(function(client)
      for _, buf in ipairs(vim.lsp.get_buffers_by_client_id(client.id)) do
        vim.lsp.inlay_hint.enable(on, { bufnr = buf })
      end
    end)
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("NeonivInlayHints", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end
    local ok, supports = pcall(function()
      return client:supports_method("textDocument/inlayHint")
    end)
    if ok and supports then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end
  end,
})

local function report(on)
  if on then
    vim.notify("inlay hints: 已开启", vim.log.levels.INFO)
  else
    vim.notify("inlay hints: 已关闭", vim.log.levels.INFO)
  end
end

vim.api.nvim_create_user_command("InlayHintsEnable", function()
  enable(0, true)
  report(true)
end, { desc = "开启行内类型提示" })

vim.api.nvim_create_user_command("InlayHintsDisable", function()
  enable(0, false)
  report(false)
end, { desc = "关闭行内类型提示" })

vim.api.nvim_create_user_command("InlayHintsToggle", function()
  local on = not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
  enable(0, on)
  report(on)
end, { desc = "切换行内类型提示" })
