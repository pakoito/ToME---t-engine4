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
	text = [[#LIGHT_GREEN#*Before you stands a young man, a novice mage by his looks*#WHITE#
Good day to you fellow traveller!]],
	answers = {
		{"What brings an apprentice mage in the wilds?", jump="quest", cond=function(npc, player) return not player:hasQuest("mage-apprentice") end},
		{"I have a staff for you!",
			jump="welcome",
			cond=function(npc, player) return player:hasQuest("mage-apprentice") and player:hasQuest("mage-apprentice"):can_offer(player) end,
			action=function(npc, player, dialog) player:hasQuest("mage-apprentice"):collect_staff(player, dialog) end
		},
		-- Reward for non-mages: access to Angolwen
		{"So you have enough staves now?",
			jump="thanks",
			cond=function(npc, player) return player:hasQuest("mage-apprentice") and player:hasQuest("mage-apprentice"):isCompleted() and player.descriptor.class ~= "Mage" end,
		},
		-- Reward for mages: upgrade a talent mastery
		{"So you have enough staves now?",
			jump="thanks_mage",
			cond=function(npc, player) return player:hasQuest("mage-apprentice") and player:hasQuest("mage-apprentice"):isCompleted() and player.descriptor.class == "Mage" end,
		},
--		{"Do you have any items to sell?", jump="store"},
		{"Sorry I have to go!"},
	}
}

newChat{ id="quest",
	text = [[Ahh, that is my sad story ... but I would not bother you with it my friend.]],
	answers = {
		{"Please you do not.", jump="quest2"},
		{"Ok, bye then!"},
	}
}
newChat{ id="quest2",
	text = [[Well if you insist...
I am a novice mage, as you might have noticed, and my goal is to be accepted by the elves of Angolwen to be taugth the secrets of the arcane.]],
	answers = {
		{"Who are the elves of Angolwen?", jump="quest3", cond=function(npc, player) return player.descriptor.class ~= "Mage" end,},
		{"Ah yes Angolwen, this place I called home for many years...", jump="quest3_mage", cond=function(npc, player) return player.descriptor.class == "Mage" end,},
		{"Well good luck, bye!"},
	}
}
newChat{ id="quest3",
	text = [[The keepers of ar... err I do not think I am supposed to talk about them sorry my friend...
Anyway, I must collect 15 magic staves and I have yet to find one. If you could bring me some should you find any, I would be grateful]],
	answers = {
		{"I will keep that in mind", action=function(npc, player) player:grantQuest("mage-apprentice") end},
		{"No way, bye!"},
	}
}
newChat{ id="quest3_mage",
	text = [[I hope I will too ...
Anyway, I must collect 15 magic staves and I have yet to find one. If you could bring me some should you find any, I would be grateful]],
	answers = {
		{"I will keep that in mind", action=function(npc, player) player:grantQuest("mage-apprentice") end},
		{"No way, bye!"},
	}
}

newChat{ id="thanks",
	text = [[Ah yes! I am so glad! I will be able to go back to Angolw..err. Oh well I just I can tell you, you deserve it for helping me.
During the late years of Sauron, more than one hundred years ago, Gandalf the Grey worried that magic could disappear with him and would be lost to mortals should they need it again.
So he set a secret plan into action and taught a small group of elves and men into its usage with a specific task: to build a secret place where magic would be kept alive.
His plan worked and the group built a town called Angolwen in the Blue Mountains #LIGHT_GREEN#*he marks it on your map, along with a portal to access it*#WHITE#.
Not many people are accepted there but I will arrange for you to be allowed inside.]],
	answers = {
		{"Oh! How could such a place be kept secret for so long.. This is interresting indeed, thanks for your trust.",
			action = function(npc, player)
				player:hasQuest("mage-apprentice"):access_angolwen(player)
				npc:die()
			end,
		},
	}
}

newChat{ id="thanks_mage",
	text = [[Ah yes! I am so glad! I will be able to go back to Angolwen now, maybe we will meet there.
Oh and take this ring, it has served me well.]],
	answers = {
		{"Thanks, and best luck for you studies!",
			action = function(npc, player)
				player:hasQuest("mage-apprentice"):ring_gift(player)
				npc:die()
			end,
		},
	}
}

return "welcome"
