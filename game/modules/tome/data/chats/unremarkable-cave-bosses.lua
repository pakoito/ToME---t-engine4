-- ToME - Tales of Maj'Eyal
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

local function attack_krogar(npc, player)
	local fillarel, krogar
	for uid, e in pairs(game.level.entities) do
		if e.define_as == "FILLAREL" and not e.dead then fillarel = e
		elseif e.define_as == "CORRUPTOR" and not e.dead then krogar = e end
	end
	krogar.faction = "enemies"
	fillarel.inc_damage = {all=-80}
	fillarel:setTarget(krogar)
	krogar:setTarget(filarel)
end

local function attack_fillarel(npc, player)
	local fillarel, krogar
	for uid, e in pairs(game.level.entities) do
		if e.define_as == "FILLAREL" and not e.dead then fillarel = e
		elseif e.define_as == "CORRUPTOR" and not e.dead then krogar = e end
	end
	fillarel.faction = "enemies"
	krogar.inc_damage = {all=-80}
	fillarel:setTarget(krogar)
	krogar:setTarget(filarel)
end

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*A beautiful elven woman in golden robes stands before you, facing an orc clad in mail.*#WHITE#
Fillarel: "Abandon this fight, orc! You cannot win: I stand with the power of the sun and the shadows of the moon."
Krogar: "Ha! It's only been one hour and you already look tired, my 'lady'."
#LIGHT_GREEN#*As you enter the room they notice you.*#WHITE#
Fillarel: "You! @playerdescriptor.race@! help me defeat this monster or be gone with you!"
Krogar: "Ah, looking for help? Bah. @playerdescriptor.race@, kill this wench for me and I shall reward you!"]],
	answers = {
		{"[attack Krogar]", action=attack_krogar},
		{"[attack Fillarel]", action=attack_fillarel},
	}
}
return "welcome"
