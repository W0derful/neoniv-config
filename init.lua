vim.g.mapleader = " "          -- 必须放在最前面
vim.g.maplocalleader = " "     -- （可选，但推荐）
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>')
require("core.basic")
require("core.lazy")
