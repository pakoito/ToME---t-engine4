-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

local lpeg = require "lpeg"

function lpeg.anywhere (p)
	return lpeg.P{ p + 1 * lpeg.V(1) }
end

function table.clone(tbl, deep)
	local n = {}
	for k, e in pairs(tbl) do
		-- Deep copy subtables, but not objects!
		if deep and type(e) == "table" and not e.__CLASSNAME then
			n[k] = table.clone(e, true)
		else
			n[k] = e
		end
	end
	return n
end

function table.merge(dst, src, deep)
	for k, e in pairs(src) do
		if deep and dst[k] and type(e) == "table" and type(dst[k]) == "table" and not e.__CLASSNAME then
			table.merge(dst[k], e, true)
		elseif deep and not dst[k] and type(e) == "table" and not e.__CLASSNAME then
			dst[k] = table.clone(e, true)
		else
			dst[k] = e
		end
	end
end

function table.mergeAdd(dst, src, deep)
	for k, e in pairs(src) do
		if deep and dst[k] and type(e) == "table" and type(dst[k]) == "table" and not e.__CLASSNAME then
			table.mergeAdd(dst[k], e, true)
		elseif deep and not dst[k] and type(e) == "table" and not e.__CLASSNAME then
			dst[k] = table.clone(e, true)
		elseif dst[k] and type(e) == "number" then
			dst[k] = dst[k] + e
		else
			dst[k] = e
		end
	end
end

function string.ordinal(number)
	local suffix = "th"
	number = tonumber(number)
	if number == 1 then
		suffix = "st"
	elseif number == 2 then
		suffix = "nd"
	elseif number == 3 then
		suffix = "rd"
	end
	return number..suffix
end

function string.capitalize(str)
	if #str > 1 then
		return string.upper(str:sub(1, 1))..str:sub(2)
	elseif #str == 1 then
		return str:upper()
	else
		return str
	end
end

function string.bookCapitalize(str)
	local words = str:split(' ')

	for i = 1, #words do
		local word = words[i]

		-- Don't capitalize certain words unless they are at the begining
		-- of the string.
		if i == 1 or (word ~= "of" and word ~= "the" and word ~= "and" and word ~= "a" and word ~= "an")
		then
			words[i] = word:gsub("^(.)",
							function(x)
								return x:upper()
							end)
		end
	end

	return table.concat(words, " ")
end

