-- Make highlight groups transparent while preserving their other attributes.
-- Applied immediately AND on every ColorScheme change, so a manual
-- `:colorscheme` mid-session keeps transparency too (the Omarchy hot-reload
-- re-sources this file, which is safe: the augroup clears its old autocmd).
local function make_transparent(name)
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
	if ok and hl.bg ~= nil then
		hl.bg = nil
		vim.api.nvim_set_hl(0, name, hl)
	end
end

local groups = {
	-- transparent background
	"Normal",
	"NormalFloat",
	"FloatBorder",
	"Pmenu",
	"Terminal",
	"EndOfBuffer",
	"FoldColumn",
	"Folded",
	"SignColumn",
	"LineNr",
	"CursorLineNr",
	"NormalNC",
	"WhichKeyFloat",
	"TelescopeBorder",
	"TelescopeNormal",
	"TelescopePromptBorder",
	"TelescopePromptTitle",
	-- neotree
	"NeoTreeNormal",
	"NeoTreeNormalNC",
	"NeoTreeVertSplit",
	"NeoTreeWinSeparator",
	"NeoTreeEndOfBuffer",
	-- nvim-tree
	"NvimTreeNormal",
	"NvimTreeVertSplit",
	"NvimTreeEndOfBuffer",
	-- notify
	"NotifyINFOBody",
	"NotifyERRORBody",
	"NotifyWARNBody",
	"NotifyTRACEBody",
	"NotifyDEBUGBody",
	"NotifyINFOTitle",
	"NotifyERRORTitle",
	"NotifyWARNTitle",
	"NotifyTRACETitle",
	"NotifyDEBUGTitle",
	"NotifyINFOBorder",
	"NotifyERRORBorder",
	"NotifyWARNBorder",
	"NotifyTRACEBorder",
	"NotifyDEBUGBorder",
}

local function apply()
	for _, name in ipairs(groups) do
		make_transparent(name)
	end
end

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("user_transparency", { clear = true }),
	callback = apply,
})

apply()
