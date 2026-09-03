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
-- advertise Full didChange sync - and it must stay ON: without it the server
-- advertises no static sync at all and Neovim ignores its late dynamic
-- registration, so saves/changes never reach it and diagnostics never
-- refresh (measured: marker diagnostic never arrived in 300s).
local bacon_ls_settings = {
  backend = "cargo",
  cargo = {
    command = "clippy",
    -- no --all-targets: it doubles every run's scope (bin + test targets);
    -- clippy-on-tests can run manually/CI instead. --no-deps: don't re-lint
    -- dependency crates after their recompilation.
    extraArgs = { "--workspace", "--all-features", "--no-deps" },
    updateOnInsert = true,
    -- Default is 500ms: every >0.5s typing pause launches a clippy run,
    -- most of which get cancelled by the next keystroke. 800ms roughly
    -- halves the spawn/cancel churn and CPU burn while typing, for ~0.3s
    -- extra latency on the final result.
    updateOnInsertDebounceMillis = 800,
    -- OFF deliberately: with ~1s auto-save, checkOnSave is a second run
    -- pipeline racing the updateOnInsert one - runs cancel each other and
    -- serialize on cargo's build-dir lock, stacking "checking (0%)" progress
    -- rows for ages. Single pipeline measured 0.8-0.9s edit-to-diagnostic
    -- vs 5.6s with both pipelines on.
    checkOnSave = false,
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
