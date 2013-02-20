-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

class = require("mod.class.WorldNPC")

newEntity{
	name = "Allied Kingdoms human patrol",
	type = "patrol", subtype = "allied kingdoms",
	display = 'p', color = colors.LIGHT_UMBER,
	faction = "allied-kingdoms",
	level_range = {1, nil},
	sight = 4,
	rarity = 3,
	unit_power = 10,
	cant_be_moved = false,
	ai = "world_patrol", ai_state = {route_kind="allied-kingdoms"},
	on_encounter = {
		type="ambush",
		width=14,
		height=14,
		nb={3, 4},
		filters={{special_rarity="humanoid_random_boss", subtype="human", random_boss={
			nb_classes=1,
			rank=3, ai = "tactical",
			life_rating=function(v) return v * 1.4 + 3 end,
			loot_quality = "store",
			loot_quantity = 1,
			no_loot_randart = true,
		}}}
	},
}

newEntity{
	name = "Allied Kingdoms halfling patrol",
	type = "patrol", subtype = "allied kingdoms",
	display = 'p', color = colors.UMBER,
	faction = "allied-kingdoms",
	level_range = {1, nil},
	sight = 4,
	rarity = 3,
	unit_power = 10,
	cant_be_moved = false,
	ai = "world_patrol", ai_state = {route_kind="allied-kingdoms"},
	on_encounter = {
		type="ambush",
		width=14,
		height=14,
		nb={3, 4},
		filters={{special_rarity="humanoid_random_boss", subtype="halfling", random_boss={
			nb_classes=1,
			rank=3, ai = "tactical",
			life_rating=function(v) return v * 1.4 + 3 end,
			loot_quality = "store",
			loot_quantity = 1,
			no_loot_randart = true,
		}}}
	},
}

newEntity{
	name = "adventurers party",
	type = "hostile", subtype = "humanoid",
	display = '@', color = colors.UMBER,
	level_range = {14, nil},
	sight = 1,
	rarity = 1,
	unit_power = 14,
	movement_speed = 0.75,
	ai = "world_hostile", ai_state = {chase_distance=3},
	on_encounter = {
		type="ambush",
		width=18,
		height=18,
		nb={2, 3},
		filters={{special_rarity="humanoid_random_boss", random_boss={
			nb_classes=1,
			rank=3, ai = "tactical",
			life_rating=function(v) return v * 1.3 + 2 end,
			loot_quality = "store",
			loot_quantity = 1,
			no_loot_randart = true,
			on_die = function(self, src) -- When they die they have a chance to drop an alchemist ingredient
				if rng.percent(30) then
					local list = {}
					for id, d in pairs(game.party.__ingredients_def) do if d.type == "organic" then list[#list+1] = id end end
					if #list > 0 then game.party:collectIngredient(rng.table(list)) end
				end
			end
		}}}
	},
}

newEntity{
	name = "ziguranth patrol",
	type = "hostile", subtype = "humanoid",
	desc = "You have got nothing to fear if you are not using filthy arcane magic. Otherwise: DIE!",
	display = '@', color = colors.GREEN,
	level_range = {14, nil},
	faction = "zigur",
	sight = 1,
	rarity = 6,
	unit_power = 20,
	hates_arcane = 1,
	movement_speed = 0.75,
	cant_be_moved = false,
	ai = "world_hostile", ai_state = {chase_distance=3},
	on_encounter = {
		type="ambush",
		width=18,
		height=18,
		nb={2, 3},
		filters={{special_rarity="humanoid_random_boss", random_boss={
			nb_classes=1,
			rank=3, ai = "tactical",
			life_rating=function(v) return v * 1.3 + 2 end,
			loot_quality = "store",
			loot_quantity = 1,
			class_filter = function(c)
				if c.power_source and c.power_source.arcane then return false end
				return true
			end,
			no_loot_randart = true,
			add_trees = {["wild-gift/antimagic"]=true},
		}}}
	},
}
