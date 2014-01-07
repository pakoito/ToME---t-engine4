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
	text = [[What may I do for you?]],
	answers = {
		{"Lady Aeryn, at last I am back home! [tell her your story]", jump="return", cond=function(npc, player) return player:hasQuest("start-sunwall") and player:isQuestStatus("start-sunwall", engine.Quest.COMPLETED, "slazish") and not player:isQuestStatus("start-sunwall", engine.Quest.COMPLETED, "return") end, action=function(npc, player) player:setQuestStatus("start-sunwall", engine.Quest.COMPLETED, "return") end},
		{"Tell me more about the Gates of Morning.", jump="explain-gates", cond=function(npc, player) return player.faction ~= "sunwall" end},
		{"Before I came here, I happened upon members of the Sunwall in Maj'Eyal. Do you know of this?.", jump="sunwall_west", cond=function(npc, player) return game.state.found_sunwall_west and not npc.been_asked_sunwall_west end, action=function(npc, player) npc.been_asked_sunwall_west = true end},
		{"I need help in my hunt for clues about the staff.", jump="clues", cond=function(npc, player) return game.state:isAdvanced() and not player:hasQuest("orc-pride") end},
		{"I have destroyed the leaders of all the Orc Prides.", jump="prides-dead", cond=function(npc, player) return player:isQuestStatus("orc-pride", engine.Quest.COMPLETED) end},
		{"I am back from the Charred Scar, where the orcs took the staff.", jump="charred-scar", cond=function(npc, player) return player:hasQuest("charred-scar") and player:hasQuest("charred-scar"):isCompleted() end},
		{"A dying paladin gave me this map; something about orc breeding pits. [tell her the story]", jump="orc-breeding-pits", cond=function(npc, player) return player:hasQuest("orc-breeding-pits") and player:isQuestStatus("orc-breeding-pits", engine.Quest.COMPLETED, "wuss-out") and not player:isQuestStatus("orc-breeding-pits", engine.Quest.COMPLETED, "wuss-out-done") end},
		{"Sorry, I have to go!"},
	}
}

newChat{ id="return",
	text = [[@playername@! We thought you had died in the portal explosion. I am glad we were wrong. You saved the Sunwall.
The news about the staff is troubling. Ah well, please at least take time to rest for a while.]],
	answers = {
		{"I shall, thank you, my lady.", jump="welcome"},
	},
}

newChat{ id="explain-gates",
	text = [[There are two main groups in the population here, Humans and Elves.
Humans came here in the Age of Pyre. Our ancestors were part of a Mardrop expedition to find what had happened to the Naloren lands that sunk under the sea. Their ship was wrecked and the survivors landed on this continent.
They came across a group of elves, seemingly native to those lands, and befriended them - founding the Sunwall and the Gates of Morning.
Then the orc pride came and we have been fighting for our survival ever since.]],
	answers = {
		{"Thank you, my lady.", jump="welcome"},
	},
}

newChat{ id="sunwall_west",
	text = [[Ahh, so they survived? That is good news...]],
	answers = {
		{"Go on.", jump="sunwall_west2"},
		{"Well, actually...", jump="sunwall_west2", cond=function(npc, player) return game.state.found_sunwall_west_died end},
	},
}

newChat{ id="sunwall_west2",
	text = [[The people you saw are likely the volunteers of Zemekkys' early experiments regarding the farportals.
He is a mage who resides here in the Sunwall, eccentric but skilled, who believes that creation of a new farportal to Maj'Eyal is possible.
Aside from a few early attempts with questionable results, he hasn't had much luck. Still, it's gladdening to hear that the volunteers for his experiments live, regardless of their location. We are all still under the same Sun, after all.

Actually... maybe it would benefit you if you meet Zemekkys. He would surely be intrigued by that Orb of Many Ways you possess. He lives in a small house just to the north.]],
	answers = {
		{"Maybe I'll visit him. Thank you.", jump="welcome"},
	},
}

newChat{ id="prides-dead",
	text = [[The news has indeed reached me. I could scarce believe it, so long have we been at war with the Pride.
Now they are dead? At the hands of just one @playerdescriptor.race@? Truly I am amazed by your power.
While you were busy bringing an end to the orcs, we managed to discover some parts of the truth from a captive orc.
He talked about the shield protecting the High Peak. It seems to be controlled by "orbs of command" which the masters of the Prides had in their possession.
Look for them if you have not yet found them.
He also said the only way to enter the peak and de-activate the shield is through the "slime tunnels", located somewhere in one of the Prides, probably Grushnak.
]],
	answers = {
		{"Thanks, my lady. I will look for the tunnel and venture inside the Peak.", action=function(npc, player)
			player:setQuestStatus("orc-pride", engine.Quest.DONE)
			player:grantQuest("high-peak")
		end},
	},
}

