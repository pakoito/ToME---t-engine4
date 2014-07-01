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

-- This file describes artifacts associated with a boss of the game, they have a high chance of dropping their respective ones, but they can still be found elsewhere

newEntity{ base = "BASE_KNIFE", define_as = "LIFE_DRINKER",
	power_source = {arcane=true},
	unique = true,
	name = "Life Drinker", image = "object/artifact/dagger_life_drinker.png",
	unided_name = "blood coated dagger",
	desc = [[Black blood for foul deeds. This dagger serves evil.]],
	level_range = {40, 50},
	rarity = 300,
	require = { stat = { mag=44 }, },
	cost = 450,
	material_level = 5,
	combat = {
		dam = 42,
		apr = 11,
		physcrit = 18,
		dammod = {mag=0.55,str=0.35},
	},
	wielder = {
		inc_damage={
			[DamageType.BLIGHT] = 15,
			[DamageType.DARKNESS] = 15,
			[DamageType.ACID] = 15,
		},
		combat_spellpower = 12,
		combat_spellcrit = 10,
		inc_stats = { [Stats.STAT_MAG] = 6, [Stats.STAT_CUN] = 6, },
		infravision = 2,
	},
	max_power = 50, power_regen = 1,
	use_talent = { id = Talents.T_WORM_ROT, level = 2, power = 40 },
	talent_on_spell = {
		{chance=15, talent=Talents.T_BLOOD_GRASP, level=2},
	},
}

newEntity{ base = "BASE_TRIDENT",
	power_source = {nature=true},
	define_as = "TRIDENT_TIDES",
	unided_name = "ever-dripping trident",
	name = "Trident of the Tides", unique=true, image = "object/artifact/trident_of_the_tides.png",
	desc = [[The power of the tides rush through this trident.
Tridents require the exotic weapons mastery talent to use correctly.]],
	require = { stat = { str=35 }, },
	level_range = {30, 40},
	rarity = 230,
	cost = 300,
	material_level = 4,
	combat = {
		dam = 80,
		apr = 20,
		physcrit = 15,
		dammod = {str=1.4},
		damrange = 1.4,
		melee_project={
			[DamageType.COLD] = 15,
			[DamageType.NATURE] = 20,
		},
		talent_on_hit = { T_WATER_BOLT = {level=3, chance=40} }
	},

	wielder = {
		combat_atk = 10,
		combat_spellresist = 18,
		see_invisible = 2,
		resists={[DamageType.COLD] = 25},
		inc_damage = { [DamageType.COLD] = 20 },
	},

	talent_on_spell = { {chance=20, talent="T_WATER_BOLT", level=3} },

	max_power = 150, power_regen = 1,
	use_talent = { id = Talents.T_FREEZE, level=3, power = 60 },
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	define_as = "FIERY_CHOKER", 
	unided_name = "flame-wrought amulet",
	name = "Fiery Choker", unique=true, image="object/artifact/fiery_choker.png",
	desc = [[A choker made of pure flame, casting forever shifting patterns around the neck of its wearer. Its fire seems to not harm the wearer.]],
	level_range = {32, 42},
	rarity = 220,
	cost = 190,
	material_level = 3,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 4, [Stats.STAT_CUN] = 3 },
		combat_spellpower = 7,
		combat_spellcrit = 8,
		resists = {
			[DamageType.FIRE] = 20,
			[DamageType.COLD] = -20,
		},
		inc_damage={
			[DamageType.FIRE] = 10,
			[DamageType.COLD] = -5,
		},
		damage_affinity={
			[DamageType.FIRE] = 30,
		},
		blind_immune = 0.4,
	},
	talent_on_spell = { {chance=10, talent=Talents.T_VOLCANO, level=3} },
}