function string.splitLine(str, max_width, font)
	local space_w = font:size(" ")
	local lines = {}
	local cur_line, cur_size = "", 0
	for _, v in ipairs(str:split(lpeg.S"\n ")) do
		local w, h = font:size(v)

		-- Ignore the size of color markers
		local _, _, color1 = v:find("(#%x%x%x%x%x%x#)")
		local _, _, color2 = v:find("(#[A-Z_]+#)")
		if color1 then
			local color_w = font:size(color1)
			w = w - color_w
		elseif color2 then
			local color_w = font:size(color2)
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
	for _, v in ipairs(str:split(lpeg.S"\n")) do
		local ls = v:splitLine(max_width, font)
		if #ls > 0 then
			for i, l in ipairs(ls) do
				lines[#lines+1] = l
			end
		else
			lines[#lines+1] = ""
		end
	end
	return lines
end

-- Split a string by the given character(s)
function string.split(str, char, keep_separator)
	char = lpeg.P(char)
	if keep_separator then char = lpeg.C(char) end
	local elem = lpeg.C((1 - char)^0)
	local p = lpeg.Ct(elem * (char * elem)^0)
	return lpeg.match(p, str)
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
local hexcache = {}
function string.parseHex(str)
	if hexcache[str] then return hexcache[str] end
	local res = 0
	local power = 1
	for i = 1, #str do
		res = res + power * (hex_to_dec[str:sub(#str-i+1,#str-i+1):lower()] or 0)
		power = power * 16
	end
	hexcache[str] = res
	return res
end

local tmps = core.display.newSurface(1, 1)
getmetatable(tmps).__index.drawColorString = function(s, font, str, x, y, r, g, b)
	local Pcolorname = (lpeg.R"AZ" + "_")^3
	local Pcode = (lpeg.R"az" + lpeg.R"AZ" + lpeg.R"09")
	local Pcolorcode = Pcode * Pcode

	local list = str:split("#" * (Pcolorname + (Pcolorcode * Pcolorcode * Pcolorcode)) * "#", true)
	r = r or 255
	g = g or 255
	b = b or 255
	local oldr, oldg, oldb = r, g, b
	for i, v in ipairs(list) do
		local nr, ng, nb = lpeg.match("#" * lpeg.C(Pcolorcode) * lpeg.C(Pcolorcode) * lpeg.C(Pcolorcode) * "#", v)
		local col = lpeg.match("#" * lpeg.C(Pcolorname) * "#", v)
		if nr and ng and nb then
			oldr, oldg, oldb = r, g, b
			r, g, b = nr:parseHex(), ng:parseHex(), nb:parseHex()
		elseif col then
			if col == "LAST" then
				r, g, b = oldr, oldg, oldb
			else
				oldr, oldg, oldb = r, g, b
				r, g, b = colors[col].r, colors[col].g, colors[col].b
			end
		else
			local w, h = font:size(v)
			s:drawString(font, v, x, y, r, g, b)
			x = x + w
		end
	end
	return r, g, b
end

getmetatable(tmps).__index.drawColorStringCentered = function(s, font, str, dx, dy, dw, dh, r, g, b)
	local w, h = font:size(str)
	local x, y = dx + (dw - w) / 2, dy + (dh - h) / 2
	s:drawColorString(font, str, x, y, r, g, b)
end

dir_to_coord = {
	[1] = {-1, 1},
	[2] = { 0, 1},
	[3] = { 1, 1},
	[4] = {-1, 0},
	[5] = { 0, 0},
	[6] = { 1, 0},
	[7] = {-1,-1},
	[8] = { 0,-1},
	[9] = { 1,-1},
}
coord_to_dir = {
	[-1] = {
		[-1] = 7,
		[ 0] = 4,
		[ 1] = 1,
	},
	[ 0] = {
		[-1] = 8,
		[ 0] = 5,
		[ 1] = 2,
	},
	[ 1] = {
		[-1] = 9,
		[ 0] = 6,
		[ 1] = 3,
	},
}

dir_sides =
{
	[1] = {left=2, right=4},
	[2] = {left=3, right=1},
	[3] = {left=6, right=2},
	[4] = {left=1, right=7},
	[6] = {left=9, right=3},
	[7] = {left=4, right=8},
	[8] = {left=7, right=9},
	[9] = {left=8, right=6},
}

util = {}

function util.getDir(x1, y1, x2, y2)
	local xd, yd = x1 - x2, y1 - y2
	if xd ~= 0 then xd = xd / math.abs(xd) end
	if yd ~= 0 then yd = yd / math.abs(yd) end
	return coord_to_dir[xd][yd], xd, yd
end

function util.coordAddDir(x, y, dir)
	return x + dir_to_coord[dir][1], y + dir_to_coord[dir][2]
end

function util.boundWrap(i, min, max)
	if i < min then i = max
	elseif i > max then i = min end
	return i
end
function util.bound(i, min, max)
	if i < min then i = min
	elseif i > max then i = max end
	return i
end
function util.scroll(sel, scroll, max)
	if sel > scroll + max - 1 then scroll = sel - max + 1 end
	if sel < scroll then scroll = sel end
	return scroll
end

function util.getval(val, ...)
	if type(val) == "function" then return val(...)
	elseif type(val) == "table" then return val[rng.range(1, #val)]
	else return val
	end
end

function core.fov.circle_grids(x, y, radius, block)
	local grids = {}
	core.fov.calc_circle(x, y, radius, function(_, lx, ly)
		if not grids[lx] then grids[lx] = {} end
		grids[lx][ly] = true

		if block and game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") then return true end
	end, function()end, nil)

	-- point of origin
	if not grids[x] then grids[x] = {} end
	grids[x][y] = true

	return grids
end

function core.fov.beam_grids(x, y, radius, dir, angle, block)
	local grids = {}
	core.fov.calc_beam(x, y, radius, dir, angle, function(_, lx, ly)
		if not grids[lx] then grids[lx] = {} end
		grids[lx][ly] = true

		if block and game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") then return true end
	end, function()end, nil)

	-- point of origin
	if not grids[x] then grids[x] = {} end
	grids[x][y] = true

	return grids
end

--- Finds free grids around coords in a radius.
-- This will return a random grid, the closest possible to the epicenter
-- @param sx the epicenter coordinates
-- @param sy the epicenter coordinates
-- @param radius the radius in which to search
-- @param block true if we only consider line of sight
-- @param what a table which can have the fields Map.ACTOR, Map.OBJECT, ..., set to true. If so it will only return grids that are free of this kind of entities.
function util.findFreeGrid(sx, sy, radius, block, what)
	what = what or {}
	local grids = core.fov.circle_grids(sx, sy, radius, block)
	local gs = {}
	for x, yy in pairs(grids) do for y, _ in pairs(yy) do
		local ok = true
		for w, _ in pairs(what) do
			if game.level.map(x, y, w) then ok = false end
		end
		if game.level.map:checkEntity(x, y, game.level.map.TERRAIN, "block_move") then ok = false end
--		print("findFreeGrid", x, y, "from", sx,sy,"=>", ok)
		if ok then
			gs[#gs+1] = {x, y, math.floor(core.fov.distance(sx, sy, x, y)), rng.range(1, 1000)}
		end
	end end

	if #gs == 0 then return nil end

	table.sort(gs, function(a, b)
		if a[3] == b[3] then
			return a[4] < b[4]
		else
			return a[3] < b[3]
		end
	end)

	return gs[1][1], gs[1][2]
end

function util.showMainMenu()
	local Menu = require("special.mainmenu.class.Game")
	game = Menu.new()
	game:run()
end

function rng.mbonus(max, level, max_level)
	if level > max_level - 1 then level = max_level - 1 end

	local bonus = (max * level) / max_level
	local extra = (max * level) % max_level
	if rng.range(0, max_level - 1) < extra then bonus = bonus + 1 end

	local stand = max / 4
	extra = max % 4
	if rng.range(0, 3) < extra then stand = stand + 1 end

	local val = rng.normal(bonus, stand)
	if val < 0 then val = 0 end
	if val > max then val = max end

	return val
end

function rng.table(t)
	local id = rng.range(1, #t)
	return t[id], id
end

function rng.tableRemove(t)
	local id = rng.range(1, #t)
	return table.remove(t, id)
end

function util.show_backtrace()
	local level = 2

	print("backtrace:")
	while true do
		local stacktrace = debug.getinfo(level, "nlS")
		if stacktrace == nil then break end
		print(("    function: %s (%s) at %s:%d"):format(stacktrace.name or "???", stacktrace.what, stacktrace.source or stacktrace.short_src or "???", stacktrace.currentline))
		level = level + 1
	end
end
