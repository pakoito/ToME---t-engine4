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

local p = game.party:findMember{main=true}
if p:attr("forbid_arcane") then

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*Before you stands a young man, a novice mage by his looks*#WHITE#
Good day to yo...#LIGHT_GREEN#*He stares at you and starts to run away fast!*#WHITE#
Do not kill me please!]],
	answers = {
		{"...", action = function(npc, player) npc:die() end,
},
	}
}
return "welcome"

end

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*Before you stands a young man, a novice mage by his looks*#WHITE#
Good day to you, fellow traveler!]],
	answers = {
		{"What brings an apprentice mage out into the wilds?", jump="quest", cond=function(npc, player) return not player:hasQuest("mage-apprentice") end},
		{"I found this artefact; it looks powerful and arcane infused. Maybe it would be enough?",
			jump="unique",
			cond=function(npc, player) return player:hasQuest("mage-apprentice") and player:hasQuest("mage-apprentice"):can_offer_unique(player) end,
			action=function(npc, player, dialog) player:hasQuest("mage-apprentice"):collect_staff_unique(npc, player, dialog) end
		},
		-- Reward for non-mages: access to Angolwen
		{"So you have enough magical items now?",
			jump="thanks",
			cond=function(npc, player) return player:hasQuest("mage-apprentice") and player:hasQuest("mage-apprentice"):isCompleted() and not player:knowTalent(player.T_TELEPORT_ANGOLWEN) end,
		},
		-- Reward for mages: upgrade a talent mastery
		{"So you have enough magical items now?",
			jump="thanks_mage",
			cond=function(npc, player) return player:hasQuest("mage-apprentice") and player:hasQuest("mage-apprentice"):isCompleted() and player:knowTalent(player.T_TELEPORT_ANGOLWEN) end,
		},
--		{"Do you have any items to sell?", jump="store"},
		{"Sorry I have to go!"},
	}
}

newChat{ id="quest",
	text = [[Ahh, my story is a sad one... I should not trouble you with it, my friend.]],
	answers = {
		{"It is no trouble at all! Please tell me!", jump="quest2"},
		{"Ok, bye then!"},
	}
}
newChat{ id="quest2",
	text = [[Well, if you insist...
I am a novice mage, as you might have noticed, and my goal is to be accepted by the people of Angolwen and be taught the secrets of the arcane.]],
	answers = {
		{"Who are the people of Angolwen?", jump="quest3", cond=function(npc, player) return player.faction ~= "angolwen" end,},
		{"Ah yes, Angolwen, I have called it home for many years...", jump="quest3_mage", cond=function(npc, player) return player.faction == "angolwen" end,},
		{"Well, good luck, bye!"},
	}
}
newChat{ id="quest3",
	text = [[The keepers of ar... err, I do not think I am supposed to talk about them... sorry, my friend...
In any case, I must collect many items. I have some already but I am still looking for an arcane-infused artefact. You do not happen to have one, I imagine... Well, if you do, tell me please!]],
	answers = {
		{"I will keep that in mind!", action=function(npc, player) player:grantQuest("mage-apprentice") end},
		{"No way, bye!"},
	}
}
newChat{ id="quest3_mage",
	text = [[I hope I will too...
In any case, I must collect many items. I have some already but I am still looking for an arcane-infused artefact. You do not happen to have one, I imagine... Well, if you do, tell me please!]],
	answers = {
		{"I will keep that in mind!", action=function(npc, player) player:grantQuest("mage-apprentice") end},
		{"No way, bye!"},
	}
}

newChat{ id="unique",
	text = [[Let me examine it.
Oh yes, my friend, this is indeed a powerful artefact! I think that it should suffice to complete my quest! Many thanks!]],
	answers = {
		{"Well, I cannot use it anyway.", jump="welcome"},
	}
}

newChat{ id="thanks",
	text = [[Ah yes! I am so glad! I will be able to go back to Angolw...err... Oh well, I guess I can tell you; you deserve it for helping me.
During the dark years of the Spellhunt, many thousands of years ago, Linaniil, the great mage of the Kor'Krul, worried that magic might disappear with her generation and be lost to mortals should they need it again.
So she set a secret plan into action and built a secret place where magic would be kept alive.
Her plan worked and the group built a town called Angolwen in the western mountains. #LIGHT_GREEN#*He marks it on your map, along with a portal to access it*#WHITE#
Not many people are accepted there but I will arrange for you to be allowed inside.]],
	answers = {
		{"Oh! How could such a place be kept secret for so long... This is interesting indeed. Thank you for your trust!",
			action = function(npc, player)
				player:hasQuest("mage-apprentice"):access_angolwen(player)
				npc:die()
			end,
		},
	}
}

newChat{ id="thanks_mage",
	text = [[Ah yes! I am so glad! I will be able to go back to Angolwen now, and perhaps we will meet there.
Please take this ring; it has served me well.]],
	answers = {
		{"Thanks, and best luck in your studies!",
			action = function(npc, player)
				player:hasQuest("mage-apprentice"):ring_gift(player)
				npc:die()
			end,
		},
	}
}

return "welcome"
