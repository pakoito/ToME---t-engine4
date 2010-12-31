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
local Object = require "mod.class.Object"
local Parser = require "mod.class.info.Parser"
local lpeg = require "lpeg"

module(..., package.seeall, class.inherit(Parser))

-- Tell the parser what fields to retrieve & match
info_format =
{
	N = { "ang_id", "name", new_entity=true },
	G = { "display", "color" },
	I = { "tval", "sval", "pval", all_numbers=true },
	W = { "depth", "__", "weight", "cost", all_numbers=true },
	P = { "ac", "damage", "to_hit", "to_dam", "to_ac" },
	A = { "rarity", "min_to_max" },
	C = { "charges", all_numbers=true },
	M = { "chance of being generated in a pile", "dice for number of items" },
	E = { "effect", "recharge_time", ignore_count=true },
	F = { "flags", flags_parse="self" },
	D = { "desc", ignore_count=true, unsplit=true, concat=true },
}

function _M:callback(e)
	e.define_as = e.name:upper():gsub("[^A-Z0-9]", "_")

	local ttval = Object.tval_table[e.tval]

	e.color = colors[self.color_codes[e.color]]
	e.back_color = colors.BLACK
	e.type = ttval and ttval[1] or "misc"
	e.subtype = e.type
	if ttval then
		if ttval.slot then e.slot = ttval.slot end
		if ttval.flags then table.merge(e, ttval.flags, true) end
		if ttval.wielder then e.wielder = e.wielder or {} table.merge(e.wielder, ttval.wielder, true) end
		if ttval.random_color then e.color = colors[rng.table(table.values(color_codes))] end
		if ttval.name_gen then e.name = ttval.name_gen(e) end
	end

	e.ac = tonumber(e.ac)
	e.to_ac = tonumber(e.to_ac)
	e.to_hit = tonumber(e.to_hit)
	e.to_dam = tonumber(e.to_dam)

	if e.damage then
		local _, _, mind, maxd = e.damage:find("^(%d+)d(%d+)")
		e.damage = nil
		if mind and maxd then e.damage = {tonumber(mind), tonumber(maxd)} end
	end

	e.rarity = tonumber(e.rarity)
	if e.min_to_max then
		local _, _, min, max = e.min_to_max:find("^(%d+) to (%d+)")
		e.min_to_max = nil
		if min and max then e.level_range = {tonumber(min), tonumber(max)} end
	end
end
