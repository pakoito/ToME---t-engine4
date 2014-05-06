-- ToME - Tales of Middle-Earth
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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

-- This file describes artifacts associated with unique enemies that can appear anywhere their base enemy can.

newEntity{ define_as = "RUNGOF_FANG",
	power_source = {nature=true},
	unique = true,
	type = "misc", subtype="fang",
	unided_name = "bloodied fang",
	name = "Rungof's Fang", image = "object/artifact/rungof_fang.png",
	level_range = {20, 35},
	rarity = false,
	display = "*", color=colors.DARK_RED,
	encumber = 1,
	not_in_stores = true,
	desc = [[A fang from the great warg, Rungof, still covered in blood.]],

	carrier = {
		combat_apr = 7,
		esp = {['animal/canine']=1},
	},
}

newEntity{ base = "BASE_BATTLEAXE",
	power_source = {arcane=true},
	define_as = "KHULMANAR_WRATH",
	name = "Khulmanar's Wrath", color = colors.DARK_RED, image = "object/artifact/hellfire.png",
	unided_name = "firey blackened battleaxe", unique = true,
	desc = [[Blackened with soot and covered in spikes, this battleaxe roars with the flames of the Fearscape. Given by Urh'Rok himself to his general, this powerful weapon can burn even the most resilient of foes.]],
	level_range = {37, 50},
	rarity = 300,
	require = { stat = { str=52 }, },
	cost = 600,
	material_level = 5,
	combat = {
		dam = 70,
		apr = 8,
		physcrit = 8,
		dammod = {str=1.2},
		convert_damage = {[DamageType.FIRE] = 20},
		melee_project={[DamageType.FIRE] = 50,}
	},
	wielder = {
		demon=1,
		inc_damage={
			[DamageType.FIRE] = 20,
		},
		resists={
			[DamageType.FIRE] = 20,
		},
		resists_pen={
			[DamageType.FIRE] = 25,
		},
	},
	max_power = 35, power_regen = 1,
	use_talent = { id = Talents.T_INFERNAL_BREATH, level = 3, power = 35 },
}

newEntity{ base = "BASE_TOOL_MISC", image="object/temporal_instability.png",
	power_source = {arcane=true, psionic=true},
	define_as = "BLADE_RIFT",
	unique = true,
	name = "The Bladed Rift", color = colors.BLUE, image = "object/artifact/bladed_rift.png",
	unided_name = "hole in space",
	desc = [[Upon defeat, Ak'Gishil collapsed into this tiny rift. How it remains stable, you are unsure. If you focus, you think you can call forth a sword from it.]],
	level_range = {30, 50},
	rarity = 500,
	cost = 500,
	material_level = 5,
	metallic = false,
	use_no_energy = true,
	special_desc = function(self) return "This item does not take a turn to use." end,
	wielder = {
		combat_spellpower=10,
		combat_mindpower=10,
		on_melee_hit = {[DamageType.PHYSICALBLEED]=25},
		melee_project = {[DamageType.PHYSICALBLEED]=25},
		resists={
			[DamageType.TEMPORAL] 	= 15,
		},
		inc_damage={
			[DamageType.TEMPORAL] 	= 10,
			[DamageType.PHYSICAL] 	= 5,
		},
	},
	-- Trinket slots are allowed to have extremely good actives because of their opportunity cost
	max_power = 25, power_regen = 1,
	use_talent = { id = Talents.T_ANIMATE_BLADE, level = 1, power = 15 },
}

newEntity{ base = "BASE_LONGSWORD", define_as = "RIFT_SWORD",
	power_source = {arcane=true},
	unique = true,
	name = "Blade of Distorted Time", image = "object/artifact/blade_of_distorted_time.png",
	unided_name = "time-warped sword",
	desc = [[The remnants of a damaged timeline, this blade shifts and fades at random.]],
	level_range = {30, 50},
	rarity = 220,
	require = { stat = { str=44 }, },
	cost = 300,
	material_level = 4,
	combat = {
		dam = 40,
		apr = 10,
		physcrit = 8,
		dammod = {str=0.9,mag=0.2},
		convert_damage={[DamageType.TEMPORAL] = 20},
		special_on_hit = {desc="inflicts bonus temporal damage and slows target", fct=function(combat, who, target)
			local dam = (20 + who:getMag()/2)
			local slow = (10 + who:getMag()/5)/100
			who:project({type="hit", range=1}, target.x, target.y, engine.DamageType.CHRONOSLOW, {dam=dam, slow=slow})
		end},
	},
	wielder = {
		inc_damage={
			[DamageType.TEMPORAL] = 12,
			[DamageType.PHYSICAL] = 10,
		},
	},
	max_power = 8, power_regen = 1,
	use_talent = { id = Talents.T_RETHREAD, level = 2, power = 8 },
}

newEntity{ base = "BASE_RUNE", define_as = "RUNE_REFLECT",
	name = "Rune of Reflection", unique=true, image = "object/artifact/rune_of_reflection.png",
	desc = [[You can see your own image mirrored in the surface of this silvery rune.]],
	unided_name = "shiny rune",
	level_range = {5, 15},
	rarity = 240,
	cost = 100,
	material_level = 3,

	inscription_kind = "protect",
	inscription_data = {
		cooldown = 15,
	},
	inscription_talent = "RUNE:_REFLECTION_SHIELD",
}

newEntity{ base = "BASE_BATTLEAXE",
	power_source = {nature=true, antimagic=true},
	define_as = "GAPING_MAW",
	name = "The Gaping Maw", color = colors.SLATE, image = "object/artifact/battleaxe_the_gaping_maw.png",
	unided_name = "huge granite battleaxe", unique = true,
	desc = [[This huge granite battleaxe is as much mace as it is axe.  The shaft is made of blackened wood tightly bound in drakeskin leather and the sharpened granite head glistens with a viscous green fluid.]],
	level_range = {38, 50},
	rarity = 300,
	require = { stat = { str=60 }, },
	metallic = false,
	cost = 650,
	material_level = 5,
	combat = {
		dam = 72,
		apr = 4,
		physcrit = 8,
		dammod = {str=1.2},
		melee_project={[DamageType.SLIME] = 50, [DamageType.ACID] = 50},
		special_on_crit = {desc="deal manaburn damage equal to your mindpower in a radius 3 cone", on_kill=1, fct=function(combat, who, target)
			who.turn_procs.gaping_maw = (who.turn_procs.gaping_maw or 0) + 1
			local tg = {type="cone", range=10, radius=3, force_target=target, selffire=false}
			local grids = who:project(tg, target.x, target.y, engine.DamageType.MANABURN, who:combatMindpower() / (who.turn_procs.gaping_maw))
			game.level.map:particleEmitter(target.x, target.y, tg.radius, "directional_shout", {life=8, size=3, tx=target.x-who.x, ty=target.y-who.y, distorion_factor=0.1, radius=3, nb_circles=8, rm=0.8, rM=1, gm=0.4, gM=0.6, bm=0.1, bM=0.2, am=1, aM=1})
			who.turn_procs.gaping_maw = (who.turn_procs.gaping_maw or 0) + 1
		end},
	},
	wielder = {
		talent_cd_reduction= {
			[Talents.T_SWALLOW] = 2,
			[Talents.T_MANA_CLASH] = 2,
			[Talents.T_ICE_CLAW] = 1,
		},
	},
	on_wear = function(self, who)
		if who:attr("forbid_arcane") then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder","inc_damage"}, {[DamageType.NATURE]=15})
			self:specialWearAdd({"wielder","inc_stats"}, { [Stats.STAT_STR] = 6, [Stats.STAT_WIL] = 6, })
			game.logPlayer(who, "#DARK_GREEN#You feel like Nature's Wrath incarnate!")
		end
	end,
}