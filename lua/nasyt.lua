-- ~/.config/nvim/lua/nasyt.lua
local M = {}

-- ============ 终端执行核心（不自动关闭） ============
function M.exec(cmd, desc)
  vim.cmd("write")
  
  -- 关闭旧终端
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
      local config = vim.api.nvim_win_get_config(win)
      if config.relative ~= "" then
        vim.api.nvim_win_close(win, true)
      end
    end
  end
  
  -- 创建浮动终端
  local width = vim.o.columns - 10
  local height = vim.o.lines - 8
  local row = (vim.o.lines - height) / 2
  local col = (vim.o.columns - width) / 2
  
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    border = "rounded",
    title = " nasyt: " .. (desc or cmd),
    title_pos = "center",
    style = "minimal",
  })
  
  -- 拆分命令参数
  local args = {}
  for arg in cmd:gmatch("%S+") do
    table.insert(args, arg)
  end
  
  vim.fn.termopen(args, {
    on_exit = function()
      -- 命令结束后，只发通知，不关闭窗口
      vim.notify("执行完毕: " .. (desc or cmd), vim.log.levels.INFO)
    end,
  })
  
  vim.api.nvim_buf_set_option(buf, "buftype", "terminal")
  vim.api.nvim_set_current_win(win)
  vim.api.nvim_set_current_buf(buf)
  vim.cmd("startinsert")
  
  vim.notify("运行 " .. (desc or cmd), vim.log.levels.INFO)
end

-- ============ 关闭所有终端 ============
function M.term_close()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
      local config = vim.api.nvim_win_get_config(win)
      if config.relative ~= "" then
        vim.api.nvim_win_close(win, true)
      end
    end
  end
end

-- ============ 手动终端 ============
function M.term_open()
  M.exec(vim.o.shell, "手动终端")
end

-- ============ Rust 命令 ============
function M.rust_run() M.exec("cargo run", "cargo run") end
function M.rust_check() M.exec("cargo check", "cargo check") end
function M.rust_test() M.exec("cargo test", "cargo test") end
function M.rust_build() M.exec("cargo build --release", "cargo build") end
function M.rust_fmt() M.exec("cargo fmt", "cargo fmt") end
function M.rust_clippy() M.exec("cargo clippy", "cargo clippy") end
function M.rust_doc() M.exec("cargo doc --open", "cargo doc") end
function M.rust_update() M.exec("cargo update", "cargo update") end
function M.rust_clean() M.exec("cargo clean", "cargo clean") end
function M.rust_publish() M.exec("cargo publish", "cargo publish") end


-- ============ 工具命令 ============
function M.tool_fastfetch() M.exec("fastfetch", "fastfetch") end
function M.tool_htop() M.exec("htop", "htop") end
function M.tool_python() M.exec("python3", "python3") end
function M.tool_node() M.exec("node", "node") end
function M.tool_bat() M.exec("bat", "bat") end
function M.tool_ls() M.exec("ls -la --color=auto", "ls -la") end
function M.tool_pwd() M.exec("pwd", "pwd") end
function M.tool_date() M.exec("date", "date") end
function M.tool_df() M.exec("df -h", "磁盘使用") end
function M.tool_free() M.exec("free -h", "内存使用") end

-- ============ 版本命令 ============
function M.version_nvim() M.exec("nvim --version | head -1", "Neovim") end
function M.version_rust() M.exec("rustc --version", "Rust") end
function M.version_cargo() M.exec("cargo --version", "Cargo") end
function M.version_git() M.exec("git --version", "Git") end
function M.version_python() M.exec("python3 --version", "Python") end
function M.version_node() M.exec("node --version", "Node") end
function M.version_go() M.exec("go version", "Go") end
function M.version_os() M.exec("uname -a", "系统信息") end
function M.version_nasyt() M.exec("nasyt -v", "nasyt版本") end

-- ============ nasyt 自身 ============
function M.nasyt_edit()
  vim.cmd("edit ~/.config/nvim/lua/nasyt.lua")
end

