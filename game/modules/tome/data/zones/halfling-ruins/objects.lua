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

load("/data/general/objects/objects-maj-eyal.lua")

for i = 1, 4 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "research log of halfling mage Hompalan", lore="halfling-research-note-"..i,
	desc = [[A very faded research note, nearly unreadable.]],
	rarity = false,
	encumberance = 0,
}
end

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {psionic=true},
	unique = true,
	name = "Yeek-fur Robe", color = colors.WHITE, image = "object/artifact/yeek_fur_robe.png",
	unided_name = "sleek fur robe",
	desc = [[A beautifully soft robe of fine white fur. It looks designed for a halfling noble, with glorious sapphires sewn across the hems. But entrancing as it is, you can't help but feel a little queasy wearing it.]],
	level_range = {12, 22},
	rarity = 20,
	cost = 250,
	material_level = 2,
	wielder = {
		combat_def = 9,
		combat_armor = 3,
		combat_mindpower = 5,
		combat_mentalresist = 10,
		inc_damage={[DamageType.MIND] = 5},
		resists={[DamageType.COLD] = 20},
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Yeek" then
			local Talents = require "engine.interface.ActorStats"
			self:specialWearAdd({"wielder","combat_mindpower"}, -15)
			self:specialWearAdd({"wielder","combat_mentalresist"}, -25)
			game.logPlayer(who, "#RED#You feel disgusted touching this thing!")
		end
		if who.descriptor and who.descriptor.race == "Halfling" then
			local Talents = require "engine.interface.ActorStats"
			self:specialWearAdd({"wielder","resists"}, {[engine.DamageType.MIND] = 15,})
			self:specialWearAdd({"wielder","combat_mentalresist"}, 10)
			game.logPlayer(who, "#LIGHT_BLUE#You feel this robe was made for you!")
		end
	end,
}
