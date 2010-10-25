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
	W = { "depth", "rarity", "weight", "cost", all_numbers=true },
	P = { "ac", "damage", "to_hit", "to_dam", "to_ac", all_numbers=true },
	A = { "commonness", "min_to_max", all_numbers=true },
	C = { "charges", all_numbers=true },
	M = { "chance of being generated in a pile", "dice for number of items" },
	E = { "effect", "recharge_time", ignore_count=true },
	F = { "flags", flags_parse="self" },
	D = { "desc", ignore_count=true, unsplit=true, concat=true },
}

tval_table = {
	[1] = "skeleton",
	[2] = "bottle",
	[3] = "junk",
	[5] = "spike",
	[7] = "chest",
	[16] = "shot",
	[17] = "arrow",
	[18] = "bolt",
	[19] = "bow",
	[20] = "digging",
	[21] = "hafted",
	[22] = "polearm",
	[23] = "sword",
	[30] = "boots",
	[31] = "gloves",
	[32] = "helm",
	[33] = "crown",
	[34] = "shield",
	[35] = "cloak",
	[36] = "soft armor",
	[37] = "hard armor",
	[38] = "drag armor",
	[39] = "light",
	[40] = "amulet",
	[45] = "ring",
	[55] = "staff",
	[65] = "wand",
	[66] = "rod",
	[70] = "scroll",
	[75] = "potion",
	[77] = "flask",
	[80] = "food",
	[90] = "magic book",
	[91] = "prayer book",
	[100] = "gold",
}

function _M:callback(e)
	e.define_as = e.name:upper():gsub("[^A-Z0-9]", "_")

	e.color = colors[self.color_codes[e.color]]
	e.commonness = tonumber(e.commonness)
	e.type = tval_table[e.tval] or "misc"
	e.subtype = e.type
end
