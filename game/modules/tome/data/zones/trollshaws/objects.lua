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

for i = 1, 5 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "tattered paper scrap", lore="trollshaws-note-"..i,
	desc = [[A paper scrap, left by an adventurer.]],
	rarity = false,
	is_magic_device = false,
	encumberance = 0,
}
end

newEntity{ base = "BASE_WAND",
	define_as = "ROD_OF_RECALL",
	unided_name = "unstable wand", identified=true, force_lore_artifact=true,
	name = "Rod of Recall", color=colors.LIGHT_BLUE, unique=true,
	desc = [[This rod is made entirely of voratun, infused with raw magical energies it can bend space itself.
This seems to be what the troll was keeping as "treasure". You have heard of such items before, they are very useful to adventurers, allowing faster travel.]],
	cost = 0, quest=true,
	elec_proof = true,

	max_power = 1000, power_regen = 1,
	use_power = { name = "recall the user to the worldmap", power = 1000,
		use = function(self, who)
			if who:canBe("worldport") then
				who:setEffect(who.EFF_RECALL, 40, {})
				game.logPlayer(who, "Space around you starts to disolve...")
			else
				game.logPlayer(who, "The rod emits a strange noise, glows briefly and returns to normal.")
			end
		end
	},
}