newEntity{ base = "BASE_HEAVY_ARMOR",
	power_source = {nature=true},
	define_as = "CHROMATIC_HARNESS", image = "object/artifact/armor_chromatic_harness.png",
	name = "Chromatic Harness", unique=true,
	unided_name = "multi-hued scale-mail armour", color=colors.VIOLET,
	desc = [[This dragon scale harness shines with multiple colors, quickly shifting through them in a seemingly chaotic manner.]],
	level_range = {40, 50},
	rarity = 280,
	cost = 500,
	material_level = 5,
	wielder = {
		talent_cd_reduction={[Talents.T_ICE_BREATH]=3, [Talents.T_FIRE_BREATH]=3, [Talents.T_SAND_BREATH]=3, [Talents.T_LIGHTNING_BREATH]=3, [Talents.T_CORROSIVE_BREATH]=3,},
		inc_stats = { [Stats.STAT_WIL] = 6, [Stats.STAT_CUN] = 4, [Stats.STAT_STR] = 6, [Stats.STAT_LCK] = 10, },
		blind_immune = 0.5,
		stun_immune = 0.25,
		knockback_immune = 0.5,
		esp = { dragon = 1 },
		combat_def = 10,
		combat_armor = 14,
		fatigue = 16,
		resists = {
			[DamageType.COLD] = 20,
			[DamageType.LIGHTNING] = 20,
			[DamageType.FIRE] = 20,
			[DamageType.ACID] = 20,
			[DamageType.PHYSICAL] = 20,
		},
	},
}

-- Randart rings are REALLY good, these need to be brought up to par
newEntity{ base = "BASE_RING",
	power_source = {technique=true},
	define_as = "PRIDE_GLORY",
	name = "Glory of the Pride", unique=true, image="object/artifact/glory_of_the_pride.png",
	desc = [[The most prized treasure of the Battlemaster of the Pride, Grushnak. This gold ring is inscribed in the now lost orc tongue.]],
	unided_name = "deep black ring",
	level_range = {40, 50},
	rarity = 280,
	cost = 500,
	material_level = 5,
	wielder = {
		max_mana = -40,
		max_stamina = 40,
		combat_physresist = 45,
		confusion_immune = 0.5,
		combat_atk = 10,
		combat_dam = 10,
		combat_def = 5,
		combat_armor = 10,
		combat_armor_hardiness = 20,
		fatigue = -15,
		talent_cd_reduction={
			[Talents.T_RUSH]=6,
		},
		inc_damage={ [DamageType.PHYSICAL] = 8, },
	},
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {arcane=true},
	define_as = "BLACK_ROBE",
	name = "Black Robe", unique=true,
	unided_name = "black robe", color=colors.DARK_GREY, image = "object/artifact/robe_black_robe.png",
	desc = [[A silk robe, darker than the darkest night sky, it radiates power.]],
	level_range = {40, 50},
	rarity = 280,
	cost = 500,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 4, [Stats.STAT_CUN] = 3 },
		see_invisible = 10,
		blind_immune = 0.5,
		combat_spellpower = 30,
		combat_spellresist = 25,
		combat_dam = 10,
		combat_def = 6,
	},
	talent_on_spell = {
		{chance=5, talent=Talents.T_SOUL_ROT, level=3},
		{chance=5, talent=Talents.T_BLOOD_GRASP, level=3},
		{chance=5, talent=Talents.T_BONE_SPEAR, level=3},
	},
}

newEntity{ base = "BASE_LEATHER_CAP",
	power_source = {arcane=true},
	define_as = "CROWN_ELEMENTS", 
	name = "Crown of the Elements", unique=true, image = "object/artifact/crown_of_the_elements.png",
	unided_name = "jeweled crown", color=colors.DARK_GREY,
	desc = [[This jeweled crown shimmers with colors.]],
	level_range = {40, 50},
	rarity = 280,
	cost = 500,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 5, [Stats.STAT_WIL] = 3, },
		resists={
			[DamageType.FIRE] = 15,
			[DamageType.COLD] = 15,
			[DamageType.ACID] = 15,
			[DamageType.LIGHTNING] = 15,
		},
		melee_project={
			[DamageType.FIRE] = 10,
			[DamageType.COLD] = 10,
			[DamageType.ACID] = 10,
			[DamageType.LIGHTNING] = 10,
		},
		inc_damage = {
			[DamageType.FIRE] = 8,
			[DamageType.COLD] = 8,
			[DamageType.ACID] = 8,
			[DamageType.LIGHTNING] = 8,
		},
		see_invisible = 15,
		combat_armor = 5,
		fatigue = 5,
	},
}