newChat{ id="clues",
	text = [[As much as I would like to help, our forces are already spread too thin; we cannot provide you with direct assistance.
But I might be able to help you by explaining how the Pride is organised.
Recently we have heard the Pride speaking about a new master, or masters. They might be the ones behind that mysterious staff of yours.
We believe that the heart of their power is the High Peak, in the center of the continent. But it is inaccessible and covered by some kind of shield.
You must investigate the bastions of the Pride. Perhaps you will find more information about the High Peak, and any orc you kill is one less that will attack us.
The known bastions of the Pride are:
- Rak'shor Pride, in the west of the southern desert
- Gorbat Pride, in a mountain range in the southern desert
- Vor Pride, in the northeast
- Grushnak Pride, on the eastern slope of the High Peak]],
-- - A group of corrupted humans live in Eastport on the southern coastline; they have contact with the Pride
	answers = {
		{"I will investigate them.", jump="relentless", action=function(npc, player)
			player:setQuestStatus("orc-hunt", engine.Quest.DONE)
			player:grantQuest("orc-pride")
			game.logPlayer(game.player, "Aeryn points to the known locations on your map.")
		end},
	},
}

newChat{ id="relentless",
	text = [[One more bit of aid I might give you before you go. Your tale has moved me, and the very stars shine with approval of your relentless pursuit. Take their blessing, and let nothing stop you in your quest.
	#LIGHT_GREEN#*She touches your forehead with one cool hand, and you feel a surge of power*
	]],
	answers = {
		{"I'll leave not a single orc standing.", jump="welcome", action=function(npc, player)
			player:learnTalent(player.T_RELENTLESS_PURSUIT, true, 1, {no_unlearn=true})
			game.logPlayer(game.player, "#VIOLET#You have learned the talent Relentless Pursuit.")
		end},
	},
}

newChat{ id="charred-scar",
	text = [[I have heard about that; good men lost their lives for this. I hope it was worth it.]],
	answers = {
		{"Yes, my lady, they delayed the orcs so that I could get to the heart of the volcano. *#LIGHT_GREEN#Tell her what happened#WHITE#*", jump="charred-scar-success",
			cond=function(npc, player) return player:isQuestStatus("charred-scar", engine.Quest.COMPLETED, "stopped") end,
		},
		{"I am afraid I was too late, but I still have some valuable information. *#LIGHT_GREEN#Tell her what happened#WHITE#*", jump="charred-scar-fail",
			cond=function(npc, player) return player:isQuestStatus("charred-scar", engine.Quest.COMPLETED, "not-stopped") end,
		},
	},
}

newChat{ id="charred-scar-success",
	text = [[Sorcerers? I have never heard of them. There were rumours about a new master of the Pride, but it seems they have two.
Thank you for everything. You must continue your hunt now that you know what to look for.]],
	answers = {
		{"I will avenge your men.", action=function(npc, player) player:setQuestStatus("charred-scar", engine.Quest.DONE) end}
	},
}

newChat{ id="charred-scar-fail",
	text = [[Sorcerers? I have never heard of them. There were rumours about a new master of the Pride, but it seems they have two.
I am afraid with the power they gained today they will be even harder to stop, but we do not have a choice.]],
	answers = {
		{"I will avenge your men.", action=function(npc, player) player:setQuestStatus("charred-scar", engine.Quest.DONE) end}
	},
}

newChat{ id="orc-breeding-pits",
	text = [[Ah! This is wonderful! Finally a ray of hope amidst the darkness. I will assign my best troops to this. Thank you, @playername@ - take this as a token of gratitude.]],
	answers = {
		{"Good luck.", action=function(npc, player)
			player:setQuestStatus("orc-breeding-pits", engine.Quest.COMPLETED, "wuss-out-done")
			player:setQuestStatus("orc-breeding-pits", engine.Quest.COMPLETED)

			for i = 1, 5 do
				local ro = game.zone:makeEntity(game.level, "object", {ignore_material_restriction=true, type="gem", special=function(o) return o.material_level and o.material_level >= 5 end}, nil, true)
				if ro then
					ro:identify(true)
					game.logPlayer(player, "Aeryn gives you: %s", ro:getName{do_color=true})
					game.zone:addEntity(game.level, ro, "object")
					player:addObject(player:getInven("INVEN"), ro)
				end
			end
		end}
	},
}


return "welcome"
