-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

local function kill(npc, player)
	player:setQuestStatus("high-peak", engine.Quest.COMPLETED, "killed-aeryn")
	npc.die = nil
	mod.class.NPC.die(npc, player)
end

local function spare(npc, player)
	player:setQuestStatus("high-peak", engine.Quest.COMPLETED, "spared-aeryn")
	npc.die = nil
	game.level:removeEntity(npc)
	game.logPlayer(player, "%s grabs her amulet and disappears in a whirl of arcane energies.", npc.name:capitalize())
end

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*She lies nearly dead at your feet*#WHITE#
So, now you will kill me and complete the cycle of destruction?]],
	answers = {
		{"What are you talking about? Why did you attack me?", jump="what"},
		{"Speak and I might spare you. Why did you attack me?", jump="what"},
		{"[kill her]", action=kill},
	}
}

newChat{ id="what",
	text = [[You.. you do not know?
A few hours after you entered this place a raid of orcs fell upon us. They were not alone -- demons walked among them. We were overwhelmed! Utterly destroyed!
My land is no more! All because you could not stop them at the Charred Scar! You failed us! People died to protect you, and you failed!
#LIGHT_GREEN#*She starts to weep...*#WHITE#]],
	answers = {
		{"I know my mistakes and I intend to correct them. Please let me pass. I cannot save your people, but I can make their deaths mean something!", action=spare},
		{"[kill her]", action=kill},
	}
}

return "welcome"