newEntity{ base = "BASE_GREATSWORD",
	power_source = {technique=true},
	define_as = "MURDERBLADE",
	name = "Warmaster Gnarg's Murderblade", unique=true, image="object/artifact/warmaster_gnargs_murderblade.png",
	unided_name = "blood-etched greatsword", color=colors.CRIMSON,
	desc = [[A blood-etched greatsword, it has seen many foes. From the inside.]],
	require = { stat = { str=35 }, },
	level_range = {32, 45},
	rarity = 230,
	cost = 300,
	material_level = 4,
	combat = {
		dam = 60,
		apr = 19,
		physcrit = 10,
		dammod = {str=1.2},
		special_on_hit = {desc="10% chance to send the wielder into a killing frenzy", on_kill=1, fct=function(combat, who)
			if not rng.percent(10) then return end
			who:setEffect(who.EFF_FRENZY, 3, {crit=12, power=0.3, dieat=0.25})
		end},
		inc_damage_type = {living=20},
	},
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 15, [Stats.STAT_STR] = 15, [Stats.STAT_DEX] = 5, },
		talents_types_mastery = {
			["technique/2hweapon-cripple"] = 0.2,
			["technique/2hweapon-offense"] = 0.2,
			["technique/2hweapon-assault"] = 0.2,
		},
		resists_actor_type = {living=20},
	},
}

