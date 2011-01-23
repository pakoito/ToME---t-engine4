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

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*Before you stands a creature about as tall as a halfling, covered in small white fur and with a disproportionate head.
You also notice he does not wield its greatsword, it seems to float in the air - bound to his will.*#WHITE#
Why did you save me stranger? You are not of the Way.]],
	answers = {
		{"So I could rip your throat myself!", action=function(npc, player) npc:checkAngered(player, false, -200) end},
		{"Well, you seemed to need help.", jump="kindness"},
	}
}

newChat{ id="kindness",
	text = [[#LIGHT_GREEN#*The greatsword floats to a less aggresive stance. He seems surprised.*#WHITE#
Then, on behalf of the Way, I thank you.]],
	answers = {
		{"What is the way, and what are you?", jump="what"},
	}
}

newChat{ id="what",
	text = [[The Way is enlightenment, peace and protection. I am a Yeek, I come through this tunnel to explore this part of the world that was closed to us for centuries.]],
	answers = {
		{"Can you tell me more about the way?", jump="way", action=function(npc, player)
			player.combat_mentalresist = player.combat_mentalresist + 15
			player:attr("confusion_immune", 0.10)
			game.logPlayer(player, "The contact with the Wayist mind has improved your mental shields. (+15 mental save, +10%% confusion resistance)")
		end},
		{"So you will wander the land alone?", jump="done"},
	}
}

newChat{ id="done",
	text = [[I am never alone, I have the Way.]],
	answers = {
		{"Farewell then.", action=function(npc, player) npc:disappear() end},
	}
}

newChat{ id="way",
	text = [[I can not, but I may show you a glimpse.
#LIGHT_GREEN#*He leans toward you. Your mind is suddenly filled with feelings of peace and happiness.*#WHITE#
This is the way.]],
	answers = {
		{"Thank you for this vision. Farewell my friend.", action=function(npc, player)
			npc:disappear()
			game:setAllowedBuild("yeek", true)
		end},
	}
}

return "welcome"
