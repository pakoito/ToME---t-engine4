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

local p = game.party:findMember{main=true}
if not p:isQuestStatus("antimagic", engine.Quest.DONE) then
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*A halfling woman stands before you, clad in dark steel plate.*#WHITE#
Take the test, then we can talk.]],
	answers = {
		{"But.."},
	}
}
return "welcome"
end



newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*A halfling woman stands before you, clad in dark steel plate.*#WHITE#
I am Protector Myssil. Welcome to Zigur.]],
	answers = {
		{"I require all the help I can get, not for my sake but for the town of Derth, to the northeast of here.", jump="save-derth", cond=function(npc, player) local q = player:hasQuest("lightning-overload") return q and q:isCompleted("saved-derth") and not q:isCompleted("tempest-entrance") end},
		{"Nothing for now. Sorry to have taken your time. Farewell, Protector."},
	}
}

newChat{ id="save-derth",
	text = [[Yes, we have sensed the blight of the eldritch forces there. I have already people to dispel the cloud, but the real threat is not there.
We know that a Tempest, a powerful Archmage who can control the storms, is responsible for the damage. Those wretched fools from Angolwen will not act. All corrupted!
So you must act @playername@. I will show you the location of this mage - high in the Daikara mountains.
Erase him.]],
	answers = {
		{"You can count on me, Protector.", action=function(npc, player)
			player:hasQuest("lightning-overload"):create_entrance()
		end},
	}
}

return "welcome"
