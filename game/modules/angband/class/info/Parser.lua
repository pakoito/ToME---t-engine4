-- ToME - Tales of Middle-Earth
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

require "engine.class"

module(..., package.seeall, class.make)

color_codes = {
	D = "DARK_GREY",
	w = "WHITE",
	s = "SLATE",
	o = "ORANGE",
	r = "RED",
	g = "GREEN",
	b = "BLUE",
	u = "UMBER",
	d = "BLACK",
	W = "LIGHT_GRAY",
	v = "VIOLET",
	y = "YELLOW",
	R = "LIGHT_RED",
	G = "LIGHT_GREEN",
	B = "LIGHT_BLUE",
	U = "LIGHT_UMBER",
}

local doubledot = lpeg.P":"
local dash = lpeg.P"#"

function _M:parse(file)
	local first = true
	local old_e = {}
	local e = {}
	local ret = {}

	local f = fs.open(file, "r")
	local line_nb = 0
	while true do
		local l = f:readLine()
		line_nb = line_nb + 1
		if not l then break end

		old_e = e
		e = self:parseLine(l, line_nb, ret, e)
		if old_e ~= e then if first then first = false else self:callback(old_e) end end
	end
	f:close()

	if old_e ~= e then self:callback(old_e) end

	return ret
end

function _M:parseLine(l, line_nb, ret, e)
	if #l == 0 then return e end
	if lpeg.match(dash, l) then return e end
	local data = l:split(doubledot)
	if not data or not data[1] or not self.info_format[data[1]] then return e end
	local linfo = self.info_format[data[1]]

	if not linfo.ignore_count then assert(#linfo == #data - 1, "Wrong number of fields to match definition of "..data[1].." on line "..line_nb.." ("..(#linfo).." != "..(#data-1)..")") end

	if linfo.new_entity then ret[#ret+1] = e; e = {} end

	if linfo.addtable then
		e[linfo.addtable] = e[linfo.addtable] or {}
		table.insert(e[linfo.addtable], {})
	elseif linfo.intable then
		e[linfo.intable] = e[linfo.intable] or {}
	end

	do
		local e = (linfo.addtable) and e[linfo.addtable][#e[linfo.addtable]] or ((linfo.intable) and e[linfo.intable] or e)
		if linfo.unsplit then
			table.remove(data, 1)
			if linfo.concat then e[linfo[1]] = (e[linfo[1]] or "")..table.concat(data, ":")
			else e[linfo[1]] = table.concat(data, ":") end
		elseif linfo.flags_parse then
			local f
			if linfo.flags_parse ~= "self" then e[linfo.flags_parse] = e[linfo.flags_parse] or {} f = e[linfo.flags_parse] else f = e end
			self:parseFlags(f, data[2])
		else
			for i = 2, #data do
				local v = data[i]
				if linfo.all_numbers then v = tonumber(v) end
				if linfo.concat then e[linfo[i-1]] = (e[linfo[i-1]] or "")..v
				else e[linfo[i-1]] = v end
			end
		end
	end

	return e
end

function _M:parseFlags(f, flags)
	local data = flags:split(lpeg.S"| ")
	for i = 1, #data do
		if data[i] ~= "" then
			f[data[i]:lower()] = true
		end
	end
end

function _M:callback(e)
end
