-- bacon-ls 0.29+ has a native "cargo" backend that runs clippy itself and
-- pushes diagnostics - no bacon process or .bacon-locations export needed
-- (the older "bacon" backend still works and is configured globally in
-- ~/.config/bacon/prefs.toml if we ever want to switch back).
--
-- updateOnInsert is the RustRover-style part: bacon-ls mirrors the workspace
-- into a hardlinked shadow under target/bacon-ls-live/, writes dirty buffers
-- into it on every didChange, and runs clippy against the shadow - so
-- diagnostics update as you type, before any save. It MUST be set in
-- init_options (not settings): the server needs it at initialize-time to
-- advertise Full didChange sync.
local bacon_ls_settings = {
  backend = "cargo",
  cargo = {
    command = "clippy",
    extraArgs = { "--workspace", "--all-targets", "--all-features" },
    updateOnInsert = true,
  },
}

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      bacon_ls = {
        init_options = bacon_ls_settings,
        -- Also answered to the server's workspace/configuration pull.
        settings = { bacon_ls = bacon_ls_settings },
      },
    },
  },
}
