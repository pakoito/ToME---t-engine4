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
	N = { "race_ang_id", "name", new_entity=true },
	S = { "str", "int", "wis", "dex", "con", "cha", intable="stats", all_numbers=true },
	R = { "skill_dis", "skill_dev", "skill_sav", "skill_stl", "skill_srh", "skill_fos", "skill_thn", "skill_thb", "skill_throw", "skill_dig", intable="copy", all_numbers=true },
	X = { "hitdie", "expbase", "infra", intable="copy", all_numbers=true },
	I = { "history", "agebase", "agemod", intable="__unused", all_numbers=true },
	H = { "hgtmale", "modhgtmale", "hgtfemale", "modhgtfemale", intable="__unused", all_numbers=true },
	W = { "wgtmale", "modwgtmale", "wgtfemale", "modwgtfemale", intable="__unused", all_numbers=true },
	F = { "racial flags", flags_parse="copy" },
	C = { "classes (numeric)" },
}

function _M:callback(e)
	e.type = "race"
	e.desc = ""
	print("callback", e.name)
end
