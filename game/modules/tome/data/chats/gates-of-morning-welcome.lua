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
	text = [[#LIGHT_GREEN#*Before you stands a beautiful woman clad in shining golden armour*#WHITE#
Stop! You are clearly a stranger! Where do you come from? The Gates of Morning are the last bastion of freedom in these lands, so who are you? A spy?]],
	answers = {
		{"My lady, I am indeed a stranger in those lands. I come from the west, from Maj'Eyal.", jump="from",
		  cond=function(npc, player) return not player:hasQuest("spydric-infestation") end},
		{"The spiders will not cause you any more problems, my lady.", jump="access",
		  cond=function(npc, player) return player:hasQuest("spydric-infestation") and player:hasQuest("spydric-infestation"):isCompleted() end},
		{"Sorry, I have to go!"},
	}
}

newChat{ id="from",
	text = [[Maj'Eyal! We Sun Paladins have not heard from there for thousands of years... perhaps the Anorithil know more...
In any event, what is your purpose here?]],
	answers = {
		{"It seems that I am stranded in these unfamiliar lands. #LIGHT_GREEN#*Tell her about your hunt for orcs.*#WHITE#", jump="orcs"},
		{"Sun Paladins? What do you mean? We know of no such thing where I come from.", jump="sun-paladins", cond=function() return profile.mod.allow_build.divine_sun_paladin end},
	}
}

newChat{ id="orcs",
	text = [[Orcs! Ah! Well then this is your lucky day. This whole continent is swarming with Orcs. They have united as the Orc Pride and, according to rumor, their masters are powerful.
They roam the lands freely, ever assaulting us.
@playername@, you are welcome in the Gates of Morning, should you prove to be trustworthy.
There is a cavern full of spiders just to the north. We cannot stand against both them and the Orc Pride.
Please go there and destroy the source of infestation.]],
	answers = {
		{"I will, my lady.", action=function(npc, player) player:grantQuest("spydric-infestation") end},
		{"Ahh .. if I must, I must.", action=function(npc, player) player:grantQuest("spydric-infestation") end},
	}
}

newChat{ id="sun-paladins",
	text = [[We are the mighty warriors of the Sunwall, channeling the power of the sun and merging it with martial training.
For thousands of years, we stood between the Orc Pride and the free people. Our numbers are diminishing, but we will stand firm until our last breath.]],
	answers = {
		{"You have a noble spirit, my lady.", jump="from"},
	}
}

newChat{ id="access",
	text = [[So I have heard. You have helped us enormously; consider yourself a friend of the Sunwall.
You may now enter the Gates of Morning.]],
	answers = {
		{"Thank you, my lady.", action=function(npc, player)
			world:gainAchievement("SPYDRIC_INFESTATION", game.player)
			player:setQuestStatus("spydric-infestation", engine.Quest.DONE)
			npc:move(46, 27, true)
			npc.can_talk = "gates-of-morning-main"
			game:setAllowedBuild("divine")
			game:setAllowedBuild("divine_sun_paladin", true)
		end},
	}
}

return "welcome"