newEntity{ base = "BASE_WHIP",
	power_source = {arcane=true},
	define_as = "WHIP_URH_ROK",
	unided_name = "fiery whip",
	name = "Whip of Urh'Rok", color=colors.PURPLE, unique = true, image = "object/artifact/whip_of_urh_rok.png",
	desc = [[With this unbearably bright whip of flame, the demon master Urh'Rok has become known for never having lost in combat.]],
	require = { stat = { dex=48 }, },
	level_range = {40, 50},
	rarity = 390,
	cost = 250,
	material_level = 5,
	combat = {
		dam = 55,
		apr = 0,
		physcrit = 9,
		dammod = {dex=1},
		damtype = DamageType.FIREKNOCKBACK,
		talent_on_hit = { [Talents.T_BONE_NOVA] = {level=4, chance=20}, [Talents.T_BLOOD_BOIL] = {level=3, chance=15} },
	},
	wielder = {
		esp = {["demon/minor"]=1, ["demon/major"]=1},
		see_invisible = 2,
		combat_spellpower = 15,
		inc_damage={
			[DamageType.FIRE] = 20,
			[DamageType.BLIGHT] = 20,
	},
	},
	carrier = {
		inc_damage={
			[DamageType.BLIGHT] = 8,
		},
	},
}

--Storm fury, lightning infused bow that automatically attacks nearby enemies with bolts of lightning.
newEntity{ base = "BASE_LONGBOW",
	power_source = {arcane=true},
	define_as = "STORM_FURY",
	name = "Storm Fury", unique=true,
	unided_name = "crackling longbow", color=colors.BLUE,
	desc = [[This dragonbone longbow is enhanced with bands of steel, which arc with intense lightning. Bolts travel up and down the string, ignorant of you.]],
	require = { stat = { dex=30, mag=30 }, },
	level_range = {40, 50},
	rarity = 250,
	cost = 300,
	material_level = 5,
	sentient = true,
	special_desc = function(self) return "Automatically fires lightning bolts at nearby enemies, with a chance to inflict Daze." end,
	combat = {
		range=10,
		physspeed = 0.7,
	},
	wielder = {
		combat_spellpower=20,
		inc_stats = { [Stats.STAT_MAG] = 7, [Stats.STAT_DEX] = 5},
		combat_def_ranged = 15,
		ranged_project = {[DamageType.LIGHTNING] = 75},
		talents_types_mastery = {
			["spell/air"] = 0.2,
			["spell/storm"] = 0.1,
		},
		inc_damage={
			[DamageType.LIGHTNING] = 20,
		},
		resists={
			[DamageType.LIGHTNING] = 20,
		},
		talent_on_hit = { T_CHAIN_LIGHTNING = {level=3, chance=12},},
		movement_speed=0.1,
	},
	act = function(self)
		self:useEnergy()
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) then self.worn_by = nil return end
		if self.worn_by:attr("dead") then return end
		self.zap = self.zap + 5
		if not rng.percent(self.zap)  then return end
		local who = self.worn_by
		local Map = require "engine.Map"
		--local project = require "engine.DamageType"
		local tgts = {}
		local DamageType = require "engine.DamageType"
		--local project = "engine.ActorProject"
		local grids = core.fov.circle_grids(who.x, who.y, 5, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and who:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		local tg = {type="hit", range=5,}
		for i = 1, 1 do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self.zap = 0
			who:project(tg, a.x, a.y, engine.DamageType.LIGHTNING_DAZE, {daze=40, dam = rng.avg(1,3) * (40+ who:getMag() * 1.5)} )
			game.level.map:particleEmitter(who.x, who.y, math.max(math.abs(a.x-who.x), math.abs(a.y-who.y)), "lightning", {tx=a.x-who.x, ty=a.y-who.y})
			game:playSoundNear(self, "talents/lightning")
			who:logCombat(a, "#GOLD#A bolt of lightning fires from #Source#'s bow, striking #Target#!")
		end
	end,
	on_wear = function(self, who)
		self.worn_by = who
		self.zap = 0
	end,
	on_takeoff = function(self)
		self.worn_by = nil
	end,
}
--Ice Cloak that can release massive freezing AOE, dropped by Glacial Legion.
newEntity{ base = "BASE_CLOAK", define_as="GLACIAL_CLOAK",
	power_source = {arcane=true},
	unique = true,
	name = "Frozen Shroud", 
	unided_name = "chilling cloak", image = "object/artifact/frozen_shroud.png",
	desc = [[All that remains of the Glacial Legion. This cloak seems to exude an icy cold vapor that freezes all it touches.]],
	level_range = {40, 50},
	rarity = 250,
	cost = 300,
	material_level = 5,
	wielder = {
		resists= {[DamageType.FIRE] = -15,[DamageType.COLD] = 25, all=8},
		inc_stats = { [Stats.STAT_MAG] = 7,},
		combat_def = 12,
		on_melee_hit = {[DamageType.ICE]=60},
	},
	max_power = 30, power_regen = 1,
	use_power = { name = "release a blast of ice", power = 30,
		use = function(self, who)
			local duration = 10
			local radius = 4
			local dam = (25 + who:getMag())
			local blast = {type="ball", range=0, radius=radius, selffire=false, display={particle="bolt_ice", trail="icetrail"}}
			who:project(blast, who.x, who.y, engine.DamageType.COLD, dam*3)
			who:project(blast, who.x, who.y, engine.DamageType.FREEZE, {dur=6, hp=80+dam})
			game.level.map:particleEmitter(who.x, who.y, blast.radius, "iceflash", {radius=blast.radius})
			-- Add a lasting map effect
			game.level.map:addEffect(who,
				who.x, who.y, duration,
				engine.DamageType.ICE, dam,
				radius,
				5, nil,
				engine.MapEffect.new{color_br=255, color_bg=255, color_bb=255, effect_shader="shader_images/ice_effect.png"},
				function(e)
					e.radius = e.radius
					return true
				end,
				false
			)
			game.logSeen(who, "%s releases a burst of freezing cold from within their cloak!", who.name:capitalize(), self:getName())
			return {id=true, used=true}
		end
	},
}
--Blight+Phys Greatmaul that inflicts disease, dropped by Rotting Titan.
newEntity{ base = "BASE_GREATMAUL", define_as="ROTTING_MAUL",
	power_source = {arcane=true},
	unique = true,
	name = "Blighted Maul", color = colors.LIGHT_RED,  image = "object/artifact/blighted_maul.png",
	unided_name = "rotten stone limb",
	desc = [[The massive stone limb of the Rotting Titan, a mass of stone and rotting flesh. You think you can lift it, but it is very heavy.]],
	level_range = {40, 50},
	rarity = 250,
	require = { stat = { str=60 }, },
	cost = 300,
	metallic = false,
	encumber = 12,
	material_level = 5,
	combat = {
		dam = 96,
		apr = 22,
		physcrit = 10,
		physspeed=1.2,
		dammod = {str=1.4},
		convert_damage = {[DamageType.BLIGHT] = 20},
		melee_project={[DamageType.ITEM_BLIGHT_DISEASE] = 50},
		special_on_hit = {desc="Damages enemies in radius 1 around your target (based on Strength).", on_kill=1, fct=function(combat, who, target)
			local o, item, inven_id = who:findInAllInventoriesBy("define_as", "ROTTING_MAUL")
			local dam = rng.avg(1,3) * (70+ who:getStr())
			game.logSeen(who, "The ground shakes as the %s hits!", o:getName())
			local tg = {type="ball", range=10, selffire=false, force_target=target, radius=1, no_restrict=true}
			who:project(tg, target.x, target.y, engine.DamageType.PHYSICAL, dam)
		end},
	},
	wielder = {
		inc_damage={[DamageType.PHYSICAL] = 12,},
		knockback_immune=0.3,
		combat_critical_power = 40,
	},
	max_power = 50, power_regen = 1,
	use_power = { name = "knock away nearby foes", power = 50,
		use = function(self, who)
			local dam = rng.avg(1,2) * (125+ who:getStr() * 3)
			local tg = {type="ball", range=0, selffire=false, radius=4, no_restrict=true}
			who:project(tg, who.x, who.y, engine.DamageType.PHYSKNOCKBACK, {dam=dam, dist=4})
			game.logSeen(who, "%s slams their %s into the ground, sending out a shockwave!", who.name:capitalize(), self:getName())
			return {id=true, used=true}
		end
	},
}
--Molten Skin, dropped by Heavy Sentinel.
newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {arcane=true},
	define_as = "ARMOR_MOLTEN",
	unided_name = "melting bony armour",
	name = "Molten Skin", unique=true, image = "object/artifact/molten_skin.png",
	desc = [[This mass of fused molten bone from the Heavy Sentinel radiates intense power. It still glows red with the heat of the Sentinel's core, and yet seems to do you no harm.]],
	level_range = {40, 50},
	rarity = 250,
	cost = 300,
	material_level=5,
	moddable_tile = "special/molten_skin",
	moddable_tile_big = true,

	wielder = {
		combat_spellpower = 15,
		combat_spellcrit = 10,
		combat_physcrit = 8,
		combat_damage = 10,
		combat_critical_power = 20,
		combat_def = 15,
		combat_armor = 12,
		inc_stats = { [Stats.STAT_MAG] = 6,[Stats.STAT_CUN] = 6,},
		melee_project={[DamageType.FIRE] = 30,[DamageType.LIGHT] = 15,},
		ranged_project={[DamageType.FIRE] = 30,[DamageType.LIGHT] = 15,},
		on_melee_hit = {[DamageType.FIRE]=30},
 		inc_damage={
			[DamageType.FIRE] = 20,
			[DamageType.LIGHT] = 5,
			all=10,
 		},
 		resists={
			[DamageType.FIRE] = 20,
			[DamageType.LIGHT] = 12,
			[DamageType.COLD] = -5,
 		},
 		resists_pen={
			[DamageType.FIRE] = 15,
			[DamageType.LIGHT] = 10,
 		},
 		talents_types_mastery = {
 			["spell/fire"] = 0.1,
 			["spell/wildfire"] = 0.1,
			["celestial/sun"] = 0.1,
			["celestial/sunlight"] = 0.1,
 		},
	},
	max_power = 16, power_regen = 1,
	use_talent = { id = Talents.T_BLASTWAVE, level = 4, power = 12 },
}

newEntity{ base = "BASE_RING",
	power_source = {arcane=true},
	define_as = "AETHER_RING",
	name = "Void Orb", unique=true, image = "object/artifact/void_orbs.png",
	desc = [[This thin grey ring is adorned with a deep black orb. Tiny white dots swirl slowly within it, and a faint purple light glows from its core.]],
	unided_name = "ethereal ring",
	level_range = {40, 50},
	rarity = 250,
	cost = 300,
	material_level = 5,
	wielder = {
		max_mana = 35,
		combat_spellresist = 10,
		combat_spellpower = 10,
		combat_spellcrit=5,
		silence_immune = 0.3,
		talent_cd_reduction={
			[Talents.T_AETHER_AVATAR]=4,
		},
		inc_damage={ [DamageType.ARCANE] = 15, [DamageType.PHYSICAL] = 4, [DamageType.FIRE] = 4, [DamageType.COLD] = 4, [DamageType.LIGHTNING] = 4, all=5},
		resists={ [DamageType.ARCANE] = 15,},
		resists_pen={ [DamageType.ARCANE] = 10,},
		melee_project={ [DamageType.ARCANE] = 15,},
		talents_types_mastery = {
 			["spell/arcane"] = 0.1,
 			["spell/aether"] = 0.1,
 		},
	},
	talent_on_spell = { {chance=10, talent="T_ARCANE_VORTEX", level = 2} },
	max_power = 6, power_regen = 1,
	use_talent = { id = Talents.T_MANATHRUST, level = 4, power = 6 },
}
