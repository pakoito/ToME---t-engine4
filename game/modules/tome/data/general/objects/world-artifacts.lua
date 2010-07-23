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

local Stats = require "engine.interface.ActorStats"

-- This file describes artifacts not bound to a special location, they can be found anywhere
newEntity{ base = "BASE_STAFF",
	unique = true,
	name = "Staff of Destruction",
	unided_name = "ash staff",
	level_range = {20, 25},
	color=colors.VIOLET,
	rarity = 100,
	desc = [[This unique looking staff is carved with runes of destruction.]],
	cost = 500,

	require = { stat = { mag=24 }, },
	combat = {
		dam = 15,
		apr = 4,
		dammod = {mag=1.5},
	},
	wielder = {
		combat_spellpower = 10,
		combat_spellcrit = 15,
		inc_damage={
			[DamageType.FIRE] = resolvers.mbonus(25, 8),
			[DamageType.LIGHTNING] = resolvers.mbonus(25, 8),
		},
	},
}

newEntity{ base = "BASE_RING",
	unique = true,
	name = "Ring of Ulmo", color = colors.LIGHT_BLUE,
	unided_name = "sea-blue ring",
	desc = [[This azure ring seems to be always moist to the touch.]],
	level_range = {10, 20},
	rarity = 150,
	cost = 500,

	max_power = 60, power_regen = 1,
	use_power = { name = "summon a tidal wave", power = 60,
		use = function(self, who)
			local duration = 7
			local radius = 1
			local dam = 20
			-- Add a lasting map effect
			game.level.map:addEffect(who,
				who.x, who.y, duration,
				engine.DamageType.WAVE, dam,
				radius,
				5, nil,
				engine.Entity.new{alpha=100, display='', color_br=30, color_bg=60, color_bb=200},
				function(e)
					e.radius = e.radius + 1
				end,
				false
			)
			game.logSeen(who, "%s brandishes the %s, calling forth the might of the oceans!", who.name:capitalize(), self:getName())
		end
	},
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 4, [Stats.STAT_CON] = 3 },
		max_mana = 20,
		max_stamina = 20,
		resists = {
			[DamageType.COLD] = 25,
			[DamageType.NATURE] = 10,
		},
	},
}

newEntity{ base = "BASE_RING",
	unique = true,
	name = "Elemental Fury", color = colors.PURPLE,
	unided_name = "multi-hued ring",
	desc = [[This ring shines with many colors.]],
	level_range = {15, 30},
	rarity = 150,
	cost = 500,

	wielder = {
		inc_stats = { [Stats.STAT_CUN] = 3, },
		inc_damage = {
			[DamageType.ARCANE]    = 10,
			[DamageType.FIRE]      = 10,
			[DamageType.COLD]      = 10,
			[DamageType.ACID]      = 10,
			[DamageType.LIGHTNING] = 10,
		},
	},
}

newEntity{ base = "BASE_LITE", define_as = "PHIAL_GALADRIEL",
	unique = true,
	name = "Phial of Galadriel",
	unided_name = "glowing phial",
	level_range = {1, 10},
	color=colors.YELLOW,
	encumber = 1,
	rarity = 100,
	desc = [[A small crystal phial, with the light of Earendil's Star contained inside. Its light is imperishable, and near it darkness cannot endure.]],
	cost = 200,

	max_power = 15, power_regen = 1,
	use_power = { name = "call light", power = 10,
		use = function(self, who)
			who:project({type="ball", range=0, friendlyfire=false, radius=20}, who.x, who.y, engine.DamageType.LITE, 100)
			game.logSeen(who, "%s brandishes the %s and banishes all shadows!", who.name:capitalize(), self:getName())
		end
	},
	wielder = {
		lite = 4,
	},
}

newEntity{ base = "BASE_LITE",
	unique = true,
	name = "Arkenstone of Thrain",
	unided_name = "great jewel",
	level_range = {20, 30},
	color=colors.YELLOW,
	encumber = 1,
	rarity = 250,
	desc = [[A great globe seemingly filled with moonlight, the famed Heart of the Mountain, which splinters the light that falls upon it into a thousand glowing shards.]],
	cost = 400,

	max_power = 150, power_regen = 1,
	use_power = { name = "map surroundings", power = 100,
		use = function(self, who)
			who:magicMap(20)
			game.logSeen(who, "%s brandishes the %s which glitters in all directions!", who.name:capitalize(), self:getName())
		end
	},
	wielder = {
		lite = 5,
	},
}

newEntity{
	unique = true,
	type = "potion", subtype="potion",
	name = "Ever-Refilling Potion of Healing",
	unided_name = "strange potion",
	level_range = {35, 40},
	display = '!', color=colors.VIOLET, image="object/potion-0x3-violet.png",
	encumber = 0.4,
	rarity = 150,
	desc = [[Bottle containing healing magic. But the more you drink from it, the more it refills!]],
	cost = 80,

	max_power = 100, power_regen = 1,
	use_power = { name = "heal", power = 80,
		use = function(self, who)
			who:heal(150 + who:getMag())
			game.logSeen(who, "%s quaffs an %s!", who.name:capitalize(), self:getName())
		end
	},
}

newEntity{
	unique = true,
	type = "potion", subtype="potion",
	name = "Ever-Refilling Potion of Mana",
	unided_name = "strange potion",
	level_range = {35, 40},
	display = '!', color=colors.VIOLET, image="object/potion-0x3-violet.png",
	encumber = 0.4,
	rarity = 150,
	desc = [[Bottle containing raw magic. But the more you drink from it, the more it refills!]],
	cost = 80,

	max_power = 100, power_regen = 1,
	use_power = { name = "restore mana", power = 80,
		use = function(self, who)
			who:incMana(150 + who:getMag())
			game.logSeen(who, "%s quaffs an %s!", who.name:capitalize(), self:getName())
		end
	},
}

newEntity{
	unique = true,
	type = "potion", subtype="potion",
	name = "Blood of Life",
	unided_name = "bloody phial",
	level_range = {1, 50},
	display = '!', color=colors.VIOLET, image="object/potion-0x3-violet.png",
	encumber = 0.4,
	rarity = 350,
	desc = [[The Blood of Life! It can let a living being resurrect in case of an untimely demise. But only once!]],
	cost = 1000,

	use_simple = { name = "quaff the Blood of Life", use = function(self, who)
		if not who:attr("undead") then
			who.blood_life = true
			game.logPlayer(who, "#LIGHT_RED#You feel the Blood of Life rushing through your veins.")
		else
			game.logPlayer(who, "The Blood of Life seems to have no effect on you.")
		end
		game.logSeen(who, "%s quaffs the %s!", who.name:capitalize(), self:getName())
		return "destroy", true
	end},
}

newEntity{ base = "BASE_LONGBOW",
	name = "Gondor-Tree Longbow", unided_name = "glowing elven-wood longbow", unique=true,
	desc = [[In the aftermath of the wars against Sauron, the strength of the Trees of Gondor faded and one of the trees died despite the efforts of the men of the city to save it. Its wood was fashioned into a bow to be wielded against the darkness that poisoned Gondor's tree.]],
	level_range = {40, 50},
	rarity = 200
	require = { stat = { dex=36 }, },
	cost = 800,
	material_level = 5,
	combat = {
		range = 18,
		physspeed = 0.7,
		apr = 12,
	},
	wielder = {
		inc_damage={ [DamageType.PHYSICAL] = 12, },
		lite = 1,
		inc_stats = { [Stats.STAT_DEX] = 5, [Stats.STAT_WIL] = 4,  },
		ranged_project={[DamageType.LIGHT] = 30},
	},
}
