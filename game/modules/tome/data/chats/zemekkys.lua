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

local function remove_materials(npc, player)
	local gem_o, gem_item, gem_inven_id = player:findInAllInventories("Resonating Diamond")
	player:removeObject(gem_inven_id, gem_item, false)
	gem_o:removed()

	local athame_o, athame_item, athame_inven_id = player:findInAllInventories("Blood-Runed Athame")
	player:removeObject(athame_inven_id, athame_item, false)
	athame_o:removed()

	player:incMoney(-100)
end

local function check_materials(npc, player)
	local gem_o, gem_item, gem_inven_id = player:findInAllInventories("Resonating Diamond")
	local athame_o, athame_item, athame_inven_id = player:findInAllInventories("Blood-Runed Athame")
	return gem_o and athame_o and player.money >= 100
end

-----------------------------------------------------------------
-- Main dialog
-----------------------------------------------------------------

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*A slot in the door opens and a pair of wild eyes peers out.*#WHITE#
What do you want, @playerdescriptor.race@?]],
	answers = {
		{"Paladin Aeryn told me that you could help me. I need to get to Maj'Eyal.", jump="help", cond=function(npc, player) return game.state:isAdvanced() and not player:hasQuest("west-portal") end},
		{"I found the Blood-Runed Athame, but there was no Resonating Diamond.", jump="athame", cond=function(npc, player) return player:hasQuest("west-portal") and player:hasQuest("west-portal"):isCompleted("athame") and not player:hasQuest("west-portal"):isCompleted("gem") end},
		{"I have a Resonating Diamond.", jump="complete", cond=function(npc, player) return player:hasQuest("west-portal") and player:hasQuest("west-portal"):isCompleted("gem") end},
		{"Sorry, I have to go!"},
	}
}

-----------------------------------------------------------------
-- Give quest
-----------------------------------------------------------------
newChat{ id="help",
	text = [[Pfaugh! Her goal in life is to waste my time! Maj'Eyal? Why not Narnia or Chicago? Just as easy to send you someplace entirely fictional as Maj'Eyal. Go away.
#LIGHT_GREEN#*Slot slams shut.*#WHITE#]],
	answers = {
		{"I got here from Maj'Eyal, didn't I? I have this magic Orb I looted from a dead orc, see, and...", jump="offer"},
	}
}

newChat{ id="offer",
	text = [[#LIGHT_GREEN#*Slot opens.*#WHITE#
Orb, you say? That you used to travel here from Maj'Eyal? Surely you don't possess the Orb of Many Ways! It's been lost for ages!]],
	answers = {
		{"[Hold up the orb]", jump="offer2"},
	}
}
newChat{ id="offer2",
	text = [[#LIGHT_GREEN#*His eyes widen.*#WHITE#
Great Socks of Aeryn! It IS the Orb! Maybe we can get you home after all. Or maybe we can get you embedded in magma a thousand leagues straight down.]],
	answers = {
		{"May I come in?", jump="offer3"},
	}
}

newChat{ id="offer3",
	text = [[You think I'm letting some filthy @playerdescriptor.race@ in my house with the Orb of Many Ways?
I blow myself up quite enough already without that thing in the house, thank you.
Besides, I still can't help you unless you have a Blood-Runed Athame to etch a portal.
Err, and that portal must be etched on a piece of prepared Resonating Marble.
The Gates of the Morning has a slab of Marble that once could have served, but a number of, um, incidents have taken their toll.
It'll require a Resonating Diamond to get it properly prepared. Oh, and I want 100 gold.]],
	answers = {
		{"Where can I find all that?", jump="quest"},
	}
}

newChat{ id="quest",
	text = [[Try your purse for the 100 gold. As for an Athame and a Resonating Diamond, I assume the orcs have some if they're cooking up portals to use that Orb on. Try the Vor Armory. It so happens that I know a back way in. Never mind why.]],
	answers = {
		{"Thank you.", action=function(npc, player)
			player:grantQuest("west-portal")
		end},
	}
}


-----------------------------------------------------------------
-- Return athame
-----------------------------------------------------------------
newChat{ id="athame",
	text = [[Of course there was no Resonating Diamond. What makes you think Briagh would let one loose for even a second?]],
	answers = {
		{"Briagh?", jump="athame2"},
	}
}
newChat{ id="athame2",
	text = [[Briagh the Great Sand Wyrm. Where do you think Resonating Diamonds come from? They're just regular diamonds until they get stuck between Briagh's scales for a few centuries and get infused with his life rhythms. He sleeps on a hoard of precious gems and metals, you see.]],
	answers = {
		{"Where might I find Briagh's lair??", jump="athame3"},
	}
}
newChat{ id="athame3",
	text = [[Well south of the Sunwall. I'll mark it for you on your map.]],
	answers = {
		{"I'll be back with a Resonating Diamond.", action=function(npc, player) player:hasQuest("west-portal"):wyrm_lair(player) end},
	}
}

-----------------------------------------------------------------
-- Return gem
-----------------------------------------------------------------
newChat{ id="complete",
	text = [[Yes? You got the Athame, the gem and 100 gold?]],
	answers = {
		{"[Give him the gem, the athame and 100 gold]", jump="complete2", cond=check_materials, action=remove_materials},
		{"Sorry, it seems I lack some stuff. I will be back."},
	}
}
newChat{ id="complete2",
	text = [[#LIGHT_GREEN#*The door opens and a shabby Elf emerges.*#WHITE#
Off we go to prepare the portal!]],
	answers = {
		{"[follow him]", action=function(npc, player) player:hasQuest("west-portal"):create_portal(npc, player) end},
	}
}

return "welcome"
