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

local function attack(str)
	return function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) npc:doEmote(str, 150) end
end

-----------------------------------------------------------------------
-- Default
-----------------------------------------------------------------------
if not game.player:isQuestStatus("maglor", engine.Quest.COMPLETED, "maglor-story") then

newChat{ id="welcome",
	text = [[What is this? Why do you come in my sanctuary and slay its guardians?
Speak or die, for I am Maglor, son of Fëanor and I shall guard the Silmaril for all of eternity!]],
	answers = {
		{"[attack]", action=attack("So be it... Die now!")},
		{"I want the Silmaril!", action=attack("The Oath shall be fullfilled once more...")},
		{"I was sent by Ukllmswwik to stop your mad schemes to control all underwater life!", jump="quest"},
	}
}

newChat{ id="quest",
	text = [[I see, so the dragon sent you. He told you I am insane I assume?
But then who is evil, me that fullfills a sacred oath, secluded in this sanctuary, or you that comes in to kill me, destroying my friends and planning to take the Silmaril?
Who is the insane one?]],
	answers = {
		{"Your feeble attemp to sway me away from the side of good will not work. Pay for you sins!", action=attack("If you refuse to see reason, you leave me no choice!")},
		{"Your words are... disturbing. Why should I spare you?", jump="givequest"},
	}
}

newChat{ id="givequest",
	text = [[Spare me?#LIGHT_GREEN#*He laugths.*#WHITE#
Do not presume of your power so hastily!
Yet you may want to hear my story. As I was drowning Ossë came to me, he told me nobody should ever see the Silmaril again, but he did not want to destroy it for it held the last shininh light of the first age.
So he made a pact with me, he would save me and provide me with a way to fullfil my oath, by being its guardian, at the bottom of the sea, for all eternity.
Recently that water dragon that sent you started sending "agents" to retrieve the jewel, I can only imagine his goals, but they are clearly not peaceful.
The Silmaril shall never leave this sanctuary!]],
	answers = {
		{"You do not sound mad to me, could Ukllmswwik have lied?", jump="portal_back", action=function(npc, player) player:setQuestStatus("maglor", engine.Quest.COMPLETED, "maglor-story") end},
		{"I will not be deceived by your lies, I will make your pay for your victims!", action=attack("As you wish, it did not have to come to it...")},
	}
}

newChat{ id="portal_back",
	text = [[Use this portal, it will bring you back to his cave, ask him the truth.]],
	answers = {
		{"I will make him pay for his treachery.", action=function(npc, player) player:hasQuest("maglor"):portal_back() end},
	}
}

-----------------------------------------------------------------------
-- Coming back later
-----------------------------------------------------------------------
else
newChat{ id="welcome",
	text = [[Thanks for listening to me.]],
	answers = {
		{"[attack]", action=attack("So be it... Die now!")},
		{"I want the Silmaril!", action=attack("The Oath shall be fullfilled once more...")},
		{"Farewell, Guardian."},
	}
}
end

return "welcome"
