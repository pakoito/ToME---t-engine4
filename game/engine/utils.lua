function string.splitLine(str, max_width, font)
	local space_w = font:size(" ")
	local lines = {}
	local cur_line, cur_size = "", 0
	for v in str:gmatch("([^\n ]+)") do
		local w, h = font:size(v)

		-- Ignore the size of color markers
		local _, _, color = v:find("(#%x%x%x%x%x%x#)")
		if color then
			local color_w = font:size(color)
			w = w - color_w
		end

		if cur_size + space_w + w < max_width then
			cur_line = cur_line..(cur_size==0 and "" or " ")..v
			cur_size = cur_size + (cur_size==0 and 0 or space_w) + w
		else
			lines[#lines+1] = cur_line
			cur_line = v
			cur_size = w
		end
	end
	if cur_size > 0 then lines[#lines+1] = cur_line end
	return lines
end

function string.splitLines(str, max_width, font)
	local lines = {}
	for v in str:gmatch("([^\n]+)") do
		local ls = v:splitLine(max_width, font)
		for i, l in ipairs(ls) do
			lines[#lines+1] = l
		end
	end
	return lines
end

-- Split a string by the given character(s)
function string.split(str, char, keep_sperator)
	local ret   = {}
	local len   = str:len()
	local start = 1

	while true do
		local split_start, split_end, sep = str:find(char, start)

		if not split_start then
			table.insert(ret, str:sub(start))
			break
		end

		table.insert(ret, str:sub(start, split_start - 1))

		if split_start and keep_sperator then
			table.insert(ret, str:sub(split_start, split_end))
		end

		if split_end == len then
			break
		end

		start = split_end + 1
	end

	return ret
end

local hex_to_dec = {
	["0"] = 0,
	["1"] = 1,
	["2"] = 2,
	["3"] = 3,
	["4"] = 4,
	["5"] = 5,
	["6"] = 6,
	["7"] = 7,
	["8"] = 8,
	["9"] = 9,
	["a"] = 10,
	["b"] = 11,
	["c"] = 12,
	["d"] = 13,
	["e"] = 14,
	["f"] = 15,
}
function string.parseHex(str)
	local res = 0
	local power = 1
	for i = 1, #str do
		res = res + power * (hex_to_dec[str:sub(#str-i+1,#str-i+1):lower()] or 0)
		power = power * 16
	end
	return res
end

local tmps = core.display.newSurface(1, 1)
getmetatable(tmps).__index.drawColorString = function(s, font, str, x, y, r, g, b)
	local list = str:split("#%x%x%x%x%x%x#", true)
	for i, v in ipairs(list) do
		local _, _, nr, ng, nb = v:find("^#(%x%x)(%x%x)(%x%x)#")
		if nr and ng and nb then
			r, g, b = nr:parseHex(), ng:parseHex(), nb:parseHex()
		else
			local w, h = font:size(v)
			s:drawString(font, v, x, y, r, g, b)
			x = x + w
		end
	end
end
