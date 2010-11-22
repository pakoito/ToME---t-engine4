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
	N = { "class_ang_id", "name", new_entity=true },
	S = { "str", "int", "wis", "dex", "con", "cha", intable="stats", all_numbers=true },
	C = { "skill_dis", "skill_dev", "skill_sav", "skill_stl", "skill_srh", "skill_fos", "skill_thn", "skill_thb", "skill_throw", "skill_dig", intable="copy", all_numbers=true },
	X = { "xskill_dis", "xskill_dev", "xskill_sav", "xskill_stl", "xskill_srh", "xskill_fos", "xskill_thn", "xskill_thb", "xskill_throw", "xskill_dig", intable="copy", all_numbers=true },
	I = { "mhp", "exp", "sense_base", "sense_div", intable="copy", all_numbers=true },
	A = { "max_attacks", "min_weight", "att_multiply",intable="copy", all_numbers=true },
	M = { "spellbook tval", "spell-stat", "first-level", "max weight", intable="copy", all_numbers=true },
	B = { "spell number", "level", "mana", "fail", "exp", ignore_count=true, addtable="spells", },
	T = { "title", addtable="titles", },
	E = { "tval", "sval", "min", "max", ignore_count=true, addtable="starting_items", },
	F = { "class flags", flags_parse="copy" },
}

function _M:callback(e)
	e.type = "class"
	e.desc = ""
	print("callback", e.name)

	e.copy = e.copy or {}
	for i, item in ipairs(e.starting_items) do
		local nb = rng.range(tonumber(item.min) or 1, tonumber(item.max) or 1)
		for j = 1, nb do
			e.copy[#e.copy+1] = resolvers.inventory{ id=true, {type=item.tval, special=function(e)
				return e.name == item.sval or e.name == "& "..item.sval
			end} }
		end
	end
end
