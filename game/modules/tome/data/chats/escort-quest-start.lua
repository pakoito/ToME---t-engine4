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

local p = game.party:findMember{main=true}
if p:attr("forbid_arcane") and not npc.antimagic_ok then

newChat{ id="welcome",
	text = text,
	answers =
	{
		{"#LIGHT_GREEN#[Pretend to help but when it is time you will use a Ziguranth technique to make the portal fizzle. @npcname@ will be sent to Zigur to be 'dealt with' properly.]#WHITE#\nLead on; I will protect you.", action=function(npc, player)
			player:hasQuest(npc.quest_id).to_zigur = true
			npc.ai_state.tactic_leash = 100
			game.party:addMember(npc, {
				control="order",
				type="escort",
				title="Escort",
				orders = {escort_portal=true, escort_rest=true},
			})
		end},
		{"Go away; I do not help filthy arcane users!", action=function(npc, player)
			game.player:registerEscorts("lost")
			npc:disappear()
			npc:removed()
			player:hasQuest(npc.quest_id).abandoned = true
			player:setQuestStatus(npc.quest_id, engine.Quest.FAILED)
		end},
	},
}

else

if not npc.antimagic_ok and profile.mod.allow_build.birth_zigur_sacrifice then

newChat{ id="welcome",
	text = text,
	answers =
	{
		{"Lead on; I will protect you.", action=function(npc, player)
			npc.ai_state.tactic_leash = 100
			game.party:addMember(npc, {
				control="order",
				type="escort",
				title="Escort",
				orders = {escort_portal=true, escort_rest=true},
			})
		end},
		{"#LIGHT_GREEN#[Pretend to help but when it is time you will use a technique to make the portal fizzle. @npcname@ will be sent to Zigur to be 'dealt with' properly.]#WHITE#\nLead on; I will protect you.", action=function(npc, player)
			player:hasQuest(npc.quest_id).to_zigur = true
			npc.ai_state.tactic_leash = 100
			game.party:addMember(npc, {
				control="order",
				type="escort",
				title="Escort",
				orders = {escort_portal=true, escort_rest=true},
			})
		end},
		{"Go away; I do not care for the weak.", action=function(npc, player)
			game.player:registerEscorts("lost")
			npc:disappear()
			npc:removed()
			player:hasQuest(npc.quest_id).abandoned = true
			player:setQuestStatus(npc.quest_id, engine.Quest.FAILED)
		end},
	},
}

else

newChat{ id="welcome",
	text = text,
	answers =
	{
		{"Lead on; I will protect you.", action=function(npc, player)
			npc.ai_state.tactic_leash = 100
			game.party:addMember(npc, {
				control="order",
				type="escort",
				title="Escort",
				orders = {escort_portal=true, escort_rest=true},
			})
		end},
		{"Go away; I do not care for the weak.", action=function(npc, player)
			game.player:registerEscorts("lost")
			npc:disappear()
			npc:removed()
			player:hasQuest(npc.quest_id).abandoned = true
			player:setQuestStatus(npc.quest_id, engine.Quest.FAILED)
		end},
	},
}

end

end

return "welcome"
