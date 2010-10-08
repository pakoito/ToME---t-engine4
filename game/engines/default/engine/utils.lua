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

--- Merges additively the named fields and append the array part
-- Yes this is weird and you'll probably not need it, but the engine does :)
function table.mergeAddAppendArray(dst, src, deep)
	-- Append the array part
	for i = 1, #src do
		local b = src[i]
		if deep and type(b) == "table" and not b.__CLASSNAME then b = table.clone(b, true)
		elseif deep and type(b) == "table" and b.__CLASSNAME then b = b:clone()
		end
		table.insert(dst, b)
	end

	-- Copy the table part
	for k, e in pairs(src) do
		if type(k) ~= "number" then
			if deep and dst[k] and type(e) == "table" and type(dst[k]) == "table" and not e.__CLASSNAME then
				-- WARNING we do not recurse on ourself but instead of the simple mergeAdd, we do not want to do the array stuff for subtables
				-- yes I warned you this is weird
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
end

function table.append(dst, src)
	for i = 1, #src do dst[#dst+1] = src[i] end
end

function table.reverse(t)
	local tt = {}
	for i, e in ipairs(t) do tt[e] = i end
	return tt
end

function table.listify(t)
	local tt = {}
	for k, e in pairs(t) do tt[#tt+1] = {k, e} end
	return tt
end

function table.update(dst, src, deep)
	for k, e in pairs(src) do
		if deep and dst[k] and type(e) == "table" and type(dst[k]) == "table" and not e.__CLASSNAME then
			table.update(dst[k], e, true)
		elseif deep and not dst[k] and type(e) == "table" and not e.__CLASSNAME then
			dst[k] = table.clone(e, true)
		elseif not dst[k] then
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

function string.lpegSub(s, patt, repl)
	patt = lpeg.P(patt)
	patt = lpeg.Cs((patt / repl + 1)^0)
	return lpeg.match(patt, s)
end

-- Those matching patterns are used both by splitLine and drawColorString*
local Puid = "UID:" * lpeg.R"09"^1 * ":" * lpeg.R"09"
local Puid_cap = "UID:" * lpeg.C(lpeg.R"09"^1) * ":" * lpeg.C(lpeg.R"09")
local Pcolorname = (lpeg.R"AZ" + "_")^3
local Pcode = (lpeg.R"af" + lpeg.R"09" + lpeg.R"AF")
local Pcolorcode = Pcode * Pcode
local Pfontstyle = "{" * (lpeg.P"bold" + lpeg.P"italic" + lpeg.P"underline" + lpeg.P"normal") * "}"
local Pfontstyle_cap = "{" * lpeg.C(lpeg.P"bold" + lpeg.P"italic" + lpeg.P"underline" + lpeg.P"normal") * "}"
local Pcolorcodefull = Pcolorcode * Pcolorcode * Pcolorcode

function string.removeColorCodes(str)
	return str:lpegSub("#" * (Puid + Pcolorcodefull + Pcolorname + Pfontstyle) * "#", "")
end

function string.splitLine(str, max_width, font)
	local space_w = font:size(" ")
	local lines = {}
	local cur_line, cur_size = "", 0
	for _, v in ipairs(str:split(lpeg.S"\n ")) do
		local shortv = v:lpegSub("#" * (Puid + Pcolorcodefull + Pcolorname + Pfontstyle) * "#", "")
		local w, h = font:size(shortv)

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
	str = str:lower()
	for i = 1, #str do
		res = res + power * (hex_to_dec[str:sub(#str-i+1,#str-i+1)] or 0)
		power = power * 16
	end
	hexcache[str] = res
	return res
end

local tmps = core.display.newSurface(1, 1)
getmetatable(tmps).__index.drawColorString = function(s, font, str, x, y, r, g, b, alpha_from_texture, limit_w)
	local list = str:split("#" * (Puid + Pcolorcodefull + Pcolorname + Pfontstyle) * "#", true)
	r = r or 255
	g = g or 255
	b = b or 255
	limit_w = limit_w or 99999999
	local oldr, oldg, oldb = r, g, b
	local max_h = 0
	local sw = 0
	local bx, by = x, y
	for i, v in ipairs(list) do
		local nr, ng, nb = lpeg.match("#" * lpeg.C(Pcolorcode) * lpeg.C(Pcolorcode) * lpeg.C(Pcolorcode) * "#", v)
		local col = lpeg.match("#" * lpeg.C(Pcolorname) * "#", v)
		local uid, mo = lpeg.match("#" * Puid_cap * "#", v)
		local fontstyle = lpeg.match("#" * Pfontstyle_cap * "#", v)
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
		elseif uid and mo and game.level then
			uid = tonumber(uid)
			mo = tonumber(mo)
			local e = __uids[uid]
			if e then
				local surf = e:getEntityFinalSurface(game.level.map.tiles, font:lineSkip(), font:lineSkip())
				if surf then
					local w, h = surf:getSize()
					if sw + w > limit_w then break end
					s:merge(surf, x, y)
					if h > max_h then max_h = h end
					x = x + (w or 0)
					sw = sw + (w or 0)
				end
			end
		elseif fontstyle then
			font:setStyle(fontstyle)
		else
			local w, h = font:size(v)
			local stop = false
			while sw + w > limit_w do
				v = v:sub(1, #v - 1)
				if #v == 0 then break end
				w, h = font:size(v)
				stop = true
			end
			if h > max_h then max_h = h end
			s:drawStringBlended(font, v, x, y, r, g, b, alpha_from_texture)
			x = x + w
			sw = sw + w
			if stop then break end
		end
	end
	return r, g, b, sw, max_h, bx, by
end

getmetatable(tmps).__index.drawColorStringCentered = function(s, font, str, dx, dy, dw, dh, r, g, b, alpha_from_texture, limit_w)
	local w, h = font:size(str)
	local x, y = dx + (dw - w) / 2, dy + (dh - h) / 2
	s:drawColorString(font, str, x, y, r, g, b, alpha_from_texture, limit_w)
end


getmetatable(tmps).__index.drawColorStringBlended = function(s, font, str, x, y, r, g, b, alpha_from_texture, limit_w)
	local list = str:split("#" * (Puid + Pcolorcodefull + Pcolorname + Pfontstyle) * "#", true)
	r = r or 255
	g = g or 255
	b = b or 255
	limit_w = limit_w or 99999999
	local oldr, oldg, oldb = r, g, b
	local max_h = 0
	local sw = 0
	local bx, by = x, y
	for i, v in ipairs(list) do
		local nr, ng, nb = lpeg.match("#" * lpeg.C(Pcolorcode) * lpeg.C(Pcolorcode) * lpeg.C(Pcolorcode) * "#", v)
		local col = lpeg.match("#" * lpeg.C(Pcolorname) * "#", v)
		local uid, mo = lpeg.match("#" * Puid_cap * "#", v)
		local fontstyle = lpeg.match("#" * Pfontstyle_cap * "#", v)
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
		elseif uid and mo and game.level then
			uid = tonumber(uid)
			mo = tonumber(mo)
			local e = __uids[uid]
			if e then
				local surf = e:getEntityFinalSurface(game.level.map.tiles, font:lineSkip(), font:lineSkip())
				if surf then
					local w, h = surf:getSize()
					if sw + (w or 0) > limit_w then break end
					s:merge(surf, x, y)
					if h > max_h then max_h = h end
					x = x + (w or 0)
					sw = sw + (w or 0)
				end
			end
		elseif fontstyle then
			font:setStyle(fontstyle)
		else
			local w, h = font:size(v)
			local stop = false
			while sw + w > limit_w do
				v = v:sub(1, #v - 1)
				if #v == 0 then break end
				w, h = font:size(v)
				stop = true
			end
			if h > max_h then max_h = h end
			s:drawStringBlended(font, v, x, y, r, g, b, alpha_from_texture)
			x = x + w
			sw = sw + w
			if stop then break end
		end
	end
	return r, g, b, sw, max_h, bx, by
end

getmetatable(tmps).__index.drawColorStringBlendedCentered = function(s, font, str, dx, dy, dw, dh, r, g, b, alpha_from_texture, limit_w)
	local w, h = font:size(str)
	local x, y = dx + (dw - w) / 2, dy + (dh - h) / 2
	s:drawColorStringBlended(font, str, x, y, r, g, b, alpha_from_texture, limit_w)
end

local tmps = core.display.newFont("/data/font/Vera.ttf", 12)
local fontoldsize = getmetatable(tmps).__index.size
getmetatable(tmps).__index.size = function(font, str)
	local list = str:split("#" * (Puid + Pcolorcodefull + Pcolorname + Pfontstyle) * "#", true)
	local mw, mh = 0, 0
	for i, v in ipairs(list) do
		local nr, ng, nb = lpeg.match("#" * lpeg.C(Pcolorcode) * lpeg.C(Pcolorcode) * lpeg.C(Pcolorcode) * "#", v)
		local col = lpeg.match("#" * lpeg.C(Pcolorname) * "#", v)
		local uid, mo = lpeg.match("#" * Puid_cap * "#", v)
		local fontstyle = lpeg.match("#" * Pfontstyle_cap * "#", v)
		if nr and ng and nb then
			-- Ignore
		elseif col then
			-- Ignore
		elseif uid and mo and game.level then
			-- Ignore
		elseif fontstyle then
			font:setStyle(fontstyle)
		else
			local w, h = fontoldsize(font, v)
			if h > mh then mh = h end
			mw = mw + w
		end
	end
	return mw, mh
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
	if radius == 0 then return {[x]={[y]=true}} end
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
	if radius == 0 then return {[x]={[y]=true}} end
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
		if not game.level.map:isBound(x, y) then ok = false end
		for w, _ in pairs(what) do
--			print("findFreeGrid test", x, y, w, ":=>", game.level.map(x, y, w))
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

	print("findFreeGrid using", gs[1][1], gs[1][2])
	return gs[1][1], gs[1][2]
end

function util.showMainMenu(no_reboot, reboot_engine, reboot_engine_version, reboot_module, reboot_name, reboot_new)
	-- Turn based by default
	core.game.setRealtime(0)

	-- Save any remaining files
	savefile_pipe:forceWait()

	if game and type(game) == "table" and game.__session_time_played_start then
		profile.generic.modules_played = profile.generic.modules_played or {}
		profile.generic.modules_played[game.__mod_info.short_name] = (profile.generic.modules_played[game.__mod_info.short_name] or 0) + (os.time() - game.__session_time_played_start)
		profile:saveGenericProfile("modules_played", profile.generic.modules_played)
	end

	-- Join threads
	if game and type(game) == "table" then game:joinThreads(30) end

	if no_reboot then
		local Module = require("engine.Module")
		local ms = Module:listModules()
		local mod = ms[__load_module]
		Module:instanciate(mod, __player_name, __player_new, true)
	else
		-- Tell the C engine to discard the current lua state and make a new one
		print("[MAIN] rebooting lua state: ", reboot_engine, reboot_engine_version, reboot_module, reboot_name, reboot_new)
		core.game.reboot(reboot_engine or "te4", reboot_engine_version or "LATEST", reboot_module or "boot", reboot_name or "player", reboot_new)
	end
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

function rng.tableIndex(t, ignore)
	local rt = {}
	if not ignore then ignore = {} end
	for k, e in pairs(t) do if not ignore[k] then rt[#rt+1] = k end end
	return rng.table(rt)
end

function util.factorial(n)
	if n == 0 then
		return 1
	else
		return n * util.factorial(n - 1)
	end
end

function rng.poissonProcess(k, turn_scale, rate)
	return math.exp(-rate*turn_scale) * ((rate*turn_scale) ^ k)/ util.factorial(k)
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

function util.uuid()
	local x = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'}
	local y = {'8', '9', 'a', 'b'}
	local tpl = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
	local uuid = tpl:gsub("[xy]", function(c) if c=='y' then return rng.table(y) else return rng.table(x) end end)
	return uuid
end

function util.browserOpenUrl(url)
	local tries = {
		"rundll32 url.dll,FileProtocolHandler %s",  -- Windows
		"open %s",  -- OSX
		"xdg-open %s",  -- Linux - portable way
		"gnome-open %s",  -- Linux - Gnome
		"kde-open %s",  -- Linux - Kde
		"firefox %s",  -- Linux - try to find something
		"mozilla-firefox %s",  -- Linux - try to find something
	}
	while #tries > 0 do
		local urlbase = table.remove(tries, 1)
		urlbase = urlbase:format(url)
		print("Trying to run URL with command: ", urlbase)
		if os.execute(urlbase) == 0 then return true end
	end
	return false
end
