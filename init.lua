-- 加载基础配置

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.keymaps")
require("config.options")
require("config.inlay-hints")
require("config.lazy")

-- fcitx5 状态切换与恢复（原 Arch 美化脚本配置，迁移时保留）
local fcitx_st = ""
vim.api.nvim_create_autocmd("InsertLeave", { callback = function() fcitx_st = vim.fn.system("fcitx5-remote"); vim.fn.jobstart("fcitx5-remote -c") end })
vim.api.nvim_create_autocmd("InsertEnter", { callback = function() if fcitx_st:match("2") then vim.fn.jobstart("fcitx5-remote -o") end end })
vim.api.nvim_create_autocmd("VimEnter", { callback = function() vim.fn.jobstart("fcitx5-remote -c") end })
