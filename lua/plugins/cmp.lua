return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter", -- 进入插入模式时加载，优化启动速度
    dependencies = {
        -- 核心补全源
        "hrsh7th/cmp-nvim-lsp",       -- LSP 提供的智能补全（最重要）
        "hrsh7th/cmp-buffer",         -- 当前缓冲区中的单词补全
        "hrsh7th/cmp-path",           -- 文件系统路径补全
        "hrsh7th/cmp-cmdline",        -- 命令行模式补全（如 :e ~/.c<Tab>）

        -- 代码片段引擎（支持变量占位符和跳转）
        "L3MON4D3/LuaSnip",

        -- 可选：提供额外的 snippet 来源（如果你需要常用代码片段）
        -- "rafamadriz/friendly-snippets",
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        -- 可选：加载友好代码片段库（需要先安装 friendly-snippets 插件）
        -- require("luasnip.loaders.from_vscode").lazy_load()

        cmp.setup({
            -- 1. 代码片段配置
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body) -- 使用 LuaSnip 展开 LSP 提供的 snippet
                end,
            },

            -- 2. 快捷键映射
            mapping = cmp.mapping.preset.insert({
                -- 向上/向下滚动补全文档
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),

                -- 手动触发补全（默认会在输入几个字符后自动触发）
                ["<C-Space>"] = cmp.mapping.complete(),

                -- 取消补全
                ["<C-e>"] = cmp.mapping.abort(),

                -- 确认选择（回车键）
                ["<CR>"] = cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = true, -- 自动选中第一个候选词
                }),

                -- 使用 Tab 键在补全项之间循环（可选，替代默认的上下箭头）
                 ["<Tab>"] = cmp.mapping(function(fallback)
                     if cmp.visible() then
                         cmp.select_next_item()
                     elseif luasnip.expand_or_jumpable() then
                         luasnip.expand_or_jump()
                     else
                         fallback()
                     end
                 end, { "i", "s" }),
                
                 ["<S-Tab>"] = cmp.mapping(function(fallback)
                     if cmp.visible() then
                         cmp.select_prev_item()
                     elseif luasnip.jumpable(-1) then
                         luasnip.jump(-1)
                     else
                         fallback()
                     end
                 end, { "i", "s" }),
            }),

            -- 3. 补全来源（按优先级排序）
            sources = cmp.config.sources({
                { name = "nvim_lsp" },    -- LSP 智能补全
                { name = "luasnip" },     -- 代码片段
                { name = "buffer" },      -- 当前文件单词
                { name = "path" },        -- 文件路径
            }),

            -- 4. 补全窗口外观
            window = {
                completion = cmp.config.window.bordered({
                    border = "rounded",    -- 圆角边框
                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
                }),
                documentation = cmp.config.window.bordered({
                    border = "rounded",
                }),
            },

            -- 5. 补全行为微调
            completion = {
                completeopt = "menu,menuone,noselect", -- 总是显示补全菜单，但不自动选择
            },

            -- 6. 实验性功能：自动显示函数签名
            experimental = {
                ghost_text = true, -- 显示当前补全项的灰色预览文本（类似 VSCode）
            },
        })

        -- 7. 为命令行模式单独配置补全（用于输入命令时的路径补全）
        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = "cmdline" }, -- 命令行历史与自定义补全
                { name = "path" },    -- 路径补全
            }),
        })

        -- 8. 为搜索模式（/ 或 ?）配置补全
        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = "buffer" }, -- 从当前缓冲区补全搜索词
            },
        })
    end,
}

