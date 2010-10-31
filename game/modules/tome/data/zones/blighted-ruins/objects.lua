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

load("/data/general/objects/objects.lua")

-- Allows undeads to pass as normal humans
newEntity{ define_as = "CLOAK_DECEPTION",
	unique = true, quest=true,
	slot = "CLOAK",
	type = "armor", subtype="cloak",
	unided_name = "black cloak",
	name = "Cloak of Deception",
	display = ")", color=colors.DARk_GREY,
	encumber = 1,
	desc = [[A black cloak, with subtle illusion enchantments woven in its very fabric.]],

	wielder = {
		combat_spellpower = 5,
		combat_dam = 5,
	},

	on_wear = function(self, who)
		who.old_faction_cloak = who.faction
		who.faction = "allied-kingdoms"
		if who.alchemy_golem then who.alchemy_golem.faction = who.faction end
		if who.player then engine.Map:setViewerFaction(who.faction) end
		game.logPlayer(who, "#LIGHT_BLUE#An illusion appears around %s, making it appear human.", who.name:capitalize())
	end,
	on_takeoff = function(self, who)
		who.faction = who.old_faction_cloak
		if who.alchemy_golem then who.alchemy_golem.faction = who.faction end
		if who.player then engine.Map:setViewerFaction(who.faction) end
		game.logPlayer(who, "#LIGHT_BLUE#The illusion covering %s disappears", who.name:capitalize())
	end,
	on_pickup = function(self, who)
		who:setQuestStatus("start-undead", engine.Quest.COMPLETED, "black-cloak")
	end,
}
