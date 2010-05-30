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

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*Before you stands a beautiful woman clad in massive golden armour*#WHITE#
Stop! you are obviously a stranger, where do you come from? The Gates of Morning are the last bastion of freedom in those lands, so who are you? A spy?]],
	answers = {
		{"My Lady I am indeed a stranger in those lands, more than you think. I come from the west, from middle-earth.", jump="from",
		  cond=function(npc, player) return not player:hasQuest("spydric-infestation") end},
		{"The spiders will not cause you any more problems my Lady.", jump="access",
		  cond=function(npc, player) return player:hasQuest("spydric-infestation") and player:hasQuest("spydric-infestation"):isCompleted() end},
		{"Sorry I have to go!"},
	}
}

newChat{ id="from",
	text = [[Middle-earth! We Sun Paladins have not heard from there for thousands of years, maybe the Anorithil would know more...
But anyway, what is your purpose here?]],
	answers = {
		{"It seems I am stranded on those unfamiliar lands. #LIGHT_GREEN#*Tell her about your hunt for orcs*#WHITE#", jump="orcs"},
		{"Sun Paladins? What do you mean? We know of no such thing where I come from.", jump="sun-paladins", cond=function() return profile.mod.allow_build.divine_sun_paladin end},
	}
}

newChat{ id="orcs",
	text = [[Orcs! Ah! Well then this is your lucky day, this whole continent is filled with Orcs. They have united themselves as the Orc Pride and rumours speak of some powerful masters.
They roam the lands freely, ever assaulting us.
@playername@ you are welcome to the Gates of Morning, should you prove to be trustful.
There is a cavern full of spiders just to he north, we can not stand against both them and the Orc Pride.
Please go there and destroy the source of infestation.]],
	answers = {
		{"I will my Lady.", action=function(npc, player) player:grantQuest("spydric-infestation") end},
		{"Ahh .. if I must.", action=function(npc, player) player:grantQuest("spydric-infestation") end},
	}
}

newChat{ id="sun-paladins",
	text = [[We are the armed force of the Sunwall, channeling the Sun power and merging it with martial training.
For thousands of years we stood between the Orc Pride and the free people, our numbers are disminishing but always we stand firm, until our last breath.]],
	answers = {
		{"You have noble ideals my Lady.", jump="from"},
	}
}

newChat{ id="access",
	text = [[So I have heard. You have helped us in a great way, consider yourself of friend of the Sunwall.
You may now enter the Gates of Morning.]],
	answers = {
		{"Thank you my Lady.", action=function(npc, player)
			player:setQuestStatus("spydric-infestation", engine.Quest.DONE)
			game.level:removeEntity(npc)
			game:setAllowedBuild("divine")
			game:setAllowedBuild("divine_sun_paladin", true)
		end},
	}
}

return "welcome"
