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

newChat{ id="welcome",
	text = [[Thank you, @playername@. I hate to admit it, but you saved my life.]],
	answers = {
		{"At your service. But may I ask what you were doing in this dark place?", jump="what", cond=function(npc, player) return not player:hasQuest("start-sunwall") end},
		{"At your service. I have been gone for months, but I can feel it, at last this is my homeland!", jump="back", cond=function(npc, player) return player:hasQuest("start-sunwall") end},
	}
}

newChat{ id="what",
	text = [[I am an Anorithil, a mage of the Sun and Moons; we fight all that is evil. I was with a group of Sun Paladins; we came from the Gates of Morning to the east.
My companions were... were slaughtered by orcs, and I nearly died as well. Thank you again for your help.]],
	answers = {
		{"It was my pleasure. But may I ask a favor myself? I am not from these lands. I used a farportal guarded by orcs deep below the Iron Throne and was brought here.", action=function(npc, player) game:setAllowedBuild("divine") game:setAllowedBuild("divine_anorithil", true) end, jump="sunwall"},
	}
}

newChat{ id="sunwall",
	text = [[Yes, I noticed you were not from here. Your only hope is the Gates of Morning, the last bastion of freedom in this orc territory. When you leave the caves, head southeast; you cannot miss it.
Tell High Sun Paladin Aeryn that you met me. I'll send word to let you pass.]],
	answers = {
		{"Thank you, I will talk with Aeryn.", action=function(npc, player) game.player:setQuestStatus("strange-new-world", engine.Quest.COMPLETED, "helped-fillarel") end},
	}
}

newChat{ id="back",
	text = [[Gone? Wait, this face.. you are @playername@! We thought you died in the naga portal explosion!
Thanks to your courrage the Gates of Morning still stand.
You should go there at once.]],
	answers = {
		{"Sadly I am the bringer of bad news, the orcs are planning something. Good luck, my lady."},
	}
}

return "welcome"
