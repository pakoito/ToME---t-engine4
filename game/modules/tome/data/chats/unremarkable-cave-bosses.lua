-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
	fillarel.inc_damage.all = -80
	fillarel:setTarget(krogar)
	krogar:setTarget(filarel)
	game.player:setQuestStatus("strange-new-world", engine.Quest.COMPLETED, "sided-fillarel")
end

local function attack_fillarel(npc, player)
	local fillarel, krogar
	for uid, e in pairs(game.level.entities) do
		if e.define_as == "FILLAREL" and not e.dead then fillarel = e
		elseif e.define_as == "CORRUPTOR" and not e.dead then krogar = e end
	end
	fillarel.faction = "enemies"
	krogar.inc_damage.all = -80
	fillarel:setTarget(krogar)
	krogar:setTarget(filarel)
	game.player:setQuestStatus("strange-new-world", engine.Quest.COMPLETED, "sided-krogar")
end

game.player:grantQuest("strange-new-world")

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*A beautiful Elven woman in golden robes stands before you, facing an orc clad in mail.*#WHITE#
Fillarel: "Abandon this fight, orc! You cannot win: I stand with the power of the Sun and the shadows of the Moons."
Krogar: "Ha! It's only been one hour and you already look tired, my 'lady'."
#LIGHT_GREEN#*As you enter the room they notice you.*#WHITE#
Fillarel: "You! @playerdescriptor.race@! Help me defeat this monster or begone!"
Krogar: "Ah, looking for help? Bah. @playerdescriptor.race@, kill this wench for me and I shall reward you!"]],
	answers = {
		{"[attack Krogar]", action=attack_krogar},
--		{"[attack Fillarel]", action=attack_fillarel, cond=function(npc, player) return not player:hasQuest("start-sunwall") and config.settings.cheat end},
	}
}
return "welcome"
