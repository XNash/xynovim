return {
  "ThePrimeagen/99",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    local _99 = require("99")

    _99.setup({
      provider = _99.Providers.ClaudeCodeProvider,
      model = "claude-sonnet-5",
      provider_extra_args = { "--effort", "medium" },
    })

    vim.keymap.set("n", "<leader>9s", function() _99.search() end, { desc = "99: Search" })
    vim.keymap.set("v", "<leader>9vv", function() _99.visual() end, { desc = "99: Visual" })
    vim.keymap.set("n", "<leader>9x", function() _99.stop_all_requests() end, { desc = "99: Stop all requests" })
    vim.keymap.set(
      "n",
      "<leader>9m",
      function() require("99.extensions.telescope").select_model() end,
      { desc = "99: Select model" }
    )
    -- capitalized: <leader>9p is intentionally left free
    vim.keymap.set(
      "n",
      "<leader>9P",
      function() require("99.extensions.telescope").select_provider() end,
      { desc = "99: Select provider" }
    )
  end,
}
