return {
  "ThePrimeagen/99",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    -- required by 99's blink completion source
    { "saghen/blink.compat", version = "2.*" },
  },
  config = function()
    local _99 = require("99")

    _99.setup({
      provider = _99.Providers.ClaudeCodeProvider,
      model = "claude-sonnet-5",
      provider_extra_args = { "--effort", "medium" },
      -- MUST be absolute. 99 resolves a relative tmp_dir against nvim's cwd,
      -- but claude resolves the same relative TEMP_FILE against the project
      -- it's working in - launch nvim from outside the project (e.g.
      -- `nvim Projects/foo/` from ~) and the answer lands where 99 never
      -- reads, so every response comes back empty. An absolute path is
      -- unambiguous for both sides; writing outside claude's cwd is fine
      -- because the provider passes --dangerously-skip-permissions.
      tmp_dir = vim.fn.stdpath("cache") .. "/99",
      display_errors = true,
      logger = {
        -- type = "file" is required for path to take effect; without it the
        -- logger silently uses a void sink (the README example omits it).
        type = "file",
        level = _99.DEBUG,
        path = "/tmp/" .. vim.fs.basename(vim.uv.cwd() or "nvim") .. ".99.debug",
        print_on_error = true,
      },
      completion = {
        -- #rules / @files completion in the prompt buffer via LazyVim's
        -- completion engine (default is the plugin's own "native" source).
        source = "blink",
      },
    })

    vim.keymap.set("n", "<leader>9s", function() _99.search() end, { desc = "99: Search" })
    vim.keymap.set("n", "<leader>9v", function() _99.vibe() end, { desc = "99: Vibe" })
    vim.keymap.set("v", "<leader>9vv", function() _99.visual() end, { desc = "99: Visual" })
    vim.keymap.set("n", "<leader>9o", function() _99.open() end, { desc = "99: Open last interaction" })
    vim.keymap.set("n", "<leader>9l", function() _99.view_logs() end, { desc = "99: View logs" })
    vim.keymap.set("n", "<leader>9c", function() _99.clear_previous_requests() end, { desc = "99: Clear previous" })
    vim.keymap.set("n", "<leader>9x", function() _99.stop_all_requests() end, { desc = "99: Stop all requests" })
    vim.keymap.set("n", "<leader>9w", function() _99.Extensions.Worker.search() end, { desc = "99: Worker search" })
    vim.keymap.set("n", "<leader>9W", function() _99.Extensions.Worker.set_work() end, { desc = "99: Worker set work" })
    vim.keymap.set(
      "n",
      "<leader>9m",
      function() require("99.extensions.telescope").select_model() end,
      { desc = "99: Select model" }
    )
    -- capitalized: keeps the provider picker grouped with the model picker
    vim.keymap.set(
      "n",
      "<leader>9P",
      function() require("99.extensions.telescope").select_provider() end,
      { desc = "99: Select provider" }
    )
  end,
}
