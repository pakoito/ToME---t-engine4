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
	P = { "ac", "damage", "to_hit", "to_dam", "to_ac", all_numbers=true },
	A = { "rarity", "min_to_max" },
	C = { "charges", all_numbers=true },
	M = { "chance of being generated in a pile", "dice for number of items" },
	E = { "effect", "recharge_time", ignore_count=true },
	F = { "flags", flags_parse="self" },
	D = { "desc", ignore_count=true, unsplit=true, concat=true },
}

tval_table = {
	[1] = {"skeleton"},
	[2] = {"bottle"},
	[3] = {"junk"},
	[5] = {"spike"},
	[7] = {"chest"},
	[16] = {"shot", slot="QUIVER"},
	[17] = {"arrow", slot="QUIVER"},
	[18] = {"bolt", slot="QUIVER"},
	[19] = {"bow", slot="SHOOTER"},
	[20] = {"digging"},
	[21] = {"hafted", slot="WEAPON"},
	[22] = {"polearm", slot="WEAPON"},
	[23] = {"sword", slot="WEAPON"},
	[30] = {"boots", slot="FEET"},
	[31] = {"gloves", slot="HANDS"},
	[32] = {"helm", slot="HEAD"},
	[33] = {"crown", slot="HEAD"},
	[34] = {"shield", slot="SHIELD"},
	[35] = {"cloak", slot="CLOAK"},
	[36] = {"soft armor", slot="BODY"},
	[37] = {"hard armor", slot="BODY"},
	[38] = {"drag armor", slot="BODY"},
	[39] = {"light", slot="LITE"},
	[40] = {"amulet", slot="NECK"},
	[45] = {"ring", slot="FINGER"},
	[55] = {"staff", slot="WEAPON"},
	[65] = {"wand"},
	[66] = {"rod"},
	[70] = {"scroll"},
	[75] = {"potion"},
	[77] = {"flask"},
	[80] = {"food"},
	[90] = {"magic book"},
	[91] = {"prayer book"},
	[100] = {"gold"},
}

function _M:callback(e)
	e.define_as = e.name:upper():gsub("[^A-Z0-9]", "_")

	e.color = colors[self.color_codes[e.color]]
	e.back_color = colors.BLACK
	e.type = tval_table[e.tval] and tval_table[e.tval][1] or "misc"
	e.subtype = e.type
	if tval_table[e.tval] and tval_table[e.tval].slot then e.slot = tval_table[e.tval].slot end

	e.rarity = tonumber(e.rarity)
	if e.min_to_max then
		local _, _, min, max = e.min_to_max:find("^(%d+) to (%d+)")
		e.min_to_max = nil
		if min and max then e.level_range = {tonumber(min), tonumber(max)} end
	end
end
