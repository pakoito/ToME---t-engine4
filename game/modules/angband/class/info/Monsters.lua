-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
	I = { "speed", "max_life", "sight", "ac", "alertness", all_numbers=true },
	W = { "level", "rarity", "_", "exp_worth", all_numbers=true },
	B = { "method", "effect", "damage", ignore_count=true, addtable="blows", },
	S = { "spells", flags_parse="spells" },
	F = { "flags", flags_parse="self" },
	D = { "desc", ignore_count=true, unsplit=true, concat=true },
}

function _M:callback(e)
	if e.name == "<player>" then return end

	e.define_as = e.name:upper():gsub("[^A-Z0-9]", "_")
	if not e.unique then
		e[#e+1] = resolvers.generic(function(e)
			local std_dev = (((e.max_life * 10) / 8) + 5) / 10
			if e.max_life > 1 then std_dev = std_dev + 1 end
			e.max_life = rng.normal(e.max_life, std_dev)
		end)
	end
	e.color = colors[self.color_codes[e.color]]
	e.back_color = colors.BLACK
	e.level_range = {e.level, e.level}
	e.speed = (e.speed or 110) - 110
	if e.blows then
		for i = 1, #e.blows do
			if e.blows[i].damage then
				local s = e.blows[i].damage:split("d")
				e.blows[i].damage = {tonumber(s[1]), tonumber(s[2])}
			else e.blows[i].damage = {0, 0} end
		end
	end

	e.ai = "angband"
end
