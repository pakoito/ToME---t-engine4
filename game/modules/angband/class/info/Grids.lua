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
	G = { "display", "color", "fail_parse", ignore_count=true },
	M = { "mimic", all_numbers=true },
	P = { "minimap_priority", all_numbers=true },
	F = { "flags", flags_parse="self" },
	X = { "lockedness", "jammedness", "shop_number", "digging", all_numbers=true },
	E = { "effect" },
}

function _M:callback(e)
	-- Terrible
	if e.fail_parse then e.display = ":" e.color = e.fail_parse e.fail_parse = nil end

	e.define_as = e.name:upper():gsub("[^A-Z0-9]", "_")
	e.color = colors[self.color_codes[e.color]]
	if not e.ppass then
		e.does_block_move = true
		e.block_sight = true
	end
	if e.door then e.door_opened = "OPEN_DOOR" end
end
