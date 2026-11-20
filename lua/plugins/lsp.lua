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
          -- 「类型提示」(inlay hints)：把推断出来的类型用灰色小字显示在变量/参数旁边。
          -- 注意：vtsls 默认把所有 inlay hint 都关掉，不写这段就跟没有类型提示一样。
          -- 可用 :InlayHintsToggle / :InlayHintsEnable / :InlayHintsDisable 临时开关。
          typescript = {
            inlayHints = {
              parameterNames = { enabled = "all" },         -- 函数调用时的参数名
              variableTypes = { enabled = true },           -- let/const 推断出的类型
              functionLikeReturnTypes = { enabled = true }, -- 函数返回值类型
              propertyDeclarationTypes = { enabled = true },-- 类属性声明类型
              enumMemberValues = { enabled = true },        -- 枚举成员的值
              parameterTypes = { enabled = true },          -- 函数参数类型
            },
          },
          javascript = {
            inlayHints = {
              parameterNames = { enabled = "all" },
              variableTypes = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
            },
          },
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
       vim.lsp.config("csharp_ls", {
        cmd = { "csharp-ls" },
        filetypes = { "cs" },
        root_dir = vim.fs.root(0, function(name)
          return name:match("%.sln$") ~= nil or name:match("%.csproj$") ~= nil
        end),
      })

      -- ─────────────────────────────────────────────
      -- 4.5) C / C++（clangd）
      --   系统里编译用 GCC，这里让 clangd 向 GCC 查询系统头文件路径，
      --   避免标准库头文件解析失败。
      --   单文件练习无需 compile_commands.json；多文件项目建议生成。
      -- ─────────────────────────────────────────────
      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
          "--query-driver=/usr/bin/gcc,/usr/bin/g++",
        },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
        root_markers = {
          "compile_commands.json",
          "compile_flags.txt",
          ".clangd",
          "Makefile",
          "CMakeLists.txt",
          "meson.build",
          ".git",
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      })

      -- ─────────────────────────────────────────────
      -- 5) 启用服务（未列出的服务不会启动）
      -- ─────────────────────────────────────────────
      -- 只启用「可执行文件真的存在」的服务。
      -- 否则 vim.lsp.enable 会直接抛 invalid config 错误（例如没装 clangd 时
      -- 打开 .c 文件只得到一句 clangd is not executable），看起来就像 LSP 没启动。
      local wanted = {
        { "vtsls", "vtsls" },                                   -- TS / JS / React
        { "vue_ls", "vue-language-server" },                    -- Vue
        { "csharp_ls", "csharp-ls" },                           -- C#（需 dotnet SDK）
        { "html", "vscode-html-language-server" },              -- HTML
        { "cssls", "vscode-css-language-server" },              -- CSS / SCSS / LESS
        { "jsonls", "vscode-json-language-server" },            -- JSON
        { "eslint", "vscode-eslint-language-server" },          -- ESLint
        { "tailwindcss", "tailwindcss-language-server" },       -- Tailwind CSS
        { "emmet_language_server", "emmet-language-server" },   -- Emmet 缩写展开
        { "clangd", "clangd" },                                 -- C / C++
      }

      local ready, missing = {}, {}
      for _, item in ipairs(wanted) do
        if vim.fn.executable(item[2]) == 1 then
          ready[#ready + 1] = item[1]
        else
          missing[#missing + 1] = string.format("%s  ← 缺 %s", item[1], item[2])
        end
      end

      vim.lsp.enable(ready)

      if #missing > 0 then
        vim.notify(
          "以下语言服务缺少可执行文件，未启动：\n  " .. table.concat(missing, "\n  "),
          vim.log.levels.WARN
        )
      end
    end,
  },
}
