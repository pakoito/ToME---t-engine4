-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

-----------------------------------------------------------
-- Non-yeek version
-----------------------------------------------------------

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*Before you stands a creature about as tall as a Halfling, covered in small white fur and with a disproportionate head.
You also notice he does not wield his greatsword. It seems to float in the air, bound to his will.*#WHITE#
Why did you save me, stranger? You are not of the Way.]],
	answers = {
		{"So I could rip your throat myself!", action=function(npc, player) npc:checkAngered(player, false, -200) end},
		{"Well, you seemed to need help.", jump="kindness"},
	}
}

newChat{ id="kindness",
	text = [[#LIGHT_GREEN#*The greatsword floats to a less aggressive stance. He seems surprised.*#WHITE#
Then, on behalf of the Way, I thank you.]],
	answers = {
		{"What is the Way, and what are you?", jump="what"},
	}
}

newChat{ id="what",
	text = [[The Way is enlightenment, peace and protection. I am a Yeek. I came through this tunnel to explore this part of the world that was closed to us for centuries.]],
	answers = {
		{"Can you tell me more about the Way?", jump="way", action=function(npc, player)
			game.party:reward("Select the party member to receive the mental shield:", function(player)
				player.combat_mentalresist = player.combat_mentalresist + 15
				player:attr("confusion_immune", 0.10)
			end)
			game.logPlayer(player, "The contact with the Wayist mind has improved your mental shields. (+15 mental save, +10%% confusion resistance)")
		end},
--		{"So you will wander the land alone?", jump="done"},
	}
}

newChat{ id="done",
	text = [[I am never alone. I have the Way.]],
	answers = {
		{"Farewell, then.", action=function(npc, player) npc:disappear() end},
	}
}

newChat{ id="way",
	text = [[I cannot, but I may show you a glimpse.
#LIGHT_GREEN#*He leans toward you. Your mind is suddenly filled with feelings of peace and happiness.*#WHITE#
This is the Way.]],
	answers = {
		{"Thank you for this vision. Farewell, my friend.", action=function(npc, player)
			npc:disappear()
			game:setAllowedBuild("yeek", true)
		end},
	}
}

-----------------------------------------------------------
-- Yeek version
-----------------------------------------------------------

newChat{ id="yeek-welcome",
	text = [[Thank the Way. This... thing... would have killed me.]],
	answers = {
		{"The Way sent me to explore this side of the tunnel.", jump="explore"},
	}
}

newChat{ id="explore",
	text = [[Yes, me too. We should split up to cover more ground.]],
	answers = {
		{"Farewell. We are the Way, always.", action=function()
			game:setAllowedBuild("psionic")
			game:setAllowedBuild("psionic_mindslayer", true)
		end},
	}
}

return (game.party:findMember{main=true}.descriptor.race == "Yeek") and "yeek-welcome" or "welcome"
