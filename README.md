# xyno-neovim

Personal Neovim config, built on [LazyVim](https://github.com/LazyVim/LazyVim), running on Linux (Omarchy/Arch). The previous from-scratch Windows config lives on the [`windows-legacy`](../../tree/windows-legacy) branch.

Every notable change is documented in [CHANGELOG.md](CHANGELOG.md), including what was verified and how.

## What's here beyond stock LazyVim

### Rust

- **LazyVim `lang.rust` extra**: rustaceanvim + rust-analyzer, crates.nvim for Cargo.toml, codelldb for debugging, neotest adapter.
- **Live-as-you-type diagnostics via [bacon-ls](https://github.com/crisidev/bacon-ls)** (`lua/plugins/bacon-ls.lua`): the native cargo backend runs clippy (`--workspace --all-targets --all-features`) with `updateOnInsert` — it mirrors the workspace into a hardlinked shadow under `target/bacon-ls-live/` and re-runs clippy on every buffer change, so diagnostics stream in while typing, before any save. rust-analyzer keeps completion, goto/references, hover, and code actions; its own checkOnSave/diagnostics are disabled to avoid duplicates.
- **rustaceanvim tuning** (`lua/plugins/rustaceanvim.lua`): inlay hints (closure return types, elided lifetimes), fill-arguments completion snippets, full function signatures, module-grouped auto-imports.

Requires: `rust-analyzer` on PATH, `bacon` ≥ 3.8 (from pacman here; Mason's bacon package didn't produce a binary), `bacon-ls` (Mason).

### 99 (AI assistant)

[ThePrimeagen/99](https://github.com/ThePrimeagen/99) on the Claude Code provider (`lua/plugins/ninety-nine.lua`), model `claude-sonnet-5` with `--effort medium`.

Hard-won configuration notes:

- `tmp_dir` **must be an absolute path** (here: `~/.cache/nvim/99`). 99 resolves a relative tmp_dir against nvim's cwd, but claude resolves the same relative TEMP_FILE against the project it's working in — launch nvim from outside the project and every response comes back empty because the answer lands where 99 never reads.
- The logger needs `type = "file"` for `path` to take effect; the plugin README's example omits it and logs silently go nowhere. Logs land at `/tmp/<dirname>.99.debug`.
- The blink completion source (`#rules` / `@files` in the prompt buffer) needs `saghen/blink.compat`.

| Keymap | Action |
| --- | --- |
| `<leader>9s` | Search (results → quickfix) |
| `<leader>9v` / `<leader>9vv` (visual) | Vibe / replace selection |
| `<leader>9o` | Open last interaction |
| `<leader>9l` | View logs |
| `<leader>9c` / `<leader>9x` | Clear previous / stop all requests |
| `<leader>9w` / `<leader>9W` | Worker search / set work |
| `<leader>9m` / `<leader>9P` | Select model / provider (telescope) |

### Editor behavior

- **auto-save** (`lua/plugins/auto-save.lua`): okuuva/auto-save.nvim, ~1s debounce including while typing (`TextChangedI`). Autosaves skip format-on-save via `noautocmd`, with a narrow `vim.cmd` proxy that re-sends `textDocument/didSave` so LSP save-triggered behavior survives. Manual `:w` still formats.
- **harpoon**, and Omarchy desktop integration: live theme hot-reload, transparency, remote clipboard.
- Format-on-save off globally (`vim.g.autoformat = false`), relative numbers off.

## Layout

```
lua/config/    options, keymaps, autocmds, remote clipboard
lua/plugins/   one spec per concern (bacon-ls, rustaceanvim, ninety-nine, auto-save, …)
plugin/after/  transparency
```

LazyVim extras enabled (`lazyvim.json`): `editor.neo-tree`, `lang.rust`.
