return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {},
  keys = function()
    local harpoon = require("harpoon")

    local keys = {
      { "<leader>a", function() harpoon:list():add() end, desc = "Harpoon: Add file" },
      { "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "Harpoon: Quick menu" },
    }

    for i = 1, 4 do
      table.insert(keys, {
        "<M-" .. i .. ">",
        function() harpoon:list():select(i) end,
        desc = "Harpoon: Jump to file " .. i,
      })
    end

    return keys
  end,
}