function M.nasyt_reload()
  vim.cmd("source ~/.config/nvim/init.lua")
  vim.notify("✅ 配置已重载", vim.log.levels.INFO)
end

-- ============ 设置快捷键 ============
function M.setup_keys()
  local keymap = vim.keymap.set
  
  -- Rust: <leader>nr?
  keymap("n", "<leader>nrr", M.rust_run, { desc = "cargo run" })
  keymap("n", "<leader>nrc", M.rust_check, { desc = "cargo check" })
  keymap("n", "<leader>nrt", M.rust_test, { desc = "cargo test" })
  keymap("n", "<leader>nrb", M.rust_build, { desc = "cargo build" })
  keymap("n", "<leader>nrf", M.rust_fmt, { desc = "cargo fmt" })
  keymap("n", "<leader>nrl", M.rust_clippy, { desc = "cargo clippy" })
  keymap("n", "<leader>nrd", M.rust_doc, { desc = "cargo doc" })
  keymap("n", "<leader>nru", M.rust_update, { desc = "cargo update" })
  keymap("n", "<leader>nrC", M.rust_clean, { desc = "cargo clean" })
  keymap("n", "<leader>nrp", M.rust_publish, { desc = "cargo publish" })
  
  -- 工具: <leader>nt?
  keymap("n", "<leader>ntn", M.tool_fastfetch, { desc = "fastfetch" })
  keymap("n", "<leader>nth", M.tool_htop, { desc = "htop" })
  keymap("n", "<leader>ntp", M.tool_python, { desc = "python" })
  keymap("n", "<leader>ntj", M.tool_node, { desc = "node" })
  keymap("n", "<leader>ntb", M.tool_bat, { desc = "bat" })
  keymap("n", "<leader>ntl", M.tool_ls, { desc = "ls -la" })
  keymap("n", "<leader>ntw", M.tool_pwd, { desc = "pwd" })
  keymap("n", "<leader>ntd", M.tool_date, { desc = "date" })
  keymap("n", "<leader>ntD", M.tool_df, { desc = "磁盘信息" })
  keymap("n", "<leader>ntF", M.tool_free, { desc = "内存信息" })
  
  -- 版本: <leader>nv?
  keymap("n", "<leader>nvn", M.version_nvim, { desc = "Neovim版本" })
  keymap("n", "<leader>nvr", M.version_rust, { desc = "Rust版本" })
  keymap("n", "<leader>nvc", M.version_cargo, { desc = "Cargo版本" })
  keymap("n", "<leader>nvg", M.version_git, { desc = "Git版本" })
  keymap("n", "<leader>nvp", M.version_python, { desc = "Python版本" })
  keymap("n", "<leader>nvj", M.version_node, { desc = "Node版本" })
  keymap("n", "<leader>nvG", M.version_go, { desc = "Go版本" })
  keymap("n", "<leader>nvO", M.version_os, { desc = "系统信息" })
  keymap("n", "<leader>nvv", M.version_nasyt, { desc = "nasyt版本" })
  
  -- nasyt: <leader>ns?
  keymap("n", "<leader>nse", M.nasyt_edit, { desc = "编辑 nasyt" })
  keymap("n", "<leader>nsr", M.nasyt_reload, { desc = "重载配置" })
  keymap("n", "<leader>nst", M.term_open, { desc = "手动终端" })
  keymap("n", "<leader>nsq", M.term_close, { desc = "关闭终端" })
end

-- ============ which-key 菜单 ============
function M.setup_whichkey()
  local wk = require("which-key")
  wk.add({
    { "<leader>n", group = "🤓 NAS油条" },
    { "<leader>nr", group = "Rust工具" },
    { "<leader>nt", group = "常用工具" },
    { "<leader>nv", group = "工作版本" },
    { "<leader>ns", group = "插件配置" },
  })
end

-- ============ 初始化 ============
function M.setup()
  M.setup_keys()
  M.setup_whichkey()
  vim.notify("🤓 NAS油条nvim工具 已加载", vim.log.levels.INFO)
end

return M
