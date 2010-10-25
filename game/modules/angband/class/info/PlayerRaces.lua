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
	I = { "speed", "life", "sight", "ac", "alertness", all_numbers=true },
	W = { "level", "rarity", "_", "exp", all_numbers=true },
	B = { "method", "effect", "damage", ignore_count=true, addtable="blows", },
	S = { "spells", flags_parse="spells" },
	F = { "flags", flags_parse="self" },
	D = { "desc", ignore_count=true, unsplit=true, concat=true },

	N = { "race_ang_id", "name" },
	S = { "str", "int", "wis", "dex", "con", "chr", all_numbers=true },
	R = { "dis", "dev", "sav", "stl", "srh", "fos", "thn", "thb", "throw", "dig", all_numbers=true },
	X = { "hitdie", "expbase", "infra", all_numbers=true },
	I = { "history", "agebase", "agemod", all_numbers=true },
	H = { "hgtmale", "modhgtmale", "hgtfemale", "modhgtfemale", all_numbers=true },
	W = { "wgtmale", "modwgtmale", "wgtfemale", "modwgtfemale", all_numbers=true },
	F = { "racial flags", flags_parse="copy" },
	C = { "classes (numeric)" },
}

function _M:callback(e)
	e.type = "race"
end
