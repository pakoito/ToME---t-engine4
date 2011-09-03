-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
local Talents = require "engine.interface.ActorTalents"

-- This one starts a quest it has a level and rarity so it can drop randomly, but there are places where it is more likely to appear
newEntity{ base = "BASE_SCROLL", define_as = "JEWELER_TOME", subtype="tome", no_unique_lore=true,
	unique = true, quest=true,
	unided_name = "ancient tome",
	name = "Ancient Tome titled 'Gems and their uses'", image = "object/artifact/ancient_tome_gems_and_their_uses.png",
	level_range = {30, 40}, rarity = 120,
	color = colors.VIOLET,
	is_magic_device = false,
	fire_proof = true,
	not_in_stores = true,

	on_pickup = function(self, who)
		if who == game.player then
			self:identify(true)
			who:grantQuest("master-jeweler")
		end
	end,
}

-- Not a random drop, used by the quest started above
newEntity{ base = "BASE_SCROLL", define_as = "JEWELER_SUMMON", subtype="tome", no_unique_lore=true,
	power_source = {unknown=true},
	unique = true, quest=true, identified=true,
	name = "Scroll of Summoning (Limmir the Jeweler)",
	color = colors.VIOLET,
	fire_proof = true,
	is_magic_device = false,

	max_power = 1, power_regen = 1,
	use_power = { name = "summon Limmir the jeweler at the center of the lake of the moon", power = 1,
		use = function(self, who) who:hasQuest("master-jeweler"):summon_limmir(who) return true end
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	unique = true,
	name = "Pendent of the Sun and Moons", color = colors.LIGHT_SLATE, image = "object/artifact/amulet_pendant_of_sun_and_the_moon.png",
	unided_name = "a gray and gold pendent",
	desc = [[This small pendent depicts a hematite moon eclipsing a golden sun and according to legend was worn by one of the Sunwall's founders.]],
	level_range = {35, 45},
	rarity = 300,
	cost = 200,
	material_level = 4,
	wielder = {
		combat_spellpower = 8,
		combat_spellcrit = 5,
		inc_damage = { [DamageType.LIGHT]= 8,[DamageType.DARKNESS]= 8 },
		resists = { [DamageType.LIGHT]= 10, [DamageType.DARKNESS]= 10 },
		resists_cap = { [DamageType.LIGHT]= 5, [DamageType.DARKNESS]= 5 },
		resists_pen = { [DamageType.LIGHT]= 15, [DamageType.DARKNESS]= 15 },
	},
	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_CIRCLE_OF_SANCTITY, level = 2, power = 60 },
}

newEntity{ base = "BASE_SHIELD",
	power_source = {arcane=true},
	unique = true,
	unided_name = "shimmering gold shield",
	name = "Unsetting Sun", image = "object/artifact/shield_unsetting_sun.png",
	desc = [[When Elmio Panason, captain of the Vanguard, first sought shelter for his shipwrecked crew, he reflected the last rays of the setting sun off his shield.  Where the beam hit they rested and built the settlement that would become the Sunwall.  In the dark days that followed the shield became a symbol of hope for a better future.]],
	color = colors.YELLOW,
	rarity = 300,
	level_range = {35, 45},
	require = { stat = { str=40 }, },
	cost = 400,
	material_level = 5,
	special_combat = {
		dam = 50,
		physcrit = 4.5,
		dammod = {str=1},
		damtype = DamageType.LIGHT,
	},
	wielder = {
		lite = 2,
		combat_armor = 9,
		combat_def = 16,
		combat_def_ranged = 17,
		fatigue = 14,
		combat_spellresist = 19,
		resists = {[DamageType.DARKNESS] = 30},
	},
}

newEntity{ base = "BASE_HEAVY_BOOTS",
	power_source = {arcane=true},
	unique = true,
	name = "Scorched Boots", image = "object/artifact/scorched_boots.png",
	unided_name = "pair of blackened boots",
	desc = [[The master blood mage Ru'Khan was the first orc to experiment with the power of the Sher'Tul farportals in the Age of Pyre.  However, that first experiment was not particularly successful, and after the explosion of energy all that could be found of Ru'Khan was a pair of scorched boots.]],
	color = colors.DARK_GRAY,
	level_range = {30, 40},
	rarity = 250,
	cost = 200,
	material_level = 5,
	wielder = {
		combat_armor = 4,
		combat_def = 4,
		fatigue = 8,
		combat_spellpower = 13,
		inc_damage = { [DamageType.BLIGHT] = 15 },
	},
}

newEntity{ base = "BASE_GEM",
	power_source = {arcane=true},
	unique = true,
	unided_name = "unearthly black stone",
	name = "Goedalath Rock", subtype = "black", image = "object/artifact/goedalath_rock.png",
	color = colors.PURPLE,
	level_range = {42, 50},
	desc = [[A small rock that seems from beyond this world, vibrating with a fierce energy.  It feels warped and terrible and evil... and yet oh so powerful.]],
	rarity = 300,
	cost = 300,
	material_level = 5,
	carrier = {
		on_melee_hit = {[DamageType.HEAL] = 34},
		life_regen = -2,
		lite = -2,
		combat_mentalresist = -18,
		healing_factor = -0.5,
	},
	imbue_powers = {
		combat_dam = 12,
		combat_spellpower = 16,
		see_invisible = 14,
		infravision = 3,
		inc_damage = {all = 9},
		inc_damage_type = {demon = 20},
		esp = {["demon/major"]=1, ["demon/minor"]=1},
		on_melee_hit = {[DamageType.DARKNESS] = 34},
		healing_factor = 0.5,
	},
}

newEntity{ base = "BASE_CLOAK",
	power_source = {arcane=true},
	unique = true,
	name = "Threads of Fate", image = "object/artifact/cloak_threads_of_fate.png",
	unided_name = "a shimmering white cloak",
	desc = [[Untouched by the ravages of time, this fine spun white cloak appears to be crafted of an otherworldly material that shifts and shimmers in the light.  While it has cropped up in the hands of many through out history, from great mages to lowly card sharks, no one has ever claimed to be its creator or know its true origins.]],
	level_range = {45, 50},
	color = colors.WHITE,
	rarity = 500,
	cost = 300,
	material_level = 5,

	wielder = {
		combat_def = 10,
		combat_spellpower = 8,
		confusion_immune = 0.4,
		inc_stats = { [Stats.STAT_MAG] = 6, [Stats.STAT_WIL] = 6, [Stats.STAT_LCK] = 10, },

		inc_damage = { [DamageType.TEMPORAL]= 10 },
		resists_cap = { [DamageType.TEMPORAL] = 10, },
		resists = { [DamageType.TEMPORAL] = 20, },
		combat_physresist = 20,
		combat_mentalresist = 20,
		combat_spellresist = 20,

		talents_types_mastery = {
			["chronomancy/timeline-threading"] = 0.1,
			["chronomancy/chronomancy"] = 0.1,
			["spell/divination"] = 0.1,
		},
	},

	max_power = 1000, power_regen = 1,
	use_talent = { id = Talents.T_SEE_THE_THREADS, level = 1, power = 1000 },
}
