return {
  "mrcjkb/rustaceanvim",
  opts = {
    server = {
      default_settings = {
        ["rust-analyzer"] = {
          -- Two diagnostic tiers: rust-analyzer's NATIVE diagnostics are
          -- computed in-memory as you type (no cargo run) - instant type
          -- errors, unresolved names, typos. Clippy depth still comes from
          -- bacon-ls ~1s later (see bacon-ls.lua). checkOnSave stays off
          -- (the extra disables it) so no cargo pipeline is duplicated;
          -- overlap is only visual: a type error may briefly show from both
          -- sources. styleLints stay off - that's clippy's job.
          diagnostics = { enable = true },
          -- Separate target dir for rust-analyzer's own cargo runs (build
          -- scripts, proc-macros) so they never contend for the build-dir
          -- file lock with terminal `cargo run`/`cargo test`.
          cargo = { targetDir = true },
          -- RustRover-style inline type/lifetime annotations.
          inlayHints = {
            closureReturnTypeHints = { enable = "with_block" },
            lifetimeElisionHints = { enable = "skip_trivial", useParameterNames = true },
            expressionAdjustmentHints = { enable = "never" },
          },
          -- Completion niceties: auto-import granularity + fill call args.
          imports = {
            granularity = { group = "module" },
            prefix = "self",
          },
          completion = {
            callable = { snippets = "fill_arguments" },
            fullFunctionSignatures = { enable = true },
          },
        },
      },
    },
  },
}
