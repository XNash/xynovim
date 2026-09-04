# xynovim (formerly xyno-neovim)

Personal Neovim config, built on [LazyVim](https://github.com/LazyVim/LazyVim), running on Linux (Omarchy/Arch). The previous from-scratch Windows config lives on the [`windows-legacy`](../../tree/windows-legacy) branch.

Every notable change is documented in [CHANGELOG.md](CHANGELOG.md), including what was verified and how.

## What's here beyond stock LazyVim

### Rust

- **LazyVim `lang.rust` extra**: rustaceanvim + rust-analyzer, crates.nvim for Cargo.toml, codelldb for debugging, neotest adapter.
- **Two-tier diagnostics** for instant feedback with clippy depth:
  - *Instant tier (~0.15–0.25s measured, warm)*: rust-analyzer's native in-memory diagnostics — type errors, unresolved names, as you type, no cargo run involved.
  - *Depth tier (~0.56s median, warm)*: clippy via [bacon-ls](https://github.com/crisidev/bacon-ls)'s native cargo backend (`lua/plugins/bacon-ls.lua`) with `updateOnInsert` — it mirrors the workspace into a hardlinked shadow under `target/bacon-ls-live/` and re-runs clippy (`--workspace --all-features --no-deps`, 500ms debounce) on every buffer change, before any save. `checkOnSave` is deliberately **off**: with ~1s auto-save it was a second cargo pipeline racing the live one — runs cancelled each other and serialized on cargo's build-dir lock (measured 5.6s edit-to-diagnostic with both pipelines vs single-pipeline sub-second). `updateOnInsert` must stay **on**: without it bacon-ls advertises no document sync and diagnostics never refresh.
  - The only overlap is visual: a type error can briefly show from both sources.
- **Locally patched bacon-ls** (`cmd` override in `lua/plugins/bacon-ls.lua` → `~/.cargo/bin/bacon-ls`, source in `~/.local/src/bacon-ls-upstream`, upstream 0.30.0 + a fix branch; **filed upstream as [crisidev/bacon-ls#139](https://github.com/crisidev/bacon-ls/pull/139)**): upstream `abort()`s its debounce task even after the sleep has elapsed — at that point the task *is* the in-flight cargo run, so any keystroke (or auto-save's `didSave`) kills the run silently: the LSP progress token never closes (permanently stacked "checking…" rows) and diagnostics go stale. Three fixes, all verified by a 35-check headless E2E suite (`~/.bacon-e2e/`): (1) the debounce task drops its own handle once its sleep is over, so a later `abort()` can only cancel a still-sleeping trigger — in-flight runs are instead superseded via `CancelRunning`, which closes tokens properly; (2) with `checkOnSave` off, `didSave` no longer cancels a still-pending live trigger (a save inside the debounce window would silently skip the check); (3) closing a dirty buffer clears its now-orphaned diagnostics and restores the shadow file by *copy* (fresh mtime) instead of hardlink, so cargo re-checks instead of replaying the dirty build's cached warnings. Drop the override when #139 merges.
- **rustaceanvim tuning** (`lua/plugins/rustaceanvim.lua`): inlay hints (closure return types, elided lifetimes), fill-arguments completion snippets, full function signatures, module-grouped auto-imports, and `cargo.targetDir = true` so rust-analyzer's build-script runs never contend for the build-dir lock with terminal `cargo run`/`cargo test`.
- **System-level build speed** (`~/.cargo/config.toml`, outside this repo): mold linker via clang (links several times faster — every clippy/test/run cycle benefits) and `profile.dev.debug = "line-tables-only"` (backtraces kept, debuginfo cost dropped; set full debug per-project when using the debugger).

Requires: `rust-analyzer` on PATH, `bacon` ≥ 3.8 (from pacman here; Mason's bacon package didn't produce a binary), `bacon-ls` (Mason), `mold` + `clang` (pacman).

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

- **auto-save** (`lua/plugins/auto-save.lua`): okuuva/auto-save.nvim, ~1s debounce including while typing (`TextChangedI`). Autosaves skip format-on-save via `noautocmd`; a `User AutoSaveWritePost` hook re-sends `textDocument/didSave` so LSP save-triggered behavior survives. Manual `:w` still formats.
- **harpoon**, and Omarchy desktop integration: live theme hot-reload, transparency (re-applied on every `ColorScheme` change), remote clipboard (OSC52, activates only under tmux/SSH/herdr).
- Format-on-save off globally (`vim.g.autoformat = false`), relative numbers off.

### Performance choices

- ~18ms startup (from 29ms): 99 + telescope + blink.compat and harpoon lazy-load on their keymaps; the herdr `/proc` ancestry walk short-circuits behind env checks.
- lazy.nvim's periodic update checker is **off** (it re-fetched all plugin repos in the background and dragged `lazy.manage` into every startup) — update with `:Lazy sync`.
- Remote-plugin providers (python3/ruby/perl/node) disabled — nothing uses them.
- 99's request cache (`~/.cache/nvim/99`) is pruned of week-old files on load.

## Layout

```
lua/config/    options, keymaps, autocmds, remote clipboard
lua/plugins/   one spec per concern (bacon-ls, rustaceanvim, ninety-nine, auto-save, …)
plugin/after/  transparency
```

LazyVim extras enabled (`lazyvim.json`): `editor.neo-tree`, `lang.rust`.
