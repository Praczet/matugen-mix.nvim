local color = require("matugen-mix.color")

local M = {}

---@class MatugenMixConfig
---@field enabled boolean
---@field colors_module string
---@field fallback_accent string
---@field default_amount number
---@field palette table<string, number>

---@type MatugenMixConfig
M.config = {
	enabled = true,

	colors_module = "generated.matugen-colors",
	fallback_accent = "#7aa2f7",
	default_amount = 0.05,

	palette = {
		bg = 0.05,
		bg_dark = 0.04,
		bg_float = 0.06,
		bg_sidebar = 0.06,
	},
}

---@param opts? table
function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})

	vim.api.nvim_create_user_command("MatugenMixEnable", function()
		M.enable()
	end, {})

	vim.api.nvim_create_user_command("MatugenMixDisable", function()
		M.disable()
	end, {})

	vim.api.nvim_create_user_command("MatugenMixToggle", function()
		M.toggle()
	end, {})
end

---@return boolean
function M.is_enabled()
	return M.config.enabled == true
end

function M.reload_colorscheme()
	local colorscheme = vim.g.colors_name

	if not colorscheme then
		return
	end

	vim.cmd.colorscheme(colorscheme)
end

function M.enable()
	M.config.enabled = true
	M.reload_colorscheme()
	vim.notify("Matugen mix enabled", vim.log.levels.INFO)
end

function M.disable()
	M.config.enabled = false
	M.reload_colorscheme()
	vim.notify("Matugen mix disabled", vim.log.levels.INFO)
end

function M.toggle()
	if M.is_enabled() then
		M.disable()
	else
		M.enable()
	end
end

---@return table|nil
function M.get_matugen()
	local ok, matugen = pcall(require, M.config.colors_module)

	if not ok then
		return nil
	end

	return matugen
end

---@param key string
---@param fallback? string
---@return string
function M.get_color(key, fallback)
	local matugen = M.get_matugen()

	if not matugen or not matugen.colors then
		return fallback or M.config.fallback_accent
	end

	return matugen.colors[key] or fallback or M.config.fallback_accent
end

---@param base string
---@param matugen_key? string
---@param amount? number
---@return string
function M.mix(base, matugen_key, amount)
	local accent = M.get_color(matugen_key or "primary", M.config.fallback_accent)
	return color.mix(base, accent, amount or M.config.default_amount)
end

---@param colors table
---@param opts? table
function M.apply_tokyonight(colors, opts)
	if not M.is_enabled() then
		return
	end

	opts = opts or {}

	local accent = opts.accent or "primary"
	local palette = vim.tbl_deep_extend("force", M.config.palette, opts.palette or {})

	for key, amount in pairs(palette) do
		if colors[key] then
			colors[key] = M.mix(colors[key], accent, amount)
		end
	end
end

M.color = color

return M
