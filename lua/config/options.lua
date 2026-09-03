-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.opt.relativenumber = false
vim.g.autoformat = false

-- Rust diagnostics via bacon-ls: bacon watches the filesystem and re-runs
-- clippy on every (auto)save, bacon-ls streams the results in as LSP
-- diagnostics. The lang.rust extra reads this and disables rust-analyzer's
-- own checkOnSave/diagnostics so nothing is reported twice.
vim.g.lazyvim_rust_diagnostics = "bacon-ls"
