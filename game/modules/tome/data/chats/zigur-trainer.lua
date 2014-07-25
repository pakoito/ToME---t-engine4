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

if game.player:isQuestStatus("antimagic", engine.Quest.DONE) then
newChat{ id="welcome",
	text = [[Well met, friend.]],
	answers = {
		{"Farewell."},
	}
}
return "welcome"
end

local sex = game.player.female and "Sister" or "Brother"

local remove_magic = function(npc, player)
	for tid, _ in pairs(player.sustain_talents) do
		local t = player:getTalentFromId(tid)
		if t.is_spell then player:forceUseTalent(tid, {ignore_energy=true}) end
	end

	-- Remove equipment
	for inven_id, inven in pairs(player.inven) do
		for i = #inven, 1, -1 do
			local o = inven[i]
			if o.power_source and o.power_source.arcane then
				game.logPlayer(player, "You cannot use your %s anymore; it is tainted by magic.", o:getName{do_color=true})
				local o = player:removeObject(inven, i, true)
				player:addObject(player.INVEN_INVEN, o)
				player:sortInven()
			end
		end
	end
	player:attr("forbid_arcane", 1)
	player:attr("zigur_follower", 1)
	player.changed = true
end

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*A grim-looking Fighter stands there, clad in mail armour and a large olive cloak. He doesn't appear hostile - his sword is sheathed.*#WHITE#
]]..sex..[[, our guild has been watching you and we believe that you have potential.
We see that the hermetic arts have always been at the root of each and every trial this land has endured, and we also see that one day they will bring about our destruction. So we have decided to take action by calling upon Nature to help us combat those who wield the arcane.
We can train you, but you need to prove you are pure, untouched by the eldritch forces, and ready to fight them to the end.
You will be challenged against magical foes. Should you defeat them, we will teach you our ways, and never again will you be able to be tainted by magic, or use it.

#LIGHT_RED#Note:  Completing this quest will forever prevent this character from using spells or items powered by arcane forces.  In exchange you'll be given access to a mindpower based generic talent tree, Anti-magic, and be able to unlock hidden properties in many arcane-disrupting items.]],
	answers = {
		{"I will face your challenge!", cond=function(npc, player) return player.level >= 10 end, jump="testok"},
		{"I will face your challenge!", cond=function(npc, player) return player.level < 10 end, jump="testko"},
		{"I'm not interested.", jump="ko"},
	}
}

newChat{ id="ko",
	text = [[Very well. I will say that this is disappointing, but it is your choice. Farewell.]],
	answers = {
		{"Farewell."},
	}
}

newChat{ id="testko",
	text = [[Ah, you seem eager, but maybe still too young. Come back when you have grown a bit.]],
	answers = {
		{"I shall."},
	}
}

newChat{ id="testok",
	text = [[Very well. Before you start, we will make sure no magic can help you:
- You will not be able to use any spells or magical devices
- Any worn objects that are powered by the arcane will be unequipped

Are you ready, or do you wish to prepare first?]],
	answers = {
		{"I am ready", jump="test", action=remove_magic},
		{"I need to prepare."},
	}
}

newChat{ id="test",
	text = [[#VIOLET#*You are grabbed by two olive-clad warriors and thrown into a crude arena!*
#LIGHT_GREEN#*You hear the voice of the Fighter ring above you.*#WHITE#
]]..sex..[[! Your training begins! I want to see you prove your superiority over the works of magic! Fight!]],
	answers = {
		{"But wha.. [you notice your first opponent is already there]", action=function(npc, player)
			player:grantQuest("antimagic")
			player:hasQuest("antimagic"):start_event()
		end},
	}
}

return "welcome"
