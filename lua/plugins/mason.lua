return {
    "mason-org/mason.nvim",
    event = "VeryLazy",
    dependencies = {
        "neovim/nvim-lspconfig",
        "mason-org/mason-lspconfig.nvim",
    },
    config = function()
        -- 1. 初始化 Mason
        require("mason").setup()

        -- 2. 配置 mason-lspconfig，仅负责安装，不自动启用
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "pyright",
                "rust_analyzer",
                "ts_ls",
                "html",
                "cssls",
                "jsonls",
                "omnisharp",
                "sqlls",
                "vue_ls",
            },
            automatic_enable = false,   -- 关键：关闭自动启用
        })

        -- 3. 使用 vim.lsp.config 定义各个 LSP 的配置
        -- Lua
        vim.lsp.config("lua_ls", {
            cmd = { "lua-language-server" },
            filetypes = { "lua" },
            root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
            settings = {
                Lua = {
                    diagnostics = { globals = { "vim" } },
                },
            },
        })

        -- Python
        vim.lsp.config("pyright", {
            cmd = { "pyright-langserver", "--stdio" },
            filetypes = { "python" },
            root_markers = { "pyrightconfig.json", "pyproject.toml", ".git" },
        })

        -- Rust
        vim.lsp.config("rust_analyzer", {
            cmd = { "rust-analyzer" },
            filetypes = { "rust" },
            root_markers = { "Cargo.toml", ".git" },
        })

        -- HTML
        vim.lsp.config("html", {
            cmd = { "vscode-html-language-server", "--stdio" },
            filetypes = { "html" },
            root_markers = { "package.json", ".git" },
        })

        -- CSS/SCSS/Less
        vim.lsp.config("cssls", {
            cmd = { "vscode-css-language-server", "--stdio" },
            filetypes = { "css", "scss", "less" },
            root_markers = { "package.json", ".git" },
        })

        -- JSON
        vim.lsp.config("jsonls", {
            cmd = { "vscode-json-language-server", "--stdio" },
            filetypes = { "json", "jsonc" },
            root_markers = { ".git" },
        })

        -- SQL
        vim.lsp.config("sqlls", {
            cmd = { "sql-language-server", "up", "--method", "stdio" },
            filetypes = { "sql" },
            root_markers = { ".git" },
        })

        -- C# (OmniSharp)
        vim.lsp.config("omnisharp", {
            cmd = { "OmniSharp", "-z", "--hostPID", tostring(vim.fn.getpid()), "--encoding", "utf-8", "--languageserver" },
            filetypes = { "cs", "vb" },
            root_markers = { "*.sln", "*.csproj", ".git" },
        })

        -- Vue (Volar)
        vim.lsp.config("vue_ls", {
            cmd = { "vue-language-server", "--stdio" },
            filetypes = { "vue" },
            root_markers = { "package.json", "vue.config.js", "nuxt.config.js", ".git" },
            init_options = {
                vue = {
                    hybridMode = false,   -- 禁用混合模式，避免某些错误
                },
            },
        })

        -- TypeScript + Vue 支持
        vim.lsp.config("ts_ls", {
            cmd = { "typescript-language-server", "--stdio" },
            filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
            root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
            init_options = {
                hostInfo = "neovim",
                plugins = {
                    {
                        name = "@vue/typescript-plugin",
                        location = vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
                        languages = { "vue" },
                    },
                },
            },
        })

        -- 4. 手动启用所有需要的 LSP
        local servers = {
            "lua_ls",
            "pyright",
            "rust_analyzer",
            "html",
            "cssls",
            "jsonls",
            "sqlls",
            "omnisharp",
            "vue_ls",
            "ts_ls",
        }
        for _, server in ipairs(servers) do
            vim.lsp.enable(server)
        end

        -- 5. 全局诊断配置
        vim.diagnostic.config({
            virtual_text = true,
            underline = true,
            update_in_insert = true,
        })

        -- 6. LSP 附加后的快捷键映射
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                local buf = args.buf
                if client then
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = buf, desc = "跳转到定义" })
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = buf, desc = "查看文档" })
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = buf, desc = "重命名" })
                           -- 👇 添加这一行
                    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = buf, desc = "Code Action" })
            -- 如果你想在可视模式也支持，可以再加一行
                    vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action, { buffer = buf, desc = "Range Code Action" })
                end
            end,
        })
    end,
}
