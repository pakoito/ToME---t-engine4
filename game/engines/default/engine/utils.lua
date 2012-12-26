-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

function math.decimals(v, nb)
	nb = 10 ^ nb
	return math.floor(v * nb) / nb
end

function lpeg.anywhere (p)
	return lpeg.P{ p + 1 * lpeg.V(1) }
end

function table.concatNice(t, sep, endsep)
	if not endsep then return table.concat(t, sep) end
	local str = ""
	for i, s in ipairs(t) do 
		if i == #t and i > 1 then str = str..endsep..s
		elseif i == 1 then str = s
		else str = str..sep..s
		end
	end
	return str
end

function table.min(t)
	local m = nil
	for _, v in pairs(t) do
		if not m then m = v
		else m = math.min(m, v)
		end
	end
	return m
end

function table.max(t)
	local m = nil
	for _, v in pairs(t) do
		if not m then m = v
		else m = math.max(m, v)
		end
	end
	return m
end

function table.print(src, offset, ret)
	offset = offset or ""
	for k, e in pairs(src) do
		-- Deep copy subtables, but not objects!
		if type(e) == "table" and not e.__CLASSNAME then
			print(("%s[%s] = {"):format(offset, tostring(k)))
			table.print(e, offset.."  ")
			print(("%s}"):format(offset))
		else
			print(("%s[%s] = %s"):format(offset, tostring(k), tostring(e)))
		end
	end
end

function table.iprint(src, offset)
	offset = offset or ""
	for k, e in ipairs(src) do
		-- Deep copy subtables, but not objects!
		if type(e) == "table" and not e.__CLASSNAME then
			print(("%s[%s] = {"):format(offset, tostring(k)))
			table.print(e, offset.."  ")
			print(("%s}"):format(offset))
		else
			print(("%s[%s] = %s"):format(offset, tostring(k), tostring(e)))
		end
	end
end

--- Generate a containing indexes between a and b and set to value v
function table.genrange(a, b, v)
	local t = {}
	for i = a, b do
		t[i] = v
	end
	return t
end

--- Return a new table containing the keys from t1 without the keys from t2
function table.minus_keys(t1, t2)
	local t = table.clone(t1)
	for k, _ in pairs(t2) do t[k] = nil end
	return t
end

--- Returns a clone of a table
-- @param tbl The original table to be cloned
-- @param deep Boolean to determine if recursive cloning occurs
-- @param k_skip A table containing key values set to true if you want to skip them.
-- @return The cloned table.
function table.clone(tbl, deep, k_skip)
	local n = {}
	k_skip = k_skip or {}
	for k, e in pairs(tbl) do
		if not k_skip[k] then
			-- Deep copy subtables, but not objects!
			if deep and type(e) == "table" and not e.__CLASSNAME then
				n[k] = table.clone(e, true, k_skip)
			else
				n[k] = e
			end
		end
	end
	return n
end

table.NIL_MERGE = {}

--- Merges two tables in-place.
-- The table.NIL_MERGE is a special value that will nil out the corresponding dst key.
-- @param dst The destination table, which will have all merged values.
-- @param src The source table, supplying values to be merged.
-- @param deep Boolean that determines if tables will be recursively merged.
-- @param k_skip A table containing key values set to true if you want to skip them.
-- @param k_skip_deep Like k_skip, except this table is passed on to the deep recursions.
-- @param addnumbers Boolean that determines if two numbers will be added rather than replaced.
function table.merge(dst, src, deep, k_skip, k_skip_deep, addnumbers)
	k_skip = k_skip or {}
	k_skip_deep = k_skip_deep or {}
	for k, e in pairs(src) do
		if not k_skip[k] and not k_skip_deep[k] then
			-- Recursively merge tables
			if deep and dst[k] and type(e) == "table" and type(dst[k]) == "table" and not e.__CLASSNAME then
				table.merge(dst[k], e, deep, nil, k_skip_deep, addnumbers)
			-- Clone tables if into the destination
			elseif deep and not dst[k] and type(e) == "table" and not e.__CLASSNAME then
				dst[k] = table.clone(e, deep, nil, k_skip_deep)
			-- Nil out any NIL_MERGE entries
			elseif e == table.NIL_MERGE then
				dst[k] = nil
			-- Add number entries if "add" is set
			elseif addnumbers and not dst.__no_merge_add and dst[k] and type(dst[k]) == "number" and type(e) == "number" then
				dst[k] = dst[k] + e
			-- Or simply replace/set with the src value
			else
				dst[k] = e
			end
		end
	end
	return dst
end

function table.mergeAppendArray(dst, src, deep, k_skip, k_skip_deep, addnumbers)
	-- Append the array part
	k_skip = k_skip or {}
	for i = 1, #src do
		k_skip[i] = true
		local b = src[i]
		if deep and type(b) == "table" then
			if b.__CLASSNAME then
				b = b:clone()
			else
				b = table.clone(b, true)
			end
		end
		table.insert(dst, b)
	end
	-- Copy the table part
	return table.merge(dst, src, deep, k_skip, k_skip_deep, addnumbers)
end

function table.mergeAdd(dst, src, deep, k_skip, k_skip_deep)
	return table.merge(dst, src, deep, k_skip, k_skip_deep, true)
end

--- Merges additively the named fields and append the array part
-- Yes this is weird and you'll probably not need it, but the engine does :)
function table.mergeAddAppendArray(dst, src, deep, k_skip, k_skip_deep)
	return table.mergeAppendArray(dst, src, deep, k_skip, k_skip_deep, true)
end

function table.append(dst, src)
	for i = 1, #src do dst[#dst+1] = src[i] end
end

function table.reverse(t)
	local tt = {}
	for i, e in ipairs(t) do tt[e] = i end
	return tt
end

function table.reversekey(t, k)
	local tt = {}
	for i, e in ipairs(t) do tt[e[k]] = i end
	return tt
end

