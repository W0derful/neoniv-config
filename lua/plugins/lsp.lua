-- =============================================================================
-- lsp.lua - LSP 语言服务配置
-- =============================================================================
-- 说明：原 nasyt-nvim 配置只装了 nvim-lspconfig 这个依赖，并没有启用任何语言服务。
-- 此文件补上语言服务，覆盖：TypeScript / JavaScript / React(JSX/TSX)、Vue、
-- C#、HTML、CSS、JSON、ESLint、Tailwind CSS、Emmet。
--
-- 所有服务的可执行文件都安装在用户目录（~/.npm-global/bin、~/.local/bin），
-- 不需要 root 权限；升级方式见仓库 README。
-- =============================================================================

return {
  {
    "neovim/nvim-lspconfig",
    -- 打开任意文件时加载，保证 FileType 事件之前完成服务注册
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- ─────────────────────────────────────────────
      -- 1) 把 nvim-cmp 的补全能力并入所有 LSP 客户端
      -- ─────────────────────────────────────────────
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local has_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if has_cmp then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end
      vim.lsp.config("*", { capabilities = capabilities })

      -- ─────────────────────────────────────────────
      -- 2) 服务启动后挂上 config/keymaps.lua 里定义好的 LSP 快捷键
      --    (K 悬浮文档 / <leader>ca 代码动作 / <leader>rn 重命名 / [d ]d 诊断跳转)
      -- ─────────────────────────────────────────────
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("NasytLspAttach", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local ok, km = pcall(require, "config.keymaps")
          if ok and km.lsp_on_attach and client then
            km.lsp_on_attach(client, args.buf)
          end
        end,
      })

      -- ─────────────────────────────────────────────
      -- 3) TypeScript / JavaScript / React + Vue
      --    vtsls 负责 TS/JS/React，并通过 @vue/typescript-plugin 支持 .vue 里的 TS
      --    vue_ls 负责 .vue 的模板与样式
      -- ─────────────────────────────────────────────
      local vue_plugin_path =
        vim.fn.expand("$HOME/.npm-global/lib/node_modules/@vue/language-server")

      vim.lsp.config("vtsls", {
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "vue",
        },
        settings = {
          vtsls = {
            autoUseWorkspaceTsdk = true,
            tsserver = {
              globalPlugins = {
                {
                  name = "@vue/typescript-plugin",
                  location = vue_plugin_path,
                  languages = { "vue" },
                  configNamespace = "typescript",
                },
              },
            },
          },
        },
      })

      -- Vue 官方建议：不要同时启用 ts_ls 和 vtsls，这里统一用 vtsls
      vim.lsp.config("vue_ls", {
        settings = {
          vue = {
            inlayHints = {
              missingProps = true,
              inlineHandlerReturns = true,
            },
          },
        },
      })

      -- ─────────────────────────────────────────────
      -- 4) C#（OmniSharp）
      -- ─────────────────────────────────────────────
      vim.lsp.config("omnisharp", {
        settings = {
          FormattingOptions = {
            EnableEditorConfigSupport = true, -- 读取 .editorconfig
            OrganizeImports = nil,            -- 保存时不强制整理 using
          },
          MsBuild = {
            LoadProjectsOnDemand = false,
          },
          RoslynExtensionsOptions = {
            EnableAnalyzersSupport = true,     -- 启用 Roslyn 分析器/代码修复
            EnableImportCompletion = true,      -- 支持补全缺失的 using
            AnalyzeOpenDocumentsOnly = false,
          },
          Sdk = {
            IncludePrereleases = true,
          },
        },
      })

      -- ─────────────────────────────────────────────
      -- 5) 启用服务（未列出的服务不会启动）
      -- ─────────────────────────────────────────────
      vim.lsp.enable({
        "vtsls",                  -- TS / JS / React
        "vue_ls",                 -- Vue
        "omnisharp",              -- C#
        "html",                   -- HTML
        "cssls",                  -- CSS / SCSS / LESS
        "jsonls",                 -- JSON
        "eslint",                 -- ESLint
        "tailwindcss",            -- Tailwind CSS
        "emmet_language_server",  -- Emmet 缩写展开
      })
    end,
  },
}
