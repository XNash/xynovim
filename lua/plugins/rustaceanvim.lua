return {
  "mrcjkb/rustaceanvim",
  opts = {
    server = {
      default_settings = {
        ["rust-analyzer"] = {
          -- LazyVim's rust extra enables checkOnSave but leaves the default
          -- `cargo check`; clippy is the full lint set (what RustRover's
          -- inspections roughly correspond to). --no-deps keeps saves fast.
          check = {
            command = "clippy",
            extraArgs = { "--no-deps" },
          },
          -- Push-style native diagnostics (typos, unresolved names, type
          -- mismatches) appear as you type, without waiting for cargo.
          diagnostics = {
            enable = true,
            styleLints = { enable = true },
          },
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