function table.listify(t)
	local tt = {}
	for k, e in pairs(t) do tt[#tt+1] = {k, e} end
	return tt
end

function table.keys_to_values(t)
	local tt = {}
	for k, e in pairs(t) do tt[e] = k end
	return tt
end

function table.keys(t)
	local tt = {}
	for k, e in pairs(t) do tt[#tt+1] = k end
	return tt
end

function table.values(t)
	local tt = {}
	for k, e in pairs(t) do tt[#tt+1] = e end
	return tt
end

function table.from_list(t, k, v)
	local tt = {}
	for i, e in ipairs(t) do tt[e[k or 1]] = e[v or 2] end
	return tt
end

function table.removeFromList(t, ...)
	for _, v in ipairs{...} do
		for i = #t, 1, -1 do if t[i] == v then table.remove(t, i) end end
	end
end

--- Adds missing keys from the src table to the dst table.
-- @param dst The destination table, which will have all merged values.
-- @param src The source table, supplying values to be merged.
-- @param deep Boolean that determines if tables will be recursively merged.
function table.update(dst, src, deep)
	for k, e in pairs(src) do
		if deep and dst[k] and type(e) == "table" and type(dst[k]) == "table" and not e.__CLASSNAME then
			table.update(dst[k], e, deep)
		elseif deep and not dst[k] and type(e) == "table" and not e.__CLASSNAME then
			dst[k] = table.clone(e, deep)
		elseif not dst[k] and type(dst[k]) ~= "boolean" then
			dst[k] = e
		end
	end
end

--- Creates a read-only table
function table.readonly(src)
   for k, v in pairs(src) do
	if type(v) == "table" then
		src[k] = table.readonly(v)
	end
   end
   return setmetatable(src, {
	 __newindex = function(src, key, value)
					error("Attempt to modify read-only table")
				end,
	__metatable = false
   });
end

-- Taken from http://lua-users.org/wiki/SortedIteration
local function cmp_multitype(op1, op2)
	local type1, type2 = type(op1), type(op2)
	if type1 ~= type2 then --cmp by type
		return type1 < type2
	elseif type1 == "number" and type2 == "number"
	  or type1 == "string" and type2 == "string" then
		return op1 < op2 --comp by default
	elseif type1 == "boolean" and type2 == "boolean" then
		return op1 == true
	else
		return tostring(op1) < tostring(op2) --cmp by address
	end
end

local __genOrderedIndex = function(t)
	local orderedIndex = {}
	for key in pairs(t) do
		table.insert(orderedIndex, key)
	end
	table.sort(orderedIndex, cmp_multitype) --### CANGE ###
	return orderedIndex
end

local orderedNext = function(t, state)
	-- Equivalent of the next function, but returns the keys in the alphabetic
	-- order. We use a temporary ordered key table that is stored in the
	-- table being iterated.
	if state == nil then
		-- the first time, generate the index
		t.__orderedIndex = __genOrderedIndex(t)
		key = t.__orderedIndex[1]
		return key, t[key]
	end
	-- fetch the next value
	key = nil
	for i = 1,table.getn(t.__orderedIndex) do
		if t.__orderedIndex[i] == state then
			key = t.__orderedIndex[i+1]
		end
	end

	if key then
		return key, t[key]
	end

	-- no more value to return, cleanup
	t.__orderedIndex = nil
	return
end

--- An ordered iteration through a table
function table.orderedPairs(t)
	return orderedNext, t, nil
end

--- Shuffles the content of a table (list)
function table.shuffle(t)
	local n = #t
	for i = n, 2, -1 do
		local j = rng.range(1, i)
		t[i], t[j] = t[j], t[i]
	end
	return t
end

function string.ordinal(number)
	local suffix = "th"
	number = tonumber(number)
	local base = number % 10
	if base == 1 then
		suffix = "st"
	elseif base == 2 then
		suffix = "nd"
	elseif base == 3 then
		suffix = "rd"
	end
	return number..suffix
end

function string.trim(str)
	return str:gsub("^%s*(.-)%s*$", "%1")
end

function string.a_an(str)
	local first = str:sub(1, 1)
	if first == "a" or first == "e" or first == "i" or first == "o" or first == "u" or first == "y" then return "an "..str
	else return "a "..str end
end

function string.his_her(actor)
	if actor.female then return "her"
	else return "his"
	end
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

		-- Don't capitalize certain words unless they are at the beginning
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
local Pextra = "&" * lpeg.P"linebg:" * lpeg.C(lpeg.R"09"^1 + Pcolorname)
local Pcode = (lpeg.R"af" + lpeg.R"09" + lpeg.R"AF")
local Pcolorcode = Pcode * Pcode
local Pfontstyle = "{" * (lpeg.P"bold" + lpeg.P"italic" + lpeg.P"underline" + lpeg.P"normal") * "}"
local Pfontstyle_cap = "{" * lpeg.C(lpeg.P"bold" + lpeg.P"italic" + lpeg.P"underline" + lpeg.P"normal") * "}"
local Pcolorcodefull = Pcolorcode * Pcolorcode * Pcolorcode

function string.removeColorCodes(str)
	return str:lpegSub("#" * (Puid + Pcolorcodefull + Pcolorname + Pfontstyle + Pextra) * "#", "")
end

function string.removeUIDCodes(str)
	return str:lpegSub("#" * Puid * "#", "")
end

function string.splitLine(str, max_width, font)
	local space_w = font:size(" ")
	local lines = {}
	local cur_line, cur_size = "", 0
	local v
	local ls = str:split(lpeg.S"\n ")
	for i = 1, #ls do
		local v = ls[i]
		local shortv = v:lpegSub("#" * (Puid + Pcolorcodefull + Pcolorname + Pfontstyle + Pextra) * "#", "")
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
	local ls = str:split(lpeg.S"\n")
	local v
	for i = 1, #ls do
		v = ls[i]
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

function __get_uid_surface(uid, w, h)
	uid = tonumber(uid)
	local e = uid and __uids[uid]
	if e and game.level then
		return e:getEntityFinalSurface(game.level.map.tiles, w, h)
	end
	return nil
end

function __get_uid_entity(uid)
	uid = tonumber(uid)
	local e = uid and __uids[uid]
	if e and game.level then
		return e
	end
	return nil
end

local tmps = core.display.newSurface(1, 1)
getmetatable(tmps).__index.drawColorString = function(s, font, str, x, y, r, g, b, alpha_from_texture, limit_w)
	local list = str:split("#" * (Puid + Pcolorcodefull + Pcolorname + Pfontstyle + Pextra) * "#", true)
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
		local extra = lpeg.match("#" * lpeg.C(Pextra) * "#", v)
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
		elseif extra then
			--
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
	local list = str:split("#" * (Puid + Pcolorcodefull + Pcolorname + Pfontstyle + Pextra) * "#", true)
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
		local extra = lpeg.match("#" * lpeg.C(Pextra) * "#", v)
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
		elseif extra then
			--
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

local font_cache = {}
local oldNewFont = core.display.newFont

core.display.resetAllFonts = function(state)
	for font, sizes in pairs(font_cache) do for size, f in pairs(sizes) do
		f:setStyle(state)
	end end
end

core.display.newFont = function(font, size, no_cache)
	if no_cache then return oldNewFont(font, size) end
	if font_cache[font] and font_cache[font][size] then print("Using cached font", font, size) return font_cache[font][size] end
	font_cache[font] = font_cache[font] or {}
	font_cache[font][size] = oldNewFont(font, size)
	return font_cache[font][size]
end

local tmps = core.display.newFont("/data/font/Vera.ttf", 12)
local word_size_cache = {}
local fontoldsize = getmetatable(tmps).__index.size
getmetatable(tmps).__index.size = function(font, str)
	local list = str:split("#" * (Puid + Pcolorcodefull + Pcolorname + Pfontstyle + Pextra) * "#", true)
	local mw, mh = 0, 0
	local fstyle = font:getStyle()
	word_size_cache[font] = word_size_cache[font] or {}
	word_size_cache[font][fstyle] = word_size_cache[font][fstyle] or {}
	local v
	for i = 1, #list do
		v = list[i]
		local nr, ng, nb = lpeg.match("#" * lpeg.C(Pcolorcode) * lpeg.C(Pcolorcode) * lpeg.C(Pcolorcode) * "#", v)
		local col = lpeg.match("#" * lpeg.C(Pcolorname) * "#", v)
		local uid, mo = lpeg.match("#" * Puid_cap * "#", v)
		local fontstyle = lpeg.match("#" * Pfontstyle_cap * "#", v)
		local extra = lpeg.match("#" * lpeg.C(Pextra) * "#", v)
		if nr and ng and nb then
			-- Ignore
		elseif col then
			-- Ignore
		elseif uid and mo and game.level then
			uid = tonumber(uid)
			mo = tonumber(mo)
			local e = __uids[uid]
			if e then
				local surf = e:getEntityFinalSurface(game.level.map.tiles, font:lineSkip(), font:lineSkip())
				if surf then
					local w, h = surf:getSize()
					mw = mw + w
					if h > mh then mh = h end
				end
			end
		elseif fontstyle then
			font:setStyle(fontstyle)
			fstyle = fontstyle
			word_size_cache[font][fstyle] = word_size_cache[font][fstyle] or {}
		elseif extra then
			--
		else
			local w, h
			if word_size_cache[font][fstyle][v] then
				w, h = word_size_cache[font][fstyle][v][1], word_size_cache[font][fstyle][v][2]
			else
				w, h = fontoldsize(font, v)
				word_size_cache[font][fstyle][v] = {w, h}
			end
			if h > mh then mh = h end
			mw = mw + w
		end
	end
	return mw, mh
end

local virtualimages = {}
function core.display.virtualImage(path, data)
	virtualimages[path] = data
end

local oldloadimage = core.display.loadImage
function core.display.loadImage(path)
	if virtualimages[path] then return core.display.loadImageMemory(virtualimages[path]) end
	return oldloadimage(path)
end

local oldfsexists = fs.exists
function fs.exists(path)
	if virtualimages[path] then return true end
	return oldfsexists(path)
end

tstring = {}
tstring.is_tstring = true

function tstring:add(...)
	local v = {...}
	for i = 1, #v do
		self[#self+1] = v[i]
	end
	return self
end

function tstring:merge(v)
	if not v then return end
	for i = 1, #v do
		self[#self+1] = v[i]
	end
	return self
end

function tstring:countLines()
	local nb = 1
	local v
	for i = 1, #self do
		v = self[i]
		if type(v) == "boolean" then nb = nb + 1 end
	end
	return nb
end

function tstring:maxWidth(font)
	local max_w = 0
	local old_style = font:getStyle()
	local line_max = 0
	local v
	local w, h = font:size("")
	for i = 1, #self do
		v = self[i]
		if type(v) == "string" then line_max = line_max + font:size(v) + 1
	elseif type(v) == "table" then if v[1] == "uid" then line_max = line_max + h -- UID surface is same as font size
		elseif v[1] == "font" and v[2] == "bold" then font:setStyle("bold")
		elseif v[1] == "font" and v[2] == "normal" then font:setStyle("normal") end
		elseif type(v) == "boolean" then max_w = math.max(max_w, line_max) line_max = 0 end
	end
	font:setStyle(old_style)
	max_w = math.max(max_w, line_max) + 1
	return max_w
end

function tstring.from(str)
	if type(str) ~= "table" then
		return tstring{str}
	else
		return str
	end
end

--- Parse a string and return a tstring
function string.toTString(str)
	local tstr = tstring{}
	local list = str:split(("#" * (Puid + Pcolorcodefull + Pcolorname + Pfontstyle + Pextra) * "#") + lpeg.P"\n", true)
	for i = 1, #list do
		v = list[i]
		local nr, ng, nb = lpeg.match("#" * lpeg.C(Pcolorcode) * lpeg.C(Pcolorcode) * lpeg.C(Pcolorcode) * "#", v)
		local col = lpeg.match("#" * lpeg.C(Pcolorname) * "#", v)
		local uid, mo = lpeg.match("#" * Puid_cap * "#", v)
		local fontstyle = lpeg.match("#" * Pfontstyle_cap * "#", v)
		local extra = lpeg.match("#" * lpeg.C(Pextra) * "#", v)
		if nr and ng and nb then
			tstr:add({"color", nr:parseHex(), ng:parseHex(), nb:parseHex()})
		elseif col then
			tstr:add({"color", col})
		elseif uid and mo then
			tstr:add({"uid", tonumber(uid)})
		elseif fontstyle then
			tstr:add({"font", fontstyle})
		elseif extra then
			tstr:add({"extra", extra:sub(2)})
		elseif v == "\n" then
			tstr:add(true)
		else
			tstr:add(v)
		end
	end
	return tstr
end
function string:toString() return self end

--- Tablestrings degrade "peacefully" into normal formated strings
function tstring:toString()
	local ret = {}
	local v
	for i = 1, #self do
		v = self[i]
		if type(v) == "boolean" then ret[#ret+1] = "\n"
		elseif type(v) == "string" then ret[#ret+1] = v
		elseif type(v) == "table" then
			if v[1] == "color" and v[2] == "LAST" then ret[#ret+1] = "#LAST#"
			elseif v[1] == "color" and not v[3] then ret[#ret+1] = "#"..v[2].."#"
			elseif v[1] == "color" then ret[#ret+1] = ("#%02x%02x%02x#"):format(v[2], v[3], v[4]):upper()
			elseif v[1] == "font" then ret[#ret+1] = "#{"..v[2].."}#"
			elseif v[1] == "uid" then ret[#ret+1] = "#UID:"..v[2]..":0#"
			elseif v[1] == "extra" then ret[#ret+1] = "#&"..v[2].."#"
			end
		end
	end
	return table.concat(ret)
end
function tstring:toTString() return self end

--- Tablestrings can not be formated, this just returns self
function tstring:format() return self end

function tstring:splitLines(max_width, font)
	local space_w = font:size(" ")
	local ret = tstring{}
	local cur_size = 0
	local max_w = 0
	local v, tv
	for i = 1, #self do
		v = self[i]
		tv = type(v)
		if tv == "string" then
			local ls = v:split(lpeg.S"\n ", true)
			for i = 1, #ls do
				local vv = ls[i]
				if vv == "\n" then
					ret[#ret+1] = true
					max_w = math.max(max_w, cur_size)
					cur_size = 0
				else
					local w, h = fontoldsize(font, vv)
					if cur_size + w < max_width then
						cur_size = cur_size + w
						ret[#ret+1] = vv
					else
						ret[#ret+1] = true
						ret[#ret+1] = vv
						max_w = math.max(max_w, cur_size)
						cur_size = w
					end
				end
			end
		elseif tv == "table" and v[1] == "font" then
			font:setStyle(v[2])
			ret[#ret+1] = v
		elseif tv == "table" and v[1] == "extra" then
			ret[#ret+1] = v
		elseif tv == "table" and v[1] == "uid" then
			local e = __uids[v[2]]
			if e and game.level then
				local surf = e:getEntityFinalSurface(game.level.map.tiles, font:lineSkip(), font:lineSkip())
				if surf then
					local w, h = surf:getSize()
					if cur_size + w < max_width then
						cur_size = cur_size + w
						ret[#ret+1] = v
					else
						ret[#ret+1] = true
						ret[#ret+1] = v
						max_w = math.max(max_w, cur_size)
						cur_size = w
					end
				end
			end
		elseif tv == "boolean" then
			max_w = math.max(max_w, cur_size)
			cur_size = 0
			ret[#ret+1] = v
		else
			ret[#ret+1] = v
		end
	end
	max_w = math.max(max_w, cur_size)
	return ret, max_w
end

function tstring:tokenize(tokens)
	local ret = tstring{}
	local v, tv
	for i = 1, #self do
		v = self[i]
		tv = type(v)
		if tv == "string" then
			local ls = v:split(lpeg.S("\n"..tokens), true)
			for i = 1, #ls do
				local vv = ls[i]
				if vv == "\n" then
					ret[#ret+1] = true
				else
					ret[#ret+1] = vv
				end
			end
		else
			ret[#ret+1] = v
		end
	end
	return ret
end


function tstring:extractLines(keep_color)
	local rets = {}
	local ret = tstring{}
	local last_color = {"color", "WHITE"}
	local v
	for i = 1, #self do
		v = self[i]
		if type(v) == "table" and v[1] == "color" then
			last_color = v
		end
		if v == true then
			rets[#rets+1] = ret
			ret = tstring{}
			if keep_color and #rets > 0 then ret:add(last_color) end
		else
			ret[#ret+1] = v
		end
	end
	if keep_color and #rets > 0 then table.insert(ret, 1, last_color) end
	rets[#rets+1] = ret
	return rets
end

function tstring:isEmpty()
	return #self == 0
end

function tstring:makeLineTextures(max_width, font, no_split, r, g, b)
	local list = no_split and self or self:splitLines(max_width, font)
	local fh = font:lineSkip()
	local s = core.display.newSurface(max_width, fh)
	s:erase(0, 0, 0, 0)
	local texs = {}
	local w = 0
	local r, g, b = r or 255, g or 255, b or 255
	local oldr, oldg, oldb = r, g, b
	local v, tv
	for i = 1, #list do
		v = list[i]
		tv = type(v)
		if tv == "string" then
			s:drawStringBlended(font, v, w, 0, r, g, b, true)
			w = w + fontoldsize(font, v)
		elseif tv == "boolean" then
			w = 0
			local dat = {w=max_width, h=fh}
			dat._tex, dat._tex_w, dat._tex_h = s:glTexture()
			texs[#texs+1] = dat
			s:erase(0, 0, 0, 0)
		else
			if v[1] == "color" and v[2] == "LAST" then
				r, g, b = oldr, oldg, oldb
			elseif v[1] == "color" and not v[3] then
				oldr, oldg, oldb = r, g, b
				r, g, b = unpack(colors.simple(colors[v[2]] or {255,255,255}))
			elseif v[1] == "color" then
				oldr, oldg, oldb = r, g, b
				r, g, b = v[2], v[3], v[4]
			elseif v[1] == "font" then
				font:setStyle(v[2])
			elseif v[1] == "extra" then
				--
			elseif v[1] == "uid" then
				local e = __uids[v[2]]
				if e then
					local surf = e:getEntityFinalSurface(game.level.map.tiles, font:lineSkip(), font:lineSkip())
					if surf then
						local sw = surf:getSize()
						s:merge(surf, w, 0)
						w = w + sw
					end
				end
			end
		end
	end

	-- Last line
	local dat = {w=max_width, h=fh}
	dat._tex, dat._tex_w, dat._tex_h = s:glTexture()
	texs[#texs+1] = dat

	return texs
end

function tstring:drawOnSurface(s, max_width, max_lines, font, x, y, r, g, b, no_alpha, on_word)
	local list = self:splitLines(max_width, font)
	max_lines = util.bound(max_lines or #list, 1, #list)
	local fh = font:lineSkip()
	local w, h = 0, 0
	r, g, b = r or 255, g or 255, b or 255
	local oldr, oldg, oldb = r, g, b
	local v, tv
	local on_word_w, on_word_h
	for i = 1, #list do
		v = list[i]
		tv = type(v)
		if tv == "string" then
			if on_word then on_word_w, on_word_h = on_word(v, w, h) end
			if on_word_w and on_word_h then
				w, h = on_word_w, on_word_h
			else
				s:drawStringBlended(font, v, x + w, y + h, r, g, b, not no_alpha)
				w = w + fontoldsize(font, v)
			end
		elseif tv == "boolean" then
			w = 0
			h = h + fh
			max_lines = max_lines - 1
			if max_lines <= 0 then break end
		else
			if v[1] == "color" and v[2] == "LAST" then
				r, g, b = oldr, oldg, oldb
			elseif v[1] == "color" and not v[3] then
				oldr, oldg, oldb = r, g, b
				r, g, b = unpack(colors.simple(colors[v[2]] or {255,255,255}))
			elseif v[1] == "color" then
				oldr, oldg, oldb = r, g, b
				r, g, b = v[2], v[3], v[4]
			elseif v[1] == "font" then
				font:setStyle(v[2])
			elseif v[1] == "extra" then
				--
			elseif v[1] == "uid" then
				local e = __uids[v[2]]
				if e then
					local surf = e:getEntityFinalSurface(game.level.map.tiles, font:lineSkip(), font:lineSkip())
					if surf then
						local sw = surf:getSize()
						s:merge(surf, x + w, y + h)
						w = w + sw
					end
				end
			end
		end
	end
end

function tstring:diffWith(str2, on_diff)
	local res = tstring{}
	local j = 1
	for i = 1, #self do
		if type(self[i]) == "string" and self[i] ~= str2[j] then
			on_diff(self[i], str2[j], res)
		else
			res:add(self[i])
		end
		j = j + 1
	end
	return res
end

-- Make tstring into an object
local tsmeta = {__index=tstring, __tostring = tstring.toString}
setmetatable(tstring, {
	__call = function(self, t)
		setmetatable(t, tsmeta)
		return t
	end,
})

local dir_to_angle = table.readonly{
	[1] = 225,
	[2] = 270,
	[3] = 315,
	[4] = 180,
	[5] = 0,
	[6] = 0,
	[7] = 135,
	[8] = 90,
	[9] = 45,
}

local dir_to_coord = table.readonly{
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

local coord_to_dir = table.readonly{
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

local dir_sides = table.readonly{
	[1] = {hard_left=3, left=2, right=4, hard_right=7},
	[2] = {hard_left=6, left=3, right=1, hard_right=4},
	[3] = {hard_left=9, left=6, right=2, hard_right=1},
	[4] = {hard_left=2, left=1, right=7, hard_right=8},
	[5] = {hard_left=4, left=7, right=9, hard_right=6}, -- To avoid problems
	[6] = {hard_left=8, left=9, right=3, hard_right=2},
	[7] = {hard_left=1, left=4, right=8, hard_right=9},
	[8] = {hard_left=4, left=7, right=9, hard_right=6},
	[9] = {hard_left=7, left=8, right=6, hard_right=3},
}

local opposed_dir = table.readonly{
	[1] = 9,
	[2] = 8,
	[3] = 7,
	[4] = 6,
	[5] = 5,
	[6] = 4,
	[7] = 3,
	[8] = 2,
	[9] = 1,
}

local hex_dir_to_angle = table.readonly{
	[1] = 210,
	[2] = 270,
	[3] = 330,
	[4] = 180,
	[5] = 0,
	[6] = 0,
	[7] = 150,
	[8] = 90,
	[9] = 30,
}

local hex_dir_to_coord = table.readonly{
	[0] = {
		[1] = {-1, 0},
		[2] = { 0, 1},
		[3] = { 1, 0},
		[4] = {-1, 0},
		[5] = { 0, 0},
		[6] = { 1, 0},
		[7] = {-1,-1},
		[8] = { 0,-1},
		[9] = { 1,-1},
	},
	[1] = {
		[1] = {-1, 1},
		[2] = { 0, 1},
		[3] = { 1, 1},
		[4] = {-1, 0},
		[5] = { 0, 0},
		[6] = { 1, 0},
		[7] = {-1, 0},
		[8] = { 0,-1},
		[9] = { 1, 0},
	}
}

local hex_coord_to_dir = table.readonly{
	[0] = {
		[-1] = {
			[-1] = 7,
			[ 0] = 1, -- or 4
			[ 1] = 1,
		},
		[ 0] = {
			[-1] = 8,
			[ 0] = 5,
			[ 1] = 2,
		},
		[ 1] = {
			[-1] = 9,
			[ 0] = 3, -- or 6
			[ 1] = 3,
		},
	},
	[1] = {
		[-1] = {
			[-1] = 7,
			[ 0] = 7, -- or 4
			[ 1] = 1,
		},
		[ 0] = {
			[-1] = 8,
			[ 0] = 5,
			[ 1] = 2,
		},
		[ 1] = {
			[-1] = 9,
			[ 0] = 9, -- or 6
			[ 1] = 3,
		},
	}
}

local hex_dir_sides = table.readonly{
	[0] = {
		[1] = {hard_left=3, left=2, right=7, hard_right=8},
		[2] = {hard_left=9, left=3, right=1, hard_right=7},
		[3] = {hard_left=8, left=9, right=2, hard_right=1},
		[4] = {hard_left=2, left=1, right=7, hard_right=8},
		[5] = {hard_left=1, left=7, right=9, hard_right=3}, -- To avoid problems
		[6] = {hard_left=8, left=9, right=3, hard_right=2},
		[7] = {hard_left=2, left=1, right=8, hard_right=9},
		[8] = {hard_left=1, left=7, right=9, hard_right=3},
		[9] = {hard_left=7, left=8, right=3, hard_right=2},
	},
	[1] = {
		[1] = {hard_left=3, left=2, right=7, hard_right=8},
		[2] = {hard_left=9, left=3, right=1, hard_right=7},
		[3] = {hard_left=8, left=9, right=2, hard_right=1},
		[4] = {hard_left=2, left=1, right=7, hard_right=8},
		[5] = {hard_left=1, left=7, right=9, hard_right=3}, -- To avoid problems
		[6] = {hard_left=8, left=9, right=3, hard_right=2},
		[7] = {hard_left=2, left=1, right=8, hard_right=9},
		[8] = {hard_left=1, left=7, right=9, hard_right=3},
		[9] = {hard_left=7, left=8, right=3, hard_right=2},
	}
}

local hex_next_zig_zag = table.readonly{
	[1] = "zig",
	[2] = "zig",
	[3] = "zig",
	[7] = "zag",
	[8] = "zag",
	[9] = "zag",
	zag = "zig",
	zig = "zag",
}

local hex_zig_zag = table.readonly{
	[4] = {
		zig = 7,
		zag = 1,
	},
	[6] = {
		zig = 9,
		zag = 3,
	},
}

local hex_opposed_dir = table.readonly{
	[0] = {
		[1] = 9,
		[2] = 8,
		[3] = 7,
		[4] = 3,
		[5] = 5,
		[6] = 1,
		[7] = 3,
		[8] = 2,
		[9] = 1,
	},
	[1] = {
		[1] = 9,
		[2] = 8,
		[3] = 7,
		[4] = 9,
		[5] = 5,
		[6] = 7,
		[7] = 3,
		[8] = 2,
		[9] = 1,
	},
}

util = {}

function util.clipOffset(w, h, total_w, total_h, loffset_x, loffset_y, dest_area)
	w, h = math.floor(w), math.floor(h)
	total_w, total_h, loffset_x, loffset_y = math.floor(total_w), math.floor(total_h), math.floor(loffset_x), math.floor(loffset_y)
	dest_area.w , dest_area.h = math.floor(dest_area.w), math.floor(dest_area.h)
	local clip_y_start = 0
	local clip_y_end = 0
	local clip_x_start = 0
	local clip_x_end = 0
	-- if its visible then compute how much of it needs to be clipped, take centering into account
	if total_h < loffset_y then clip_y_start = loffset_y - total_h end

	-- if it ended after visible area then compute its bottom clip
	if total_h + h > loffset_y + dest_area.h then clip_y_end = total_h + h - (loffset_y + dest_area.h) end

	-- if its visible then compute how much of it needs to be clipped, take centering into account
	if total_w < loffset_x then clip_x_start = loffset_x - total_w end

	-- if it ended after visible area then compute its bottom clip
	if total_w + w > loffset_x + dest_area.w then clip_x_end = total_w + w - (loffset_x + dest_area.w) end

	if clip_x_start > w then clip_x_start = w end
	if clip_x_end < 0 then clip_x_end = 0 end
	if clip_y_start > h then clip_y_start = h end
	if clip_y_end < 0 then clip_y_end = 0 end

	return clip_x_start, clip_x_end, clip_y_start, clip_y_end
end

function util.clipTexture(texture, x, y, w, h, total_w, total_h, loffset_x, loffset_y, dest_area, r, g, b, a)
	if not texture then return 0, 0, 0, 0 end
	x, y, w, h = math.floor(x), math.floor(y), math.floor(w), math.floor(h)
	total_w, total_h, loffset_x, loffset_y = math.floor(total_w), math.floor(total_h), math.floor(loffset_x), math.floor(loffset_y)
	dest_area.w , dest_area.h = math.floor(dest_area.w), math.floor(dest_area.h)
	local clip_y_start = 0
	local clip_y_end = 0
	local clip_x_start = 0
	local clip_x_end = 0
	-- if its visible then compute how much of it needs to be clipped, take centering into account
	if total_h < loffset_y then clip_y_start = loffset_y - total_h end

	-- if it ended after visible area then compute its bottom clip
	if total_h + h > loffset_y + dest_area.h then clip_y_end = total_h + h - (loffset_y + dest_area.h) end

	-- if its visible then compute how much of it needs to be clipped, take centering into account
	if total_w < loffset_x then clip_x_start = loffset_x - total_w end

	-- if it ended after visible area then compute its bottom clip
	if total_w + w > loffset_x + dest_area.w then clip_x_end = total_w + w - (loffset_x + dest_area.w) end

	local one_by_tex_h = 1 / texture._tex_h
	local one_by_tex_w = 1 / texture._tex_w
	--talent icon
	texture._tex:toScreenPrecise(x, y, w - (clip_x_start + clip_x_end), h - (clip_y_start + clip_y_end), clip_x_start * one_by_tex_w, (w - clip_x_end) * one_by_tex_w, clip_y_start * one_by_tex_h, (h - clip_y_end) * one_by_tex_h, r, g, b, a)

	if clip_x_start > w then clip_x_start = w end
	if clip_x_end < 0 then clip_x_end = 0 end
	if clip_y_start > h then clip_y_start = h end
	if clip_y_end < 0 then clip_y_end = 0 end

	return clip_x_start, clip_x_end, clip_y_start, clip_y_end
end

local is_hex = 0
function util.hexOffset(x)
	return 0.5 * (x % 2) * is_hex
end

function util.isHex()
	return is_hex == 1
end

function util.dirToAngle(dir, sx, sy)
	return is_hex == 0 and dir_to_angle[dir] or hex_dir_to_angle[dir]
end

function util.dirToCoord(dir, sx, sy)
	return unpack(is_hex == 0 and dir_to_coord[dir] or (sx and hex_dir_to_coord[sx % 2][dir]))
end

function util.coordToDir(dx, dy, sx, sy)
	return is_hex == 0 and coord_to_dir[dx][dy] or (sx and hex_coord_to_dir[sx % 2][dx][dy])
end

function util.dirSides(dir, sx, sy)
	return is_hex == 0 and dir_sides[dir] or (sx and hex_dir_sides[sx % 2][dir])
end

function util.dirZigZag(dir, sx, sy)
	if is_hex == 0 then
		return nil
	else
		return hex_zig_zag[dir]
	end
end

function util.dirNextZigZag(dir, sx, sy)
	if is_hex == 0 then
		return nil
	else
		return hex_next_zig_zag[dir]
	end
end

function util.opposedDir(dir, sx, sy)
	return is_hex == 0 and opposed_dir[dir] or (sx and hex_opposed_dir[sx % 2][dir])
end

function util.getDir(x1, y1, x2, y2)
	local xd, yd = x1 - x2, y1 - y2
	if xd ~= 0 then xd = xd / math.abs(xd) end
	if yd ~= 0 then yd = yd / math.abs(yd) end
	return util.coordToDir(xd, yd, x2, y2), xd, yd
end

function util.primaryDirs()
	return is_hex == 0 and {2, 4, 6, 8} or {1, 2, 3, 7, 8, 9}
end

function util.adjacentDirs()
	return is_hex == 0 and {1, 2, 3, 4, 6, 7, 8, 9} or {1, 2, 3, 7, 8, 9}
end

--- A list of adjacent coordinates depending on core.fov.set_algorithm.
-- @param x x-coordinate of the source tile.
-- @param y y-coordinate of the source tile.
-- @param no_diagonals Boolean that restricts diagonal motion.
-- @param no_cardinals Boolean that restricts cardinal motion.
-- @return Array of {x, y} coordinate arrays indexed by direction from source.
function util.adjacentCoords(x, y, no_diagonals, no_cardinals)
	local coords = {}

	if is_hex == 0 then
		if not no_cardinals then
			coords[6] = {x+1, y  }
			coords[4] = {x-1, y  }
			coords[2] = {x  , y+1}
			coords[8] = {x  , y-1}
		end
		if not no_diagonals then
			coords[3] = {x+1, y+1}
			coords[9] = {x+1, y-1}
			coords[1] = {x-1, y+1}
			coords[7] = {x-1, y-1}
		end
	elseif not no_cardinals then
		for _, dir in ipairs(util.primaryDirs()) do
			coords[dir] = {util.coordAddDir(x, y, dir)}
		end
	end
	return coords
end

function util.coordAddDir(x, y, dir)
	local dx, dy = util.dirToCoord(dir, x, y)
	return x + dx, y + dy
end

function util.boundWrap(i, min, max)
	if i < min then i = max
	elseif i > max then i = min end
	return i
end

function util.bound(i, min, max)
	if min and i < min then i = min
	elseif max and i > max then i = max end
	return i
end

function util.minBound(i, min, max)
	return math.max(math.min(max, i), min)
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

function fs.reset()
	local list = fs.getSearchPath(true)
	for i, m in ipairs(list) do
		fs.umount(m.path)
	end
	print("After fs.reset")
	table.print(fs.getSearchPath(true))
end

function fs.mountAll(list)
	for i, m in ipairs(list) do
		fs.mount(m.path, "/" .. (m.mount or ""), true)
	end
end

function util.loadfilemods(file, env)
	-- Base loader
	local prev, err = loadfile(file)
	if err then error(err) end
	setfenv(prev, env)

	for i, addon in ipairs(fs.list("/mod/addons/")) do
		local fn = "/mod/addons/"..addon.."/superload/"..file
		if fs.exists(fn) then
			print("Loading mod", fn)
			local f, err = loadfile(fn)
			if err then error(err) end
			local base = prev
			setfenv(f, setmetatable({
				loadPrevious = function()
					local ok, err = pcall(base, bname)
					if not ok and err then error(err) end
				end
			}, {__index=env}))
			print("Loaded mod", f, fn)
			prev = f
		end
	end
	return prev
end

-- if these functions are ever desired elsewhere, don't be shy to make these accessible beyond utils.lua
local function deltaCoordsToReal(dx, dy, source_x, source_y)
	if util.isHex() then
		dy = dy + (math.floor(math.abs(dx) + 0.5) % 2) * (0.5 - math.floor(source_x) % 2)
		dx = dx * math.sqrt(3) / 2
	end
	return dx, dy
end

local function deltaRealToCoords(dx, dy, source_x, source_y)
	if util.isHex() then
		dx = dx < 0 and math.ceil(dx * 2 / math.sqrt(3) - 0.5) or math.floor(dx * 2 / math.sqrt(3) + 0.5)
		dy = dy - (math.floor(math.abs(dx) + 0.5) % 2) * (0.5 - math.floor(source_x) % 2)
	end
	return source_x + dx, source_y + dy
end

function core.fov.calc_wall(x, y, w, h, halflength, halfmax_spots, source_x, source_y, delta_x, delta_y, block, apply)
	apply(_, x, y)
	delta_x, delta_y = deltaCoordsToReal(delta_x, delta_y, source_x, source_y)

	local angle = math.atan2(delta_y, delta_x) + math.pi / 2

	local dx, dy = math.cos(angle) * halflength, math.sin(angle) * halflength
	local adx, ady = math.abs(dx), math.abs(dy)

	local x1, y1 = deltaRealToCoords( dx,  dy, x, y)
	local x2, y2 = deltaRealToCoords(-dx, -dy, x, y)

	local spots = 1
	local wall_block_corner = function(_, bx, by)
		if halfmax_spots and spots > halfmax_spots or math.floor(core.fov.distance(x2, y2, bx, by, true) - 0.25) > 2*halflength then return true end
		apply(_, bx, by)
		spots = spots + 1
		return block(_, bx, by)
	end

	local l = core.fov.line(x+0.5, y+0.5, x1+0.5, y1+0.5, function(_, bx, by) return true end)
	l:set_corner_block(wall_block_corner)
	-- use the correct tangent (not approximate) and round corner tie-breakers toward the player (via wiggles!)
	if adx < ady then
		l:change_step(dx/ady, dy/ady)
		if delta_y < 0 then l:wiggle(true) else l:wiggle() end
	else
		l:change_step(dx/adx, dy/adx)
		if delta_x < 0 then l:wiggle(true) else l:wiggle() end
	end
	while true do
		local lx, ly, is_corner_blocked = l:step(true)
		if not lx or is_corner_blocked or halfmax_spots and spots > halfmax_spots or math.floor(core.fov.distance(x2, y2, lx, ly, true) + 0.25) > 2*halflength then break end
		apply(_, lx, ly)
		spots = spots + 1
		if block(_, lx, ly) then break end
	end

	spots = 1
	wall_block_corner = function(_, bx, by)
		if halfmax_spots and spots > halfmax_spots or math.floor(core.fov.distance(x1, y1, bx, by, true) - 0.25) > 2*halflength then return true end
		apply(_, bx, by)
		spots = spots + 1
		return block(_, bx, by)
	end

	local l = core.fov.line(x+0.5, y+0.5, x2+0.5, y2+0.5, function(_, bx, by) return true end)
	l:set_corner_block(wall_block_corner)
	-- use the correct tangent (not approximate) and round corner tie-breakers toward the player (via wiggles!)
	if adx < ady then
		l:change_step(-dx/ady, -dy/ady)
		if delta_y < 0 then l:wiggle(true) else l:wiggle() end
	else
		l:change_step(-dx/adx, -dy/adx)
		if delta_x < 0 then l:wiggle(true) else l:wiggle() end
	end
	while true do
		local lx, ly, is_corner_blocked = l:step(true)
		if not lx or is_corner_blocked or halfmax_spots and spots > halfmax_spots or math.floor(core.fov.distance(x1, y1, lx, ly, true) + 0.25) > 2*halflength then break end
		apply(_, lx, ly)
		spots = spots + 1
		if block(_, lx, ly) then break end
	end
end

function core.fov.wall_grids(x, y, halflength, halfmax_spots, source_x, source_y, delta_x, delta_y, block)
	if not x or not y then return {} end
	local grids = {}
	core.fov.calc_wall(x, y, game.level.map.w, game.level.map.h, halflength, halfmax_spots, source_x, source_y, delta_x, delta_y,
		function(_, lx, ly)
			if type(block) == "function" then
				return block(_, lx, ly)
			elseif block and game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") then return true end
		end,
		function(_, lx, ly)
			if not grids[lx] then grids[lx] = {} end
			grids[lx][ly] = true
		end,
	nil)

	-- point of origin
	if not grids[x] then grids[x] = {} end
	grids[x][y] = true

	return grids
end

function core.fov.circle_grids(x, y, radius, block)
	if not x or not y then return {} end
	if radius == 0 then return {[x]={[y]=true}} end
	local grids = {}
	core.fov.calc_circle(x, y, game.level.map.w, game.level.map.h, radius,
		function(_, lx, ly)
			if type(block) == "function" then
				return block(_, lx, ly)
			elseif block and game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") then return true end
		end,
		function(_, lx, ly)
			if not grids[lx] then grids[lx] = {} end
			grids[lx][ly] = true
		end,
	nil)

	-- point of origin
	if not grids[x] then grids[x] = {} end
	grids[x][y] = true

	return grids
end

function core.fov.beam_grids(x, y, radius, dir, angle, block)
	if not x or not y then return {} end
	if radius == 0 then return {[x]={[y]=true}} end
	local grids = {}
	core.fov.calc_beam(x, y, game.level.map.w, game.level.map.h, radius, dir, angle,
		function(_, lx, ly)
			if type(block) == "function" then
				return block(_, lx, ly)
			elseif block and game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") then return true end
		end,
		function(_, lx, ly)
			if not grids[lx] then grids[lx] = {} end
			grids[lx][ly] = true
		end,
	nil)

	-- point of origin
	if not grids[x] then grids[x] = {} end
	grids[x][y] = true

	return grids
end

function core.fov.beam_any_angle_grids(x, y, radius, angle, source_x, source_y, delta_x, delta_y, block)
	if not x or not y then return {} end
	if radius == 0 then return {[x]={[y]=true}} end
	local grids = {}
	core.fov.calc_beam_any_angle(x, y, game.level.map.w, game.level.map.h, radius, angle, source_x, source_y, delta_x, delta_y,
		function(_, lx, ly)
			if type(block) == "function" then
				return block(_, lx, ly)
			elseif block and game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") then return true end
		end,
		function(_, lx, ly)
			if not grids[lx] then grids[lx] = {} end
			grids[lx][ly] = true
		end,
	nil)

	-- point of origin
	if not grids[x] then grids[x] = {} end
	grids[x][y] = true

	return grids
end

function core.fov.set_corner_block(l, block_corner)
	block_corner = type(block_corner) == "function" and block_corner or
		block_corner == false and function(_, x, y) return end or
		type(block_corner) == "string" and function(_, x, y) return game.level.map:checkAllEntities(x, y, what) end or
		function(_, x, y) return game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_move") and
			not game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "pass_projectile") end
	l.block = block_corner
	return block_corner
end

function core.fov.line(sx, sy, tx, ty, block, start_at_end)
	local what = type(block) == "string" and block or "block_sight"
	block = type(block) == "function" and block or
		block == false and function(_, x, y) return end or
		function(_, x, y)
			return game.level.map:checkAllEntities(x, y, what)
		end

	local line = is_hex == 0 and core.fov.line_base(sx, sy, tx, ty, game.level.map.w, game.level.map.h, start_at_end, block) or
			core.fov.hex_line_base(sx, sy, tx, ty, game.level.map.w, game.level.map.h, start_at_end, block)
	local l = {}
	l.line = line
	l.block = block
	l.set_corner_block = core.fov.set_corner_block
	local mt = {}
	mt.__index = function(t, key, ...) if t.line[key] then return t.line[key] end end
	mt.__call = function(t, ...) return t.line:step(...) end
	setmetatable(l, mt)

	return l
end

--- Sets the permissiveness of FoV based on the shape of blocked terrain
-- @param val can be any number between 0.0 and 1.0 (least permissive to most permissive) or the name of a shape: square, diamond, octagon, firstpeek.
-- val = 0.0 is equivalent to "square", and val = 1.0 is equivalent to "diamond"
-- "firstpeek" is the least permissive setting that allows @ to see r below:
-- @##
-- ..r
-- Default is "square"
function core.fov.set_permissiveness(val)
	val = type(val) == "string" and ((string.lower(val) == "default" or string.lower(val) == "square") and 0.0 or
						string.lower(val) == "diamond" and 0.5 or
						string.lower(val) == "octagon" and 1 - math.sqrt(0.5) or   --0.29289321881345247560 or
						string.lower(val) == "firstpeek" and 0.167) or
					type(tonumber(val)) == "number" and 0.5*tonumber(val)

	if type(val) ~= "number" then return end
	val = util.bound(val, 0.0, 0.5)
	core.fov.set_permissiveness_base(val)
	return 2*val
end

--- Sets the FoV vision size of the source actor (if applicable to the chosen FoV algorithm).
-- @param should be any number between 0.0 and 1.0 (smallest to largest).  Default is 1.
-- val = 1.0 will result in symmetric vision and targeting (i.e., I can see you if and only if you can see me)
--           for applicable fov algorithms ("large_ass").
function core.fov.set_actor_vision_size(val)
	val = util.bound(0.5*val, 0.0, 0.5)
	core.fov.set_actor_vision_size_base(val)
	return 2*val
end

--- Sets the algorithm used for FoV (and LoS).
-- @param val should be a string: "recursive_shadowcasting" (same as "default"), or "large_actor_recursive_shadowcasting" (same as "large_ass")
-- "large_ass" is symmetric if "actor_vision_size" is set to 1.
-- Note: Hexagonal vision shape currently only supports "recursive_shadowcasting", but all algorithms will eventually be supported in hex grids.
-- For backwards compatibility, if val is "hex" or "hexagon", then grid is changed to hex (one should instead call core.fov.set_vision_shape("hex"))
function core.fov.set_algorithm(val)
	if type(val) == "string" and (string.lower(val) == "hex" or string.lower(val) == "hexagon") then
		core.fov.set_vision_shape("hex")
		is_hex = 1
		return
	end
	val = type(val) == "string" and ((string.lower(val) == "default" or string.lower(val) == "recursive_shadowcasting") and 0 or
						(string.lower(val) == "large_ass" or string.lower(val) == "large_actor_recursive_shadowcasting") and 1) or
					type(tonumber(val)) == "number" and math.floor(util.bound(tonumber(val), 0, 1))

	core.fov.set_algorithm_base(val)
	return val
end

--- Sets the vision shape or distance metric for field of vision, talent ranges, AoEs, etc.
-- @param should be a string: circle, circle_round (same as circle), circle_floor, circle_ceil, circle_plus1, octagon, diamond, square.
-- See "src/fov/fov.h" to see how each shape calculates distance and height.
-- "circle_round" is aesthetically pleasing, "octagon" is a traditional roguelike FoV shape, and "circle_plus1" is similar to both "circle_round" and "octagon"
-- Default is "circle_round"
function core.fov.set_vision_shape(val)
	sval = type(val) == "string" and string.lower(val)
	val = sval and ((sval == "default" or sval == "circle" or sval == "circle_round") and 0 or
				sval == "circle_floor" and 1 or
				sval == "circle_ceil" and 2 or
				sval == "circle_plus1" and 3 or
				sval == "octagon" and 4 or
				sval == "diamond" and 5 or
				sval == "square" and 6 or
				(sval == "hex" or sval == "hexagon") and 7) or
			type(tonumber(val)) == "number" and tonumber(val)

	if type(val) ~= "number" then return end
	if val == 7 then  -- hex
		is_hex = 1
	else
		is_hex = 0
	end
	core.fov.set_vision_shape_base(val)
	return val
end

--- create a basic bresenham line (or hex equivalent)
line = {}
function line.new(sx, sy, tx, ty)
	return is_hex == 0 and bresenham.new(sx, sy, tx, ty) or core.fov.line(sx, sy, tx, ty, function() end, false)
end

--- Finds free grids around coords in a radius.
-- This will return a random grid, the closest possible to the epicenter
-- @param sx the epicenter coordinates
-- @param sy the epicenter coordinates
-- @param radius the radius in which to search
-- @param block true if we only consider line of sight
-- @param what a table which can have the fields Map.ACTOR, Map.OBJECT, ..., set to true. If so it will only return grids that are free of this kind of entities.
function util.findFreeGrid(sx, sy, radius, block, what)
	if not sx or not sy then return nil, nil, {} end
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
			gs[#gs+1] = {x, y, core.fov.distance(sx, sy, x, y), rng.range(1, 1000)}
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

--	print("findFreeGrid using", gs[1][1], gs[1][2])
	return gs[1][1], gs[1][2], gs
end

function util.showMainMenu(no_reboot, reboot_engine, reboot_engine_version, reboot_module, reboot_name, reboot_new, reboot_einfo)
	-- Turn based by default
	core.game.setRealtime(0)

	-- Save any remaining files
	savefile_pipe:forceWait()

	if game and type(game) == "table" and game.__session_time_played_start then
		if game.onDealloc then game:onDealloc() end
		profile:saveGenericProfile("modules_played", {name=game.__mod_info.short_name, time_played={"inc", os.time() - game.__session_time_played_start}})
	end

	-- Join threads
	if game and type(game) == "table" then game:joinThreads(30) end

	if no_reboot then
		local Module = require("engine.Module")
		local ms = Module:listModules(true)
		local mod = ms[__load_module]
		Module:instanciate(mod, __player_name, __player_new, true)
	else
		-- Tell the C engine to discard the current lua state and make a new one
		print("[MAIN] rebooting lua state: ", reboot_engine, reboot_engine_version, reboot_module, reboot_name, reboot_new)
		core.game.reboot("te4core", -1, reboot_engine or "te4", reboot_engine_version or "LATEST", reboot_module or "boot", reboot_name or "player", reboot_new, reboot_einfo or "")
	end
end

function util.lerp(a, b, x)
	return a + x * (b - a)
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
		"rundll32 url.dll,FileProtocolHandler %s",	-- Windows
		"open %s",	-- OSX
		"xdg-open %s",	-- Linux - portable way
		"gnome-open %s",  -- Linux - Gnome
		"kde-open %s",	-- Linux - Kde
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

-- Ultra weird, this is used by the C serialization code because I'm too dumb to make lua_dump() work on windows ...
function __dump_fct(f)
	return string.format("%q", string.dump(f))
end

-- Tries to load a lua module from a list, returns the first available
function require_first(...)
	local list = {...}
	for i = 1, #list do
		local ok, m = xpcall(function() return require(list[i]) end, function(...)
			local str = debug.traceback(...)
			if not str:find("No such file or directory") then print(str) end
		end)
		if ok then return m end
	end
	return nil
end

