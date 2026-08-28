<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/343cb4e0-1b08-4b11-b861-b4339141728e" />

# xyno-neovim

A minimal, from-scratch Neovim config — inspired by [ThePrimeagen's init.lua](https://github.com/ThePrimeagen/init.lua)
(same infra-level plugin choices, same leader key convention) but scoped only to what's
actually needed: Rust, Node/TypeScript, PowerShell, Flutter/Dart, plus AI via
[99](https://github.com/ThePrimeagen/99) on Claude Code.

Leader key is `<Space>`.

## Structure

- `init.lua` — leader key, loads options/lazy/keymaps
- `lua/config/options.lua` — editor options
- `lua/config/keymaps.lua` — non-plugin-specific keymaps
- `lua/config/lazy.lua` — lazy.nvim bootstrap
- `lua/config/plugins/*.lua` — one file per plugin or tightly related group
- `lua/config/colors/islands-dark.lua` — the colorscheme, ported from RustRover's
  "Islands Dark" scheme; loaded via a local (non-cloned) `lazy.nvim` spec in
  `lua/config/plugins/misc.lua`

## Requirements

- Neovim 0.10+
- git, ripgrep, a C compiler (Treesitter parser builds)
- Node/npm, Rust (rustup), PowerShell, the Flutter SDK — for the respective language tooling
- The `claude` CLI, authenticated, for the 99 AI integration

## Local plugins

Two plugins are pulled from local clones rather than a git URL and expected at:

- `~/personal/harpoon` — [ThePrimeagen/harpoon](https://github.com/ThePrimeagen/harpoon), `harpoon2` branch
- `~/personal/99` — [ThePrimeagen/99](https://github.com/ThePrimeagen/99)

Clone both before first launch.

## Cross-device sync via OneDrive

This config physically lives at `<OneDrive>\cross_device_configs\neovim`, not at
`%LOCALAPPDATA%\nvim`. Neovim still finds it at the default path via a **directory
junction** (`%LOCALAPPDATA%\nvim` → the OneDrive folder) — junctions are used instead of
symlinks because they don't require admin rights or Developer Mode.

### New device (clean machine or replacing an existing config)

From an **elevated** PowerShell (Run as Administrator):

```powershell
irm https://raw.githubusercontent.com/XNash/xyno-neovim/master/bootstrap-device.ps1 | iex
```

This runs straight from GitHub, so it works even before OneDrive/git/anything else is
installed. It checks for and installs everything this config needs — Git, ripgrep,
Node.js, Rust (rustup), a C compiler (for Treesitter parser builds), Neovim, the Claude
Code CLI, the Flutter SDK (downloaded and extracted directly — no winget package exists
for it), the `harpoon`/`99` local plugin clones, PATH entries, and finally the config link
itself, then pre-installs all plugins (`Lazy sync`) so the first real launch is instant.
Every step is idempotent — safe to re-run, including after a partial failure (e.g. a
network hiccup partway through).

If an existing `%LOCALAPPDATA%\nvim` is found that isn't already this link, it **asks
before touching it** and backs it up (`nvim.bak.<timestamp>`) rather than overwriting
silently.

Two things it deliberately does not automate, since they're credential/GUI flows: signing
in to OneDrive, and `claude auth login`. It detects both and tells you exactly what to do.

Only the config itself syncs via OneDrive; `nvim-data` (installed plugins, Mason tools,
undo history) stays local per device.

## Features

### Navigation

| Key | Action |
|---|---|
| `<leader>pf` | Telescope: find files |
| `<C-p>` | Telescope: git files |
| `<leader>ps` | Telescope: grep for a string |
| `<leader>pg` | Telescope: live grep |
| `<leader>pb` | Telescope: switch buffers |
| `<leader>a` | Harpoon: add current file |
| `<C-e>` | Harpoon: quick menu |
| `<M-1>`–`<M-4>` | Harpoon: jump to pinned file 1–4 |
| `<leader>pv` | netrw file explorer (`%` new file, `d` new dir, `R` rename, `D` delete) |

### LSP / IDE features

`rust_analyzer`, `vtsls`, `eslint`, `powershell_es` and Dart's `dartls` (via flutter-tools.nvim)
are wired through Mason with per-server settings layered on nvim-lspconfig's native
`vim.lsp.config()` defaults (not the old `mason-lspconfig` `handlers` API, which this
version of the plugin no longer supports).

- Inline diagnostics with gutter icons and virtual text, same idea as RustRover's inline
  error messages
- Inlay type hints (inferred types, parameter names) enabled automatically on any client
  that supports them
- Rust diagnostics run through **clippy**, not plain `cargo check`
  (`rust-analyzer.check.command = "clippy"`)
- A 💡 sign (`nvim-lightbulb`) appears in the gutter whenever a code action is available
  at the cursor — quick fixes, auto-imports, suggestions — so you know when `<leader>vca`
  has something to offer instead of checking blind.

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `K` | Hover |
| `[d` / `]d` | Next / prev diagnostic |
| `<leader>vd` | Diagnostic float |
| `<leader>vca` | Code action |
| `<leader>vrr` | References |
| `<leader>vrn` | Rename |

**Linting**: clippy (Rust), `eslint` (JS/TS — see note below), PSScriptAnalyzer
(PowerShell, via `powershell_es`), and Dart's built-in analyzer all run as real-time LSP
diagnostics, no separate lint command needed.

> **ESLint note**: `eslint` resolves ESLint from the **project's own** `node_modules` —
> it won't lint anything without a real local `eslint` install and a config file
> (`eslint.config.js` for flat config, or a legacy `.eslintrc.*`) in that project. It's
> not a global linter.

### Formatting

`conform.nvim` formats on save (`rustfmt`, `prettier`, `dart_format`; PowerShell via a
custom PSScriptAnalyzer-based formatter, since `powershell_es` doesn't advertise LSP
formatting support). `<leader>f` formats on demand without saving.

Autocompletion pairs brackets/quotes automatically (`nvim-autopairs`, cmp-integrated).

### Auto-save

`auto-save.nvim` writes the buffer automatically after a short pause in typing or on
losing focus — no more losing work to a crash or an accidental quit. It's configured with
`noautocmd = true` so autosaves **don't** trigger format-on-save; only an explicit `:w`
or `<leader>f` formats.

### Statusline

`lualine.nvim` replaces Neovim's plain `-- INSERT --` echo-area mode message with a real,
always-visible statusline whose leftmost cell shows the current mode by name (NORMAL,
INSERT, VISUAL, REPLACE, COMMAND, ...) and recolors itself per mode using the active
colorscheme's own colors (`theme = "auto"`), plus git branch/diff, diagnostics count,
filename, filetype, and cursor position. One global statusline (`globalstatus = true`)
rather than one per split.

### Terminal

`<C-\>` toggles a terminal in a bottom split, JetBrains-style — same key opens and closes
it from either code or the terminal itself. Inside the terminal, `<C-h/j/k/l>` jumps
between windows, `<Esc>` drops to terminal-normal mode.

### AI (99 on Claude Code)

Configured with `provider = ClaudeCodeProvider`, `model = "claude-sonnet-5"`, and
`--effort medium` (via 99's `provider_extra_args`, not a source patch).

| Key | Action |
|---|---|
| `<leader>9s` | Search — sends the project to Claude Code, results land as a quickfix list |
| `<leader>9vv` | Visual — prompts for what to do with the selected code |
| `<leader>9x` | Stop all in-flight requests |
| `<leader>9m` | Model picker |
| `<leader>9P` | Provider picker (capital — `<leader>9p` is intentionally left free) |

See [CHANGELOG.md](./CHANGELOG.md) for what's changed since the initial commit.

