return {
  "mrcjkb/rustaceanvim",
  opts = {
    server = {
      default_settings = {
        ["rust-analyzer"] = {
          -- Diagnostics come from bacon-ls (see lazyvim_rust_diagnostics in
          -- options.lua); the lang.rust extra disables rust-analyzer's
          -- checkOnSave/diagnostics itself, so no check/diagnostics here.
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
