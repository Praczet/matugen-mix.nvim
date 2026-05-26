local M = {}

---@class MatugenMixRgb
---@field r integer
---@field g integer
---@field b integer

---@param hex string
---@return MatugenMixRgb
function M.hex_to_rgb(hex)
	hex = hex:gsub("#", "")

	return {
		r = tonumber(hex:sub(1, 2), 16),
		g = tonumber(hex:sub(3, 4), 16),
		b = tonumber(hex:sub(5, 6), 16),
	}
end

---@param rgb MatugenMixRgb
---@return string
function M.rgb_to_hex(rgb)
	return string.format("#%02x%02x%02x", rgb.r, rgb.g, rgb.b)
end

---@param a string
---@param b string
---@param amount number 0.0 - 1.0
---@return string
function M.mix(a, b, amount)
	local ca = M.hex_to_rgb(a)
	local cb = M.hex_to_rgb(b)

	return M.rgb_to_hex({
		r = math.floor(ca.r * (1 - amount) + cb.r * amount),
		g = math.floor(ca.g * (1 - amount) + cb.g * amount),
		b = math.floor(ca.b * (1 - amount) + cb.b * amount),
	})
end

return M
