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

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*Before you stands a beautiful woman clad in shining golden armour*#WHITE#
Stop! You are clearly a stranger! Where do you come from? The Gates of Morning are the last bastion of freedom in these lands, so who are you? A spy?]],
	answers = {
		{"My lady, I am indeed a stranger in these lands. I come from the west, from Maj'Eyal.", jump="from",
		  cond=function(npc, player) return player:hasQuest("strange-new-world") and player:hasQuest("strange-new-world"):isCompleted("helped-fillarel") end},
		{"Sorry, I have to go!"},
	}
}

newChat{ id="from",
	text = [[Maj'Eyal! For many years have we tried to contact your people. We always failed.
In any event, what is your purpose here?]],
	answers = {
		{"It seems that I am stranded in these unfamiliar lands. #LIGHT_GREEN#*Tell her about your hunt for orcs and your encounter with Fillarel.*#WHITE#", jump="orcs"},
		{"Sun Paladins? What do you mean? We know of no such thing where I come from.", jump="sun-paladins", cond=function() return profile.mod.allow_build.divine_sun_paladin end},
	}
}

newChat{ id="sun-paladins",
	text = [[We are the mighty warriors of the Sunwall, channeling the power of the Sun and merging it with martial training.
For hundreds of years, we stood between the Orc Pride and the free people. Our numbers are diminishing, but we will stand firm until our last breath.]],
	answers = {
		{"You have a noble spirit, my lady.", jump="from"},
	}
}

newChat{ id="orcs",
	text = [[Orcs! Ah! Well then this is your lucky day. This whole continent is swarming with Orcs. They have united as the Orc Pride and, according to rumour, their masters are powerful.
They roam the lands freely, ever assaulting us.
@playername@, you have helped one of ours. I grant you access to the Gates of Morning and name you friend of the Sunwall.]],
	answers = {
		{"Thank you, my lady.", action=function(npc, player)
			world:gainAchievement("STRANGE_NEW_WORLD", game.player)
			player:setQuestStatus("strange-new-world", engine.Quest.DONE)
			local spot = game.level:pickSpot{type="npc", subtype="aeryn-main"}
			npc:move(spot.x, spot.y, true)
			npc.can_talk = "gates-of-morning-main"
		end},
	}
}

return "welcome"
