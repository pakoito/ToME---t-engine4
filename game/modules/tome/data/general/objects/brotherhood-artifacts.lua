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
load("/data/general/objects/scrolls.lua")
load("/data/general/objects/gem.lua")

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

-- This file describes the twelve elixirs and three artifacts obtainable through the Brotherhood of Alchemists quest

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_FOX",
	type = "potion", subtype="potion", image = "object/elixir_of_the_fox.png",
	name = "Elixir of the Fox", unique=true, unided_name="vial of pink fluid",
	display = "!", color=colors.VIOLET,
	desc = [[A vial of pink, airy fluid.]],
	no_unique_lore = true,
	cost = 1000,

	use_simple = { name="permanently increase your dexterity and cunning by three", use = function(self, who)
		game.logPlayer(who, "#00FFFF#You drink the elixir and feel forever transformed!")
		who.inc_stats[who.STAT_DEX] = who.inc_stats[who.STAT_DEX] + 3
		who:onStatChange(who.STAT_DEX, 3)
		who.inc_stats[who.STAT_CUN] = who.inc_stats[who.STAT_CUN] + 3
		who:onStatChange(who.STAT_CUN, 3)
		game.logPlayer(who, "#00FF00#The elixir has given you foxlike physical and mental agility!")
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_AVOIDANCE",
	type = "potion", subtype="potion", image = "object/elixir_of_avoidance.png",
	name = "Elixir of Avoidance", unique=true, unided_name="vial of green fluid",
	display = "!", color=colors.GREEN,
	desc = [[A vial of opaque green fluid.]],
	no_unique_lore = true,
	cost = 1000,

	use_simple = { name="permanently increase your defense and ranged defense by six", use = function(self, who)
		game.logPlayer(who, "#00FFFF#You drink the elixir and feel forever transformed!")
		who.combat_def = who.combat_def + 6
		game.logPlayer(who, "#00FF00#The elixir has improved your defensive instincts!")
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_PRECISION",
	type = "potion", subtype="potion", image = "object/elixir_of_precision.png",
	name = "Elixir of Precision", unique=true, unided_name="vial of red fluid",
	display = "!", color=colors.RED,
	desc = [[A vial of chunky red fluid.]],
	no_unique_lore = true,
	cost = 1000,

	use_simple = { name="permanently increase your physical critical strike chance by 4%", use = function(self, who)
		game.logPlayer(who, "#00FFFF#You drink the elixir and feel forever transformed!")
		who.combat_physcrit = who.combat_physcrit + 4
		game.logPlayer(who, "#00FF00#The elixir has improved your eye for an enemy's weak points!")
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_MYSTICISM",
	type = "potion", subtype="potion", image = "object/elixir_of_mysticism.png",
	name = "Elixir of Mysticism", unique=true, unided_name="vial of cyan fluid",
	display = "!", color=colors.AQUAMARINE,
	desc = [[A vial of glowing cyan fluid.]],
	no_unique_lore = true,
	cost = 1000,

	use_simple = { name="permanently increase your magic and willpower by three", use = function(self, who)
		game.logPlayer(who, "#00FFFF#You drink the elixir and feel forever transformed!")
		who.inc_stats[who.STAT_MAG] = who.inc_stats[who.STAT_MAG] + 3
		who:onStatChange(who.STAT_MAG, 3)
		who.inc_stats[who.STAT_WIL] = who.inc_stats[who.STAT_WIL] + 3
		who:onStatChange(who.STAT_WIL, 3)
		game.logPlayer(who, "#00FF00#The elixir has augmented your magical and mental capacity!")
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_SAVIOR",
	type = "potion", subtype="potion", image = "object/elixir_of_the_saviour.png",
	name = "Elixir of the Savior", unique=true, unided_name="vial of grey fluid",
	display = "!", color=colors.GREY,
	desc = [[A vial of bubbling, slate-colored fluid.]],
	no_unique_lore = true,
	cost = 1000,

	use_simple = { name="permanently increase all your saving throws by 4", use = function(self, who)
		game.logPlayer(who, "#00FFFF#You drink the elixir and feel forever transformed!")
		who.combat_physresist = who.combat_physresist + 4
		who.combat_spellresist = who.combat_spellresist + 4
		who.combat_mentalresist = who.combat_mentalresist + 4
		game.logPlayer(who, "#00FF00#The elixir has improved your resistance to unpleasant effects!")
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_MASTERY",
	type = "potion", subtype="potion", image = "object/elixir_of_mastery.png",
	name = "Elixir of Mastery", unique=true, unided_name="vial of maroon fluid",
	display = "!", color=colors.DARK_RED,
	desc = [[A vial of thick maroon fluid.]],
	no_unique_lore = true,
	cost = 1000,

	use_simple = { name="grant you four additional stat points", use = function(self, who)
		game.logPlayer(who, "#00FFFF#You drink the elixir and feel forever transformed!")
		who.unused_stats = who.unused_stats + 4
		game.logPlayer(who, "#00FF00#The elixir has greatly expanded your capacity for improving your mind and body.")
		game.logPlayer(who, "You have %d stat point(s) to spend. Press G to use them.", who.unused_stats)
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_FORCE",
	type = "potion", subtype="potion", image = "object/elixir_of_explosive_force.png",
	name = "Elixir of Explosive Force", unique=true, unided_name="vial of orange fluid",
	display = "!", color=colors.ORANGE,
	desc = [[A vial of churning orange fluid.]],
	no_unique_lore = true,
	cost = 1000,

	use_simple = { name="permanently increase your chance to critically strike with spells by 4%", use = function(self, who)
		game.logPlayer(who, "#00FFFF#You drink the elixir and feel forever transformed!")
		who.combat_spellcrit = who.combat_spellcrit + 4
		game.logPlayer(who, "#00FF00#The elixir has improved your eye for an enemy's magical weak points!")
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_SERENDIPITY",
	type = "potion", subtype="potion", image = "object/elixir_of_serendipity.png",
	name = "Elixir of Serendipity", unique=true, unided_name="vial of yellow fluid",
	display = "!", color=colors.YELLOW,
	desc = [[A vial of lifelike yellow fluid.]],
	no_unique_lore = true,
	cost = 1000,

	use_simple = { name="permanently increase your luck by 5", use = function(self, who)
		game.logPlayer(who, "#00FFFF#You drink the elixir and feel forever transformed!")
		who.inc_stats[who.STAT_LCK] = who.inc_stats[who.STAT_LCK] + 5
		who:onStatChange(who.STAT_LCK, 5)
		game.logPlayer(who, "#00FF00#The elixir seems to have subtly repositioned your entire being within the fabric of reality!")
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_FOCUS",
	type = "potion", subtype="potion", image = "object/elixir_of_focus.png",
	name = "Elixir of Focus", unique=true, unided_name="vial of clear fluid",
	display = "!", color=colors.WHITE,
	desc = [[A vial of clear, steaming fluid.]],
	no_unique_lore = true,
	cost = 1000,

	use_simple = { name="grant you two additional class talent points", use = function(self, who)
		game.logPlayer(who, "#00FFFF#You drink the elixir and feel forever transformed!")
		who.unused_talents = who.unused_talents + 2
		game.logPlayer(who, "#00FF00#The elixir has improved your capacity for exercising your core talents.")
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_BRAWN",
	type = "potion", subtype="potion", image = "object/elixir_of_brawn.png",
	name = "Elixir of Brawn", unique=true, unided_name="vial of tan fluid",
	display = "!", color=colors.TAN,
	desc = [[A vial of sluggish tan fluid.]],
	no_unique_lore = true,
	cost = 1000,

	use_simple = { name="permanently increase your strength and constitution by three", use = function(self, who)
		game.logPlayer(who, "#00FFFF#You drink the elixir and feel forever transformed!")
		who.inc_stats[who.STAT_STR] = who.inc_stats[who.STAT_STR] + 3
		who:onStatChange(who.STAT_STR, 3)
		who.inc_stats[who.STAT_CON] = who.inc_stats[who.STAT_CON] + 3
		who:onStatChange(who.STAT_CON, 3)
		game.logPlayer(who, "#00FF00#The elixir has augmented your physical might and resilience!")
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_STONESKIN",
	type = "potion", subtype="potion", image = "object/elixir_of_stoneskin.png",
	name = "Elixir of Stoneskin", unique=true, unided_name="vial of iron-colored fluid",
	display = "!", color=colors.SLATE,
	desc = [[A vial of grainy, iron-colored fluid.]],
	no_unique_lore = true,
	cost = 1000,

	use_simple = { name="permanently increase your armor by four", use = function(self, who)
		game.logPlayer(who, "#00FFFF#You drink the elixir and feel forever transformed!")
		who.combat_armor = who.combat_armor + 4
		game.logPlayer(who, "#00FF00#The elixir has reinforced your entire body!")
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_FOUNDATIONS",
	type = "potion", subtype="potion", image = "object/elixir_of_foundations.png",
	name = "Elixir of Foundations", unique=true, unided_name="vial of white fluid",
	display = "!", color=colors.WHITE,
	desc = [[A vial of murky white fluid.]],
	no_unique_lore = true,
	cost = 1000,

	use_simple = { name="grant you two additional generic talent points", use = function(self, who)
		game.logPlayer(who, "#00FFFF#You drink the elixir and feel forever transformed!")
		who.unused_generics = who.unused_generics + 2
		game.logPlayer(who, "#00FF00#The elixir has improved your capacity for exercising your core talents.")
		return {used=true, id=true, destroy=true}
	end}
}

-- The four possible final rewards for the Brotherhood of Alchemists quest:

newEntity{ base = "BASE_TAINT",
	name = "Taint of Telepathy",
	define_as = "TAINT_TELEPATHY", image = "object/taint_of_telepathy.png",
	unique = true,
	identified = true,
	cost = 200,
	material_level = 3,

	inscription_kind = "utility",
	inscription_data = {
		cooldown = 30,
		dur = 5,
	},
	inscription_talent = "TAINT:_TELEPATHY",
}

newEntity{ base = "BASE_INFUSION",
	name = "Infusion of Wild Growth",
	define_as = "INFUSION_WILD_GROWTH", image = "object/infusion_of_wild_growth.png",
	unique = true,
	identified = true,
	cost = 200,
	material_level = 3,

	inscription_kind = "utility",
	inscription_data = {
		cooldown = 30,
		dur = 5,
	},
	inscription_talent = "INFUSION:_WILD_GROWTH",
}

newEntity{ base = "BASE_GEM",
	define_as = "LIFEBINDING_EMERALD",
	power_source = {nature=true},
	unique = true,
	unided_name = "cloudy, heavy emerald",
	name = "Lifebinding Emerald", subtype = "green", image = "object/lifebinding_emerald.png",
	color = colors.GREEN,
	desc = [[A lopsided, heavy emerald with murky green clouds shifting sluggishly under the surface.]],
	cost = 200,
	material_level = 5,
	wielder = {
		inc_stats = {[Stats.STAT_CON] = 10, },
		healing_factor = 0.3,
		life_regen = 2,
		resists = {
			[DamageType.BLIGHT] = 10,
		},
	},
	imbue_powers = {
		inc_stats = {[Stats.STAT_CON] = 10, },
		healing_factor = 0.3,
		life_regen = 2,
		stun_immune = 0.3,
		resists = {
			[DamageType.BLIGHT] = 10,
		},
	},
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_INVULNERABILITY",
	encumber = 2,
	type = "potion", subtype="potion", image = "object/elixir_of_invulnerability.png",
	name = "Elixir of Invulnerability", unique=true, unided_name="vial of black fluid",
	display = "!", color=colors.SLATE,
	desc = [[A vial of thick fluid, metallic and reflective. It's incredibly heavy.]],
	cost = 200,

	use_simple = { name="grant you complete invulnerability for five turns", use = function(self, who)
		who:setEffect(who.EFF_DAMAGE_SHIELD, 5, {power=1000000})
		game.logPlayer(who, "#00FF00#You feel indestructible!")
		return {used=true, id=true, destroy=true}
	end}
}
