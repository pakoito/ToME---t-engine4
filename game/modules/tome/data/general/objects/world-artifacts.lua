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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

--- Load additional artifacts
for def, e in pairs(game.state:getWorldArtifacts()) do
	importEntity(e)
	print("Importing "..e.name.." into world artifacts")
end

-- This file describes artifacts not bound to a special location, they can be found anywhere

newEntity{ base = "BASE_GEM", 
	power_source = {arcane=true},
	unique = true,
	unided_name = "windy gem",
	name = "Windborne Azurite", subtype = "blue",
	color = colors.BLUE, image = "object/artifact/windborn_azurite.png",
	level_range = {18, 40},
	desc = [[Air currents swirl around this bright blue jewel.]],
	rarity = 240,
	cost = 200,
	identified = false,
	material_level = 4,
	wielder = {
		inc_stats = {[Stats.STAT_DEX] = 8, [Stats.STAT_CUN] = 8 },
		inc_damage = {[DamageType.LIGHTNING] = 20 },
		cancel_damage_chance = 8, -- add to tooltip
		damage_affinity={
			[DamageType.LIGHTNING] = 20,
		},
		movement_speed = 0.2,
	},
	imbue_powers = {
		inc_stats = {[Stats.STAT_DEX] = 8, [Stats.STAT_CUN] = 8 },
		inc_damage = {[DamageType.LIGHTNING] = 20 },
		cancel_damage_chance = 8,
		damage_affinity={
			[DamageType.LIGHTNING] = 20,
		},
		movement_speed = 0.15,
	},
}

-- Low base values because you can stack affinity and resist
-- The 3rd type is pretty meaningless balance-wise.  Magic debuffs hardly matter.  The real advantage is the affinity.
newEntity{ base = "BASE_INFUSION",
	name = "Primal Infusion", unique=true, image = "object/artifact/tree_of_life.png",
	desc = [[This wild infusion has evolved.]],
	unided_name = "pulsing infusion",
	level_range = {15, 40},
	rarity = 300,
	cost = 300,
	material_level = 3,

	inscription_kind = "protect",
	inscription_data = {
		cooldown = 18,
		dur = 6,
		power = 10,
		use_stat_mod = 0.1, 
		what = {physical=true, mental=true, magical=true},
	},
	inscription_talent = "INFUSION:_PRIMAL",
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	unique = true,
	name = "Staff of Destruction",
	flavor_name = "magestaff",
	unided_name = "darkness infused staff", image = "object/artifact/staff_of_destruction.png",
	level_range = {20, 25},
	color=colors.VIOLET,
	rarity = 170,
	desc = [[This unique-looking staff is carved with runes of destruction.]],
	cost = 200,
	material_level = 3,

	require = { stat = { mag=24 }, },
	modes = {"fire", "cold", "lightning", "arcane"},
	combat = {
		dam = 20,
		apr = 4,
		dammod = {mag=1.5},
		damtype = DamageType.FIRE,
		is_greater = true,
	},
	wielder = {
		combat_spellpower = 10,
		combat_spellcrit = 15,
		inc_damage={
			[DamageType.FIRE] = 20,
			[DamageType.LIGHTNING] = 20,
			[DamageType.COLD] = 20,
			[DamageType.ARCANE] = 20,
		},
		learn_talent = {[Talents.T_COMMAND_STAFF] = 1},
	},
	talent_on_spell = { {chance=10, talent=Talents.T_IMPENDING_DOOM, level=1}},
}

newEntity{ base = "BASE_RING",
	power_source = {nature=true},
	unique = true,
	name = "Vargh Redemption", color = colors.LIGHT_BLUE, image="object/artifact/ring_vargh_redemption.png",
	unided_name = "sea-blue ring",
	desc = [[This azure ring seems to be always moist to the touch.]],
	level_range = {10, 20},
	rarity = 150,
	cost = 500,
	material_level = 2,

	max_power = 60, power_regen = 1,
	use_power = { name = "summon a tidal wave", power = 60,
		use = function(self, who)
			local duration = 7
			local radius = 1
			local dam = 20
			-- Add a lasting map effect
			game.level.map:addEffect(who,
				who.x, who.y, duration,
				engine.DamageType.WAVE, {dam=dam, x=who.x, y=who.y},
				radius,
				5, nil,
				engine.MapEffect.new{color_br=30, color_bg=60, color_bb=200, effect_shader="shader_images/water_effect1.png"},
				function(e)
					e.radius = e.radius + 0.4
					return true
				end,
				false
			)
			game.logSeen(who, "%s brandishes the %s, calling forth the might of the oceans!", who.name:capitalize(), self:getName())
			return {id=true, used=true}
		end
	},
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 4, [Stats.STAT_CON] = 6 },
		max_mana = 20,
		max_stamina = 20,
		max_psi = 20,
		max_air = 50,
		resists = {
			[DamageType.COLD] = 25,
			[DamageType.NATURE] = 10,
		},
	},
}

newEntity{ base = "BASE_RING",
	power_source = {nature=true},
	unique = true,
	name = "Ring of the Dead", color = colors.DARK_GREY, image = "object/artifact/jewelry_ring_of_the_dead.png",
	unided_name = "dull black ring",
	desc = [[This ring is imbued with powers from beyond the grave. It is said that those who wear it may find a new path when all other roads turn dim.]],
	level_range = {35, 42},
	rarity = 250,
	cost = 500,
	material_level = 4,
	special_desc = function(self) return "Will bring you back from death, but only once!" end,
	wielder = {
		inc_stats = { [Stats.STAT_LCK] = 10, },
		die_at = -100,
		combat_physresist = 10,
		combat_mentalresist = 10,
		combat_spellresist = 10,
	},
	one_shot_life_saving = true,
}

newEntity{ base = "BASE_RING",
	power_source = {arcane=true},
	unique = true,
	name = "Elemental Fury", color = colors.PURPLE, image = "object/artifact/ring_elemental_fury.png",
	unided_name = "multi-hued ring",
	desc = [[This ring shines with many colors.]],
	level_range = {15, 30},
	rarity = 200,
	cost = 200,
	material_level = 3,
	special_desc = function(self) return "All your damage is converted and split into arcane, fire, cold and lightning." end,
	wielder = {
		elemental_mastery = 0.25,
		inc_stats = { [Stats.STAT_MAG] = 3,[Stats.STAT_CUN] = 3, },
		inc_damage = {
			[DamageType.ARCANE]    = 12,
			[DamageType.FIRE]      = 12,
			[DamageType.COLD]      = 12,
			[DamageType.LIGHTNING] = 12,
		},
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {technique=true},
	unique = true,
	name = "Feathersteel Amulet", color = colors.WHITE, image = "object/artifact/feathersteel_amulet.png",
	unided_name = "light amulet",
	desc = [[The weight of the world seems a little lighter with this amulet around your neck.]],
	level_range = {5, 15},
	rarity = 200,
	cost = 90,
	material_level = 2,
	wielder = {
		max_encumber = 20,
		fatigue = -20,
		avoid_pressure_traps = 1,
		movement_speed = 0.2,
	},
}

newEntity{ base = "BASE_AMULET", define_as = "SET_GARKUL_TEETH",
	power_source = {technique=true},
	unique = true,
	name = "Garkul's Teeth", color = colors.YELLOW, image = "object/artifact/amulet_garkuls_teeth.png",
	unided_name = "a necklace made of teeth",
	desc = [[Hundreds of humanoid teeth have been strung together on multiple strands of thin leather, creating this tribal necklace.  One would have to assume that these are not the teeth of Garkul the Devourer but rather the teeth of Garkul's many meals.]],
	level_range = {40, 50},
	rarity = 300,
	cost = 1000,
	material_level = 5,
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = 10,
			[Stats.STAT_CON] = 6,
		},
		talents_types_mastery = {
			["technique/2hweapon-cripple"] = 0.1,
			["technique/2hweapon-offense"] = 0.1,
			["technique/warcries"] = 0.1,
			["technique/bloodthirst"] = 0.1,
		},
		combat_physresist = 18,
		combat_mentalresist = 18,
		pin_immune = 1,
	},
	max_power = 48, power_regen = 1,
	use_talent = { id = Talents.T_SHATTERING_SHOUT, level = 4, power = 10 },

	set_list = { {"define_as", "HELM_OF_GARKUL"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","die_at"}, -100)
		game.logSeen(who, "#CRIMSON#As you wear both Garkul's heirlooms you can feel the mighty warrior's spirit flowing through you.")
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#CRIMSON#The spirit of Garkul fades away.")
	end,
}

newEntity{ base = "BASE_LITE",
	power_source = {nature=true},
	unique = true,
	name = "Summertide Phial", image="object/artifact/summertide_phial.png",
	unided_name = "glowing phial",
	level_range = {1, 10},
	color=colors.YELLOW,
	encumber = 1,
	rarity = 100,
	desc = [[A small crystal phial that captured Sunlight during the Summertide.]],
	cost = 200,

	max_power = 15, power_regen = 1,
	use_power = { name = "call light", power = 10,
		use = function(self, who)
			who:project({type="ball", range=0, radius=20}, who.x, who.y, engine.DamageType.LITE, 100)
			game.logSeen(who, "%s brandishes the %s and banishes all shadows!", who.name:capitalize(), self:getName())
			return {id=true, used=true}
		end
	},
	wielder = {
		lite = 4,
		healing_factor = 0.1,
		inc_damage = {[DamageType.LIGHT]=10},
		resists = {[DamageType.LIGHT]=30},
	},
}

newEntity{ base = "BASE_GEM",
	power_source = {arcane=true},
	unique = true,
	name = "Burning Star", image = "object/artifact/jewel_gem_burning_star.png",
	unided_name = "burning jewel",
	level_range = {20, 30},
	color=colors.YELLOW,
	encumber = 1,
	identified = false,
	rarity = 250,
	material_level = 3,
	desc = [[The first Halfling mages during the Age of Allure discovered how to capture the Sunlight and infuse gems with it.
This star is the culmination of their craft. Light radiates from its ever-shifting yellow surface.]],
	cost = 400,

	max_power = 30, power_regen = 1,
	use_power = { name = "map surroundings", power = 30,
		use = function(self, who)
			who:magicMap(20)
			game.logSeen(who, "%s brandishes the %s which radiates in all directions!", who.name:capitalize(), self:getName())
			return {id=true, used=true}
		end
	},
	carrier = {
		lite = 1,
	},
}

newEntity{ base = "BASE_LITE",
	power_source = {arcane=true},
	unique = true,
	name = "Dúathedlen Heart",
	unided_name = "a dark, fleshy mass", image = "object/artifact/dark_red_heart.png",
	level_range = {30, 40},
	color = colors.RED,
	encumber = 1,
	rarity = 300,
	material_level = 4,
	desc = [[This dark red heart still beats despite being separated from its owner.  It also snuffs out any light source that comes near it.]],
	cost = 100,

	wielder = {
		lite = -1000,
		infravision = 6,
		resists_cap = { [DamageType.LIGHT] = 10 },
		resists = { [DamageType.LIGHT] = 30 },
		talents_types_mastery = { ["cunning/stealth"] = 0.1 },
		combat_dam = 7,
	},

	max_power = 15, power_regen = 1,
	use_talent = { id = Talents.T_BLOOD_GRASP, level = 3, power = 10 },
}

newEntity{
	power_source = {nature=true},
	unique = true,
	type = "potion", subtype="potion",
	name = "Blood of Life",
	unided_name = "bloody phial",
	level_range = {1, 50},
	display = '!', color=colors.VIOLET, image="object/artifact/potion_blood_of_life.png",
	encumber = 0.4,
	rarity = 350,
	desc = [[This vial of blood was drawn from an ancient race in the Age of Haze. Some of the power and vitality of those early days of the world still flows through it. "Drink me, mortal," the red liquid seems to whisper in your thoughts. "I will bring you light beyond darkness. Those who taste my essence fear not the death of flesh. Drink me, mortal, if you value your life..."]],
	cost = 1000,
	special = true,

	use_simple = { name = "quaff the Blood of Life to grant an extra life", use = function(self, who)
		game.logSeen(who, "%s quaffs the %s!", who.name:capitalize(), self:getName())
		if not who:attr("undead") then
			who.blood_life = true
			game.logPlayer(who, "#LIGHT_RED#You feel the Blood of Life rushing through your veins.")
		else
			game.logPlayer(who, "The Blood of Life seems to have no effect on you.")
		end
		return {used=true, id=true, destroy=true}
	end},
}

newEntity{ base = "BASE_LEATHER_BOOT",
	power_source = {technique=true},
	unique = true,
	name = "Eden's Guile", image = "object/artifact/boots_edens_guile.png",
	unided_name = "pair of yellow boots",
	desc = [[The boots of a Rogue outcast, who knew that the best way to deal with a problem was to run from it.]],
	on_id_lore = "eden-guile",
	color = colors.YELLOW,
	level_range = {1, 20},
	rarity = 300,
	cost = 100,
	material_level = 2,
	wielder = {
		combat_armor = 1,
		combat_def = 2,
		fatigue = 2,
		talents_types_mastery = { ["cunning/survival"] = 0.2 },
		inc_stats = { [Stats.STAT_CUN] = 3, },
	},

	max_power = 50, power_regen = 1,
	use_power = { name = "boost speed", power = 50,
		use = function(self, who)
			who:setEffect(who.EFF_SPEED, 8, {power=math.min(0.20 + who:getCun() / 200, 0.7)})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_SHIELD",
	power_source = {nature=true, technique=true},
	unique = true,
	name = "Fire Dragon Shield", image = "object/artifact/fire_dragon_shield.png",
	unided_name = "dragon shield",
	desc = [[This large shield was made using scales of many fire drakes from the lost land of Tar'Eyal.]],
	color = colors.LIGHT_RED,
	metallic = false,
	level_range = {27, 35},
	rarity = 300,
	require = { stat = { str=28 }, },
	cost = 350,
	material_level = 4,
	special_combat = {
		dam = 58,
		block = 220,
		physcrit = 4.5,
		dammod = {str=1},
		damtype = DamageType.FIRE,
	},
	wielder = {
		resists={[DamageType.FIRE] = 35},
		on_melee_hit={[DamageType.FIRE] = 17},
		combat_armor = 9,
		combat_def = 16,
		combat_def_ranged = 15,
		fatigue = 20,
		learn_talent = { [Talents.T_BLOCK] = 5, },
	},
}

newEntity{ base = "BASE_SHIELD",
	power_source = {technique=true},
	unique = true,
	name = "Titanic", image = "object/artifact/shield_titanic.png",
	moddable_tile = "special/%s_titanic",
	moddable_tile_big = true,
	unided_name = "huge shield",
	desc = [[This shield made of the darkest stralite is huge, heavy and very solid.]],
	color = colors.GREY,
	level_range = {20, 30},
	rarity = 270,
	require = { stat = { str=37 }, },
	cost = 300,
	material_level = 3,
	special_combat = {
		dam = 48,
		block = 320,
		physcrit = 4.5,
		dammod = {str=1},
	},
	wielder = {
		combat_armor = 18,
		combat_def = 20,
		combat_def_ranged = 10,
		fatigue = 30,
		combat_armor_hardiness = 20,
		learn_talent = { [Talents.T_BLOCK] = 4, },
	},
}

newEntity{ base = "BASE_SHIELD",
	power_source = {nature=true},
	unique = true,
	name = "Black Mesh", image = "object/artifact/shield_mesh.png",
	unided_name = "pile of tendrils",
	desc = [[Black, interwoven tendrils form this mesh that can be used as a shield. It reacts visibly to your touch, clinging to your arm and engulfing it in a warm, black mass.]],
	color = colors.BLACK,
	level_range = {15, 30},
	rarity = 270,
	require = { stat = { str=20 }, },
	cost = 400,
	material_level = 3,
	moddable_tile = "special/%s_black_mesh",
	moddable_tile_big = true,
	metallic = false,
	special_combat = {
		dam = resolvers.rngavg(25,35),
		block = resolvers.rngavg(90, 120),
		physcrit = 5,
		dammod = {str=1},
	},
	wielder = {
		combat_armor = 2,
		combat_def = 8,
		combat_def_ranged = 8,
		fatigue = 12,
		learn_talent = { [Talents.T_BLOCK] = 3, },
		resists = { [DamageType.BLIGHT] = 15, [DamageType.DARKNESS] = 30, },
		stamina_regen = 2,
	},
	on_block = {desc = "30% chance of pulling in the attacker", fct = function(self, who, src, type, dam, eff)
		if rng.percent(30) then
			if not src then return end

			src:pull(who.x, who.y, 15)
			game.logSeen(src, "Black tendrils shoot out of the mesh and pull %s to you!", src.name:capitalize())
			if core.fov.distance(who.x, who.y, src.x, src.y) <= 1 and src:canBe('pin') then
				src:setEffect(src.EFF_CONSTRICTED, 6, {src=who})
			end
		end
	end,}
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {technique=true},
	unique = true,
	name = "Rogue Plight", image = "object/artifact/armor_rogue_plight.png",
	define_as = "ROGUE_PLIGHT",
	unided_name = "blackened leather armour",
	desc = [[No rogue blades shall incapacitate the wearer of this armour.]],
	level_range = {25, 40},
	rarity = 270,
	cost = 200,
	sentient = true,
	global_speed = 0.25, -- act every 4th turn
	require = { stat = { str=22 }, },
	material_level = 3,
	on_wear = function(self, who)
		self.worn_by = who
	end,
	on_takeoff = function(self, who)
		self.worn_by = nil
	end,
	special_desc = function(self) return "Transfers a bleed, poison, or wound to its source or a nearby enemy every 4 turns." 
	end,
	wielder = {
		combat_def = 6,
		combat_armor = 7,
		fatigue = 7,
		ignore_direct_crits = 30,
		inc_stats = { [Stats.STAT_WIL] = 5, [Stats.STAT_CON] = 4, },
		resists={[DamageType.NATURE] = 35},
	},
	act = function(self)
		self:useEnergy()
	
		if not self.worn_by then return end -- items act even when not equipped
		local who = self.worn_by

		-- Make sure the item is worn
		-- This should be redundant but whatever
		local o, item, inven_id = who:findInAllInventoriesBy("define_as", "ROGUE_PLIGHT")
		if not o or not who:getInven(inven_id).worn then return end
		
		local Map = require "engine.Map"
		
		for eff_id, p in pairs(who.tmp) do
			-- p only has parameters, we need to get the effect definition (e) to check subtypes
			local e = who.tempeffect_def[eff_id]
			if e.status == "detrimental" and e.subtype and (e.subtype.bleed or e.subtype.poison or e.subtype.wound) then	
				
				-- Copy the effect parameters then change only the source
				-- This will preserve everything passed to the debuff in setEffect but will use the new source for +damage%, etc
				local effectParam = who:copyEffect(eff_id)
				effectParam.src = who
					
				if p.src and p.src.setEffect and not p.src.dead then -- Most debuffs don't define a source
					p.src:setEffect(eff_id, p.dur, effectParam)
					who:removeEffect(eff_id)
					game.logPlayer(who, "#CRIMSON#Rogue Plight transfers an effect to its source!")
					return true
				else 
					-- If there is no source move the debuff to an adjacent enemy instead
					-- If there is no source or adjacent enemy the effect fails		
					for _, coor in pairs(util.adjacentCoords(who.x, who.y)) do
						local act = game.level.map(coor[1], coor[2], Map.ACTOR)
						if act then
							act:setEffect(eff_id, p.dur, effectParam)
							who:removeEffect(eff_id)
							game.logPlayer(who, "#CRIMSON#Rogue Plight transfers an effect to a nearby enemy!")
							return true
						end		
					end
				end
			end
		end	
		return true	
	end,
}

newEntity{
	power_source = {nature=true},
	unique = true,
	type = "misc", subtype="egg",
	unided_name = "dark egg",
	name = "Mummified Egg-sac of Ungolë", image = "object/artifact/mummified_eggsack.png",
	level_range = {20, 35},
	rarity = 190,
	display = "*", color=colors.DARK_GREY,
	encumber = 2,
	not_in_stores = true,
	desc = [[Dry and dusty to the touch, it still seems to retain some shadow of life.]],

	carrier = {
		lite = -2,
	},
	max_power = 100, power_regen = 1,
	use_power = { name = "summon spiders", power = 80, use = function(self, who)
		if not who:canBe("summon") then game.logPlayer(who, "You cannot summon; you are suppressed!") return end

		local NPC = require "mod.class.NPC"
		local list = NPC:loadList("/data/general/npcs/spider.lua")

		for i = 1, 2 do
			-- Find space
			local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.ACTOR]=true})
			if not x then break end

			local e
			repeat e = rng.tableRemove(list)
			until not e.unique and e.rarity

			local spider = game.zone:finishEntity(game.level, "actor", e)
			spider.make_escort = nil
			spider.silent_levelup = true
			spider.faction = who.faction
			spider.ai = "summoned"
			spider.ai_real = "dumb_talented_simple"
			spider.summoner = who
			spider.summon_time = 10
			spider.exp_worth = 0

			local setupSummon = getfenv(who:getTalentFromId(who.T_SPIDER).action).setupSummon
			setupSummon(who, spider, x, y)
			game:playSoundNear(who, "talents/slime")
		end
		return {id=true, used=true}
	end },
}

newEntity{ base = "BASE_HELM",
	power_source = {technique=true},
	unique = true,
	name = "Helm of the Dwarven Emperors", image = "object/artifact/helm_of_the_dwarven_emperors.png",
	unided_name = "shining helm",
	desc = [[A Dwarven helm embedded with a single diamond that can banish all underground shadows.]],
	level_range = {20, 28},
	rarity = 240,
	cost = 700,
	material_level = 2,
	wielder = {
		lite = 1,
		combat_armor = 6,
		fatigue = 4,
		blind_immune = 0.3,
		confusion_immune = 0.3,
		inc_stats = { [Stats.STAT_WIL] = 3, [Stats.STAT_MAG] = 4, },
		inc_damage={
			[DamageType.LIGHT] = 8,
		},
	},
	max_power = 30, power_regen = 1,
	use_talent = { id = Talents.T_SUN_FLARE, level = 3, power = 30 },
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Dwarf" then
			local Stats = require "engine.interface.ActorStats"

			self:specialWearAdd({"wielder","inc_stats"}, { [Stats.STAT_CUN] = 5, [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 5, })
			game.logPlayer(who, "#LIGHT_BLUE#The legacy of Dwarven Emperors grants you their wisdom.")
		end
	end,
}

newEntity{ base = "BASE_KNIFE",
	power_source = {technique=true},
	unique = true,
	name = "Silent Blade", image = "object/artifact/dagger_silent_blade.png",
	unided_name = "shining dagger",
	desc = [[A thin, dark dagger that seems to meld seamlessly into the shadows.]],
	level_range = {23, 28},
	rarity = 200,
	require = { stat = { cun=25 }, },
	cost = 250,
	material_level = 2,
	combat = {
		dam = 25,
		apr = 10,
		physcrit = 8,
		dammod = {dex=0.55,str=0.35},
		no_stealth_break = true,
		melee_project={[DamageType.RANDOM_SILENCE] = 10},
	},
	wielder = {combat_atk = 10},
}

newEntity{ base = "BASE_KNIFE", define_as = "ART_PAIR_MOON",
	power_source = {arcane=true},
	unique = true,
	name = "Moon", image = "object/artifact/dagger_moon.png",
	unided_name = "crescent blade",
	desc = [[A viciously curved blade that a folk story says is made from a material that originates from the moon.  Devouring the light around it, it fades.]],
	level_range = {20, 30},
	rarity = 200,
	require = { stat = { dex=24, cun=24 }, },
	cost = 300,
	material_level = 3,
	combat = {
		dam = 30,
		apr = 30,
		physcrit = 10,
		dammod = {dex=0.45,str=0.45},
		melee_project={[DamageType.DARKNESS] = 20},
	},
	wielder = {
		lite = -1,
		inc_damage={
			[DamageType.DARKNESS] = 10,
		},
	},
	set_list = { {"define_as","ART_PAIR_STAR"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","lite"}, 1)
		self:specialSetAdd({"combat","melee_project"}, {[engine.DamageType.RANDOM_CONFUSION]=10})
		self:specialSetAdd({"wielder","inc_damage"}, {[engine.DamageType.DARKNESS]=15})
		game.logSeen(who, "#ANTIQUE_WHITE#The two blades glow brightly as they are brought close together.")
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#ANTIQUE_WHITE#The light from the two blades fades as they are separated.")
	end,
}

newEntity{ base = "BASE_KNIFE", define_as = "ART_PAIR_STAR",
	power_source = {arcane=true},
	unique = true,
	name = "Star",
	unided_name = "jagged blade", image = "object/artifact/dagger_star.png",
	desc = [[Legend tells of a blade, shining bright as a star. Forged from a material fallen from the skies, it glows.]],
	level_range = {20, 30},
	rarity = 200,
	require = { stat = { dex=24, cun=24 }, },
	cost = 300,
	material_level = 3,
	combat = {
		dam = 25,
		apr = 20,
		physcrit = 20,
		dammod = {dex=0.45,str=0.45},
		melee_project={[DamageType.LIGHT] = 20},
	},
	wielder = {
		lite = 1,
		inc_damage={
			[DamageType.LIGHT] = 10,
		},
	},
	set_list = { {"define_as","ART_PAIR_MOON"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","lite"}, 1)
		self:specialSetAdd({"combat","melee_project"}, {[engine.DamageType.RANDOM_BLIND]=10})
		self:specialSetAdd({"wielder","inc_damage"}, {[engine.DamageType.LIGHT]=15})
	end,

}

newEntity{ base = "BASE_RING",
	power_source = {technique=true},
	unique = true,
	name = "Ring of the War Master", color = colors.DARK_GREY, image = "object/artifact/ring_of_war_master.png",
	unided_name = "blade-edged ring",
	desc = [[A blade-edged ring that radiates power. As you put it on, strange thoughts of pain and destruction come to your mind.]],
	level_range = {40, 50},
	rarity = 200,
	cost = 500,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 3, [Stats.STAT_DEX] = 3, [Stats.STAT_CON] = 3, },
		combat_apr = 15,
		combat_dam = 10,
		combat_physcrit = 5,
		talents_types_mastery = {
			["technique/2hweapon-cripple"] = 0.3,
			["technique/2hweapon-offense"] = 0.3,
			["technique/archery-bow"] = 0.3,
			["technique/archery-sling"] = 0.3,
			["technique/archery-training"] = 0.3,
			["technique/archery-utility"] = 0.3,
			["technique/archery-excellence"] = 0.3,
			["technique/combat-techniques-active"] = 0.3,
			["technique/combat-techniques-passive"] = 0.3,
			["technique/combat-training"] = 0.3,
			["technique/dualweapon-attack"] = 0.3,
			["technique/dualweapon-training"] = 0.3,
			["technique/shield-defense"] = 0.3,
			["technique/shield-offense"] = 0.3,
			["technique/warcries"] = 0.3,
			["technique/superiority"] = 0.3,
			["technique/thuggery"] = 0.3,
			["technique/pugilism"] = 0.3,
			["technique/unarmed-discipline"] = 0.3,
			["technique/unarmed-training"] = 0.3,
			["technique/grappling"] = 0.3,
			["technique/finishing-moves"] = 0.3,
		},
	},
}

newEntity{ base = "BASE_GREATMAUL",
	power_source = {technique=true},
	unique = true,
	name = "Unstoppable Mauler", color = colors.UMBER, image = "object/artifact/unstoppable_mauler.png",
	unided_name = "heavy maul",
	desc = [[A huge greatmaul of incredible weight. Wielding it, you feel utterly unstoppable.]],
	level_range = {23, 30},
	rarity = 270,
	require = { stat = { str=40 }, },
	cost = 250,
	material_level = 3,
	combat = {
		dam = 48,
		apr = 15,
		physcrit = 3,
		dammod = {str=1.2},
		talent_on_hit = { [Talents.T_SUNDER_ARMOUR] = {level=3, chance=15} },
	},
	wielder = {
		combat_atk = 20,
		pin_immune = 1,
		knockback_immune = 1,
	},
	max_power = 18, power_regen = 1,
	use_talent = { id = Talents.T_FEARLESS_CLEAVE, level = 3, power = 18 },
}

newEntity{ base = "BASE_MACE",
	power_source = {technique=true},
	unique = true,
	name = "Crooked Club", color = colors.GREEN, image = "object/artifact/weapon_crooked_club.png",
	unided_name = "weird club",
	desc = [[An oddly twisted club with a hefty weight on the end. There's something very strange about it.]],
	level_range = {12, 20},
	rarity = 192,
	require = { stat = { str=20 }, },
	cost = 250,
	material_level = 2,
	combat = {
		dam = 25,
		apr = 4,
		physcrit = 10,
		dammod = {str=1},
		melee_project={[DamageType.RANDOM_CONFUSION_PHYS] = 14},
		talent_on_hit = { T_BATTLE_CALL = {level=1, chance=10},},
		burst_on_crit = {
			[DamageType.PHYSKNOCKBACK] = 20,
		},
	},
	wielder = {combat_atk=12,},
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {nature=true},
	unique = true,
	name = "Spider-Silk Robe of Spydrë", color = colors.DARK_GREEN, image = "object/artifact/robe_spider_silk_robe_spydre.png",
	unided_name = "spider-silk robe",
	desc = [[This set of robes is made wholly of spider silk. It looks outlandish and some sages think it came from another world, probably through a farportal.]],
	level_range = {20, 30},
	rarity = 190,
	cost = 250,
	material_level = 3,
	wielder = {
		combat_def = 10,
		combat_armor = 15,
		combat_armor_hardiness = 30,
		inc_stats = { [Stats.STAT_CON] = 5, [Stats.STAT_WIL] = 4, },
		combat_mindpower = 10,
		combat_mindcrit = 5,
		combat_spellresist = 10,
		combat_physresist = 10,
		inc_damage={[DamageType.NATURE] = 10, [DamageType.MIND] = 10, [DamageType.ACID] = 10},
		resists={[DamageType.NATURE] = 30},
		on_melee_hit={[DamageType.POISON] = 20, [DamageType.SLIME] = 20},
	},
}

newEntity{ base = "BASE_HELM", define_as = "HELM_KROLTAR",
	power_source = {technique=true},
	unique = true,
	name = "Dragon-helm of Kroltar", image = "object/artifact/dragon_helm_of_kroltar.png",
	unided_name = "dragon-helm",
	desc = [[A visored steel helm, embossed and embellished with gold, that bears as its crest the head of Kroltar, the greatest of the fire drakes.]],
	require = { talent = { {Talents.T_ARMOUR_TRAINING,3} }, stat = { str=35 }, },
	level_range = {37, 45},
	rarity = 280,
	cost = 400,
	material_level = 4,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_CON] = 5, [Stats.STAT_LCK] = -4, },
		combat_def = 5,
		combat_armor = 9,
		fatigue = 10,
	},
	max_power = 45, power_regen = 1,
	use_talent = { id = Talents.T_WARSHOUT, level = 2, power = 45 },
	set_list = { {"define_as","SCALE_MAIL_KROLTAR"} },
	on_set_complete = function(self, who)
		self:specialSetAdd("skullcracker_mult", 1)
		self:specialSetAdd({"wielder","combat_spellresist"}, 15)
		self:specialSetAdd({"wielder","combat_mentalresist"}, 15)
		self:specialSetAdd({"wielder","combat_physresist"}, 15)
		game.logPlayer(who, "#GOLD#As the helm of Kroltar approaches the your scale armour, they begin to fume and emit fire.")
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#GOLD#The fumes and fire fade away.")
	end,
}

newEntity{ base = "BASE_HELM",
	power_source = {technique=true},
	unique = true,
	name = "Crown of Command", image = "object/artifact/crown_of_command.png",
	unided_name = "unblemished silver crown",
	desc = [[This crown was worn by the Halfling king Roupar, who ruled over the Nargol lands in the Age of Dusk.  Those were dark times, and the king enforced order and discipline under the harshest of terms.  Any who deviated were punished, any who disagreed were repressed, and many disappeared without a trace into his numerous prisons.  All must be loyal to the crown or suffer dearly.  When he died without heir the crown was lost and his kingdom fell into chaos.]],
	require = { stat = { cun=25 } },
	level_range = {20, 35},
	rarity = 280,
	cost = 300,
	material_level = 3,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 3, [Stats.STAT_WIL] = 10, },
		combat_def = 3,
		combat_armor = 6,
		combat_mindpower = 5,
		fatigue = 4,
		resists = { [DamageType.PHYSICAL] = 8},
		talents_types_mastery = { ["technique/superiority"] = 0.2, ["technique/field-control"] = 0.2 },
	},
	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_INDOMITABLE, level = 1, power = 60 },
	on_wear = function(self, who)
		self.worn_by = who
		if who.descriptor and who.descriptor.race == "Halfling" then
			local Stats = require "engine.interface.ActorStats"
			self:specialWearAdd({"wielder","inc_stats"}, { [Stats.STAT_CUN] = 7, [Stats.STAT_STR] = 7, }) 
			game.logPlayer(who, "#LIGHT_BLUE#You gain understanding of the might of your race.", self:getName())
		end
	end,
	on_takeoff = function(self)
		self.worn_by = nil

	end,
}

newEntity{ base = "BASE_GLOVES",
	power_source = {technique=true},
	unique = true,
	name = "Gloves of the Firm Hand", image = "object/artifact/gloves_of_the_firm_hand.png",
	unided_name = "heavy gloves",
	desc = [[These gloves make you feel rock steady! These magical gloves feel really soft to the touch from the inside. On the outside, magical stones create a rough surface that is constantly shifting. When you brace yourself, a magical ray of earth energy seems to automatically bind them to the ground, granting you increased stability.]],
	level_range = {17, 27},
	rarity = 210,
	cost = 150,
	material_level = 3,
	wielder = {
		talent_cd_reduction={[Talents.T_CLINCH]=2},
		inc_stats = { [Stats.STAT_CON] = 4 },
		combat_armor = 8,
		disarm_immune=0.4,
		knockback_immune=0.3,
		stun_immune = 0.3,
		combat = {
			dam = 18,
			apr = 1,
			physcrit = 7,
			talent_on_hit = { T_CLINCH = {level=3, chance=20}, T_MAIM = {level=3, chance=10}, T_TAKE_DOWN = {level=3, chance=10} },
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
		},
	},
}

newEntity{ base = "BASE_GAUNTLETS",
	power_source = {arcane=true, technique=true},
	unique = true,
	name = "Dakhtun's Gauntlets", color = colors.STEEL_BLUE, image = "object/artifact/dakhtuns_gauntlets.png",
	unided_name = "expertly-crafted dwarven-steel gauntlets",
	desc = [[Fashioned by Grand Smith Dakhtun in the Age of Allure, these dwarven-steel gauntlets have been etched with golden arcane runes and are said to grant the wearer unparalleled physical and magical might.]],
	level_range = {40, 50},
	rarity = 300,
	cost = 2000,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 6, [Stats.STAT_MAG] = 6 },
		inc_damage = { [DamageType.PHYSICAL] = 10 },
		combat_physcrit = 10,
		combat_spellcrit = 10,
		combat_critical_power = 50,
		combat_armor = 6,
		combat = {
			dam = 35,
			apr = 10,
			physcrit = 10,
			physspeed = 0.2,
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
			melee_project={[DamageType.ARCANE] = 20},
			talent_on_hit = { T_GREATER_WEAPON_FOCUS = {level=1, chance=10}, T_DISPLACEMENT_SHIELD = {level=1, chance=10} },
			damrange = 0.3,
		},
	},
}

newEntity{ base = "BASE_GREATMAUL",
	power_source = {technique=true, arcane=true},
	unique = true,
	name = "Voratun Hammer of the Deep Bellow", color = colors.LIGHT_RED, image = "object/artifact/voratun_hammer_of_the_deep_bellow.png",
	unided_name = "flame scorched voratun hammer",
	desc = [[The legendary hammer of the Dwarven master smiths. For ages it was used to forge powerful weapons with searing heat until it became highly powerful by itself.]],
	level_range = {38, 50},
	rarity = 250,
	require = { stat = { str=48 }, },
	cost = 650,
	material_level = 5,
	combat = {
		dam = 82,
		apr = 7,
		physcrit = 4,
		dammod = {str=1.2},
		talent_on_hit = { [Talents.T_FLAMESHOCK] = {level=3, chance=10} },
		melee_project={[DamageType.FIRE] = 30},
	},
	wielder = {
		inc_damage={
			[DamageType.PHYSICAL] = 15,
		},
	},
}

newEntity{ base = "BASE_GLOVES",
	power_source = {nature=true}, define_as = "SET_GIANT_WRAPS",
	unique = true,
	name = "Snow Giant Wraps", color = colors.SANDY_BROWN, image = "object/artifact/snow_giant_arm_wraps.png",
	unided_name = "fur-lined leather wraps",
	desc = [[Two large pieces of leather designed to be wrapped about the hands and the forearms.  This particular pair of wraps has been enchanted, imparting the wearer with great strength.]],
	level_range = {15, 25},
	rarity = 200,
	cost = 500,
	material_level = 3,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 4, },
		resists = { [DamageType.COLD]= 10, [DamageType.LIGHTNING] = 10, },
		knockback_immune = 0.5,
		combat_armor = 2,
		max_life = 60,
		combat = {
			dam = 16,
			apr = 1,
			physcrit = 4,
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
			talent_on_hit = { T_CALL_LIGHTNING = {level=5, chance=25}},
			melee_project={ [DamageType.COLD] = 10, [DamageType.LIGHTNING] = 10, },
		},
	},
	max_power = 6, power_regen = 1,
	use_talent = { id = Talents.T_THROW_BOULDER, level = 2, power = 6 },

	set_list = { {"define_as", "SET_MIGHTY_GIRDLE"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","combat_dam"}, 10)
		self:specialSetAdd({"wielder","combat_physresist"}, 10)
	end,
}

newEntity{ base = "BASE_LEATHER_BELT",
	power_source = {technique=true}, define_as = "SET_MIGHTY_GIRDLE",
	unique = true,
	name = "Mighty Girdle", image = "object/artifact/belt_mighty_girdle.png",
	unided_name = "massive, stained girdle",
	desc = [[This girdle is enchanted with mighty wards against expanding girth. Whatever the source of its wondrous strength, it will prove of great aid in the transport of awkward burdens.]],
	color = colors.LIGHT_RED,
	level_range = {1, 25},
	rarity = 170,
	cost = 350,
	material_level = 2,
	wielder = {
		knockback_immune = 0.4,
		max_encumber = 70,
		combat_armor = 4,
	},

	set_list = { {"define_as", "SET_GIANT_WRAPS"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","max_life"}, 100)
		self:specialSetAdd({"wielder","size_category"}, 2)
		game.logPlayer(who, "#GOLD#You grow to immense size!")
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#LIGHT_BLUE#You feel a lot smaller...")
	end,
}

newEntity{ base = "BASE_CLOAK",
	power_source = {nature=true},
	unique = true,
	name = "Serpentine Cloak", image = "object/artifact/serpentine_cloak.png",
	unided_name = "tattered cloak",
	desc = [[Cunning and malice seem to emanate from this cloak.]],
	level_range = {20, 29},
	rarity = 240,
	cost = 200,
	material_level = 3,
	wielder = {
		combat_def = 10,
		inc_stats = { [Stats.STAT_CUN] = 6, [Stats.STAT_CON] = 5, },
		resists_pen = { [DamageType.NATURE] = 15 },
		talents_types_mastery = { ["cunning/stealth"] = 0.1, },
	},
	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_PHASE_DOOR, level = 2, power = 30 },
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {arcane=true},
	unique = true,
	name = "Vestments of the Conclave", color = colors.DARK_GREY, image = "object/artifact/robe_vestments_of_the_conclave.png",
	unided_name = "tattered robe",
	desc = [[An ancient set of robes that has survived from the Age of Allure. Primal magic forces inhabit it.
It was made by Humans for Humans; only they can harness the true power of the robes.]],
	level_range = {12, 22},
	rarity = 220,
	cost = 150,
	material_level = 2,
	wielder = {
		inc_damage = {[DamageType.ARCANE]=10},
		inc_stats = { [Stats.STAT_MAG] = 6 },
		combat_spellcrit = 15,
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Human" then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder","inc_stats"}, { [Stats.STAT_MAG] = 3, [Stats.STAT_CUN] = 9, })
			self:specialWearAdd({"wielder","inc_damage"}, {[DamageType.ARCANE]=7})
			self:specialWearAdd({"wielder","combat_spellcrit"}, 2)
			game.logPlayer(who, "#LIGHT_BLUE#You feel as surge of power as you wear the vestments of the old Human Conclave!")
		end
	end,
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {arcane=true},
	unique = true,
	name = "Firewalker", color = colors.RED, image = "object/artifact/robe_firewalker.png",
	unided_name = "blazing robe",
	desc = [[This fiery robe was worn by the mad pyromancer Halchot, who terrorised many towns in the late Age of Dusk, burning and looting villages as they tried to recover from the Spellblaze.  Eventually he was tracked down by the Ziguranth, who cut out his tongue, chopped off his head, and rent his body to shreds.  The head was encased in a block of ice and paraded through the streets of nearby towns amidst the cheers of the locals.  Only this robe remains of the flames of Halchot.]],
	level_range = {20, 30},
	rarity = 300,
	cost = 280,
	material_level = 3,
	wielder = {
		inc_damage = {[DamageType.FIRE]=20},
		combat_def = 8,
		combat_armor = 2,
		inc_stats = { [Stats.STAT_MAG] = 6, [Stats.STAT_CUN] = 6, },
		resists = {[DamageType.FIRE] = 20, [DamageType.COLD] = -10},
		resists_pen = { [DamageType.FIRE] = 20 },
		on_melee_hit = {[DamageType.FIRE] = 18},
	},
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {arcane=true},
	unique = true,
	name = "Robe of the Archmage", color = colors.RED, image = "object/artifact/robe_of_the_archmage.png",
	unided_name = "glittering robe",
	desc = [[A plain elven-silk robe. It would be unremarkable if not for the sheer power it radiates.]],
	level_range = {30, 40},
	rarity = 290,
	cost = 550,
	material_level = 4,
	moddable_tile = "special/robe_of_the_archmage",
	moddable_tile_big = true,
	wielder = {
		lite = 1,
		inc_damage = {all=12},
		blind_immune = 0.4,
		combat_def = 10,
		combat_armor = 10,
		inc_stats = { [Stats.STAT_MAG] = 4, [Stats.STAT_WIL] = 4, [Stats.STAT_CUN] = 4, },
		combat_spellpower = 15,
		combat_spellresist = 18,
		combat_mentalresist = 15,
		resists={[DamageType.FIRE] = 10, [DamageType.COLD] = 10},
		on_melee_hit={[DamageType.ARCANE] = 15},
		mana_regen = 1,
	},
}

newEntity{ base = "BASE_CLOTH_ARMOR", define_as = "SET_TEMPORAL_ROBE",
	power_source = {arcane=true},
	unique = true,
	name = "Temporal Augmentation Robe - Designed In-Style", color = colors.BLACK, image = "object/artifact/robe_temporal_augmentation_robe.png",
	unided_name = "stylish robe with a scarf",
	desc = [[Designed by a slightly quirky Paradox Mage, this robe always appears to be stylish in any time the user finds him, her, or itself in. Crafted to aid Paradox Mages through their adventures, this robe is of great help to those that understand what a wibbly-wobbly, timey-wimey mess time actually is. Curiously, as a result of a particularly prolonged battle involving its fourth wearer, the robe appends a very long, multi-coloured scarf to its present wearers.]],
	level_range = {30, 40},
	rarity = 310,
	cost = 540,
	material_level = 4,
	wielder = {
		combat_spellpower = 23,
		inc_damage = {[DamageType.TEMPORAL]=20},
		combat_def = 9,
		combat_armor = 3,
		inc_stats = { [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 3, },
		resists={[DamageType.TEMPORAL] = 20},
		resists_pen = { [DamageType.TEMPORAL] = 20 },
		on_melee_hit={[DamageType.TEMPORAL] = 10},
	},
	max_power = 25, power_regen = 1,
	use_talent = { id = Talents.T_DAMAGE_SMEARING, level = 1, power = 25 },

	set_list = { {"define_as", "SET_TEMPORAL_FEZ"} },
	on_set_complete = function(self, who)
	end,
	on_set_broken = function(self, who)
	end,
}

newEntity{ base = "BASE_WIZARD_HAT", define_as = "SET_TEMPORAL_FEZ",
	power_source = {arcane=true, psionic=true},
	unique = true,
	name = "Un'fezan's Cap",
	unided_name = "red stylish hat",
	desc = [[This fez once belonged to a traveler; it always seems to be found lying around in odd locations.
#{italic}#Fezzes are cool.#{normal}#]],
	color = colors.BLUE, image = "object/artifact/fez.png",
	moddable_tile = "special/fez",
	moddable_tile_big = true,
	level_range = {20, 40},
	rarity = 300,
	cost = 100,
	material_level = 3,
	wielder = {
		combat_def = 1,
		combat_spellpower = 8,
		combat_mindpower = 8,
		inc_stats = { [Stats.STAT_WIL] = 4, [Stats.STAT_CUN] = 8, },
		paradox_reduce_fails = 10,
		resists = {
			[DamageType.TEMPORAL] = 20,
		},
		talents_types_mastery = {
			["chronomancy/timetravel"]=0.2,
		},
	},
	max_power = 15, power_regen = 1,
	use_talent = { id = Talents.T_WORMHOLE, level = 1, power = 15 },

	set_list = { {"define_as", "SET_TEMPORAL_ROBE"} },
	on_set_complete = function(self, who)
		game.logPlayer(who, "#STEEL_BLUE#A time vortex briefly appears in front of you.")
		self:specialSetAdd({"wielder","paradox_reduce_fails"}, 40)
		self:specialSetAdd({"wielder","confusion_immune"}, 0.4)
		self:specialSetAdd({"wielder","combat_spellspeed"}, 0.1)
		self:specialSetAdd({"wielder","inc_damage"}, { [engine.DamageType.TEMPORAL] = 10 })
	end,
	on_set_broken = function(self, who)
		self.use_talent = nil
		game.logPlayer(who, "#STEEL_BLUE#A time vortex briefly appears in front of you.")
	end,
}

newEntity{ base = "BASE_BATTLEAXE",
	power_source = {technique=true},
	unique = true,
	unided_name = "crude iron battle axe",
	name = "Crude Iron Battle Axe of Kroll", color = colors.GREY, image = "object/artifact/crude_iron_battleaxe_of_kroll.png",
	desc = [[Made in times before the Dwarves learned beautiful craftsmanship, the rough appearance of this axe belies its great power. Only Dwarves may harness its true strength, however.]],
	require = { stat = { str=50 }, },
	level_range = {39, 46},
	rarity = 300,
	material_level = 4,
	combat = {
		dam = 68,
		apr = 7,
		physcrit = 10,
		dammod = {str=1.3},
	},
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 2, [Stats.STAT_DEX] = 2, },
		combat_def = 6, combat_armor = 6,
		inc_damage = { [DamageType.PHYSICAL]=10 },
		stun_immune = 0.3,
		knockback_immune = 0.3,
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Dwarf" then
			local Stats = require "engine.interface.ActorStats"

			self:specialWearAdd({"wielder","inc_stats"}, { [Stats.STAT_CON] = 7, [Stats.STAT_DEX] = 7, })
			self:specialWearAdd({"wielder","stun_immune"}, 0.7)
			self:specialWearAdd({"wielder","knockback_immune"}, 0.7)
			game.logPlayer(who, "#LIGHT_BLUE#You feel as surge of power as you wield the axe of your ancestors!")
		end
	end,
}

newEntity{ base = "BASE_WHIP",
	power_source = {nature=true},
	unided_name = "metal whip",
	name = "Scorpion's Tail", color=colors.GREEN, unique = true, image = "object/artifact/whip_scorpions_tail.png",
	desc = [[A long whip of linked metal joints finished with a viciously sharp barb leaking terrible venom.]],
	require = { stat = { dex=28 }, },
	cost = 150,
	rarity = 340,
	level_range = {20, 30},
	material_level = 3,
	combat = {
		dam = 28,
		apr = 8,
		physcrit = 5,
		dammod = {dex=1},
		melee_project={[DamageType.POISON] = 22, [DamageType.BLEED] = 22},
		talent_on_hit = { T_DISARM = {level=3, chance=10} },
	},
	wielder = {
		combat_atk = 10,
		see_invisible = 9,
		see_stealth = 9,
	},
}

newEntity{ base = "BASE_LEATHER_BELT",
	power_source = {nature=true},
	unique = true,
	name = "Girdle of Preservation", image = "object/artifact/belt_girdle_of_preservation.png",
	unided_name = "shimmering, flawless belt",
	desc = [[A pristine belt of purest white leather with a runed voratun buckle. The ravages of neither time nor the elements have touched it.]],
	color = colors.WHITE,
	level_range = {45, 50},
	rarity = 400,
	cost = 750,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 5, [Stats.STAT_WIL] = 5,  },
		resists = {
			[DamageType.ACID] = 15,
			[DamageType.LIGHTNING] = 15,
			[DamageType.FIRE] = 15,
			[DamageType.COLD] = 15,
			[DamageType.LIGHT] = 15,
			[DamageType.DARKNESS] = 15,
			[DamageType.BLIGHT] = 15,
			[DamageType.TEMPORAL] = 15,
			[DamageType.NATURE] = 15,
			[DamageType.PHYSICAL] = 10,
			[DamageType.ARCANE] = 10,
		},
		confusion_immune = 0.2,
		combat_physresist = 15,
		combat_mentalresist = 15,
		combat_spellresist = 15,
	},
}

newEntity{ base = "BASE_LEATHER_BELT",
	power_source = {nature=true},
	unique = true,
	name = "Girdle of the Calm Waters", image = "object/artifact/girdle_of_the_calm_waters.png",
	unided_name = "golden belt",
	desc = [[A belt rumoured to have been worn by the Conclave healers.]],
	color = colors.GOLD,
	level_range = {5, 14},
	rarity = 120,
	cost = 75,
	material_level = 1,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 3,  },
		resists = {
			[DamageType.COLD] = 20,
			[DamageType.BLIGHT] = 20,
			[DamageType.NATURE] = 20,
		},
		healing_factor = 0.3,
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {technique=true},
	unique = true,
	name = "Behemoth Hide", image = "object/artifact/behemoth_skin.png",
	unided_name = "tough weathered hide",
	desc = [[A rough hide made from a massive beast.  Seeing as it's so weathered but still usable, maybe it's a bit special...]],
	color = colors.BROWN,
	level_range = {18, 23},
	rarity = 230,
	require = { stat = { str=22 }, },
	cost = 250,
	material_level = 2,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 2, [Stats.STAT_CON] = 2 },

		combat_armor = 6,
		combat_def = 4,
		combat_def_ranged = 8,

		max_encumber = 20,
		life_regen = 0.7,
		stamina_regen = 0.7,
		fatigue = 10,
		max_stamina = 43,
		max_life = 45,
		knockback_immune = 0.1,
		size_category = 1,
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {technique=true},
	unique = true,
	name = "Skin of Many", image = "object/artifact/robe_skin_of_many.png",
	unided_name = "stitched skin armour",
	desc = [[The stitched-together skins of many creatures. Some eyes and mouths still decorate the robe, and some still live, screaming in tortured agony.]],
	color = colors.BROWN,
	level_range = {12, 22},
	rarity = 200,
	require = { stat = { str=16 }, },
	cost = 200,
	material_level = 2,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 4 },
		combat_armor = 6,
		combat_def = 12,
		fatigue = 7,
		max_life = 40,
		infravision = 3,
		talents_types_mastery = { ["cunning/stealth"] = -0.2, },
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Undead" then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder", "talents_types_mastery"}, { ["cunning/stealth"] = 0.2 })
			self:specialWearAdd({"wielder","confusion_immune"}, 0.3)
			self:specialWearAdd({"wielder","fear_immune"}, 0.3)
			game.logPlayer(who, "#DARK_BLUE#The skin seems pleased to be worn by the unliving, and grows silent.")
		end
	end,
}

newEntity{ base = "BASE_HEAVY_ARMOR",
	power_source = {arcane=true},
	unique = true,
	name = "Iron Mail of Bloodletting", image = "object/artifact/iron_mail_of_bloodletting.png",
	unided_name = "gore-encrusted suit of iron mail",
	desc = [[Blood drips continuously from this fell suit of iron, and dark magics churn almost visibly around it. Bloody ruin comes to those who stand against its wearer.]],
	color = colors.RED,
	level_range = {15, 25},
	rarity = 190,
	require = { stat = { str=14 }, },
	cost = 200,
	material_level = 2,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 2, [Stats.STAT_STR] = 2 },
		resists = {
			[DamageType.ACID] = 10,
			[DamageType.DARKNESS] = 10,
			[DamageType.FIRE] = 10,
			[DamageType.BLIGHT] = 10,
		},
		talents_types_mastery = { ["technique/bloodthirst"] = 0.1 },
		life_regen = 0.5,
		healing_factor = 0.3,
		combat_def = 2,
		combat_armor = 4,
		fatigue = 12,
	},
	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_BLOODCASTING, level = 2, power = 60 },
}


newEntity{ base = "BASE_HEAVY_ARMOR", define_as = "SCALE_MAIL_KROLTAR",
	power_source = {technique=true, nature=true},
	unique = true,
	name = "Scale Mail of Kroltar", image = "object/artifact/scale_mail_of_kroltar.png",
	unided_name = "perfectly-wrought suit of dragon scales",
	desc = [[A heavy shirt of scale mail constructed from the remains of Kroltar, whose armour was like tenfold shields.]],
	color = colors.LIGHT_RED,
	metallic = false,
	level_range = {38, 45},
	rarity = 300,
	require = { stat = { str=38 }, },
	cost = 500,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 4, [Stats.STAT_STR] = 5, [Stats.STAT_DEX] = 3 },
		resists = {
			[DamageType.ACID] = 20,
			[DamageType.LIGHTNING] = 20,
			[DamageType.FIRE] = 20,
			[DamageType.BLIGHT] = 20,
			[DamageType.NATURE] = 20,
		},
		max_life=120,
		combat_def = 10,
		combat_armor = 18,
		fatigue = 16,
	},
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_INFERNO, level = 3, power = 50 },
	set_list = { {"define_as","HELM_KROLTAR"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","max_life"}, 120)
		self:specialSetAdd({"wielder","fatigue"}, -8)
		self:specialSetAdd({"wielder","combat_def"}, 10)
	end,
}

newEntity{ base = "BASE_MASSIVE_ARMOR",
	power_source = {technique=true},
	unique = true,
	name = "Cuirass of the Thronesmen", image = "object/artifact/armor_cuirass_of_the_thronesmen.png",
	unided_name = "heavy dwarven-steel armour",
	desc = [[This heavy dwarven-steel armour was created in the deepest forges of the Iron Throne. While it grants incomparable protection, it demands that you rely only on your own strength.]],
	color = colors.WHITE,
	level_range = {35, 40},
	rarity = 320,
	require = { stat = { str=44 }, },
	cost = 500,
	material_level = 4,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 6, },
		resists = {
			[DamageType.FIRE] = 25,
			[DamageType.DARKNESS] = 25,
		},
		combat_def = 20,
		combat_armor = 32,
		combat_armor_hardiness = 10,
		stun_immune = 0.4,
		knockback_immune = 0.4,
		combat_physresist = 40,
		healing_factor = -0.3,
		fatigue = 15,
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Dwarf" then
			local Talents = require "engine.interface.ActorStats"

			self:specialWearAdd({"wielder","max_life"}, 100)
			self:specialWearAdd({"wielder","fatigue"}, -15)

			game.logPlayer(who, "#LIGHT_BLUE#You feel your dwarven power swelling to meet the challenge of this armor!")
		end
	end,
}

newEntity{ base = "BASE_GREATSWORD",
	power_source = {psionic=true},
	unique = true,
	name = "Golden Three-Edged Sword 'The Truth'", image = "object/artifact/golden_3_edged_sword.png",
	unided_name = "three-edged sword",
	desc = [[The wise ones say that truth is a three-edged sword. And sometimes, the truth hurts.]],
	level_range = {27, 36},
	require = { stat = { str=18, wil=18, cun=18 }, },
	color = colors.GOLD,
	encumber = 12,
	cost = 350,
	rarity = 240,
	material_level = 3,
	moddable_tile = "special/golden_sword_right",
	moddable_tile_big = true,
	combat = {
		dam = 49,
		apr = 9,
		physcrit = 9,
		dammod = {str=1.29},
		special_on_hit = {desc="9% chance to stun or confuse the target", fct=function(combat, who, target)
			if not rng.percent(9) then return end
			local eff = rng.table{"stun", "confusion"}
			if not target:canBe(eff) then return end
			if not target:checkHit(who:combatAttack(combat), target:combatPhysicalResist(), 15) then return end
			if eff == "stun" then target:setEffect(target.EFF_STUNNED, 3, {})
			elseif eff == "confusion" then target:setEffect(target.EFF_CONFUSED, 3, {power=75})
			end
		end},
		melee_project={[DamageType.LIGHT] = 49, [DamageType.DARKNESS] = 49},
	},
}

newEntity{ base = "BASE_MACE",
	power_source = {nature=true},
	name = "Ureslak's Femur", define_as = "URESLAK_FEMUR", image="object/artifact/club_ureslaks_femur.png",
	unided_name = "a strangely colored bone", unique = true,
	desc = [[A shortened femur of the mighty prismatic dragon, this erratic club still pulses with Ureslak's volatile nature.]],
	level_range = {42, 50},
	require = { stat = { str=45, dex=30 }, },
	rarity = 400,
	metallic = false,
	cost = 300,
	material_level = 5,
	combat = {
		dam = 52,
		apr = 5,
		physcrit = 2.5,
		dammod = {str=1},
		special_on_hit = {desc="10% chance to shimmer to a different hue and gain powers", on_kill=1, fct=function(combat, who, target)
			if not rng.percent(10) then return end
			local o, item, inven_id = who:findInAllInventoriesBy("define_as", "URESLAK_FEMUR")
			if not o or not who:getInven(inven_id).worn then return end

			who:onTakeoff(o, inven_id, true)
			local b = rng.table(o.ureslak_bonuses)
			o.name = "Ureslak's "..b.name.." Femur"
			o.combat.damtype = b.damtype
			o.wielder = b.wielder
			who:onWear(o, inven_id, true)
			game.logSeen(who, "#GOLD#Ureslak's Femur glows and shimmers!")
		end },
	},
	ureslak_bonuses = {
		{ name = "Flaming", damtype = DamageType.FIREBURN, wielder = {
			global_speed_add = 0.3,
			resists = { [DamageType.FIRE] = 45 },
			resists_pen = { [DamageType.FIRE] = 30 },
			inc_damage = { [DamageType.FIRE] = 30 },
		} },
		{ name = "Frozen", damtype = DamageType.ICE, wielder = {
			combat_armor = 15,
			resists = { [DamageType.COLD] = 45 },
			resists_pen = { [DamageType.COLD] = 30 },
			inc_damage = { [DamageType.COLD] = 30 },
		} },
		{ name = "Crackling", damtype = DamageType.LIGHTNING_DAZE, wielder = {
			inc_stats = { [Stats.STAT_STR] = 6, [Stats.STAT_DEX] = 6, [Stats.STAT_CON] = 6, [Stats.STAT_CUN] = 6, [Stats.STAT_WIL] = 6, [Stats.STAT_MAG] = 6, },
			resists = { [DamageType.LIGHTNING] = 45 },
			resists_pen = { [DamageType.LIGHTNING] = 30 },
			inc_damage = { [DamageType.LIGHTNING] = 30 },
		} },
		{ name = "Venomous", damtype = DamageType.POISON, wielder = {
			resists = { all = 15, [DamageType.NATURE] = 45 },
			resists_pen = { [DamageType.NATURE] = 30 },
			inc_damage = { [DamageType.NATURE] = 30 },
		} },
		{ name = "Starry", damtype = DamageType.DARKNESS_BLIND, wielder = {
			combat_spellresist = 15, combat_mentalresist = 15, combat_physresist = 15,
			resists = { [DamageType.DARKNESS] = 45 },
			resists_pen = { [DamageType.DARKNESS] = 30 },
			inc_damage = { [DamageType.DARKNESS] = 30 },
		} },
		{ name = "Eldritch", damtype = DamageType.ARCANE, wielder = {
			resists = { [DamageType.ARCANE] = 45 },
			resists_pen = { [DamageType.ARCANE] = 30 },
			inc_damage = { all = 12, [DamageType.ARCANE] = 30 },
		} },
	},
}

newEntity{ base = "BASE_WARAXE",
	power_source = {psionic=true},
	unique = true, unided_name = "razor sharp war axe",
	name = "Razorblade, the Cursed Waraxe", color = colors.LIGHT_BLUE, image = "object/artifact/razorblade_the_cursed_waraxe.png",
	desc = [[This mighty axe can cleave through armour like the sharpest swords, yet hit with all the impact of a heavy club.
It is said the wielder will slowly grow mad. This, however, has never been proven - no known possessor of this item has lived to tell the tale.]],
	require = { stat = { str=42 }, },
	level_range = {40, 50},
	rarity = 250,
	material_level = 5,
	combat = {
		dam = 58,
		apr = 16,
		physcrit = 7,
		dammod = {str=1},
		damrange = 1.4,
		damtype = DamageType.PHYSICALBLEED,
	},
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 4, [Stats.STAT_DEX] = 4, },
		see_invisible = 5,
		inc_damage = { [DamageType.PHYSICAL]=10 },
	},
}

newEntity{ base = "BASE_LONGSWORD", define_as = "ART_PAIR_TWSWORD",
	power_source = {arcane=true},
	unique = true,
	name = "Sword of Potential Futures", image = "object/artifact/sword_of_potential_futures.png",
	unided_name = "under-wrought blade",
	desc = [[Legend has it this blade is one of a pair: twin blades forged in the earliest of days of the Wardens. To an untrained wielder it is less than perfect; to a Warden, it represents the untapped potential of time.]],
	level_range = {20, 30},
	rarity = 250,
	require = { stat = { str=24, mag=24 }, },
	cost = 300,
	material_level = 3,
	combat = {
		dam = 28,
		apr = 10,
		physcrit = 8,
		physspeed = 0.9,
		dammod = {str=0.8,mag=0.2},
		melee_project={[DamageType.TEMPORAL] = 5},
		convert_damage = {
			[DamageType.TEMPORAL] = 30,
	},
	},
	wielder = {
		inc_damage={
			[DamageType.TEMPORAL] = 5,
		},
		combat_spellpower = 5,
		combat_spellcrit = 5,
		resist_all_on_teleport = 5,
		defense_on_teleport = 10,
		effect_reduction_on_teleport = 15,
	},
	set_list = { {"define_as","ART_PAIR_TWDAG"} },
	on_set_complete = function(self, who)
		self.combat.special_on_hit = {desc="10% chance to reduce the target's resistances to all damage", fct=function(combat, who, target)
			if not rng.percent(10) then return end
			target:setEffect(target.EFF_FLAWED_DESIGN, 3, {power=20})
		end}
		self:specialSetAdd({"wielder","inc_damage"}, {[engine.DamageType.TEMPORAL]=5, [engine.DamageType.PHYSICAL]=10,})
		game.logSeen(who, "#CRIMSON#The echoes of time resound as the blades are reunited once more.")
	end,
	on_set_broken = function(self, who)
		self.combat.special_on_hit = nil
		game.logPlayer(who, "#CRIMSON#Time seems less perfect in your eyes as the blades are separated.")
	end,
}

newEntity{ base = "BASE_KNIFE", define_as = "ART_PAIR_TWDAG",
	power_source = {arcane=true},
	unique = true,
	name = "Dagger of the Past", image = "object/artifact/dagger_of_the_past.png",
	unided_name = "rusted blade",
	desc = [[Legend has it this blade is one of a pair: twin blades forged in the earliest of days of the Wardens. To an untrained wielder it is less than perfect; to a Warden, it represents the opportunity to learn from the mistakes of the past.]],
	level_range = {20, 30},
	rarity = 250,
	require = { stat = { dex=24, mag=24 }, },
	cost = 300,
	material_level = 3,
	combat = {
		dam = 25,
		apr = 20,
		physcrit = 20,
		physspeed = 0.9,
		dammod = {dex=0.5,mag=0.5},
		melee_project={[DamageType.TEMPORAL] = 5},
		convert_damage = {
			[DamageType.TEMPORAL] = 30,
	},
	},
	wielder = {
		inc_damage={
			[DamageType.TEMPORAL] = 5,
		},
		movement_speed = 0.20,
		combat_def = 10,
		combat_spellresist = 10,
		resist_all_on_teleport = 5,
		defense_on_teleport = 10,
		effect_reduction_on_teleport = 15,
	},
	set_list = { {"define_as","ART_PAIR_TWSWORD"} },
	on_set_complete = function(self, who)
		self.combat.special_on_hit = {desc="10% chance to return the target to a much younger state", fct=function(combat, who, target)
			if not rng.percent(10) then return end
			target:setEffect(target.EFF_TURN_BACK_THE_CLOCK, 3, {power=10})
		end}
		self:specialSetAdd({"wielder","inc_damage"}, {[engine.DamageType.TEMPORAL]=5, [engine.DamageType.PHYSICAL]=10,})
		self:specialSetAdd({"wielder","resists_pen"}, {[engine.DamageType.TEMPORAL]=15,})
	end,
	on_set_broken = function(self, who)
		self.combat.special_on_hit = nil
	end,
}

newEntity{ base = "BASE_GAUNTLETS",
	power_source = {arcane=true},
	unique = true,
	name = "Stone Gauntlets of Harkor'Zun",
	unided_name = "dark stone gauntlets",
	desc = [[Fashioned in ancient times by cultists of Harkor'Zun, these heavy granite gauntlets were designed to protect the wearer from the wrath of their dark master.]],
	level_range = {26, 31},
	rarity = 210,
	encumber = 7,
	metallic = false,
	cost = 150,
	material_level = 3,
	wielder = {
		talent_cd_reduction={
			[Talents.T_CLINCH]=2,
		},
		fatigue = 10,
		combat_armor = 7,
		inc_damage = { [DamageType.PHYSICAL]=5, [DamageType.ACID]=10, },
		resists = {[DamageType.ACID] = 20, [DamageType.PHYSICAL] = 10, },
		resists_cap = {[DamageType.ACID] = 10, [DamageType.PHYSICAL] = 5, },
		resists_pen = {[DamageType.ACID] = 15, [DamageType.PHYSICAL] = 15, },
		combat = {
			dam = 26,
			apr = 15,
			physcrit = 5,
			dammod = {dex=0.3, str=-0.4, cun=0.3 },
			melee_project={[DamageType.ACID] = 10},
			talent_on_hit = { T_EARTHEN_MISSILES = {level=3, chance=20}, T_CORROSIVE_MIST = {level=1, chance=10} },
			damrange = 0.3,
			physspeed = 0.2,
		},
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true, psionic=true},
	unique = true,
	name = "Unflinching Eye", color = colors.WHITE, image = "object/artifact/amulet_unflinching_eye.png",
	unided_name = "a bloodshot eye",
	desc = [[Someone has strung a thick black cord through this large bloodshot eyeball, allowing it to be worn around the neck, should you so choose.]],
	level_range = {30, 40},
	rarity = 300,
	cost = 300,
	material_level = 4,
	metallic = false,
	wielder = {
		infravision = 3,
		resists = { [DamageType.LIGHT] = -25 },
		resists_cap = { [DamageType.LIGHT] = -25 },
		blind_immune = 1,
		confusion_immune = 0.5,
		esp = { horror = 1 }, esp_range = 10,
	},
	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_ARCANE_EYE, level = 2, power = 60 },
}

newEntity{ base = "BASE_CLOAK",
	power_source = {nature=true},
	unique = true,
	name = "Ureslak's Molted Scales", image = "object/artifact/ureslaks_molted_scales.png",
	unided_name = "scaley multi-hued cloak",
	desc = [[This cloak is fashioned from the scales of some large reptilian creature.  It appears to reflect every color of the rainbow.]],
	level_range = {40, 50},
	rarity = 400,
	cost = 300,
	material_level = 5,
	wielder = {
		resists_cap = {
			[DamageType.FIRE] = 5,
			[DamageType.COLD] = 5,
			[DamageType.LIGHTNING] = 5,
			[DamageType.NATURE] = 5,
			[DamageType.DARKNESS] = 5,
			[DamageType.ARCANE] = -30,
		},
		resists = {
			[DamageType.FIRE] = 20,
			[DamageType.COLD] = 20,
			[DamageType.LIGHTNING] = 20,
			[DamageType.NATURE] = 20,
			[DamageType.DARKNESS] = 20,
			[DamageType.ARCANE] = -30,
		},
	},
}

newEntity{ base = "BASE_DIGGER",
	power_source = {technique=true},
	unique = true,
	name = "Pick of Dwarven Emperors", color = colors.GREY, image = "object/artifact/pick_of_dwarven_emperors.png",
	unided_name = "crude iron pickaxe",
	desc = [[This ancient pickaxe was used to pass down dwarven legends from one generation to the next. Every bit of the head and shaft is covered in runes that recount the stories of the dwarven people.]],
	level_range = {40, 50},
	rarity = 290,
	cost = 150,
	material_level = 5,
	digspeed = 12,
	wielder = {
		resists_pen = { [DamageType.PHYSICAL] = 10, },
		inc_stats = { [Stats.STAT_STR] = 3, [Stats.STAT_CON] = 3, },
		combat_mentalresist = 7,
		combat_physresist = 7,
		combat_spellresist = 7,
		max_life = 50,
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Dwarf" then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder","inc_stats"}, { [Stats.STAT_STR] = 5, [Stats.STAT_CON] = 5, })
			self:specialWearAdd({"wielder","inc_damage"}, { [engine.DamageType.PHYSICAL] = 10 })
			self:specialWearAdd({"wielder", "talents_types_mastery"}, { ["race/dwarf"] = 0.2 })

			game.logPlayer(who, "#LIGHT_BLUE#You feel the whisper of your ancestors as you wield this pickaxe!")
		end
	end,
}

newEntity{ base = "BASE_ARROW",
	power_source = {arcane=true},
	unique = true,
	name = "Quiver of the Sun",
	unided_name = "bright quiver",
	desc = [[This strange orange quiver is made of brass and etched with many bright red runes that glow and glitter in the light.  The arrows themselves appear to be solid shafts of blazing hot light, like rays of sunshine, hammered and forged into a solid state.]],
	color = colors.BLUE, image = "object/artifact/quiver_of_the_sun.png",
	level_range = {20, 40},
	rarity = 300,
	cost = 100,
	material_level = 4,
	require = { stat = { dex=24 }, },
	combat = {
		capacity = 25,
		tg_type = "beam",
		travel_speed = 3,
		dam = 34,
		apr = 15, --Piercing is piercing
		physcrit = 2,
		dammod = {dex=0.7, str=0.5},
		damtype = DamageType.LITE_LIGHT,
	},
}

newEntity{ base = "BASE_ARROW",
	power_source = {psionic=true},
	unique = true,
	name = "Quiver of Domination",
	unided_name = "grey quiver",
	desc = [[Powerful telepathic forces emanate from the arrows of this quiver. The tips appear dull, but touching them causes you intense pain.]],
	color = colors.GREY, image = "object/artifact/quiver_of_domination.png",
	level_range = {20, 40},
	rarity = 300,
	cost = 100,
	material_level = 4,
	require = { stat = { dex=24 }, },
	combat = {
		capacity = 20,
		dam = 24,
		apr = 8,
		physcrit = 2,
		dammod = {dex=0.6, str=0.5, wil=0.2},
		damtype = DamageType.MIND,
		special_on_crit = {desc="dominate the target", fct=function(combat, who, target)
			if not target or target == self then return end
			if target:canBe("instakill") then
				local check = math.max(src:combatSpellpower(), src:combatMindpower(), src:combatAttack())
				target:setEffect(target.EFF_DOMINATE_ENTHRALL, 3, {src=who, apply_power=check()})
			end
		end},
	},
}

newEntity{ base = "BASE_SHIELD",
	power_source = {nature=true, antimagic=true},
	unique = true,
	name = "Blightstopper",
	unided_name = "vine coated shield",
	desc = [[This voratun shield, coated with thick vines, was imbued with nature's power long ago by the Halfling General Almadar Riul, who used it to stave off the magic and diseases of orcish corruptors during the peak of the Pyre Wars.]],
	color = colors.LIGHT_GREEN, image = "object/artifact/blightstopper.png",
	level_range = {36, 45},
	rarity = 300,
	require = { stat = { str=35 }, },
	cost = 375,
	material_level = 5,
	special_combat = {
		dam = 52,
		block = 240,
		physcrit = 4.5,
		dammod = {str=1},
		damtype = DamageType.PHYSICAL,
		convert_damage = {
			[DamageType.NATURE] = 30,
			[DamageType.MANABURN] = 10,
		},
	},
	wielder = {
		resists={[DamageType.BLIGHT] = 35, [DamageType.NATURE] = 15},
		on_melee_hit={[DamageType.NATURE] = 15},
		combat_armor = 12,
		combat_def = 18,
		combat_def_ranged = 12,
		combat_spellresist = 24,
		talents_types_mastery = { ["wild-gift/antimagic"] = 0.2, },
		fatigue = 22,
		learn_talent = { [Talents.T_BLOCK] = 5,},
		disease_immune = 0.6,
	},
	max_power = 40, power_regen = 1,
	use_power = { name = "purge diseases and increase your resistances", power = 24,
	use = function(self, who)
		local target = who
		local effs = {}
		local known = false

		who:setEffect(who.EFF_PURGE_BLIGHT, 5, {power=20})

			-- Go through all spell effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.subtype.disease then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		for i = 1, 3 + math.floor(who:getWil() / 10) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				target:removeEffect(eff[2])
				known = true
			end
		end
		game.logSeen(who, "%s is purged of diseases!", who.name:capitalize())
		return {id=true, used=true}
	end,
	},
	on_wear = function(self, who)
		if who:attr("forbid_arcane") then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder","resists"}, {[DamageType.ARCANE] = 15, [DamageType.BLIGHT] = 5})
			self:specialWearAdd({"wielder","disease_immune"}, 0.15)
			self:specialWearAdd({"wielder","poison_immune"}, 0.5)
			game.logPlayer(who, "#DARK_GREEN#You feel nature's power protecting you!")
		end
	end,
}

newEntity{ base = "BASE_SHOT",
	power_source = {arcane=true},
	unique = true,
	name = "Star Shot",
	unided_name = "blazing shot",
	desc = [[Intense heat radiates from this powerful shot.]],
	color = colors.RED, image = "object/artifact/star_shot.png",
	level_range = {25, 40},
	rarity = 300,
	cost = 110,
	material_level = 4,
	require = { stat = { dex=28 }, },
	combat = {
		capacity = 20,
		dam = 32,
		apr = 15,
		physcrit = 10,
		dammod = {dex=0.7, cun=0.5},
		damtype = DamageType.FIRE,
		special_on_hit = {desc="sets off a powerful explosion", on_kill=1, fct=function(combat, who, target)
			local tg = {type="ball", range=0, radius=3, selffire=false}
			local grids = who:project(tg, target.x, target.y, engine.DamageType.FIREKNOCKBACK, {dist=3, dam=40 + who:getMag()*0.6 + who:getCun()*0.6})
			game.level.map:particleEmitter(target.x, target.y, tg.radius, "ball_fire", {radius=tg.radius})
		end},
	},
}

--[[ For now
newEntity{ base = "BASE_MINDSTAR",
	power_source = {psionic=true},
	unique = true,
	name = "Withered Force", define_as = "WITHERED_STAR",
	unided_name = "dark mindstar",
	level_range = {28, 38},
	color=colors.AQUAMARINE,
	rarity = 250,
	desc = [=[A hazy aura emanates from this ancient gem, coated with withering, thorny vines.]=],
	cost = 98,
	require = { stat = { wil=24 }, },
	material_level = 4,
	combat = {
		dam = 16,
		apr = 28,
		physcrit = 5,
		dammod = {wil=0.45, cun=0.25},
		damtype = DamageType.MIND,
		convert_damage = {
			[DamageType.DARKNESS] = 30,
		},
		talents_types_mastery = {
			["cursed/gloom"] = 0.2,
			["cursed/darkness"] = 0.2,
		}
	},
	ms_combat = {},
	wielder = {
		combat_mindpower = 14,
		combat_mindcrit = 7,
		inc_damage={
			[DamageType.DARKNESS] 	= 10,
			[DamageType.PHYSICAL]	= 10,
		},
		inc_stats = { [Stats.STAT_WIL] = 4,},
		hate_per_kill = 3,
	},
	max_power = 40, power_regen = 1,
	use_power = { name = "switch the weapon between an axe and a mindstar", power = 40,
		use = function(self, who)
		if self.subtype == "mindstar" then
			ms_combat = table.clone(self.combat)
			--self.name	= "Withered Axe"
			if self:isTalentActive (who.T_PSIBLADES) then
				self:forceUseTalent(who.T_PSIBLADES, {ignore_energy=true})
				game.logSeen(who, "%s rejects the inferior psionic blade!", self.name:capitalize())
			end
			self.desc	= [=[A hazy aura emanates from this dark axe, withering, thorny vines twisting around the handle.]=]
			self.subtype = "waraxe"
			self.image = self.resolvers.image_material("axe", "metal")
			self.moddable_tile = self.resolvers.moddable_tile("axe")
					self:removeAllMOs()
			--Set moddable tile here
			self.combat = nil
			self.combat = {
				talented = "axe", damrange = 1.4, physspeed = 1, sound = {"actions/melee", pitch=0.6, vol=1.2}, sound_miss = {"actions/melee", pitch=0.6, vol=1.2},
				no_offhand_penalty = true,
				dam = 34,
				apr = 8,
				physcrit = 7,
				dammod = {str=0.85, wil=0.2},
				damtype = DamageType.PHYSICAL,
				convert_damage = {
					[DamageType.DARKNESS] = 25,
					[DamageType.MIND] = 15,
				},
			}
		else
			--self.name	= "Withered Star"
			self.image = self.resolvers.image_material("mindstar", "nature")
			self.moddable_tile = self.resolvers.moddable_tile("mindstar")
					self:removeAllMOs()
			--Set moddable tile here
			self.desc	= [=[A hazy aura emanates from this ancient gem, coated with withering, thorny vines."]=]
			self.subtype = "mindstar"
			self.combat = nil
			self.combat = table.clone(ms_combat)
		end
		return {id=true, used=true}
		end
	},
}
]]

newEntity{ base = "BASE_MINDSTAR",
	power_source = {psionic=true},
	unique = true,
	name = "Nexus of the Way",
	unided_name = "brilliant green mindstar",
	level_range = {38, 50},
	color=colors.AQUAMARINE, image = "object/artifact/nexus_of_the_way.png",
	rarity = 350,
	desc = [[The vast psionic force of the Way reverberates through this gemstone. With a single touch, you can sense overwhelming power, and hear countless thoughts.]],
	cost = 280,
	require = { stat = { wil=48 }, },
	material_level = 5,
	combat = {
		dam = 22,
		apr = 40,
		physcrit = 5,
		dammod = {wil=0.6, cun=0.2},
		damtype = DamageType.MIND,
	},
	wielder = {
		combat_mindpower = 20,
		combat_mindcrit = 9,
		confusion_immune=0.3,
		inc_damage={
			[DamageType.MIND] 	= 20,
		},
		resists={
			[DamageType.MIND] 	= 20,
		},
		resists_pen={
			[DamageType.MIND] 	= 20,
		},
		inc_stats = { [Stats.STAT_WIL] = 6, [Stats.STAT_CUN] = 3, },
	},
	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_WAYIST, level = 1, power = 60 },
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Yeek" then
			local Talents = require "engine.interface.ActorStats"
			self:specialWearAdd({"wielder", "talents_types_mastery"}, { ["race/yeek"] = 0.2 })
			self:specialWearAdd({"wielder","combat_mindpower"}, 5)
			self:specialWearAdd({"wielder","combat_mentalresist"}, 15)
			game.logPlayer(who, "#LIGHT_BLUE#You feel the power of the Way within you!")
		end
		if who.descriptor and who.descriptor.race == "Halfling" then
			local Talents = require "engine.interface.ActorStats"
			self:specialWearAdd({"wielder","resists"}, {[engine.DamageType.MIND] = -25,})
			self:specialWearAdd({"wielder","combat_mentalresist"}, -20)
			game.logPlayer(who, "#RED#The Way rejects its former captors!")
		end
	end,
}

newEntity{ base = "BASE_MINDSTAR",
	power_source = {psionic=true},
	unique = true,
	name = "Amethyst of Sanctuary",
	unided_name = "deep purple gem",
	level_range = {30, 38},
	color=colors.AQUAMARINE, image = "object/artifact/amethyst_of_sanctuary.png",
	rarity = 250,
	desc = [[This bright violet gem exudes a calming, focusing force. Holding it, you feel protected against outside forces.]],
	cost = 85,
	require = { stat = { wil=28 }, },
	material_level = 4,
	combat = {
		dam = 15,
		apr = 26,
		physcrit = 6,
		dammod = {wil=0.45, cun=0.22},
		damtype = DamageType.MIND,
	},
	wielder = {
		combat_mindpower = 15,
		combat_mindcrit = 8,
		combat_mentalresist = 25,
		max_psi = 20,
		talents_types_mastery = {
			["psionic/focus"] = 0.1,
			["psionic/absorption"] = 0.2,
		},
		resists={
			[DamageType.MIND] 	= 15,
		},
		inc_stats = { [Stats.STAT_WIL] = 8,},
	},
	max_power = 25, power_regen = 1,
	use_talent = { id = Talents.T_RESONANCE_FIELD, level = 3, power = 25 },
}

newEntity{ base = "BASE_STAFF", define_as = "SET_SCEPTRE_LICH",
	power_source = {arcane=true},
	unique = true,
	name = "Sceptre of the Archlich",
	flavor_name = "vilestaff",
	unided_name = "bone carved sceptre",
	level_range = {30, 38},
	color=colors.VIOLET, image = "object/artifact/sceptre_of_the_archlich.png",
	rarity = 320,
	desc = [[This sceptre, carved of ancient, blackened bone, holds a single gem of deep obsidian. You feel a dark power from deep within, looking to get out.]],
	cost = 285,
	material_level = 4,

	require = { stat = { mag=40 }, },
	combat = {
		dam = 40,
		apr = 12,
		dammod = {mag=1.3},
		damtype = DamageType.DARKNESS,
	},
	wielder = {
		combat_spellpower = 28,
		combat_spellcrit = 14,
		inc_damage={
			[DamageType.DARKNESS] = 26,
		},
		talents_types_mastery = {
			["celestial/star-fury"] = 0.2,
			["spell/necrotic-minions"] = 0.2,
			["spell/advanced-necrotic-minions"] = 0.1,
		}
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Undead" then
			local Talents = require "engine.interface.ActorStats"
			self:specialWearAdd({"wielder", "talents_types_mastery"}, { ["spell/nightfall"] = 0.2 })
			self:specialWearAdd({"wielder","combat_spellpower"}, 12)
			self:specialWearAdd({"wielder","combat_spellresist"}, 10)
			self:specialWearAdd({"wielder","combat_mentalresist"}, 10)
			self:specialWearAdd({"wielder","max_mana"}, 50)
			self:specialWearAdd({"wielder","mana_regen"}, 0.5)
			game.logPlayer(who, "#LIGHT_BLUE#You feel the power of the sceptre flow over your undead form!")
		end
	end,
	set_list = { {"define_as", "SET_LICH_RING"} },
	on_set_complete = function(self, who)
	end,
	on_set_broken = function(self, who)
	end,
}

newEntity{ base = "BASE_MINDSTAR",
	power_source = {nature=true, antimagic=true},
	unique = true,
	name = "Oozing Heart",
	unided_name = "slimy mindstar",
	level_range = {27, 34},
	color=colors.GREEN, image = "object/artifact/oozing_heart.png",
	rarity = 250,
	desc = [[This mindstar oozes a thick, caustic liquid. Magic seems to die around it.]],
	cost = 85,
	require = { stat = { wil=36 }, },
	material_level = 4,
	combat = {
		dam = 17,
		apr = 25,
		physcrit = 7,
		dammod = {wil=0.5, cun=0.2},
		damtype = DamageType.SLIME,
	},
	wielder = {
		combat_mindpower = 12,
		combat_mindcrit = 8,
		combat_spellresist=15,
		inc_damage={
			[DamageType.NATURE] = 18,
			[DamageType.ACID] = 15,
		},
		resists={
			[DamageType.ARCANE] = 12,
			[DamageType.BLIGHT] = 12,
		},
		inc_stats = { [Stats.STAT_WIL] = 7, [Stats.STAT_CUN] = 2, },
		talents_types_mastery = { ["wild-gift/ooze"] = 0.1, ["wild-gift/slime"] = 0.1,},
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_OOZE_SPIT, level = 2, power = 20 },
	on_wear = function(self, who)
		if who:attr("forbid_arcane") then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"combat","melee_project"}, {[DamageType.MANABURN]=30})
			game.logPlayer(who, "#DARK_GREEN#The Heart pulses with antimagic forces as you grasp it.")
		end
	end,
}

newEntity{ base = "BASE_MINDSTAR",
	power_source = {nature=true},
	unique = true,
	name = "Bloomsoul",
	unided_name = "flower covered mindstar",
	level_range = {10, 20},
	color=colors.GREEN, image = "object/artifact/bloomsoul.png",
	rarity = 180,
	desc = [[Pristine flowers coat the surface of this mindstar. Touching it fills you with a sense of calm and refreshes your body.]],
	cost = 40,
	require = { stat = { wil=18 }, },
	material_level = 2,
	combat = {
		dam = 8,
		apr = 13,
		physcrit = 7,
		dammod = {wil=0.25, cun=0.1},
		damtype = DamageType.NATURE,
	},
	wielder = {
		combat_mindpower = 12,
		combat_mindcrit = 8,
		life_regen = 0.5,
		healing_factor = 0.1,
		talents_types_mastery = { ["wild-gift/fungus"] = 0.2,},
	},
	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_BLOOM_HEAL, level = 1, power = 60 },
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	unique = true,
	name = "Gravitational Staff",
	flavor_name = "starstaff",
	unided_name = "heavy staff",
	level_range = {25, 33},
	color=colors.VIOLET, image = "object/artifact/gravitational_staff.png",
	rarity = 240,
	desc = [[Time and Space seem to warp and bend around the massive tip of this stave.]],
	cost = 215,
	material_level = 3,
	require = { stat = { mag=35 }, },
	combat = {
		dam = 30,
		apr = 8,
		dammod = {mag=1.3},
		damtype = DamageType.GRAVITYPIN,
	},
	wielder = {
		combat_spellpower = 25,
		combat_spellcrit = 7,
		inc_damage={
			[DamageType.PHYSICAL] 	= 20,
			[DamageType.TEMPORAL] 	= 12,
		},
		resists={
			[DamageType.PHYSICAL] 	= 15,
		},
		talents_types_mastery = {
			["chronomancy/gravity"] = 0.2,
			["chronomancy/matter"] = 0.1,
			["spell/earth"] = 0.1,
		}
	},
	max_power = 14, power_regen = 1,
	use_talent = { id = Talents.T_GRAVITY_SPIKE, level = 3, power = 14 },
}

newEntity{ base = "BASE_MINDSTAR",
	power_source = {nature=true},
	name = "Eye of the Wyrm", define_as = "EYE_WYRM",
	unided_name = "multi-colored mindstar", unique = true,
	desc = [[A black iris cuts through the core of this mindstar, which shifts with myriad colours. It darts around, as if searching for something.]],
	color = colors.BLUE, image = "object/artifact/eye_of_the_wyrm.png",
	level_range = {30, 40},
	require = { stat = { wil=45, }, },
	rarity = 280,
	cost = 300,
	material_level = 4,
	sentient=true,
	combat = {
		dam = 16,
		apr = 24,
		physcrit = 2.5,
		dammod = {wil=0.4, cun=0.1, str=0.2},
		damtype=DamageType.PHYSICAL,
		convert_damage = {
			[DamageType.COLD] = 18,
			[DamageType.FIRE] = 18,
			[DamageType.ACID] = 18,
			[DamageType.LIGHTNING] = 18,
		},
	},
	wielder = {
		combat_mindpower = 9,
		combat_mindcrit = 7,
		inc_damage={
			[DamageType.PHYSICAL] 	= 8,
			[DamageType.FIRE] 	= 8,
			[DamageType.COLD] 	= 8,
			[DamageType.LIGHTNING] 	= 8,
			[DamageType.ACID] 	= 8,
		},
		resists={
			[DamageType.PHYSICAL] 	= 8,
			[DamageType.FIRE] 	= 8,
			[DamageType.COLD] 	= 8,
			[DamageType.ACID] 	= 8,
			[DamageType.LIGHTNING] 	= 8,
		},
		talents_types_mastery = {
			["wild-gift/sand-drake"] = 0.1,
			["wild-gift/fire-drake"] = 0.1,
			["wild-gift/cold-drake"] = 0.1,
			["wild-gift/storm-drake"] = 0.1,
			["wild-gift/venom-drake"] = 0.1,
		}
	},
	on_wear = function(self, who)
		self.worn_by = who
	end,
	on_takeoff = function(self)
		self.worn_by = nil
	end,
	act = function(self)
		self:useEnergy()
		self:regenPower()
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) and not self.worn_by.player then self.worn_by = nil return end
		if self.worn_by:attr("dead") then return end
		if not rng.percent(25)  then return end
		self.use_talent.id=rng.table{ "T_FIRE_BREATH", "T_ICE_BREATH", "T_LIGHTNING_BREATH", "T_SAND_BREATH", "T_CORROSIVE_BREATH" }
--		game.logSeen(self.worn_by, "#GOLD#The %s shifts colour!", self.name:capitalize())
	end,
	max_power = 30, power_regen = 1,
	--[[use_power = { name = "release a random breath", power = 40,
	use = function(self, who)
			local Talents = require "engine.interface.ActorTalents"
			local breathe = rng.table{
				{Talents.T_FIRE_BREATH},
				{Talents.T_ICE_BREATH},
				{Talents.T_LIGHTNING_BREATH},
				{Talents.T_SAND_BREATH},
			}

			who:forceUseTalent(breathe[1], {ignore_cd=true, ignore_energy=true, force_level=4, ignore_ressources=true})
			return {id=true, used=true}
		end
	},]]
	use_talent = { id = rng.table{ Talents.T_FIRE_BREATH, Talents.T_ICE_BREATH, Talents.T_LIGHTNING_BREATH, Talents.T_SAND_BREATH, Talents.T_CORROSIVE_BREATH }, level = 4, power = 30 }
}

newEntity{ base = "BASE_MINDSTAR",
	power_source = {nature=true},
	name = "Great Caller",
	unided_name = "humming mindstar", unique = true, image = "object",
	desc = [[This mindstar constantly emits a low tone. Life seems to be pulled towards it.]],
	color = colors.GREEN,  image = "object/artifact/great_caller.png",
	level_range = {20, 32},
	require = { stat = { wil=34, }, },
	rarity = 250,
	cost = 220,
	material_level = 3,
	combat = {
		dam = 10,
		apr = 18,
		physcrit = 2.5,
		dammod = {wil=0.35, cun=0.5},
		damtype=DamageType.NATURE,
	},
	wielder = {
		combat_mindpower = 9,
		combat_mindcrit = 6,
		inc_damage={
			[DamageType.PHYSICAL] 	= 8,
			[DamageType.FIRE] 	= 8,
			[DamageType.COLD] 	= 8,
		},
		talents_types_mastery = {
			["wild-gift/summon-melee"] = 0.1,
			["wild-gift/summon-distance"] = 0.1,
			["wild-gift/summon-augmentation"] = 0.1,
			["wild-gift/summon-utility"] = 0.1,
			["wild-gift/summon-advanced"] = 0.1,
		},
		heal_on_nature_summon = 30,
		nature_summon_max = 2,
		inc_stats = { [Stats.STAT_WIL] = 5, [Stats.STAT_CUN] = 4 },
	},
	max_power = 16, power_regen = 1,
	use_talent = { id = Talents.T_RAGE, level = 4, power = 16 },
}

newEntity{ base = "BASE_HELM",
	power_source = {arcane=true},
	unique = true,
	name = "Corrupted Gaze", image = "object/artifact/corrupted_gaze.png",
	unided_name = "dark visored helm",
	desc = [[This helmet radiates a dark power. Its visor seems to twist and corrupt the vision of its wearer. You feel worried that if you were to lower it for long, the visions may affect your mind.]],
	require = { stat = { mag=16 } },
	level_range = {28, 40},
	rarity = 300,
	cost = 300,
	material_level = 4,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 3, [Stats.STAT_CUN] = 4,},
		combat_def = 4,
		combat_armor = 8,
		fatigue = 6,
		resists = { [DamageType.BLIGHT] = 10},
		inc_damage = { [DamageType.BLIGHT] = 20},
		resists_pen = { [DamageType.BLIGHT] = 10},
		disease_immune=0.4,
		talents_types_mastery = { ["corruption/vim"] = 0.1, },
		combat_atk = 10,
		see_invisible = 12,
		see_stealth = 12,
	},
	max_power = 32, power_regen = 1,
	use_talent = { id = Talents.T_VIMSENSE, level = 3, power = 25 },
}

newEntity{ base = "BASE_KNIFE",
	power_source = {arcane=true},
	unique = true,
	name = "Umbral Razor", image = "object/artifact/dagger_silent_blade.png",
	unided_name = "shadowy dagger",
	desc = [[This dagger seems to be formed of pure shadows, with a strange miasma surrounding it.]],
	level_range = {12, 25},
	rarity = 200,
	require = { stat = { dex=32 }, },
	cost = 250,
	material_level = 2,
	combat = {
		dam = 25,
		apr = 10,
		physcrit = 9,
		dammod = {dex=0.45,str=0.45, mag=0.1},
		convert_damage = {
			[DamageType.DARKNESS] = 50,
		},
	},
	wielder = {
		inc_stealth=10,
		inc_stats = {[Stats.STAT_MAG] = 4, [Stats.STAT_CUN] = 4,},
		resists = {[DamageType.DARKNESS] = 10,},
		resists_pen = {[DamageType.DARKNESS] = 10,},
		inc_damage = {[DamageType.DARKNESS] = 5,},
	},
	max_power = 10, power_regen = 1,
	use_talent = { id = Talents.T_INVOKE_DARKNESS, level = 2, power = 8 },
}


newEntity{ base = "BASE_LEATHER_BELT",
	power_source = {technique=true},
	unique = true,
	name = "Emblem of Evasion", color = colors.GOLD,
	unided_name = "gold coated emblem", image = "object/artifact/emblem_of_evasion.png",
	desc = [[Said to have belonged to a master of avoiding attacks, this gilded steel emblem symbolizes his talent.]],
	level_range = {28, 38},
	rarity = 200,
	cost = 50,
	material_level = 4,
	wielder = {
		inc_stats = { [Stats.STAT_LCK] = 8, [Stats.STAT_DEX] = 12, [Stats.STAT_CUN] = 10,},
		slow_projectiles = 30,
		combat_def_ranged = 20,
		projectile_evasion = 15,
	},
	max_power = 30, power_regen = 1,
	use_talent = { id = Talents.T_EVASION, level = 4, power = 30 },
}

newEntity{ base = "BASE_LONGBOW",
	power_source = {technique=true},
	name = "Surefire", unided_name = "high-quality bow", unique=true, image = "object/artifact/surefire.png",
	desc = [[This tightly strung bow appears to have been crafted by someone of considerable talent. When you pull the string, you feel incredible power behind it.]],
	level_range = {5, 15},
	rarity = 200,
	require = { stat = { dex=18 }, },
	cost = 20,
	use_no_energy = true,
	material_level = 1,
	combat = {
		range = 9,
		physspeed = 0.75,
	},
	wielder = {
		inc_damage={ [DamageType.PHYSICAL] = 5, },
		inc_stats = { [Stats.STAT_DEX] = 3},
		combat_atk=12,
		combat_physcrit=5,
		apr = 10,
	},
	max_power = 8, power_regen = 1,
	use_talent = { id = Talents.T_STEADY_SHOT, level = 2, power = 8 },
}

newEntity{ base = "BASE_SHOT",
	power_source = {arcane=true},
	unique = true,
	name = "Frozen Shards", image = "object/artifact/frozen_shards.png",
	unided_name = "pouch of crystallized ice",
	desc = [[In this dark blue pouch lie several small orbs of ice. A strange vapour surrounds them, and touching them chills you to the bone.]],
	color = colors.BLUE,
	level_range = {25, 40},
	rarity = 300,
	cost = 110,
	material_level = 4,
	require = { stat = { dex=28 }, },
	combat = {
		capacity = 25,
		dam = 32,
		apr = 15,
		physcrit = 10,
		dammod = {dex=0.7, cun=0.5},
		damtype = DamageType.ICE,
		special_on_hit = {desc="bursts into an icy cloud",on_kill=1, fct=function(combat, who, target)
			local duration = 4
			local radius = 1
			local dam = (10 + who:getMag()/5 + who:getDex()/3)
			game.level.map:particleEmitter(target.x, target.y, radius, "iceflash", {radius=radius})
			-- Add a lasting map effect
			game.level.map:addEffect(who,
				target.x, target.y, duration,
				engine.DamageType.ICE, dam,
				radius,
				5, nil,
				{type="ice_vapour"},
				function(e)
					e.radius = e.radius
					return true
				end,
				false
			)
		end},
	},
}

newEntity{ base = "BASE_WHIP",
	power_source = {arcane=true},
	unided_name = "electrified whip",
	name = "Stormlash", color=colors.BLUE, unique = true, image = "object/artifact/stormlash.png",
	desc = [[This steel plated whip arcs with intense electricity. The force feels uncontrollable, explosive, powerful.]],
	require = { stat = { dex=15 }, },
	cost = 90,
	rarity = 250,
	level_range = {6, 15},
	material_level = 1,
	combat = {
		dam = 17,
		apr = 7,
		physcrit = 5,
		dammod = {dex=1},
		convert_damage = {[DamageType.LIGHTNING_DAZE] = 50,},
	},
	wielder = {
		combat_atk = 7,
	},
	max_power = 10, power_regen = 1,
	use_power = { name = "strike an enemy in range 3, releasing a burst of lightning", power = 10,
		use = function(self, who)
			local dam = 20 + who:getMag()/2 + who:getDex()/3
			local tg = {type="bolt", range=3}
			local blast = {type="ball", range=0, radius=1, selffire=false}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			local _ _, x, y = who:canProject(tg, x, y)
			local target = game.level.map(x, y, engine.Map.ACTOR)
			if not target then return end
			who:attackTarget(target, engine.DamageType.LIGHTNING, 1, true)
			local _ _, x, y = who:canProject(tg, x, y)
			game.level.map:particleEmitter(who.x, who.y, math.max(math.abs(x-who.x), math.abs(y-who.y)), "lightning", {tx=x-who.x, ty=y-who.y})
			who:project(blast, x, y, engine.DamageType.LIGHTNING, rng.avg(dam / 3, dam, 3))
			game.level.map:particleEmitter(x, y, radius, "ball_lightning", {radius=blast.radius})
			game:playSoundNear(self, "talents/lightning")
			who:logCombat(target, "#Source# strikes #Target#, sending out an arc of lightning!")
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_WHIP",
	power_source = {psionic=true},
	unided_name = "gemmed whip handle",
	name = "Focus Whip", color=colors.YELLOW, unique = true, image = "object/artifact/focus_whip.png",
	desc = [[A small mindstar rests at top of this handle. As you touch it, a translucent cord appears, flicking with your will.]],
	require = { stat = { dex=15 }, },
	cost = 90,
	rarity = 250,
	metallic = false,
	level_range = {18, 28},
	material_level = 3,
	combat = {
		is_psionic_focus=true,
		dam = 19,
		apr = 7,
		physcrit = 5,
		dammod = {dex=0.7, wil=0.2, cun=0.1},
		wil_attack = true,
		damtype=DamageType.MIND,
	},
	wielder = {
		combat_mindpower = 10,
		combat_mindcrit = 3,
		talent_on_hit = { [Talents.T_MINDLASH] = {level=1, chance=18} },
	},
	max_power = 10, power_regen = 1,
	use_power = { name = "strike all targets in a line", power = 10,
		use = function(self, who)
			local tg = {type="beam", range=4}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			who:project(tg, x, y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				who:attackTarget(target, engine.DamageType.MIND, 1, true)
			end)
			local _ _, x, y = who:canProject(tg, x, y)
			game.level.map:particleEmitter(who.x, who.y, tg.radius, "matter_beam", {tx=x-who.x, ty=y-who.y})
			game:playSoundNear(self, "talents/lightning")
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_GREATSWORD",
	power_source = {arcane=true, technique=true},
	unique = true,
	name = "Latafayn",
	unided_name = "flame covered greatsword", image = "object/artifact/latafayn.png",
	level_range = {32, 40},
	color=colors.DARKRED,
	rarity = 300,
	desc = [[This massive, flame-coated greatsword was stolen by the adventurer Kestin Highfin, during the Age of Dusk. It originally belonged to a demon named Frond'Ral the Red.  It roars with vile flames and its very existence seems to be a blight upon the lands.]],
	cost = 400,
	require = { stat = { str=40 }, },
	material_level = 4,
	combat = {
		dam = 68,
		apr = 5,
		physcrit = 10,
		dammod = {str=1.25},
		convert_damage={[DamageType.FIREBURN] = 50},
		lifesteal = 8, --Won't affect the burn damage, so it gets to have a bit more
	},
	wielder = {
		resists = {
			[DamageType.FIRE] = 15,
		},
		inc_damage = {
			[DamageType.FIRE] = 15,
			[DamageType.DARKNESS] = 10,
		},
		inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_CUN] = 3 },
	},
	max_power = 25, power_regen = 1,
	use_power = {name="accelerate burns, instantly inflicting 125% of all burn damage", power = 10, --wherein Pure copies Catalepsy
	use=function(combat, who, target)
		local tg = {type="ball", range=5, radius=1, selffire=false}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end

		local source = nil
		who:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end

			-- List all diseases, I mean, burns
			local burns = {}
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.subtype.fire and p.power and e.status == "detrimental" then
					burns[#burns+1] = {id=eff_id, params=p}
				end
			end
			-- Make them EXPLODE !!!
			for i, d in ipairs(burns) do
				target:removeEffect(d.id)
				engine.DamageType:get(engine.DamageType.FIRE).projector(who, px, py, engine.DamageType.FIRE, d.params.power * d.params.dur * 1.25)
			end
			game.level.map:particleEmitter(target.x, target.y, 1, "ball_fire", {radius=1})
		end)
		game:playSoundNear(who, "talents/fireflash")
		return {id=true, used=true}
	end},
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {psionic=true},
	unique = true,
	name = "Robe of Force", color = colors.YELLOW, image = "object/artifact/robe_of_force.png",
	unided_name = "rippling cloth robe",
	desc = [[This thin cloth robe is surrounded by a pulsating shroud of telekinetic force.]],
	level_range = {20, 28},
	rarity = 190,
	cost = 250,
	material_level = 2,
	wielder = {
		combat_def = 12,
		combat_armor = 8,
		inc_stats = { [Stats.STAT_CUN] = 3, [Stats.STAT_WIL] = 4, },
		combat_mindpower = 8,
		combat_mindcrit = 4,
		combat_physresist = 10,
		inc_damage={[DamageType.PHYSICAL] = 5, [DamageType.MIND] = 5,},
		resists_pen={[DamageType.PHYSICAL] = 10, [DamageType.MIND] = 10,},
		resists={[DamageType.PHYSICAL] = 12, [DamageType.ACID] = 15,},
	},
	max_power = 10, power_regen = 1,
	use_power = { name = "send out a beam of kinetic energy", power = 10,
		use = function(self, who)
			local dam = 15 + who:getWil()/3 + who:getCun()/3
			local tg = {type="beam", range=5}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			who:project(tg, x, y, engine.DamageType.MINDKNOCKBACK, who:mindCrit(rng.avg(0.8*dam, dam)))
			game.level.map:particleEmitter(who.x, who.y, tg.radius, "matter_beam", {tx=x-who.x, ty=y-who.y})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_MINDSTAR",
	power_source = {nature=true},
	unique = true,
	name = "Serpent's Glare", image = "object/artifact/serpents_glare.png",
	unided_name = "venomous gemstone",
	level_range = {1, 10},
	color=colors.GREEN,
	rarity = 180,
	desc = [[A thick venom drips from this mindstar.]],
	cost = 40,
	require = { stat = { wil=12 }, },
	material_level = 1,
	combat = {
		dam = 7,
		apr = 15,
		physcrit = 7,
		dammod = {wil=0.30, cun=0.1},
		damtype = DamageType.NATURE,
		convert_damage={[DamageType.POISON] = 30,}
	},
	wielder = {
		combat_mindpower = 5,
		combat_mindcrit = 5,
		poison_immune = 0.5,
		resists = {
			[DamageType.NATURE] = 10,
		},
		inc_damage = {
			[DamageType.NATURE] = 10,
		}
	},
	max_power = 8, power_regen = 1,
	use_talent = { id = Talents.T_SPIT_POISON, level = 2, power = 8 },
}

--[=[ seems to generate more bugs than it's worth
newEntity{ base = "BASE_LEATHER_CAP",
	power_source = {psionic=true},
	unique = true,
	name = "The Inner Eye", image = "object/artifact/the_inner_eye.png",
	unided_name = "engraved marble eye",
	level_range = {24, 32},
	color=colors.WHITE,
	encumber = 1,
	rarity = 140,
	desc = [[This thick blindfold, with an embedded marble eye, is said to allow the wearer to sense beings around them, at the cost of physical sight.
You suspect the effects will require a moment to recover from.]],
	cost = 200,
	material_level=3,
	wielder = {
		combat_def=3,
		esp_range=-3,
		esp_all=1,
		blind=1,
		combat_mindpower=6,
		combat_mindcrit=4,
		blind_immune=1,
		blind_sight=1, -- So we can see walls, objects, and what not nearby and not break auto-explore.
		combat_mentalresist = 12,
		resists = {[DamageType.LIGHT] = 10,},
		resists_cap = {[DamageType.LIGHT] = 10,},
		resists_pen = {all=5, [DamageType.MIND] = 10,}
	},
	on_wear = function(self, who)
		game.logPlayer(who, "#CRIMSON#Your eyesight fades!")
		who:resetCanSeeCache()
		if who.player then for uid, e in pairs(game.level.entities) do if e.x then game.level.map:updateMap(e.x, e.y) end end game.level.map.changed = true end
	end,
}
]=]

newEntity{ base = "BASE_LONGSWORD", define_as="CORPUS",
	power_source = {unknown=true, technique=true},
	unique = true,
	name = "Corpathus", image = "object/artifact/corpus.png",
	unided_name = "bound sword",
	desc = [[Thick straps encircle this blade. Jagged edges like teeth travel down the blade, bisecting it. It fights to overcome the straps, but lacks the strength.]],
	level_range = {20, 30},
	rarity = 250,
	require = { stat = { str=40, }, },
	cost = 300,
	material_level = 4,
	combat = {
		dam = 40,
		apr = 12,
		physcrit = 4,
		dammod = {str=1,},
		melee_project={[DamageType.DRAINLIFE] = 18},
		special_on_kill = {desc="grows dramatically in power", fct=function(combat, who, target)
			local o, item, inven_id = who:findInAllInventoriesBy("define_as", "CORPUS")
			if not o or not who:getInven(inven_id).worn then return end
			who:onTakeoff(o, inven_id, true)
			o.combat.physcrit = (o.combat.physcrit or 0) + 2
			o.wielder.combat_critical_power = (o.wielder.combat_critical_power or 0) + 4
			who:onWear(o, inven_id, true)
			if not rng.percent(o.combat.physcrit*0.8) or o.combat.physcrit < 30 then return end
			o.summon(o, who)
		end},
		special_on_crit = {desc="grows in power", on_kill=1, fct=function(combat, who, target)
			local o, item, inven_id = who:findInAllInventoriesBy("define_as", "CORPUS")
			if not o or not who:getInven(inven_id).worn then return end
			who:onTakeoff(o, inven_id, true)
			o.combat.physcrit = (o.combat.physcrit or 0) + 1
			o.wielder.combat_critical_power = (o.wielder.combat_critical_power or 0) + 2
			who:onWear(o, inven_id, true)
			if not rng.percent(o.combat.physcrit*0.8) or o.combat.physcrit < 30 then return end
			o.summon(o, who)
		end},
	},
	summon=function(o, who)
		o.cut=nil
		o.combat.physcrit=6
		o.wielder.combat_critical_power = 0
		game.logSeen(who, "Corpathus bursts open, unleashing a horrific mass!")
		local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.ACTOR]=true})
			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				type = "horror", subtype = "eldritch",
				display = "h",
				name = "Vilespawn", color=colors.GREEN,
				image="npc/horror_eldritch_oozing_horror.png",
				desc = "This mass of putrid slime burst from Corpathus, and seems quite hungry.",
				body = { INVEN = 10, MAINHAND=1, OFFHAND=1, },
				rank = 2,
				life_rating = 8, exp_worth = 0,
				life_regen=0,
				max_vim=200,
				max_life = resolvers.rngavg(50,90),
				infravision = 20,
				autolevel = "dexmage",
				ai = "summoned", ai_real = "tactical", ai_state = { talent_in=2, ally_compassion=0},
				stats = { str=15, dex=18, mag=18, wil=15, con=10, cun=18 },
				level_range = {10, nil}, exp_worth = 0,
				silent_levelup = true,
				combat_armor = 0, combat_def = 24,
				combat = { dam=resolvers.rngavg(10,13), atk=15, apr=15, dammod={mag=0.5, dex=0.5}, damtype=engine.DamageType.BLIGHT, },

				resists = { [engine.DamageType.BLIGHT] = 100, [engine.DamageType.NATURE] = -100, },

				on_melee_hit = {[engine.DamageType.DRAINLIFE]=resolvers.mbonus(10, 30)},
				melee_project = {[engine.DamageType.DRAINLIFE]=resolvers.mbonus(10, 30)},

				resolvers.talents{
					[who.T_DRAIN]={base=1, every=7, max = 10},
					[who.T_SPIT_BLIGHT]={base=1, every=6, max = 9},
					[who.T_VIRULENT_DISEASE]={base=1, every=9, max = 7},
					[who.T_BLOOD_FURY]={base=1, every=8, max = 6},
				},
				resolvers.sustains_at_birth(),
				faction = who.faction,
			}

			m:resolve()

			game.zone:addEntity(game.level, m, "actor", x, y)
	end,
	wielder = {
		inc_damage={[DamageType.BLIGHT] = 5,},
		combat_critical_power = 0,
		cut_immune=-0.25,
		max_vim=20,
	},

}

newEntity{ base = "BASE_LONGSWORD",
	power_source = {unknown=true, psionic=true},
	unique = true,
	name = "Anmalice", image = "object/artifact/anima.png", define_as = "ANIMA",
	unided_name = "twisted blade",
	desc = [[The eye on the hilt of this blade seems to glare at you, piercing your soul and mind. Tentacles surround the hilt, latching onto your hand.]],
	level_range = {30, 40},
	rarity = 250,
	require = { stat = { str=32, wil=20, }, },
	cost = 300,
	material_level = 4,
	combat = {
		dam = 47,
		apr = 20,
		physcrit = 7,
		dammod = {str=1,wil=0.1},
		damage_convert = {[DamageType.MIND]=20,},
		special_on_hit = {desc="torments the target with many mental effects", fct=function(combat, who, target)
			if not who:checkHit(who:combatMindpower(), target:combatMentalResist()*0.9) then return end
			target:setEffect(target.EFF_WEAKENED_MIND, 2, {power=0, save=20})
			if not rng.percent(40) then return end
			local eff = rng.table{"stun", "malign", "agony", "confusion", "silence",}
			if not target:canBe(eff) then return end
			if not who:checkHit(who:combatMindpower(), target:combatMentalResist()) then return end
			if eff == "stun" then target:setEffect(target.EFF_MADNESS_STUNNED, 3, {mindResistChange=-25})
			elseif eff == "malign" then target:setEffect(target.EFF_MALIGNED, 3, {resistAllChange=10})
			elseif eff == "agony" then target:setEffect(target.EFF_AGONY, 5, { src=who, damage=40, mindpower=40, range=10, minPercent=10, duration=5})
			elseif eff == "confusion" then target:setEffect(target.EFF_CONFUSED, 3, {power=60})
			elseif eff == "silence" then target:setEffect(target.EFF_SILENCED, 3, {})
			end
		end},
		special_on_kill = {desc="reduces mental save penalty", fct=function(combat, who, target)
			local o, item, inven_id = who:findInAllInventoriesBy("define_as", "ANIMA")
			if not o or not who:getInven(inven_id).worn then return end
			if o.wielder.combat_mentalresist >= 0 then return end
			o.skipfunct=1
			who:onTakeoff(o, inven_id, true)
			o.wielder.combat_mentalresist = (o.wielder.combat_mentalresist or 0) + 2
			who:onWear(o, inven_id, true)
			o.skipfunct=nil
		end},
	},
	wielder = {
		combat_mindpower=9,
		combat_mentalresist=-30,
		inc_damage={
			[DamageType.MIND] = 8,
		},
	},
	sentient=true,
	act = function(self)
		self:useEnergy()
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) and not self.worn_by.player then self.worn_by=nil return end
		if self.worn_by:attr("dead") then return end
		local who = self.worn_by
			local blast = {type="ball", range=0, radius=2, selffire=false}
			who:project(blast, who.x, who.y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				if not rng.percent(20) then return end
				target:setEffect(target.EFF_WEAKENED_MIND, 2, {power=0, save=5})
				who:logCombat(target, "Anmalice focuses its mind-piercing eye on #Target#!")
			end)
	end,
	on_takeoff = function(self, who)
		if self.skipfunct then return end
		self.worn_by=nil
		who:removeParticles(self.particle)
		if self.wielder.combat_mentalresist == 0 then
			game.logPlayer(who, "#CRIMSON#The tentacles release your arm, sated.")
		else
			game.logPlayer(who, "#CRIMSON#As you tear the tentacles from your arm, horrible images enter your mind!")
			who:setEffect(who.EFF_WEAKENED_MIND, 15, {power=0, save=25})
			who:setEffect(who.EFF_AGONY, 5, { src=who, damage=15, mindpower=40, range=10, minPercent=10, duration=5})
		end
		self.wielder.combat_mentalresist = -30
	end,
	on_wear = function(self, who)
		if self.skipfunct then return end
		self.particle = who:addParticles(engine.Particles.new("gloom", 1))
		self.worn_by = who
		game.logPlayer(who, "#CRIMSON#As you wield the sword, the tentacles on its hilt wrap around your arm. You feel the sword's will invading your mind!")
	end,
}

newEntity{ base = "BASE_LONGSWORD", define_as="MORRIGOR",
	power_source = {arcane=true, unknown=true},
	unique = true, sentient = true,
	name = "Morrigor", image = "object/artifact/morrigor.png",
	unided_name = "jagged, segmented, sword",
	desc = [[This heavy, ridged blade emanates magical power, yet as you grasp the handle an icy chill runs its course through your spine. You feel the disembodied presence of all those slain by it. In unison, they demand company.]],
	level_range = {20, 30},
	rarity = 250,
	require = { stat = { mag=40, }, },
	cost = 300,
	material_level = 4,
	combat = {
		dam = 50,
		apr = 12,
		physcrit = 7,
		dammod = {str=0.6, mag=0.6},
		special_on_hit = {desc="deal bonus arcane and darkness damage", fct=function(combat, who, target)
			local tg = {type="ball", range=1, radius=0, selffire=false}
			who:project(tg, target.x, target.y, engine.DamageType.ARCANE, who:getMag()*0.5)
			who:project(tg, target.x, target.y, engine.DamageType.DARKNESS, who:getMag()*0.5)
		end},
		special_on_kill = {desc="swallows the victim's soul, gaining a new power", fct=function(combat, who, target)
			local o, item, inven_id = who:findInAllInventoriesBy("define_as", "MORRIGOR")
			if o.use_talent then return end
			local got_talent = false
			local tids = {}
			for tid, _ in pairs(target.talents) do
				local t = target:getTalentFromId(tid)
				if t.mode == "activated" and not t.uber and not t.on_pre_use and not t.no_npc_use and not t.hide and not t.is_nature and not t.type[1]:find("/other") and not t.type[1]:find("horror") and not t.type[1]:find("race/") and not t.type[1]:find("inscriptions/") and t.id ~= who.T_HIDE_IN_PLAIN_SIGHT then
					tids[#tids+1] = tid
					got_talent = true
				end
			end
			if got_talent == true then
				local get_talent = rng.table(tids)
				local t = target:getTalentFromId(get_talent)
				o.use_talent = {}
				o.use_talent.id = t.id
				o.use_talent.power = (who:getTalentCooldown(t) or 5)
				o.use_talent.level = 3
				o.power = 1
				o.max_power = (who:getTalentCooldown(t) or 5)
				o.power_regen = 1
			end
	end},
	},
	wielder = {
		combat_spellpower=24,
		combat_spellcrit=12,
		learn_talent = { [Talents.T_SOUL_PURGE] = 1, },
	},
}

newEntity{ base = "BASE_WHIP", define_as = "HYDRA_BITE",
	slot_forbid = "OFFHAND",
	offslot = false,
	twohanded=true,
	power_source = {technique=true, nature=true},
	unique = true,
	name = "Hydra's Bite", color = colors.LIGHT_RED, image = "object/artifact/hydras_bite.png",
	unided_name = "triple headed flail",
	desc = [[This three-headed stralite flail strikes with the power of a hydra. With each attack it lashes out, hitting everyone around you.]],
	level_range = {32, 40},
	rarity = 250,
	require = { stat = { str=40 }, },
	cost = 650,
	material_level = 4,
	running = 0, --For the on hit
	combat = {
		dam = 56,
		apr = 7,
		physcrit = 14,
		dammod = {str=1.1},
		talent_on_hit = { [Talents.T_LIGHTNING_BREATH_HYDRA] = {level=1, chance=10}, [Talents.T_ACID_BREATH] = {level=1, chance=10}, [Talents.T_POISON_BREATH] = {level=1, chance=10} },
		--convert_damage = {[DamageType.NATURE]=25,[DamageType.ACID]=25,[DamageType.LIGHTNING]=25},
		special_on_hit = {desc="hit up to two adjacent enemies",on_kill=1, fct=function(combat, who, target)
				local o, item, inven_id = who:findInAllInventoriesBy("define_as", "HYDRA_BITE")
				if not o or not who:getInven(inven_id).worn then return end
				local tgts = {}
				local twohits=1
				for _, c in pairs(util.adjacentCoords(who.x, who.y)) do
				local targ = game.level.map(c[1], c[2], engine.Map.ACTOR)
				if targ and targ ~= target and who:reactionToward(target) < 0 then tgts[#tgts+1] = targ end
				end
				if #tgts == 0 then return end
					local target1 = rng.table(tgts)
					local target2 = rng.table(tgts)
					local tries = 0
				while target1 == target2 and tries < 100 do
					local target2 = rng.table(tgts)
					tries = tries + 1
				end
				if o.running == 1 then return end
				o.running = 1
				if tries >= 100 or #tgts==1 then twohits=nil end
				if twohits then
					who:logCombat(target1, "#Source#'s three headed flail lashes at #Target#%s!",who:canSee(target2) and (" and %s"):format(target2.name:capitalize()) or "")
				else
					who:logCombat(target1, "#Source#'s three headed flail lashes at #Target#!")
				end
				who:attackTarget(target1, engine.DamageType.PHYSICAL, 0.4,  true)
				if twohits then who:attackTarget(target2, engine.DamageType.PHYSICAL, 0.4,  true) end
				o.running=0
		end},
	},
	wielder = {
		inc_damage={[DamageType.NATURE]=12, [DamageType.ACID]=12, [DamageType.LIGHTNING]=12,},

	},
}

newEntity{ base = "BASE_GAUNTLETS",
	power_source = {technique=true, antimagic=true},
	define_as = "GAUNTLETS_SPELLHUNT",
	unique = true,
	name = "Spellhunt Remnants", color = colors.GREY, image = "object/artifact/spellhunt_remnants.png",
	unided_name = "rusted voratun gauntlets",
	desc = [[These once brilliant voratun gauntlets have fallen into a deep decay. Originally used in the spellhunt, they were often used to destroy arcane artifacts, curing the world of their influence.]],
	level_range = {1, 25}, --Relevant at all levels, though of course mat level 1 limits it to early game.
	rarity = 450, -- But rare to make it not ALWAYS appear.
	cost = 1000,
	material_level = 1,
	wielder = {
		combat_mindpower=4,
		combat_mindcrit=1,
		combat_spellresist=4,
		combat_def=1,
		combat_armor=2,
		combat = {
			dam = 12,
			apr = 4,
			physcrit = 3,
			physspeed = 0.2,
			dammod = {dex=0.4, str=-0.6, cun=0.4,},
			damrange = 0.3,
			melee_project={[DamageType.RANDOM_SILENCE] = 10},
			talent_on_hit = { [Talents.T_DESTROY_MAGIC] = {level=1, chance=100} },
		},
	},
	power_up= function(self, who, level)
		local Stats = require "engine.interface.ActorStats"
		local Talents = require "engine.interface.ActorTalents"
		local DamageType = require "engine.DamageType"
		local _, _, inven_id = who:findInAllInventoriesByObject(self)
		who:onTakeoff(self, inven_id, true)
		self.wielder=nil
		if level==2 then -- LEVEL 2
		self.desc = [[These once brilliant voratun gauntlets appear heavily decayed. Originally used in the spellhunt, they were often used to destroy arcane artifacts, ridding the world of their influence.]]
		self.wielder={
			combat_mindpower=6,
			combat_mindcrit=2,
			combat_spellresist=6,
			combat_def=2,
			combat_armor=3,
			combat = {
				dam = 17,
				apr = 8,
				physcrit = 6,
				physspeed = 0.2,
				dammod = {dex=0.4, str=-0.6, cun=0.4,},
				damrange = 0.3,
				melee_project={[DamageType.RANDOM_SILENCE] = 12},
				talent_on_hit = { [Talents.T_DESTROY_MAGIC] = {level=2, chance=100} },
			},
		}
		elseif  level==3 then -- LEVEL 3
		self.desc = [[These voratun gauntlets appear to have suffered considerable damage. Originally used in the spellhunt, they were often used to destroy arcane artifacts, ridding the world of their influence.]]
		self.wielder={
			combat_mindpower=8,
			combat_mindcrit=3,
			combat_spellresist=8,
			combat_def=3,
			combat_armor=4,
			combat = {
				dam = 22,
				apr = 12,
				physcrit = 8,
				physspeed = 0.2,
				dammod = {dex=0.4, str=-0.6, cun=0.4,},
				damrange = 0.3,
				melee_project={[DamageType.RANDOM_SILENCE] = 15, [DamageType.ITEM_ANTIMAGIC_MANABURN] = 20,},
				talent_on_hit = { [Talents.T_DESTROY_MAGIC] = {level=3, chance=100}, [Talents.T_MANA_CLASH] = {level=1, chance=5} },
			},
		}
		elseif  level==4 then -- LEVEL 4
		self.desc = [[These voratun gauntlets shine brightly beneath a thin layer of wear. Originally used in the spellhunt, they were often used to destroy arcane artifacts, ridding the world of their influence.]]
		self.wielder={
			combat_mindpower=10,
			combat_mindcrit=4,
			combat_spellresist=10,
			combat_def=4,
			combat_armor=5,
			combat = {
				dam = 27,
				apr = 15,
				physcrit = 10,
				physspeed = 0.2,
				dammod = {dex=0.4, str=-0.6, cun=0.4,},
				damrange = 0.3,
				melee_project={[DamageType.RANDOM_SILENCE] = 17, [DamageType.ITEM_ANTIMAGIC_MANABURN] = 35,},
				talent_on_hit = { [Talents.T_DESTROY_MAGIC] = {level=4, chance=100}, [Talents.T_MANA_CLASH] = {level=2, chance=10} },
			},
		}
		elseif  level==5 then -- LEVEL 5
		self.desc = [[These brilliant voratun gauntlets shine with an almost otherworldly glow. Originally used in the spellhunt, they were often used to destroy arcane artifacts, ridding the world of their influence. You feel proud of having fulfilled this ancient duty.]]
		self.wielder={
			combat_mindpower=12,
			combat_mindcrit=5,
			combat_spellresist=15,
			combat_def=6,
			combat_armor=8,
			lite=1,
			combat = {
				dam = 33,
				apr = 18,
				physcrit = 12,
				physspeed = 0.2,
				dammod = {dex=0.4, str=-0.6, cun=0.4,},
				damrange = 0.3,
				melee_project={[DamageType.RANDOM_SILENCE] = 20, [DamageType.ITEM_ANTIMAGIC_MANABURN] = 50,},
				talent_on_hit = { [Talents.T_DESTROY_MAGIC] = {level=5, chance=100}, [Talents.T_MANA_CLASH] = {level=3, chance=15}, [Talents.T_AURA_OF_SILENCE] = {level=1, chance=10} },
			},
		}
		self.use_power.name = "destroy magic in a radius 5 cone"
		self.use_power.power = 100
		self.use_power.use= function(self,who)
			local tg = {type="cone", range=0, radius=5}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			who:project(tg, x, y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				target:setEffect(target.EFF_SPELL_DISRUPTION, 10, {src=who, power = 50, max = 75, apply_power=who:combatMindpower()})
				for i = 1, 2 do
					local effs = {}
					-- Go through all spell effects
					for eff_id, p in pairs(target.tmp) do
						local e = target.tempeffect_def[eff_id]
						if e.type == "magical" then
							effs[#effs+1] = {"effect", eff_id}
						end
					end
					-- Go through all sustained spells
					for tid, act in pairs(target.sustain_talents) do
						if act then
							local talent = target:getTalentFromId(tid)
							if talent.is_spell then effs[#effs+1] = {"talent", tid} end
						end
					end
					local eff = rng.tableRemove(effs)
					if eff then
						if eff[1] == "effect" then
						target:removeEffect(eff[2])
						else
							target:forceUseTalent(eff[2], {ignore_energy=true})
						end
					end
				end
				if target.undead or target.construct then
					who:project({type="hit"}, target.x, target.y, engine.DamageType.ARCANE,100+who:combatMindpower())
					if target:canBe("stun") then target:setEffect(target.EFF_STUNNED, 10, {apply_power=who:combatMindpower()}) end
					game.logSeen(who, "%s's animating magic is disrupted by the burst of power!", who.name:capitalize())
				end
			end, nil, {type="slime"})
			game:playSoundNear(who, "talents/breath")
			return {id=true, used=true}
		end
		end

		who:onWear(self, inven_id, true)
	end,
	max_power = 150, power_regen = 1,
	use_power = { name = "destroy an arcane item (of a higher tier than the gauntlets)", power = 1, use = function(self, who, obj_inven, obj_item)
		local d = who:showInventory("Destroy which item?", who:getInven("INVEN"), function(o) return o.unique and o.power_source and o.power_source.arcane and o.power_source.arcane and o.power_source.arcane == true and o.material_level and o.material_level > self.material_level end, function(o, item, inven)
			if o.material_level <= self.material_level then return end
			self.material_level=o.material_level
			game.logPlayer(who, "You crush the %s, and the gloves take on an illustrious shine!", o:getName{do_color=true})

			if not o then return end
			who:removeObject(who:getInven("INVEN"), item)
			who:sortInven(who:getInven("INVEN"))

			self.power_up(self, who, self.material_level)

			who.changed=true
		end)
	end },
}

newEntity{ base = "BASE_LONGBOW",
	power_source = {arcane=true},
	name = "Merkul's Second Eye", unided_name = "sleek stringed bow", unique=true, image = "object/artifact/merkuls_second_eye.png",
	desc = [[This bow is said to have been the tool of an infamous dwarven spy. Rumours say it allowed him to "steal" the eyes of his enemies. Adversaries struck were left alive, only to unknowingly divulge their secrets to his unwavering sight.]],
	level_range = {20, 38},
	rarity = 250,
	require = { stat = { dex=24 }, },
	cost = 200,
	material_level = 3,
	combat = {
		range = 9,
		physspeed = 0.8,
		travel_speed = 4,
		talent_on_hit = { [Talents.T_ARCANE_EYE] = {level=4, chance=100} },
	},
	wielder = {
		lite = 2,
		ranged_project = {[DamageType.ARCANE] = 25},
	},
}

newEntity{ base = "BASE_SHIELD",
	power_source = {nature=true},
	unique = true,
	name = "Summertide",
	unided_name = "shining gold shield", image = "object/artifact/summertide.png",
	level_range = {38, 50},
	color=colors.GOLD,
	rarity = 350,
	desc = [[A bright light shines from the center of this shield. Holding it clears your mind.]],
	cost = 280,
	require = { stat = { wil=28, str=20, }, },
	material_level = 5,
	special_combat = {
		dam = 52,
		block = 260,
		physcrit = 4.5,
		dammod = {str=1},
		damtype = DamageType.LIGHT,
		special_on_hit = {desc="releases a burst of light", on_kill=1, fct=function(combat, who, target)
			local tg = {type="ball", range=0, radius=1, selffire=false}
			local grids = who:project(tg, target.x, target.y, engine.DamageType.LITE_LIGHT, 30 + who:getWil()*0.5)
			game.level.map:particleEmitter(target.x, target.y, tg.radius, "ball_light", {radius=tg.radius})
		end},
		melee_project = {[DamageType.ITEM_LIGHT_BLIND]=30},
	},
	wielder = {
		combat_armor = 15,
		combat_def = 17,
		combat_def_ranged = 17,
		fatigue = 12,
		combat_mindpower = 8,
		combat_mentalresist=18,
		blind_immune=1,
		confusion_immune=0.25,
		lite=3,
		max_psi=20,
		inc_damage={
			[DamageType.MIND] 	= 15,
			[DamageType.LIGHT] 	= 15,
			[DamageType.FIRE] 	= 10,
		},
		resists={
			[DamageType.LIGHT] 		= 20,
			[DamageType.DARKNESS] 	= 15,
			[DamageType.MIND] 		= 12,
			[DamageType.FIRE] 		= 10,
		},
		resists_pen={
			[DamageType.LIGHT] 	= 10,
			[DamageType.MIND] 	= 10,
			[DamageType.FIRE] 	= 10,
		},
		learn_talent = { [Talents.T_BLOCK] = 5, },
		inc_stats = { [Stats.STAT_WIL] = 5, [Stats.STAT_CUN] = 3, },
	},
	max_power = 30, power_regen = 1,
	use_power = { name = "send out a beam of light", power = 12,
		use = function(self, who)
			local dam = 20 + who:getWil()/3 + who:getCun()/3
			local tg = {type="beam", range=7}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			
			who:project(tg, x, y, engine.DamageType.LITE_LIGHT, who:mindCrit(rng.avg(0.8*dam, dam)))
			game.level.map:particleEmitter(who.x, who.y, tg.radius, "light_beam", {tx=x-who.x, ty=y-who.y})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_LEATHER_BOOT", 
	power_source = {psionic=true},
	unique = true,
	name = "Wanderer's Rest", image = "object/artifact/wanderers_rest.png",--Thanks Grayswandir! (just for the name this time!)
	unided_name = "weightless boots",
	desc = [[These boots feel nearly completely weightless. Touching them, you feel an enormous burden lifted from you.]],
	encumber=0,
	color = colors.YELLOW,
	level_range = {17, 28},
	rarity = 200,
	cost = 100,
	material_level = 3,
	wielder = {
		combat_def = 4,
		fatigue = -10,
		mindpower=4,
		inc_stats = { [Stats.STAT_DEX] = 3, },
		movement_speed=0.10,
		pin_immune=1,
		resists={
			[DamageType.PHYSICAL] = 5,
		},
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_TELEKINETIC_LEAP, level = 3, power = 20 },
}

newEntity{ base = "BASE_CLOTH_ARMOR", --Thanks Grayswandir!
	power_source = {arcane=true},
	unique = true,
	name = "Silk Current", color = colors.BLUE, image = "object/artifact/silk_current.png",
	unided_name = "flowing robe",
	desc = [[This deep blue robe flows and ripples as if pushed by an invisible tide.]],
	level_range = {1, 15},
	rarity = 220,
	cost = 250,
	material_level = 1,
	wielder = {
		combat_def = 12,
		combat_spellpower = 4,
		
		inc_damage={[DamageType.COLD] = 10},
		resists={[DamageType.COLD] = 15},
		resists_pen={[DamageType.COLD] = 8},
		on_melee_hit={[DamageType.COLD] = 10,},
		
		movement_speed=0.15,
		talents_types_mastery = {
 			["spell/water"] = 0.1,
 		},
	},
}

newEntity{ base = "BASE_WHIP", --Thanks Grayswandir!
	power_source = {arcane=true},
	unided_name = "bone-link chain",
	name = "Skeletal Claw", color=colors.GREEN, unique = true, image = "object/artifact/skeletal_claw.png",
	desc = [[This whip appears to have been made from a human spine. A handle sits on one end, a sharply honed claw on the other.]],
	require = { stat = { dex=14 }, },
	cost = 150,
	rarity = 325,
	level_range = {40, 50},
	metallic = false,
	material_level = 5,
	combat = {
		dam = 55,
		apr = 8,
		physcrit = 9,
		dammod = {dex=1},
		melee_project={[DamageType.BLEED] = 30},
		burst_on_crit = {
			[DamageType.BLEED] = 50,
		},
		talent_on_hit = { [Talents.T_BONE_GRAB] = {level=3, chance=10}, [Talents.T_BONE_SPEAR] = {level=4, chance=20} },
		
	},
	wielder = {
		combat_def = 12,
		combat_spellpower = 4,
		combat_physspeed = 0.1,
		talents_types_mastery = { ["corruption/bone"] = 0.25, },
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_BONE_NOVA, level = 4, power = 20 },
	talent_on_spell = { {chance=10, talent=Talents.T_BONE_SPEAR, level=4} },
}

newEntity{ base = "BASE_MINDSTAR",
	power_source = {psionic=true},
	unique = true,
	name = "Core of the Forge", image = "object/artifact/core_of_the_forge.png",
	unided_name = "fiery mindstar",
	level_range = {38, 50},
	color=colors.RED,
	rarity = 350,
	desc = [[This blazing hot mindstar beats rhythmically, releasing a burst of heat with each strike.]],
	cost = 280,
	require = { stat = { wil=40 }, },
	material_level = 5,
	combat = {
		dam = 24,
		apr = 40,
		physcrit = 5,
		dammod = {wil=0.6, cun=0.2},
		damtype = DamageType.DREAMFORGE,
	},
	wielder = {
		combat_mindpower = 15,
		combat_mindcrit = 8,
		combat_atk=10,
		combat_dam=10,
		inc_damage={
			[DamageType.MIND] 		= 10,
			[DamageType.PHYSICAL] 	= 10,
			[DamageType.FIRE] 		= 10,
		},
		resists={
			[DamageType.MIND] 		= 5,
			[DamageType.PHYSICAL] 	= 5,
			[DamageType.FIRE] 		= 15,
		},
		resists_pen={
			[DamageType.MIND] 		= 10,
			[DamageType.PHYSICAL] 	= 10,
		},
		inc_stats = { [Stats.STAT_WIL] = 6, [Stats.STAT_CUN] = 3, },
		talents_types_mastery = {
			["psionic/dream-forge"] = 0.2,
			["psionic/dream-smith"] = 0.2,
		},
		melee_project={[DamageType.DREAMFORGE] = 30,},
	},
	max_power = 30, power_regen = 1,
	use_talent = { id = Talents.T_FORGE_BELLOWS, level = 3, power = 24 },
}

newEntity{ base = "BASE_LEATHER_BOOT", --Thanks Grayswandir!
	power_source = {arcane=true},
	unique = true,
	name = "Aetherwalk", image = "object/artifact/aether_walk.png",
	unided_name = "ethereal boots",
	desc = [[A wispy purple aura surrounds these translucent black boots.]],
	color = colors.PURPLE,
	level_range = {30, 40},
	rarity = 200,
	cost = 100,
	material_level = 4,
	wielder = {
		combat_def = 6,
		fatigue = 1,
		spellpower=5,
		inc_stats = { [Stats.STAT_MAG] = 8, [Stats.STAT_CUN] = 8,},
		resists={
			[DamageType.ARCANE] = 12,
		},
		resists_cap={
			[DamageType.ARCANE] = 5,
		},
	},
	max_power = 24, power_regen = 1,
	use_power = { name = "phase door in range 6, radius 2", power = 24,
		use = function(self, who)
			local tg = {type="ball", nolock=true, pass_terrain=true, nowarning=true, range=6, radius=2, requires_knowledge=false}
			local x, y = who:getTarget(tg)
			if not x then return nil end
			-- Target code does not restrict the target coordinates to the range, it lets the project function do it
			-- but we cant ...
			local _ _, x, y = who:canProject(tg, x, y)

			-- Check LOS
			local rad = 2
			game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
			who:teleportRandom(x, y, rad)
			game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
			
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_GREATSWORD", -- Thanks Alex!
	power_source = {arcane=true},
	unique = true,
	name = "Colaryem",
	unided_name = "floating sword", image = "object/artifact/colaryem.png",
	level_range = {16, 36},
	color=colors.BLUE,
	rarity = 300,
	desc = [[This intricate blade is impractically long and almost as wide as your body, yet contrary to its size and apparent girth it is not only light, but threatens to escape your grasp and fly away. You will need to be really strong to keep it grounded. Or really big.]],
	cost = 400,
	require = { stat = { str=10 }, },
	sentient=true,
	material_level = 3,
	special_desc = function(self) return "Attack speed improves with your strength and size category." end,
	combat = {
		dam = 48,
		apr = 12,
		physcrit = 11,
		dammod = {str=1.3},
		physspeed=1.8,
	},
	wielder = {
		resists = { [DamageType.LIGHTNING] = 7 },
		inc_damage = { [DamageType.LIGHTNING] = 7, },
		movement_speed = 0.1,
		inc_stats = { [Stats.STAT_DEX] = 7 },
		max_encumber = 50,
		fatigue = -12,
		avoid_pressure_traps = 1,
	},
	act = function(self)
		self:useEnergy()
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) and not self.worn_by.player then self.worn_by=nil return end
		if self.worn_by:attr("dead") then return end
		
		local size = self.worn_by.size_category-3
		local str = self.worn_by:getStr()
		self.combat.physspeed=util.bound(1.8-(str-10)*0.02-size*0.1, 0.80, 1.8)
	end,
	on_wear = function(self, who)
		self.worn_by = who
		
		local size = self.worn_by.size_category-3
		local str = self.worn_by:getStr()
		self.combat.physspeed=util.bound(1.8-(str-10)*0.02-size*0.1, 0.80, 1.8)
	end,
	on_takeoff = function(self, who)
		self.worn_by = nil
		self.combat.physspeed=2
	end,
}

newEntity{ base = "BASE_ARROW", --Thanks Grayswandir!
	power_source = {arcane=true},
	unique = true,
	name = "Void Quiver",
	unided_name = "ethereal quiver",
	desc = [[An endless supply of arrows lay within this deep black quiver. Tiny white lights dot its surface.]],
	color = colors.BLUE, image = "object/artifact/void_quiver.png",
	level_range = {35, 50},
	rarity = 300,
	cost = 100,
	material_level = 5,
	infinite=true,
	require = { stat = { dex=32 }, },
	combat = {
		capacity = 0,
		dam = 45,
		apr = 30, --No armor can stop the void
		physcrit = 6,
		dammod = {dex=0.7, str=0.5, mag=0.1,},
		damtype = DamageType.VOID,
		talent_on_hit = { [Talents.T_QUANTUM_SPIKE] = {level=1, chance=10}, [Talents.T_TEMPORAL_CLONE] = {level=1, chance=5} },
	},
}

newEntity{ base = "BASE_ARROW", --Thanks Grayswandir!
	power_source = {nature=true},
	unique = true,
	name = "Hornet Stingers", image = "object/artifact/hornet_stingers.png",
	unided_name = "sting tipped arrows",
	desc = [[A vile poison drips from the tips of these arrows.]],
	color = colors.BLUE,
	level_range = {15, 25},
	rarity = 240,
	cost = 100,
	material_level = 2,
	require = { stat = { dex=18 }, },
	combat = {
		capacity = 20,
		dam = 18,
		apr = 10,
		physcrit = 5,
		dammod = {dex=0.7, str=0.5},
		ranged_project={
			[DamageType.CRIPPLING_POISON] = 45,
		},
	},
}

newEntity{ base = "BASE_LITE", --Thanks Frumple!
	power_source = {psionic=true},
	unique = true,
	name = "Umbraphage", image="object/artifact/umbraphage.png",
	unided_name = "deep black lantern",
	level_range = {20, 30},
	color=colors.BLACK,
	rarity = 240,
	desc = [[This lantern of pale white crystal holds a sphere of darkness, that yet emanates light. Everywhere it shines, darkness vanishes entirely.]],
	cost = 320,
	material_level=3,
	sentient=true,
	charge = 0,
	special_desc = function(self) return "Absorbs all darkness in its light radius." end,
	on_wear = function(self, who)
		self.worn_by = who
	end,
	on_takeoff = function(self, who)
		self.worn_by = nil
	end,
	act = function(self)
		self:useEnergy()
		self:regenPower()
		
		local who=self.worn_by --Make sure you can actually act!
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) and not self.worn_by.player then self.worn_by = nil return end
		if self.worn_by:attr("dead") then return end
		
		
		who:project({type="ball", range=0, radius=self.wielder.lite}, who.x, who.y, function(px, py) -- The main event!
			local is_lit = game.level.map.lites(px, py)
			if is_lit then return end
			
			if not self.max_charge then
			
				self.charge = self.charge + 1
				
				if self.charge == 200 then
					self.max_charge=true
					game.logPlayer(who, "Umbraphage is fully powered!")
				end
			
			end
		end)
		who:project({type="ball", range=0, radius=self.wielder.lite}, who.x, who.y, engine.DamageType.LITE, 100) -- Light the space!
		if (5 + math.floor(self.charge/20)) > self.wielder.lite and self.wielder.lite < 10 then
			local p = self.power
			who:onTakeoff(self, who.INVEN_LITE, true)
			self.wielder.lite = math.min(10, 5+math.floor(self.charge/20))
			who:onWear(self, who.INVEN_LITE, true)
			self.power = p
		end
	end,
	wielder = {
		lite = 5,
		combat_mindpower=10,
		combat_mentalresist=10,
		
		inc_damage = {[DamageType.LIGHT]=15, [DamageType.DARKNESS]=15},
		resists = {[DamageType.DARKNESS]=20},
		resists_pen = {[DamageType.DARKNESS]=10},
		damage_affinity={
			[DamageType.DARKNESS] = 20,
		},
		talents_types_mastery = {
			["cursed/shadows"] = 0.2,
		}
	},
	max_power = 10, power_regen = 1,
	use_power = { name = "release the absorbed darkness", power = 10,
		use = function(self, who)
			if self.max_charge then self.charge=300 end -- Power boost if you fully charged :)
			local dam = (15 + who:combatMindpower()) * 4+math.floor(self.charge/50) -- Damage is based on charge
			local tg = {type="cone", range=0, radius=self.wielder.lite} -- Radius of Cone is based on lite radius of the artifact
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			
			who:project(tg, x, y, engine.DamageType.DARKNESS, who:mindCrit(dam)) -- FIRE!
			who:project(tg, x, y, engine.DamageType.RANDOM_BLIND, self.wielder.lite*10) -- FIRE!
			game.level.map:particleEmitter(who.x, who.y, tg.radius, "breath_dark", {radius=tg.radius, tx=x-who.x, ty=y-who.y})
			self.max_charge=nil -- Reset charge.
			self.charge=0
			
			local p = self.power
			who:onTakeoff(self, who.INVEN_LITE, true)
			self.wielder.lite = 5
			who:onWear(self, who.INVEN_LITE, true)
			self.power = p
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_LITE", --Thanks Grayswandir!
	power_source = {arcane=true},
	unique = true,
	name = "Spectral Cage", image="object/artifact/spectral_cage.png",
	unided_name = "ethereal blue lantern",
	level_range = {20, 30},
	color=colors.BLUE,
	rarity = 240,
	desc = [[This ancient, weathered lantern glows with a pale blue light. The metal is icy cold to the touch.]],
	cost = 320,
	material_level=3,
	wielder = {
		lite = 5,
		combat_spellpower=10,
		
		inc_damage = {[DamageType.COLD]=15},
		resists = {[DamageType.COLD]=20},
		resists_pen = {[DamageType.COLD]=10},
		
		talent_cd_reduction = {
			[Talents.T_CHILL_OF_THE_TOMB] = 2,
		},
	},
	max_power = 20, power_regen = 1,
	use_power = { name = "release a will o' the wisp", power = 20,
		use = function(self, who)
			local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.ACTOR]=true})
			local NPC = require "mod.class.NPC"
			local Talents = require "engine.interface.ActorTalents"
			local m = NPC.new{
				name = "will o' the wisp",
				type = "undead", subtype = "ghost",
				blood_color = colors.GREY,
				display = "G", color=colors.WHITE,
				combat = { dam=1, atk=1, apr=1 },
				autolevel = "warriormage",
				ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
				dont_pass_target = true,
				movement_speed = 2,
				stats = { str=14, dex=18, mag=20, con=12 },
				rank = 2,
				size_category = 1,
				infravision = 10,
				can_pass = {pass_wall=70},
				resists = {all = 35, [engine.DamageType.LIGHT] = -70, [engine.DamageType.COLD] = 65, [engine.DamageType.DARKNESS] = 65},
				no_breath = 1,
				stone_immune = 1,
				confusion_immune = 1,
				fear_immune = 1,
				teleport_immune = 0.5,
				disease_immune = 1,
				poison_immune = 1,
				stun_immune = 1,
				blind_immune = 1,
				cut_immune = 1,
				see_invisible = 80,
				undead = 1,
				will_o_wisp_dam = 110 + who:getMag() * 2.5,
				resolvers.talents{[Talents.T_WILL_O__THE_WISP_EXPLODE] = 1,},
				
				faction = who.faction,
				summoner = who, summoner_gain_exp=true,
				summon_time = 20,
			}

			m:resolve()
			game.zone:addEntity(game.level, m, "actor", x, y)
			m.remove_from_party_on_death = true,
			game.party:addMember(m, {
				control=false,
				type="summon",
				title="Summon",
				orders = {target=true, leash=true, anchor=true, talents=true},
			})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {nature = true, antimagic=true},
	unique=true, rarity=240,
	type = "charm", subtype="totem",
	name = "The Guardian's Totem", image = "object/artifact/the_guardians_totem.png",
	unided_name = "cracked stone totem",
	color = colors.GREEN,
	level_range = {40, 50},
	desc = [[This totem of ancient stone oozes a thick slime from myriad cracks. Nonetheless, you sense great power within it.]],
	cost = 320,
	material_level = 5,
	wielder = {
		resists={[DamageType.BLIGHT] = 20, [DamageType.ARCANE] = 20},
		on_melee_hit={[DamageType.SLIME] = 18},
		combat_spellresist = 20,
		talents_types_mastery = { ["wild-gift/antimagic"] = 0.1, ["wild-gift/fungus"] = 0.1},
		inc_stats = {[Stats.STAT_WIL] = 10,},
		combat_mindpower=8,
	},
		max_power = 35, power_regen = 1,
	use_power = { name = "call an antimagic pillar, but silence yourself", power = 35,
		use = function(self, who)
			local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "Not enough space to invoke!")
				return
			end
			local Talents = require "engine.interface.ActorTalents"
			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				resolvers.nice_tile{image="invis.png", add_mos = {{image="terrain/darkgreen_moonstone_01.png", display_h=2, display_y=-1}}},
				name = "Stone Guardian",
				type = "totem", subtype = "antimagic",
				desc = "This massive stone pillar drips with a viscous slime. Nature's power flows through it, obliterating magic all around it...",
				rank = 3,
				blood_color = colors.GREEN,
				display = "T", color=colors.GREEN,
				life_rating=18,
				combat_dam = 40,
				combat = {
					dam=resolvers.rngavg(50,60),
					atk=resolvers.rngavg(50,75), apr=25,
					dammod={wil=1.2}, physcrit = 10,
					damtype=engine.DamageType.SLIME,
				},
				level_range = {1, nil}, exp_worth = 0,
				silent_levelup = true,
				combat_armor=50,
				combat_armor_hardiness=70,
				autolevel = "wildcaster",
				ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
				never_move=1,
				stats = { str=14, dex=18, mag=10, con=12, wil=20, cun=20, },
				size_category = 5,
				blind=1,
				esp_all=1,
				resists={all = 15, [engine.DamageType.BLIGHT] = 40, [engine.DamageType.ARCANE] = 40, [engine.DamageType.NATURE] = 70},
				no_breath = 1,
				cant_be_moved = 1,
				stone_immune = 1,
				confusion_immune = 1,
				fear_immune = 1,
				teleport_immune = 1,
				disease_immune = 1,
				poison_immune = 1,
				stun_immune = 1,
				blind_immune = 1,
				cut_immune = 1,
				knockback_resist=1,
				combat_mentalresist=50,
				combat_spellresist=100,
				on_act = function(self) self:project({type="ball", range=0, radius=5, friendlyfire=false}, self.x, self.y, engine.DamageType.SILENCE, {dur=2, power_check=self:combatMindpower()}) end,
				resolvers.talents{
					[Talents.T_RESOLVE]={base=3, every=6},
					[Talents.T_MANA_CLASH]={base=3, every=5},
					[Talents.T_STUN]={base=3, every=4},
					[Talents.T_OOZE_SPIT]={base=5, every=4},
					[Talents.T_TENTACLE_GRAB]={base=1, every=6,},
				},
				
				faction = who.faction,
				summoner = who, summoner_gain_exp=true,
				summon_time=15,
			}

			m:resolve()
			game.zone:addEntity(game.level, m, "actor", x, y)
			m.remove_from_party_on_death = true,
			game.party:addMember(m, {
				control=false,
				type="summon",
				title="Summon",
				orders = {target=true, leash=true, anchor=true, talents=true},
			})
			who:setEffect(who.EFF_SILENCED, 5, {})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_CLOAK",
	power_source = {psionic=true},
	unique = true,
	name = "Cloth of Dreams", image = "object/artifact/cloth_of_dreams.png",
	unided_name = "tattered cloak",
	desc = [[Touching this cloak of otherworldly fabric makes you feel both drowsy yet completely aware.]],
	level_range = {30, 40},
	rarity = 240,
	cost = 200,
	material_level = 4,
	wielder = {
		combat_def = 10,
		combat_mindpower = 6,
		combat_physresist = 10,
		combat_mentalresist = 10,
		combat_spellresist = 10,
		inc_stats = { [Stats.STAT_CUN] = 6, [Stats.STAT_WIL] = 5, },
		resists = { [DamageType.MIND] = 15 },
		lucid_dreamer=1,
		sleep=1,
		talents_types_mastery = { ["psionic/dreaming"] = 0.1, ["psionic/slumber"] = 0.1,},
	},
	max_power = 25, power_regen = 1,
	use_talent = { id = Talents.T_SLUMBER, level = 3, power = 10 },
}

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {arcane=true},
	unique=true, rarity=240,
	type = "charm", subtype="wand",
	name = "Void Shard", image = "object/artifact/void_shard.png",
	unided_name = "strange jagged shape",
	color = colors.GREY,
	level_range = {40, 50},
	desc = [[This jagged shape looks like a hole in space, yet it is solid, though light in weight.]],
	cost = 320,
	material_level = 5,
	wielder = {
		resists={[DamageType.DARKNESS] = 10, [DamageType.TEMPORAL] = 10},
		inc_damage={[DamageType.DARKNESS] = 12, [DamageType.TEMPORAL] = 12},
		on_melee_hit={[DamageType.VOID] = 16},
		inc_stats = {[Stats.STAT_MAG] = 8,},
		combat_spellpower=10,
	},
	max_power = 40, power_regen = 1,
	use_power = { name = "release a burst of void energy", power = 20,
		use = function(self, who)
			local tg = {type="ball", range=5, radius=2}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			who:project(tg, x, y, engine.DamageType.VOID, 200 + who:getMag() * 2)
			game.level.map:particleEmitter(x, y, tg.radius, "shadow_flash", {radius=tg.radius, tx=x, ty=y})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_SHIELD", --Thanks SageAcrin!
	power_source = {nature=true},
	unided_name = "thick coral plate",
	name = "Coral Spray", unique=true, image = "object/artifact/coral_spray.png",
	desc = [[A chunk of jagged coral, dredged from the ocean.]],
	require = { stat = { str=16 }, },
	level_range = {1, 15},
	rarity = 200,
	cost = 60,
	material_level = 1,
	moddable_tile = "special/%s_coral_spray",
	moddable_tile_big = true,
	metallic = false,
	special_combat = {
		dam = 18,
		block = 48,
		physcrit = 2,
		dammod = {str=1.4},
		damrange = 1.4,
		melee_project = { [DamageType.COLD] = 10, },
	},
	wielder = {
		combat_armor = 8,
		combat_def = 8,
		fatigue = 12,
		resists = {
			[DamageType.COLD] = 15,
			[DamageType.FIRE] = 10,
		},
		learn_talent = { [Talents.T_BLOCK] = 2, },
		max_air = 20,
	},
	on_block = {desc = "Chance that a blast of icy cold water will spray at the target.", fct = function(self, who, target, type, dam, eff)
		if rng.percent(30) then
			if not target or target:attr("dead") or not target.x or not target.y then return end

			local burst = {type="cone", range=0, radius=4, force_target=target, selffire=false,}
		
			who:project(burst, target.x, target.y, engine.DamageType.ICE, 30)
			game.level.map:particleEmitter(who.x, who.y, burst.radius, "breath_cold", {radius=burst.radius, tx=target.x-who.x, ty=target.y-who.y})
			who:logCombat(target, "A wave of icy water bursts out from #Source#'s shield towards #Target#!")
		end
	end,},
}


newEntity{ base = "BASE_AMULET", --Thanks Grayswandir!
	power_source = {psionic=true},
	unique = true,
	name = "Shard of Insanity", color = colors.DARK_GREY, image = "object/artifact/shard_of_insanity.png",
	unided_name = "cracked black amulet",
	desc = [[A deep red light glows from within this damaged amulet of black stone. When you touch it, you can hear voices whispering within your mind.]],
	level_range = {20, 32},
	rarity = 290,
	cost = 500,
	material_level = 3,
	wielder = {
		combat_mindpower = 8,
		combat_mentalresist = 35,
		confusion_immune=-1,
		inc_damage={
			[DamageType.MIND] 	= 25,
		},
		resists={
			[DamageType.MIND] 	= -10,
		},
		resists_pen={
			[DamageType.MIND] 	= 20,
		},
		on_melee_hit={[DamageType.RANDOM_CONFUSION] = 5},
		melee_project={[DamageType.RANDOM_CONFUSION] = 5},
	},
	max_power = 30, power_regen = 1,
	use_talent = { id = Talents.T_INNER_DEMONS, level = 4, power = 30 },
}


newEntity{ base = "BASE_SHOT", --Thanks Grayswandir!
	power_source = {psionic=true},
	unique = true,
	name = "Pouch of the Subconscious", image = "object/artifact/pouch_of_the_subconscious.png",
	unided_name = "familiar pouch",
	desc = [[You find yourself constantly fighting an urge to handle this strange pouch of shot.]],
	color = colors.RED,
	level_range = {25, 40},
	rarity = 300,
	cost = 110,
	material_level = 4,
	require = { stat = { dex=28 }, },
	combat = {
		capacity = 20,
		dam = 38,
		apr = 15,
		physcrit = 10,
		dammod = {dex=0.7, cun=0.5, wil=0.1},
		ranged_project={
			[DamageType.MIND] = 25,
			[DamageType.MINDSLOW] = 30,
		},
		talent_on_hit = { [Talents.T_RELOAD] = {level=1, chance=50} },
	},
}

newEntity{ base = "BASE_SHOT", --Thanks Grayswandir!
	power_source = {nature=true},
	unique = true,
	name = "Wind Worn Shot", image = "object/artifact/wind_worn_shot.png",
	unided_name = "perfectly smooth shot",
	desc = [[These perfectly white spheres appear to have been worn down by years of exposure to strong winds.]],
	color = colors.RED,
	level_range = {25, 40},
	rarity = 300,
	cost = 110,
	material_level = 4,
	require = { stat = { dex=28 }, },
	combat = {
		capacity = 25,
		dam = 39,
		apr = 15,
		physcrit = 10,
		travel_speed = 1,
		dammod = {dex=0.7, cun=0.5},
		talent_on_hit = { [Talents.T_TORNADO] = {level=2, chance=10} },
		special_on_hit = {desc="35% chance for lightning to arc to a second target", on_kill=1, fct=function(combat, who, target)
			if not rng.percent(35) then return end
			local tgts = {}
			local x, y = target.x, target.y
			local grids = core.fov.circle_grids(x, y, 5, true)
			for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
				local a = game.level.map(x, y, engine.Map.ACTOR)
				if a and a ~= target and who:reactionToward(a) < 0 then
					tgts[#tgts+1] = a
				end
			end end

			-- Randomly take targets
			local tg = {type="beam", range=5, friendlyfire=false, x=target.x, y=target.y}
			if #tgts <= 0 then return end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			local dam = 30 + (who:combatMindpower())

			who:project(tg, a.x, a.y, engine.DamageType.LIGHTNING, rng.avg(1, dam, 3))
			game.level.map:particleEmitter(x, y, math.max(math.abs(a.x-x), math.abs(a.y-y)), "lightning", {tx=a.x-x, ty=a.y-y})
			game:playSoundNear(who, "talents/lightning")
		end},
	},
}

newEntity{ base = "BASE_GREATMAUL",
	power_source = {nature=true, antimagic=true},
	name = "Spellcrusher", color = colors.GREEN, image = "object/artifact/spellcrusher.png",
	unided_name = "vine coated hammer", unique = true,
	desc = [[This large steel greatmaul has thick vines wrapped around the handle.]],
	level_range = {10, 20},
	rarity = 300,
	require = { stat = { str=20 }, },
	cost = 650,
	material_level = 2,
	combat = {
		dam = 32,
		apr = 4,
		physcrit = 4,
		dammod = {str=1.2},
		melee_project={[DamageType.NATURE] = 20},
		special_on_hit = {desc="50% chance to shatter magical shields", fct=function(combat, who, target)
			if not rng.percent(50) then return end
			if not target then return end

			-- List all diseases, I mean, burns, I mean, shields.
			local shields = {}
			for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
				if e.subtype.shield and p.power and e.type == "magical" then
					shields[#shields+1] = {id=eff_id, params=p}
				end
			end
			local is_shield = false
			-- Make them EXPLODE !!!, I mean, remove them.
			for i, d in ipairs(shields) do
				target:removeEffect(d.id)
				is_shield=true
			end
			
			if target:attr("disruption_shield") then
				target:forceUseTalent(target.T_DISRUPTION_SHIELD, {ignore_energy=true})
				is_shield = true
			end
			if is_shield == true then
				game.logSeen(target, "%s's magical shields are shattered!", target.name:capitalize())
			end
		end},
	},
	wielder = {
		inc_damage= {[DamageType.NATURE] = 25},
		inc_stats = {[Stats.STAT_CON] = 6,},
		combat_spellresist=15,
	},
	on_wear = function(self, who)
		if who:attr("forbid_arcane") then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"combat","melee_project"}, {[DamageType.MANABURN]=20})
			self:specialWearAdd({"wielder","resists"}, {[DamageType.ARCANE] = 10, [DamageType.BLIGHT] = 10})
			game.logPlayer(who, "#DARK_GREEN#You feel a great power rise within you!")
		end
	end,
}

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {psionic=true},
	unique=true, rarity=240,
	type = "charm", subtype="torque",
	name = "Telekinetic Core", image = "object/artifact/telekinetic_core.png",
	unided_name = "heavy torque",
	color = colors.BLUE,
	level_range = {5, 20},
	desc = [[This heavy torque appears to draw nearby matter towards it.]],
	cost = 320,
	material_level = 2,
	wielder = {
		resists={[DamageType.PHYSICAL] = 5,},
		inc_damage={[DamageType.PHYSICAL] = 6,},
		combat_physresist = 12,
		inc_stats = {[Stats.STAT_WIL] = 5,},
		combat_mindpower=3,
		combat_dam=3,
	},
	max_power = 35, power_regen = 1,
	use_talent = { id = Talents.T_PSIONIC_PULL, level = 3, power = 18 },
}

newEntity{ base = "BASE_GREATSWORD", --Thanks Grayswandir!
	power_source = {arcane=true, technique=true},
	unique = true,
	name = "Spectral Blade", image = "object/artifact/spectral_blade.png",
	unided_name = "immaterial sword",
	level_range = {10, 20},
	color=colors.GRAY,
	rarity = 300,
	encumber = 0.1,
	desc = [[This sword appears weightless, and nearly invisible.]],
	cost = 400,
	require = { stat = { str=24, }, },
	metallic = false,
	material_level = 2,
	combat = {
		dam = 24,
		physspeed=0.9,
		apr = 25,
		physcrit = 3,
		dammod = {str=1.2},
		melee_project={[DamageType.ARCANE] = 10,},
		burst_on_crit = {
			[DamageType.ARCANE_SILENCE] = 30,
		},
	},
	wielder = {
		blind_fight = 1,
		see_invisible=10,
		combat_spellpower = 5,
		mana_regen = 0.5,
	},
}

newEntity{ base = "BASE_GLOVES", --Thanks SageAcrin /AND/ Edge2054!
	power_source = {technique=true, arcane=true},
	unique = true,
	name = "Crystle's Astral Bindings", --Yes, CRYSTLE. It's a name.
	unided_name = "crystalline gloves", image = "object/artifact/crystles_astral_bindings.png",
	desc = [[Said to have belonged to a lost Anorithil, stars are reflected in the myriad surfaces of these otherworldly bindings.]],
	level_range = {8, 20},
	rarity = 225,
	cost = 340,
	material_level = 2,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = 3 },
		combat_spellpower = 2,
		combat_spellcrit = 3,
		spellsurge_on_crit = 4,
		resists={[DamageType.DARKNESS] = 8, [DamageType.TEMPORAL] = 8},
		inc_damage={[DamageType.DARKNESS] = 8, [DamageType.TEMPORAL] = 8},
		resists_pen={[DamageType.DARKNESS] = 10, [DamageType.TEMPORAL] = 10},
		negative_regen=0.2,
		negative_regen_ref_mod=0.2,
		combat = {
			dam = 13,
			apr = 3,
			physcrit = 6,
			dammod = {dex=0.4, str=-0.6, cun=0.4, mag=0.2 },
			convert_damage = {[DamageType.VOID] = 100,},
			talent_on_hit = { [Talents.T_SHADOW_SIMULACRUM] = {level=1, chance=15}, [Talents.T_MIND_BLAST] = {level=1, chance=10}, [Talents.T_TURN_BACK_THE_CLOCK] = {level=1, chance=10} },
		},
	},
	talent_on_spell = { {chance=10, talent=Talents.T_DUST_TO_DUST, level=2} },
}

newEntity{ base = "BASE_GEM", --Thanks SageAcrin and Graziel!
	power_source = {arcane=true},
	unique = true,
	unided_name = "cracked golem eye",
	name = "Prothotipe's Prismatic Eye", subtype = "multi-hued",
	color = colors.WHITE, image = "object/artifact/prothotipes_prismatic_eye.png",
	level_range = {18, 30},
	desc = [[This cracked gemstone looks faded with age. It appears to have once been the eye of a golem.]],
	rarity = 240,
	cost = 200,
	identified = false,
	material_level = 3,
	wielder = {
		inc_stats = {[Stats.STAT_MAG] = 5, [Stats.STAT_CON] = 5, },
		inc_damage = {[DamageType.FIRE] = 10, [DamageType.COLD] = 10, [DamageType.LIGHTNING] = 10,  },
		talents_types_mastery = {
			["golem/arcane"] = 0.2,
		},
	},
	imbue_powers = {
		inc_stats = {[Stats.STAT_MAG] = 5, [Stats.STAT_CON] = 5, },
		inc_damage = {[DamageType.FIRE] = 10, [DamageType.COLD] = 10, [DamageType.LIGHTNING] = 10,  },
		talents_types_mastery = {
			["golem/arcane"] = 0.2,
		},
	},
	talent_on_spell = { {chance=10, talent=Talents.T_GOLEM_BEAM, level=2} },
}

newEntity{ base = "BASE_MASSIVE_ARMOR", --Thanks SageAcrin!
	power_source = {psionic=true},
	unique = true,
	name = "Plate of the Blackened Mind", image = "object/artifact/plate_of_the_blackened_mind.png",
	unided_name = "solid black breastplate",
	desc = [[This deep black armor absorbs all light that touches it. A dark power sleeps within, primal, yet aware. When you touch the plate, you feel dark thoughts creeping into your mind.]],
	color = colors.BLACK,
	level_range = {40, 50},
	rarity = 390,
	require = { stat = { str=48 }, },
	cost = 800,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 6, [Stats.STAT_CUN] = 4, [Stats.STAT_CON] = 3,},
		resists = {
			[DamageType.ACID] = 15,
			[DamageType.LIGHT] = 15,
			[DamageType.MIND] = 25,
			[DamageType.BLIGHT] = 20,
			[DamageType.DARKNESS] = 20,
		},
		combat_def = 15,
		combat_armor = 40,
		confusion_immune = 1,
		fear_immune = 1,
		combat_mentalresist = 25,
		combat_physresist = 15,
		combat_mindpower=10,
		lite = -2,
		infravision=4,
		fatigue = 17,
		talents_types_mastery = {
			["cursed/gloom"] = 0.2,
		},
		on_melee_hit={[DamageType.ITEM_MIND_GLOOM] = 20}, --Thanks Edge2054!
	},
	max_power = 25, power_regen = 1,
	use_talent = { id = Talents.T_DOMINATE, level = 2, power = 15 },
}

newEntity{ base = "BASE_TOOL_MISC", --Sorta Thanks Donkatsu!
	power_source = {nature = true},
	unique=true, rarity=220,
	type = "charm", subtype="totem",
	name = "Tree of Life", image = "object/artifact/tree_of_life.png",
	unided_name = "tree shaped totem",
	color = colors.GREEN,
	level_range = {40, 50},
	desc = [[This small tree-shaped totem is imbued with powerful healing energies.]],
	cost = 320,
	material_level = 4,
	special_desc = function(self) return "Heals all nearby living creatures by 5 points each turn." end,
	sentient=true,
	use_no_energy = true,
	wielder = {
		resists={[DamageType.BLIGHT] = 20, [DamageType.NATURE] = 20},
		inc_damage={[DamageType.NATURE] = 20},
		talents_types_mastery = { ["wild-gift/call"] = 0.1, ["wild-gift/harmony"] = 0.1, },
		inc_stats = {[Stats.STAT_WIL] = 7, [Stats.STAT_CON] = 6,},
		combat_mindpower=7,
		healing_factor=0.25,
	},
	on_takeoff = function(self, who)
		self.worn_by=nil
		who:removeParticles(self.particle)
	end,
	on_wear = function(self, who)
		self.worn_by=who
		if core.shader.active(4) then
			self.particle = who:addParticles(engine.Particles.new("shader_ring_rotating", 1, {rotation=0, radius=4}, {type="flames", aam=0.5, zoom=3, npow=4, time_factor=4000, color1={0.2,0.7,0,1}, color2={0,1,0.3,1}, hide_center=0}))
		else
			self.particle = who:addParticles(engine.Particles.new("ultrashield", 1, {rm=0, rM=0, gm=180, gM=220, bm=10, bM=80, am=80, aM=150, radius=2, density=30, life=14, instop=17}))
		end
		game.logPlayer(who, "#CRIMSON# A powerful healing aura appears around you as you equip the %s.", self:getName())
	end,
	act = function(self)
		self:useEnergy()
		self:regenPower()
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) and not self.worn_by.player then self.worn_by=nil return end
		if self.worn_by:attr("dead") then return end
		local who = self.worn_by
		local blast = {type="ball", range=0, radius=2, selffire=true}
		who:project(blast, who.x, who.y, engine.DamageType.HEALING_NATURE, 5)
	end,
	max_power = 15, power_regen = 1,
	use_power = { name = "take root increasing health, armor, and armor hardiness but rooting you in place", power = 10,
		use = function(self, who)
			who:setEffect(who.EFF_TREE_OF_LIFE, 4, {})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_RING",
	power_source = {technique=true, nature=true},
	name = "Ring of Growth", unique=true, image = "object/artifact/ring_of_growth.png",
	desc = [[This small wooden ring has a single green stem wrapped around it. Thin leaves still seem to be growing from it.]],
	unided_name = "vine encircled ring",
	level_range = {6, 20},
	rarity = 250,
	cost = 500,
	material_level = 2,
	wielder = {
		combat_physresist = 8,
		inc_stats = {[Stats.STAT_WIL] = 4, [Stats.STAT_STR] = 4,},
		inc_damage={ [DamageType.PHYSICAL] = 8, [DamageType.NATURE] = 8,},
		resists={[DamageType.NATURE] = 10,},
		life_regen=0.15,
		healing_factor=0.2,
	},
}

newEntity{ base = "BASE_CLOAK",
	power_source = {arcane=true},
	unique = true,
	name = "Wrap of Stone", image = "object/artifact/wrap_of_stone.png",
	unided_name = "solid stone cloak",
	desc = [[This thick cloak is incredibly tough, yet bends and flows with ease.]],
	level_range = {8, 20},
	rarity = 400,
	cost = 250,
	material_level = 2,
	wielder = {
		combat_spellpower=6,
		combat_armor=10,
		combat_armor_hardiness=15,
		talents_types_mastery = {
			["spell/earth"] = 0.2,
			["spell/stone"] = 0.1,
		},
		inc_damage={ [DamageType.PHYSICAL] = 5,},
		resists={ [DamageType.PHYSICAL] = 5,},
	},
	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_STONE_WALL, level = 1, power = 60 },
}

newEntity{ base = "BASE_LIGHT_ARMOR", --Thanks SageAcrin!
	power_source = {arcane=true},
	unided_name = "black leather armor",
	name = "Death's Embrace", unique=true, image = "object/artifact/deaths_embrace.png",
	desc = [[This deep black leather armor, wrapped with thick silk, is icy cold to the touch.]],
	level_range = {40, 50},
	rarity = 250,
	cost = 300,
	material_level=5,
	wielder = {
		combat_spellpower = 10,
		combat_critical_power = 20,
		combat_def = 18,
		combat_armor = 18,
		combat_armor_hardiness=15,
		inc_stats = { 
			[Stats.STAT_MAG] = 5, 
			[Stats.STAT_CUN] = 5, 
			[Stats.STAT_DEX] = 5, 
		},
		healing_factor=-0.15,
		on_melee_hit = {[DamageType.DARKNESS]=15, [DamageType.COLD]=15},
		inc_stealth=10,
 		inc_damage={
			[DamageType.DARKNESS] = 20,
			[DamageType.COLD] = 20,
 		},
 		resists={
			[DamageType.TEMPORAL] = 30,
			[DamageType.DARKNESS] = 30,
			[DamageType.COLD] = 30,
 		},
 		talents_types_mastery = {
 			["spell/phantasm"] = 0.1,
 			["spell/shades"] = 0.1,
			["cunning/stealth"] = 0.1,
 		},
	},
	max_power = 50, power_regen = 1,
	use_power = { name = "turn yourself invisible for 10 turns", power = 50,
		use = function(self, who)
			who:setEffect(who.EFF_INVISIBILITY, 10, {power=10+who:getCun()/6+who:getMag()/6, penalty=0.5, regen=true})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR", --Thanks SageAcrin!
	power_source = {nature=true, antimagic=true},
	unided_name = "gauzy green armor",
	name = "Breath of Eyal", unique=true, image = "object/artifact/breath_of_eyal.png",
	desc = [[This lightweight armor appears to have been woven of countless sprouts, still curling and growing. When you put it on, you feel the weight of the world on your shoulders, in spite of how light it feels in your hands.]],
	level_range = {40, 50},
	rarity = 250,
	cost = 300,
	material_level=5,
	wielder = {
		combat_spellresist = 20,
		combat_mindpower = 10,
		combat_def = 10,
		combat_armor = 10,
		fatigue = 20,
		resists = {
			[DamageType.ACID] = 20,
			[DamageType.LIGHTNING] = 20,
			[DamageType.FIRE] = 20,
			[DamageType.COLD] = 20,
			[DamageType.LIGHT] = 20,
			[DamageType.DARKNESS] = 20,
			[DamageType.BLIGHT] = 20,
			[DamageType.TEMPORAL] = 20,
			[DamageType.NATURE] = 20,
			[DamageType.ARCANE] = 15,
		},
	},
	on_wear = function(self, who)
		if who:attr("forbid_arcane") then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder","resists"}, {all = 10})
			game.logPlayer(who, "#DARK_GREEN#You feel the strength of the whole world behind you!")
		end
	end,
}

newEntity{ base = "BASE_TOOL_MISC", --Thanks Alex!
	power_source = {arcane=true},
	unique = true,
	name = "Eternity's Counter", color = colors.WHITE,
	unided_name = "crystalline hourglass", image="object/artifact/eternities_counter.png",
	desc = [[This hourglass of otherworldly crystal appears to be filled with countless tiny gemstones in place of sand. As they fall, you feel the flow of time change around you.]],
	level_range = {30, 40},
	rarity = 300,
	cost = 200,
	material_level = 4,
	direction=1,
	finished=false,
	sentient=true,
	metallic = false,
	special_desc = function(self) return "Offers either offensive or defensive benefits, depending on the position of the sands." end,
	wielder = {
		inc_damage = { [DamageType.TEMPORAL]= 15},
		resists = { [DamageType.TEMPORAL] = 15, all = 0, },
		movement_speed=0,
		combat_physspeed=0,
		combat_spellspeed=0,
		combat_mindspeed=0,
		flat_damage_armor = {all=0},
	},
	max_power = 20, power_regen = 1,
	use_power = { name = "flip the hourglass", power = 20,
		use = function(self, who)
			self.direction = self.direction * -1
			self.finished = false
			who:onTakeoff(self, who.INVEN_TOOL, true)
			self.wielder.inc_damage.all = 0
			self.wielder.flat_damage_armor.all = 0
			who:onWear(self, who.INVEN_TOOL, true)
			game.logPlayer(who, "#GOLD#The sands slowly begin falling in the other direction.")
		end
	},
	on_wear = function(self, who)
		self.worn_by = who
	end,
	on_takeoff = function(self)
		self.worn_by = nil
	end,
	act = function(self)
		self:useEnergy()
		self:regenPower()
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) and not self.worn_by.player then self.worn_by=nil return end
		if self.worn_by:attr("dead") then return end
		local who = self.worn_by
		local direction=self.direction
		if self.finished == true then return end
		who:onTakeoff(self, who.INVEN_TOOL, true)
		
		self.wielder.resists.all = self.wielder.resists.all + direction * 3
		self.wielder.movement_speed = self.wielder.movement_speed + direction * 0.04
		self.wielder.combat_physspeed = self.wielder.combat_physspeed - direction * 0.03
		self.wielder.combat_spellspeed = self.wielder.combat_spellspeed - direction * 0.03
		self.wielder.combat_mindspeed = self.wielder.combat_mindspeed - direction * 0.03
		
		if self.wielder.resists.all <= -10 then 
			self.wielder.inc_damage.all = 10
			game.logPlayer(who, "#GOLD#As the final sands drop into place, you feel a surge of power.")
			self.finished=true
		end
		if self.wielder.resists.all >= 10 then 
			self.wielder.flat_damage_armor.all = 10
			game.logPlayer(who, "#GOLD#As the final sands drop into place, you suddenly feel safer.")
			self.finished=true
		end
		
		who:onWear(self, who.INVEN_TOOL, true)
	end,
}

newEntity{ base = "BASE_WIZARD_HAT", --Thanks SageAcrin!
	power_source = {psionic=true, arcane=true},
	unique = true,
	name = "Malslek the Accursed's Hat",
	unided_name = "black charred hat",
	desc = [[This black hat once belonged to a powerful mage named Malslek, in the Age of Dusk, who was known to deal with beings from other planes. In particular, he dealt with many powerful demons, until one of them, tired of his affairs, betrayed him and stole his power. In his rage, Malslek set fire to his own tower in an attempt to kill the demon. This charred hat is all that remained in the ruins.]],
	color = colors.BLUE, image = "object/artifact/malslek_the_accursed_hat.png",
	level_range = {30, 40},
	rarity = 300,
	cost = 100,
	material_level = 4,
	wielder = {
		combat_def = 2,
		combat_mentalresist = -10,
		healing_factor=-0.1,
		combat_mindpower = 15,
		combat_spellpower = 10,
		combat_mindcrit=10,
		hate_on_crit = 2,
		hate_per_kill = 2,
		max_hate = 20,
		resists = { [DamageType.FIRE] = 20 },
		talents_types_mastery = {
			["cursed/punishments"]=0.2,
		},
		melee_project={[DamageType.RANDOM_GLOOM] = 30},
		inc_damage={
			[DamageType.DARKNESS] 	= 10,
			[DamageType.PHYSICAL]	= 10,
		},
	},
	talent_on_spell = { {chance=10, talent=Talents.T_AGONY, level=2} },
	talent_on_mind  = { {chance=10, talent=Talents.T_HATEFUL_WHISPER, level=2} },
}

newEntity{ base = "BASE_TOOL_MISC", --And finally, Thank you, Darkgod, for making such a wonderful game!
	power_source = {technique=true},
	unique=true, rarity=240,
	name = "Fortune's Eye", image = "object/artifact/fortunes_eye.png",
	unided_name = "golden telescope",
	color = colors.GOLD,
	level_range = {28, 40},
	desc = [[This finely crafted telescope once belonged to the explorer and adventurer Kestin Highfin. With this tool in hand he traveled in search of treasures all across Maj'Eyal, and before his death it was said his collection was incredibly vast. He often credited this telescope with his luck, saying that as long as he had it, he could escape any situation, no matter how dangerous. It is said he died confronting a demon seeking revenge for a stolen sword. 

His last known words were "Somehow this feels like an ending, yet I know there is so much more to find."]],
	cost = 350,
	material_level = 4,
	wielder = {		
		inc_stats = {[Stats.STAT_LCK] = 10, [Stats.STAT_CUN] = 5,},
		combat_atk=12,
		combat_apr=12,
		combat_physresist = 10,
		combat_spellresist = 10,
		combat_mentalresist = 10,
		combat_def = 12,
		see_invisible = 12,
		see_stealth = 12,
	},
	max_power = 35, power_regen = 1,
	use_talent = { id = Talents.T_TRACK, level = 2, power = 18 },
}

newEntity{ base = "BASE_LEATHER_CAP",
	power_source = {nature=true},
	unique = true,
	name = "Eye of the Forest",
	unided_name = "overgrown leather cap", image = "object/artifact/eye_of_the_forest.png",
	level_range = {24, 32},
	color=colors.GREEN,
	encumber = 2,
	rarity = 200,
	desc = [[This leather cap is overgrown with a thick moss, except for around the very front, where an eye, carved of wood, rests. A thick green slime slowly pours from the corners of the eye, like tears.]],
	cost = 200,
	material_level=3,
	wielder = {
		combat_def=8,
		inc_stats = { [Stats.STAT_WIL] = 8, [Stats.STAT_CUN] = 6, },
		blind_immune=1,
		combat_mentalresist = 12,
		see_invisible = 15,
		see_stealth = 15,
		inc_damage={
			[DamageType.NATURE] = 20,
		},
		infravision=2,
		resists_pen={
			[DamageType.NATURE] = 15,
		},
		talents_types_mastery = { ["wild-gift/moss"] = 0.1,},
	},
	max_power = 35, power_regen = 1,
	use_talent = { id = Talents.T_EARTH_S_EYES, level = 2, power = 35 },
}

newEntity{ base = "BASE_MINDSTAR",
	power_source = {antimagic=true},
	unique = true,
	name = "Eyal's Will",
	unided_name = "pale green mindstar",
	level_range = {38, 50},
	color=colors.AQUAMARINE, image = "object/artifact/eyals_will.png",
	rarity = 380,
	desc = [[This smooth green crystal flows with a light green slime in its core. Droplets occasionally form on its surface, tufts of grass growing quickly on the ground where they fall.]],
	cost = 280,
	require = { stat = { wil=48 }, },
	material_level = 5,
	combat = {
		dam = 22,
		apr = 40,
		physcrit = 5,
		dammod = {wil=0.6, cun=0.2},
		damtype = DamageType.NATURE,
	},
	wielder = {
		combat_mindpower = 20,
		combat_mindcrit = 9,
		resists={[DamageType.BLIGHT] = 25, [DamageType.NATURE] = 15},
		inc_damage={
			[DamageType.NATURE] = 20,
			[DamageType.ACID] = 10,
		},
		resists_pen={
			[DamageType.NATURE] = 20,
			[DamageType.ACID] = 10,
		},
		inc_stats = { [Stats.STAT_WIL] = 10, [Stats.STAT_CUN] = 5, },
		learn_talent = {[Talents.T_OOZE_SPIT] = 3},
		talents_types_mastery = { ["wild-gift/mindstar-mastery"] = 0.1,},
	},
	max_power = 30, power_regen = 1,
	use_talent = { id = Talents.T_SLIME_WAVE, level = 3, power = 30 },
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {nature=true},
	unique = true,
	name = "Evermoss Robe", color = colors.DARK_GREEN, image = "object/artifact/evermoss_robe.png",
	unided_name = "fuzzy green robe",
	desc = [[This thick robe is woven from a dark green moss, firmly bound and cool to the touch. It is said to have rejuvenating properties.]],
	level_range = {30, 42},
	rarity = 200,
	cost = 350,
	material_level = 4,
	wielder = {
		combat_def=12,
		inc_stats = { [Stats.STAT_WIL] = 5, },
		combat_mindpower = 12,
		combat_mindcrit = 5,
		combat_physresist = 15,
		life_regen=0.2,
		healing_factor=0.15,
		inc_damage={[DamageType.NATURE] = 30,},
		resists={[DamageType.NATURE] = 25},
		resists_pen={[DamageType.NATURE] = 10},
		on_melee_hit={[DamageType.SLIME] = 35},
		talents_types_mastery = { ["wild-gift/moss"] = 0.1,},
	},
}

newEntity{ base = "BASE_SLING",
	power_source = {arcane=true},
	unique = true,
	name = "Nithan's Force", image = "object/artifact/sling_eldoral_last_resort.png",
	unided_name = "massive sling",
	desc = [[This powerful sling is said to have belonged to a warrior so strong his shots could knock down a brick wall. It appears he may have had some magical assistance...]],
	level_range = {35, 50},
	rarity = 220,
	require = { stat = { dex=32 }, },
	cost = 350,
	material_level = 5,
	combat = {
		range = 10,
		physspeed = 0.7,
	},
	wielder = {
		pin_immune = 0.3,
		knockback_immune = 0.3,
		inc_stats = { [Stats.STAT_STR] = 10, [Stats.STAT_CON] = 5,},
		inc_damage={ [DamageType.PHYSICAL] = 35},
		resists_pen={[DamageType.PHYSICAL] = 15},
		resists={[DamageType.PHYSICAL] = 10},
	},
	max_power = 25, power_regen = 1,
	use_talent = { id = Talents.T_DIG, level = 3, power = 25 },
}

newEntity{ base = "BASE_ARROW",
	power_source = {technique=true},
	unique = true,
	name = "The Titan's Quiver", image = "object/artifact/the_titans_quiver.png",
	unided_name = "gigantic ceramic arrows",
	desc = [[These massive arrows are honed to a vicious sharpness, and appear to be nearly unbreakable. They seem more like spikes than any arrow you've ever seen.]],
	color = colors.GREY,
	level_range = {35, 50},
	rarity = 300,
	cost = 150,
	material_level = 5,
	require = { stat = { dex=20, str=30 }, },
	combat = {
		capacity = 18,
		dam = 62,
		apr = 20,
		physcrit = 8,
		dammod = {dex=0.5, str=0.7},
		special_on_crit = {desc="pin the target to the nearest wall", fct=function(combat, who, target)
			if not target or target == self then return end
			if target:checkHit(who:combatPhysicalpower()*1.25, target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
				game.logSeen(target, "%s is knocked back and pinned!", target.name:capitalize())
				target:knockback(who.x, who.y, 10)
				target:setEffect(target.EFF_PINNED, 5, {}) --ignores pinning resistance, too strong!
			end
		end},
	},
}

newEntity{ base = "BASE_RING",
	power_source = {technique=true, psionic=true},
	name = "Inertial Twine", unique=true, image = "object/artifact/inertial_twine.png",
	desc = [[This double-helical ring seems resistant to attempts to move it. Wearing it seems to extend this property to your entire body.]],
	unided_name = "entwined iron ring",
	level_range = {17, 28},
	rarity = 250,
	cost = 300,
	material_level = 3,
	wielder = {
		combat_physresist = 12,
		inc_stats = {[Stats.STAT_WIL] = 8, [Stats.STAT_STR] = 4,},
		inc_damage={ [DamageType.PHYSICAL] = 5,},
		resists={[DamageType.PHYSICAL] = 5,},
		knockback_immune=1,
		combat_armor = 5,
	},
	max_power = 28, power_regen = 1,
	use_talent = { id = Talents.T_BIND, level = 2, power = 25 },
}

newEntity{ base = "BASE_LONGSWORD",
	power_source = {nature=true, technique=true},
	unique = true,
	name = "Everpyre Blade",
	unided_name = "flaming wooden blade", image = "object/artifact/everpyre_blade.png",
	moddable_tile = "special/%s_everpyre_blade",
	moddable_tile_big = true,
	level_range = {28, 38},
	color=colors.RED,
	rarity = 300,
	desc = [[This ornate blade is carved from the wood of a tree said to burn eternally. Its hilt is encrusted with gems, suggesting it once belonged to a figure of considerable status. The flames seem to bend to the will of the sword's holder.]],
	cost = 400,
	require = { stat = { str=40 }, },
	material_level = 4,
	combat = {
		dam = 38,
		apr = 10,
		physcrit = 18,
		dammod = {str=1},
		convert_damage={[DamageType.FIRE] = 50,},
	},
	wielder = {
		resists = {
			[DamageType.FIRE] = 15,
			[DamageType.NATURE] = 10,
		},
		inc_damage = {
			[DamageType.FIRE] = 20,
		},
		resists_pen = {
			[DamageType.FIRE] = 15,
		},
		inc_stats = { [Stats.STAT_STR] = 7, [Stats.STAT_WIL] = 7 },
	},
	max_power = 25, power_regen = 1,
	use_talent = { id = Talents.T_FIRE_BREATH, level = 2, power = 25 },
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	image = "object/artifact/eclipse.png",
	unided_name = "dark, radiant staff",
	flavor_name = "starstaff",
	name = "Eclipse", unique=true,
	desc = [[This tall staff is tipped with a pitch black sphere that yet seems to give off a strong light.]],
	require = { stat = { mag=32 }, },
	level_range = {10, 20},
	rarity = 200,
	cost = 60,
	material_level = 2,
	modes = {"darkness", "light", "physical", "temporal"},
	combat = {
		is_greater = true,
		dam = 18,
		apr = 4,
		physcrit = 3.5,
		dammod = {mag=1.1},
		damtype = DamageType.DARKNESS,
	},
	wielder = {
		combat_spellpower = 12,
		combat_spellcrit = 8,
		inc_damage={
			[DamageType.LIGHT] = 15,
			[DamageType.DARKNESS] = 15,
			[DamageType.PHYSICAL] = 15,
			[DamageType.TEMPORAL] = 15,
		},
		positive_regen_ref_mod=0.1,
		negative_regen_ref_mod=0.1,
		positive_regen=0.1,
		negative_regen=0.1,
		talent_cd_reduction = {
			[Talents.T_TWILIGHT] = 1,
			[Talents.T_SEARING_LIGHT] = 1,
			[Talents.T_MOONLIGHT_RAY] = 1,
		},
		learn_talent = {[Talents.T_COMMAND_STAFF] = 1},
	},
}

newEntity{ base = "BASE_BATTLEAXE",
	power_source = {technique=true},
	unique = true,
	unided_name = "gore stained battleaxe",
	name = "Eksatin's Ultimatum", color = colors.GREY, image = "object/artifact/eskatins_ultimatum.png",
	desc = [[This gore-stained battleaxe was once used by an infamously sadistic king, who took the time to personally perform each and every execution he ordered. He kept a vault of every head he ever removed, each and every one of them carefully preserved. When he was overthrown, his own head was added as the centrepiece of the vault, which was maintained as a testament to his cruelty.]],
	require = { stat = { str=50 }, },
	level_range = {39, 46},
	rarity = 300,
	material_level = 4,
	combat = {
		dam = 63,
		apr = 25,
		physcrit = 25,
		dammod = {str=1.3},
		special_on_crit = {desc="decapitate a weakened target", fct=function(combat, who, target)
			if not target or target == self then return end
			if target:checkHit(who:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("instakill") and target.life > 0 and ((target.life < target.max_life * 0.25 and target.rank < 3.5) or target.life < target.max_life * 0.10) then
				target:die(who)
				game.logSeen(target, "#RED#%s#GOLD# has been decapitated!#LAST#", target.name:capitalize())
			end
		end},
	},
	wielder = {
		combat_critical_power = 25,
	},
}

newEntity{ base = "BASE_CLOAK",
	power_source = {arcane=true},
	unique = true,
	name = "Radiance", image = "object/artifact/radiance.png",
	unided_name = "a sparkling, golden cloak",
	desc = [[This pristine golden cloak flows with a wind that seems to be conjured from nowhere. Its inner surface is a completely plain white, but the outside shines with intense light.]],
	level_range = {45, 50},
	color = colors.GOLD,
	rarity = 500,
	cost = 300,
	material_level = 5,
	wielder = {
		combat_def = 15,
		combat_spellpower = 8,
		inc_stats = { 
			[Stats.STAT_MAG] = 8, 
			[Stats.STAT_CUN] = 6, 
			[Stats.STAT_DEX] = 10, 
		},
		inc_damage = { [DamageType.LIGHT]= 15 },
		resists_cap = { [DamageType.LIGHT] = 10, },
		resists = { [DamageType.LIGHT] = 20, [DamageType.DARKNESS] = 20, },
		talents_types_mastery = {
			["celestial/light"] = 0.2,
			["celestial/sun"] = 0.2,
			["spell/phantasm"] = 0.2,
			["celestial/radiance"] = 0.2, 
		},
		on_melee_hit={[DamageType.LIGHT_BLIND] = 30},
	},
	max_power = 40, power_regen = 1,
	use_talent = { id = Talents.T_BARRIER, level = 3, power = 40 },
}

newEntity{ base = "BASE_HEAVY_BOOTS",
	power_source = {technique=true},
	unique = true,
	name = "Unbreakable Greaves", image = "object/artifact/unbreakable_greaves.png",
	unided_name = "huge stony boots",
	desc = [[These titanic boots appear to have been carved from stone. They appear weathered and cracked, but easily deflect all blows.]],
	color = colors.DARK_GRAY,
	level_range = {40, 50},
	rarity = 250,
	cost = 200,
	material_level = 5,
	wielder = {
		combat_armor = 20,
		combat_def = 8,
		fatigue = 12,
		combat_dam = 10,
		inc_stats = { 
			[Stats.STAT_STR] = 20, 
			[Stats.STAT_CON] = 10, 
			[Stats.STAT_DEX] = -6, 
		},
		knockback_immune=1,
		combat_armor_hardiness = 20,
		inc_damage = { [DamageType.PHYSICAL] = 15 },
		resists = { [DamageType.PHYSICAL] = 15,  [DamageType.ACID] = 15,},
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {arcane=true},
	unique = true, sentient=true,
	name = "The Untouchable", color = colors.BLUE, image = "object/artifact/the_untouchable.png",
	unided_name = "tough leather coat",
	desc = [[This rugged jacket is the subject of many a rural legend. 
Some say it was fashioned by an adventurous mage turned rogue, in times before the Spellblaze, but was since lost.
All manner of shady gamblers have since claimed to have worn it at one point or another. To fail, but live, is what it means to be untouchable, they said.]],
	level_range = {20, 30},
	rarity = 200,
	cost = 350,
	require = { stat = { str=16 }, },
	material_level = 3,
	wearer_hp = 100,
	wielder = {
		combat_def=14,
		combat_armor=12,
		combat_apr=10,
		inc_stats = { [Stats.STAT_CUN] = 8, },
	},
	on_wear = function(self, who)
		self.worn_by = who
		self.wearer_hp = who.life / who.max_life
	end,
	on_takeoff = function(self)
		self.worn_by = nil
	end,
	special_desc = function(self) return "When you take a hit of more than 20% of your max life a shield is created equal to double the damage taken." end,
	act = function(self)
		self:useEnergy()	
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) and not self.worn_by.player then self.worn_by = nil return end
		if self.worn_by:attr("dead") then return end
		local hp_diff = (self.wearer_hp - self.worn_by.life/self.worn_by.max_life)
		
		if hp_diff >= 0.2 and not self.worn_by:hasEffect(self.worn_by.EFF_DAMAGE_SHIELD) then
			self.worn_by:setEffect(self.worn_by.EFF_DAMAGE_SHIELD, 4, {power = (hp_diff * self.worn_by.max_life)*2})
			game.logPlayer(self.worn_by, "#LIGHT_BLUE#A barrier bursts from the leather jacket!")
		end		
		
		self.wearer_hp = self.worn_by.life/self.worn_by.max_life
	end,
}

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {nature = true},
	unique=true, rarity=240, image = "object/artifact/honeywood_chalice.png",
	type = "charm", subtype="totem",
	name = "Honeywood Chalice",
	unided_name = "sap filled cup",
	color = colors.BROWN,
	level_range = {30, 40},
	desc = [[This wooden cup seems perpetually filled with a thick sap-like substance. Tasting it is exhilarating, and you feel intensely aware when you do so.]],
	cost = 320,
	material_level = 4,
	wielder = {
		combat_physresist = 10,
		inc_stats = {[Stats.STAT_STR] = 5,},
		inc_damage={[DamageType.PHYSICAL] = 5,},
		resists={[DamageType.NATURE] = 10,},
		life_regen=0.15,
		healing_factor=0.1,
		
		learn_talent = {[Talents.T_BATTLE_TRANCE] = 1},
	},
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {arcane=true},
	unique = true,
	name = "The Calm", color = colors.GREEN, image = "object/artifact/the_calm.png",
	unided_name = "ornate green robe",
	desc = [[This green robe is engraved with icons showing clouds and swirling winds. Its original owner, a powerful mage named Proccala, was often revered for both his great benevolence and his intense power when it proved necessary.]],
	level_range = {30, 40},
	rarity = 250,
	cost = 500,
	material_level = 4,
	special_desc = function(self) return "Your Lightning and Chain Lightning spells gain a 24% chance to daze, and your Thunderstorm spell gains a 12% chance to daze." end,
	wielder = {
		combat_spellpower = 20,
		inc_damage = {[DamageType.LIGHTNING]=25},
		combat_def = 15,
		inc_stats = { [Stats.STAT_MAG] = 10, [Stats.STAT_WIL] = 8, [Stats.STAT_CUN] = 6,},
		resists={[DamageType.LIGHTNING] = 20},
		resists_pen = { [DamageType.LIGHTNING] = 15 },
		slow_projectiles = 15,
		movement_speed = 0.1,
		lightning_daze_tempest=24,
	},
}

newEntity{ base = "BASE_LEATHER_CAP",
	power_source = {psionic=true},
	unique = true,
	name = "Omniscience", image = "object/artifact/omniscience.png",
	unided_name = "very plain leather cap",
	level_range = {40, 50},
	color=colors.WHITE,
	encumber = 1,
	rarity = 300,
	desc = [[This white cap is plain and dull, but as the light reflects off of its surface, you see images of faraway corners of the world in the sheen."]],
	cost = 200,
	material_level=5,
	wielder = {
		combat_def=7,
		combat_mindpower=20,
		combat_mindcrit=9,
		combat_mentalresist = 25,
		infravision=5,
		confusion_immune=0.4,
		resists = {[DamageType.MIND] = 15,},
		resists_cap = {[DamageType.MIND] = 10,},
		resists_pen = {[DamageType.MIND] = 10,},
		max_psi=50,
		psi_on_crit=6,
	},
	max_power = 30, power_regen = 1,
	use_power = { name = "reveal the surrounding area", power = 30,
		use = function(self, who)
			who:magicMap(20)
			game.logSeen(who, "%s has a sudden vision!", who.name:capitalize())
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {nature=true},
	unique = true,
	name = "Earthen Beads", color = colors.BROWN, image = "object/artifact/earthen_beads.png",
	unided_name = "strung clay beads",
	desc = [[This is a string of ancient, hardened clay beads, cracked and faded with age. It was used by Wilders in ancient times, in an attempt to enhance their connection with Nature.]],
	level_range = {10, 20},
	rarity = 200,
	cost = 100,
	material_level = 2,
	metallic = false,
	special_desc = function(self) return "Enhances the effectiveness of Meditation by 20%" end,
	wielder = {
		combat_mindpower = 5,
		enhance_meditate=0.2,
		inc_stats = { [Stats.STAT_WIL] = 4,},
		life_regen=0.2,
		damage_affinity={
			[DamageType.NATURE] = 15,
		},
	},
	max_power = 40, power_regen = 1,
	use_talent = { id = Talents.T_NATURE_TOUCH, level = 2, power = 40 },
}

newEntity{ base = "BASE_GAUNTLETS",
	power_source = {arcane=true, nature=true}, --Perhaps it is of Dwarven make :)
	unique = true,
	name = "Hand of the World-Shaper", color = colors.BROWN, image = "object/artifact/hand_of_the_worldshaper.png",
	unided_name = "otherworldly stone gauntlets",
	desc = [[These heavy stone gauntlets make the very ground beneath you bend and warp as they move.]],
	level_range = {40, 50},
	rarity = 300,
	cost = 800,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 6, [Stats.STAT_MAG] = 6 },
		inc_damage = { [DamageType.PHYSICAL] = 12 },
		resists = { [DamageType.PHYSICAL] = 10 },
		resists_pen = { [DamageType.PHYSICAL] = 15 },
		combat_spellpower=10,
		combat_spellcrit = 10,
		combat_armor = 12,
		talents_types_mastery = {
			["spell/earth"] = 0.1,
			["spell/stone"] = 0.2,
			["wild-gift/sand-drake"] = 0.1,
		},
		combat = {
			dam = 38,
			apr = 10,
			physcrit = 7,
			physspeed = 0.2,
			dammod = {dex=0.4, str=-0.6, cun=0.4, mag=0.1 },
			talent_on_hit = { T_EARTHEN_MISSILES = {level=5, chance=15},},
			damrange = 0.3,
			burst_on_hit = {
			[DamageType.GRAVITY] = 50,
			},
			burst_on_crit = {
			[DamageType.GRAVITYPIN] = 30,
			},
		},
	},
	max_power = 30, power_regen = 1,
	use_talent = { id = Talents.T_EARTHQUAKE, level = 4, power = 30 },
}

newEntity{ base = "BASE_CLOAK",
	power_source = {psionic=true},
	unique = true,
	name = "Guise of the Hated", image = "object/artifact/guise_of_the_hated.png",
	unided_name = "gloomy black cloak",
	desc = [[Forget the moons, the starry sky,
The warm and greeting sheen of sun,
The rays of light will never reach inside,
The heart which wishes that it be unseen.]],
	level_range = {40, 50},
	color = colors.BLACK,
	rarity = 370,
	cost = 300,
	material_level = 5,
	wielder = {
		combat_def = 14,
		combat_mindpower = 8,
		combat_mindcrit = 4,
		combat_physcrit = 4,
		inc_stealth=12,
		combat_mentalresist = 10,
		hate_per_kill = 5,
		hate_per_crit = 5,
		inc_stats = { 
			[Stats.STAT_WIL] = 8, 
			[Stats.STAT_CUN] = 6, 
			[Stats.STAT_DEX] = 4, 
		},
		inc_damage = { all = 4 },
		resists = {[DamageType.DARKNESS] = 10, [DamageType.MIND] = 10,},
		talents_types_mastery = {
			["cursed/gloom"] = 0.2,
			["cursed/darkness"] = 0.2,
		},
		on_melee_hit={[DamageType.MIND] = 30},
	},
	max_power = 18, power_regen = 1,
	use_talent = { id = Talents.T_CREEPING_DARKNESS, level = 4, power = 18 },
}

newEntity{ base = "BASE_KNIFE", --Thanks FearCatalyst/FlarePusher!
	power_source = {arcane=true},
	unique = true,
	name = "Spelldrinker", image = "object/artifact/spelldrinker.png",
	unided_name = "eerie black dagger",
	desc = [[Countless mages have fallen victim to the sharp sting of this blade, betrayed by those among them with greed for ever greater power.
Passed on and on, this blade has developed a thirst of its own.]],
	level_range = {20, 30},
	rarity = 250,
	require = { stat = { dex=30 }, },
	cost = 300,
	material_level = 3,
	combat = {
		dam = 27,
		apr = 8,
		physcrit = 9,
		dammod = {str=0.45, dex=0.55, mag=0.05},
		talent_on_hit = { T_DISPERSE_MAGIC = {level=1, chance=15},},
		special_on_hit = {desc="steals up to 50 mana from the target", fct=function(combat, who, target)
			local manadrain = util.bound(target:getMana(), 0, 50)
			target:incMana(-manadrain)
			who:incMana(manadrain)
			local tg = {type="ball", range=10, radius=0, selffire=false}
			who:project(tg, target.x, target.y, engine.DamageType.ARCANE, manadrain)
		end},
	},
	wielder = {
		inc_stats = {[Stats.STAT_MAG] = 6, [Stats.STAT_CUN] = 6,},
		combat_spellresist=12,
		resists={
			[DamageType.ARCANE] = 12,
		},
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	unique = true,
	name = "Frost Lord's Chain",
	unided_name = "ice coated chain", image = "object/artifact/frost_lords_chain.png",
	desc = [[This impossibly cold chain of frost-coated metal radiates a strange and imposing aura.]],
	color = colors.LIGHT_RED,
	level_range = {40, 50},
	rarity = 220,
	cost = 350,
	material_level = 5,
	special_desc = function(self) return "Gives all your cold damage a 20% chance to freeze the target." end,
	wielder = {
		combat_spellpower=12,
		inc_damage={
			[DamageType.COLD] = 12,
		},
		resists={
			[DamageType.COLD] = 25,
		},
		stun_immune = 0.3,
		on_melee_hit = {[DamageType.COLD]=10},
		cold_freezes = 20,
		iceblock_pierce=20,
		learn_talent = {[Talents.T_SHIV_LORD] = 2},
	},
}

newEntity{ base = "BASE_LONGSWORD", --Thanks BadBadger?
	power_source = {arcane=true},
	unique = true,
	name = "Twilight's Edge", image = "object/artifact/twilights_edge.png",
	unided_name = "shining long sword",
	level_range = {32, 42},
	color=colors.GREY,
	rarity = 250,
	desc = [[The blade of this sword seems to have been forged of a mixture of voratun and stralite, resulting in a blend of swirling light and darkness.]],
	cost = 800,
	require = { stat = { str=35,}, },
	material_level = 4,
	combat = {
		dam = 47,
		apr = 7,
		physcrit = 12,
		dammod = {str=1},
		special_on_crit = {desc="release a burst of light and dark damage (scales with Magic)", on_kill=1, fct=function(combat, who, target)
			local tg = {type="ball", range=10, radius=2, selffire=false}
			who:project(tg, target.x, target.y, engine.DamageType.LIGHT, 40 + who:getMag()*0.6)
			who:project(tg, target.x, target.y, engine.DamageType.DARKNESS, 40 + who:getMag()*0.6)
			game.level.map:particleEmitter(target.x, target.y, tg.radius, "shadow_flash", {radius=tg.radius})
		end},
	},
	wielder = {
		lite = 1,
		combat_spellpower = 12,
		combat_spellcrit = 4,
		inc_damage={
			[DamageType.DARKNESS] = 18,
			[DamageType.LIGHT] = 18,
		},
		inc_stats = { [Stats.STAT_MAG] = 4, [Stats.STAT_STR] = 4, [Stats.STAT_CUN] = 4, },
	},
}

newEntity{ base = "BASE_RING",
	power_source = {psionic=true},
	name = "Mnemonic", unique=true, image = "object/artifact/mnemonic.png",
	desc = [[As long as you wear this ring, you will never forget who you are.]],
	unided_name = "familiar ring",
	level_range = {40, 50},
	rarity = 250,
	cost = 300,
	material_level = 5,
	special_desc = function(self) return "When using a mental talent, gives a 10% chance to lower the current cooldowns of up to three of your wild gift, psionic, or cursed talents by three turns." end,
	wielder = {
		combat_mentalresist = 20,
		combat_mindpower = 12,
		inc_stats = {[Stats.STAT_WIL] = 8,},
		resists={[DamageType.MIND] = 25,},
		confusion_immune=0.4,
		talents_types_mastery = {
			["psionic/mentalism"]=0.2,
		},
		psi_regen=0.5,	
	},
	max_power = 30, power_regen = 1,
	use_talent = { id = Talents.T_MENTAL_SHIELDING, level = 2, power = 30 },
	talent_on_mind = { {chance=10, talent=Talents.T_MENTAL_REFRESH, level=1}},
}

newEntity{ base = "BASE_LONGSWORD",
	power_source = {arcane=true, technique=true},
	unique = true,
	name = "Acera",
	unided_name = "corroded sword", image = "object/artifact/acera.png",
	level_range = {25, 35},
	color=colors.GREEN,
	rarity = 300,
	desc = [[This warped, blackened sword drips acid from its countless pores.]],
	cost = 400,
	require = { stat = { str=40 }, },
	material_level = 3,
	combat = {
		dam = 33,
		apr = 4,
		physcrit = 10,
		dammod = {str=1},
		burst_on_crit = {
			[DamageType.ACID_CORRODE] = 40,
		},
		melee_project={[DamageType.ACID] = 12},
	},
	wielder = {
		inc_damage={ [DamageType.ACID] = 15,},
		resists={[DamageType.ACID] = 15,},
		resists_pen={[DamageType.PHYSICAL] = 10,}, --Burns right through your pathetic physical resists
		combat_physcrit = 10,
		combat_spellcrit = 10,
	},
	max_power = 30, power_regen = 1,
	use_talent = { id = Talents.T_CORROSIVE_WORM, level = 4, power = 30 },
}

newEntity{ base = "BASE_GREATSWORD",
	power_source = {technique=true},
	define_as = "DOUBLESWORD",
	name = "Borosk's Hate", unique=true, image="object/artifact/borosks_hate.png",
	unided_name = "double-bladed sword", color=colors.GREY,
	desc = [[This impressive looking sword features two massive blades aligned in parallel. They seem weighted remarkably well.]],
	require = { stat = { str=35 }, },
	level_range = {40, 50},
	rarity = 240,
	cost = 280,
	material_level = 5,
	running=false,
	combat = {
		dam = 60,
		apr = 22,
		physcrit = 10,
		dammod = {str=1.2},
		special_on_hit = {desc="25% chance to strike the target again.", fct=function(combat, who, target)
			local o, item, inven_id = who:findInAllInventoriesBy("define_as", "DOUBLESWORD")
			if not o or not who:getInven(inven_id).worn then return end
			if o.running == true then return end
			if not rng.percent(25) then return end
			o.running=true
			who:attackTarget(target, engine.DamageType.PHYSICAL, 1,  true)
			o.running=false
		end},
	},
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 10, [Stats.STAT_DEX] = 5, [Stats.STAT_CON] = 15 },
		talents_types_mastery = {
			["technique/2hweapon-cripple"] = 0.2,
		},
	},
}

newEntity{ base = "BASE_LONGSWORD",
	power_source = {technique=true, psionic=true}, define_as = "BUTCHER",
	name = "Butcher", unique=true, image="object/artifact/butcher.png",
	unided_name = "blood drenched shortsword", color=colors.CRIMSON,
	desc = [[Be it corruption, madness or eccentric boredom, the halfling butcher by the name of Caleb once took to eating his kin instead of cattle. His spree was never ended and nobody knows where he disappeared to. Only the blade remained, stuck fast in bloodied block. Beneath, a carving said "This was fun, let's do it again some time."]],
	require = { stat = { str=40 }, },
	level_range = {36, 48},
	rarity = 250,
	cost = 300,
	material_level = 5,
	sentient=true,
	running=false,
	special_desc = function(self) return ("Enter Rampage if HP falls under 20%% (Shared 30 turn cooldown)") end,
	combat = {
		dam = 48,
		apr = 12,
		physcrit = 10,
		dammod = {str=1},
		special_on_hit = {desc="Attempt to devour a low HP enemy, striking again and possibly killing instantly.", fct=function(combat, who, target)
			local Talents = require "engine.interface.ActorTalents"
			local o, item, inven_id = who:findInAllInventoriesBy("define_as", "BUTCHER")
			if not o or not who:getInven(inven_id).worn then return end
			if target.life / target.max_life > 0.15 or o.running==true then return end
			local Talents = require "engine.interface.ActorTalents"
			o.running=true
			if target:canBe("instakill") then
				who:forceUseTalent(Talents.T_SWALLOW, {ignore_cd=true, ignore_energy=true, force_target=target, force_level=4, ignore_ressources=true})
			end
			o.running=false
		end},
		special_on_kill = {desc="Enter a Rampage (Shared 30 turn cooldown).", fct=function(combat, who, target)
			local Talents = require "engine.interface.ActorTalents"
			local o, item, inven_id = who:findInAllInventoriesBy("define_as", "BUTCHER")
			if not o or not who:getInven(inven_id).worn then return end
			if o.power < o.max_power then return end
			who:forceUseTalent(Talents.T_RAMPAGE, {ignore_cd=true, ignore_energy=true, force_level=2, ignore_ressources=true})
			o.power = 0
		end},
	},
	wielder = {
		inc_stats = { [Stats.STAT_CUN] = 7, [Stats.STAT_STR] = 10, [Stats.STAT_WIL] = 10, },
		talents_types_mastery = {
			["cursed/rampage"] = 0.2,
			["cursed/slaughter"] = 0.2,
		},
		combat_atk = 18,
	},
	max_power = 30, power_regen = 1,
	use_power = { name = "", power = 30, hidden = true, use = function(self, who) return end},
	on_wear = function(self, who)
		self.worn_by = who
	end,
	on_takeoff = function(self)
		self.worn_by = nil
	end,
	act = function(self)
		self:useEnergy()
		self:regenPower()
		if not self.worn_by then return end
		local who=self.worn_by
		if game.level and not game.level:hasEntity(who) and not who.player then self.worn_by = nil return end
		if who.life/who.max_life < 0.2 and self.power == self.max_power then
			local Talents = require "engine.interface.ActorTalents"
			who:forceUseTalent(Talents.T_RAMPAGE, {ignore_cd=true, ignore_energy=true, force_level=2, ignore_ressources=true})
			self.power=0
		end
	end,
}

newEntity{ base = "BASE_CLOAK",
	power_source = {arcane=true},
	unique = true,
	name = "Ethereal Embrace", image = "object/artifact/ethereal_embrace.png",
	unided_name = "wispy purple cloak",
	desc = [[This cloak waves and bends with shimmering light, reflecting the depths of space and the heart of the Aether.]],
	level_range = {30, 40},
	rarity = 400,
	cost = 250,
	material_level = 4,
	wielder = {
		combat_spellcrit = 6,
		combat_def = 10,
		inc_stats = { 
			[Stats.STAT_MAG] = 8, 
		},
		talents_types_mastery = {
			["spell/arcane"] = 0.2,
			["spell/nightfall"] = 0.2,
			["spell/aether"] = 0.1,
		},
		spellsurge_on_crit = 5,
		inc_damage={ [DamageType.ARCANE] = 15, [DamageType.DARKNESS] = 15, },
		resists={ [DamageType.ARCANE] = 12, [DamageType.DARKNESS] = 12,},
		shield_factor=15,
		shield_dur=1,
	},
	max_power = 28, power_regen = 1,
	use_talent = { id = Talents.T_AETHER_BREACH, level = 2, power = 28 },
}

newEntity{ base = "BASE_HEAVY_BOOTS",
	power_source = {psionic=true},
	unique = true,
	name = "Boots of the Hunter", image = "object/artifact/boots_of_the_hunter.png",
	unided_name = "well-worn boots",
	desc = [[These cracked boots are caked with a thick layer of mud. It isn't clear who they previously belonged to, but they've clearly seen extensive use.]],
	color = colors.BLACK,
	level_range = {30, 40},
	rarity = 240,
	cost = 280,
	material_level = 4,
	use_no_energy = true,
	wielder = {
		combat_armor = 12,
		combat_def = 2,
		combat_dam = 12,
		combat_apr = 15,
		fatigue = 8,
		combat_mentalresist = 10,
		combat_spellresist = 10,
		max_life = 80,
		stun_immune=0.4,
		talents_types_mastery = {
			["cursed/predator"] = 0.2,
			["cursed/endless-hunt"] = 0.2,
			["cunning/trapping"] = 0.2,
		},
	},
	max_power = 32, power_regen = 1,
	use_power = { name = "boost movement speed by 300% for 4 turns (does not use a turn)", power = 32,
	use = function(self, who)
		game:onTickEnd(function() who:setEffect(who.EFF_HUNTER_SPEED, 5, {power=300}) end)
		return {id=true, used=true}
	end
	},
}

newEntity{ base = "BASE_GLOVES",
	power_source = {nature=true},
	unique = true,
	name = "Sludgegrip", color = colors.GREEN, image = "object/artifact/sludgegrip.png",
	unided_name = "slimy gloves",
	desc = [[These gloves are coated with a thick, green liquid.]],
	level_range = {1, 10},
	rarity = 190,
	cost = 70,
	material_level = 1,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 4, [Stats.STAT_CUN] = 4,},
		resists = { [DamageType.NATURE]= 10, },
		inc_damage = { [DamageType.NATURE]= 5, },
		combat_mindpower=2,
		poison_immune=0.2,
		talents_types_mastery = {
			["wild-gift/slime"] = 0.2,
		},		
		combat = {
			dam = 6,
			apr = 7,
			physcrit = 4,
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
			talent_on_hit = { T_SLIME_SPIT = {level=1, chance=35} },
			convert_damage = { [DamageType.ITEM_NATURE_SLOW] = 40,},
		},
	},
}

newEntity{ base = "BASE_RING", define_as = "SET_LICH_RING",
	power_source = {arcane=true},
	unique = true,
	name = "Ring of the Archlich", image = "object/artifact/ring_of_the_archlich.png",
	unided_name = "dusty, cracked ring",
	desc = [[This ring is filled with an overwhelming, yet restrained, power. It lashes, grasps from its metal prison, seatching for life to snuff out. You alone are unharmed.
Perhaps it feels all the death you will bring to others in the near future.]],
	color = colors.DARK_GREY,
	level_range = {30, 40},
	cost = 170,
	rarity = 280,
	material_level = 4,
	wielder = {
		max_soul = 3,
		combat_spellpower=8,
		combat_spellresist=8,
		inc_damage={[DamageType.DARKNESS] = 10, [DamageType.COLD] = 10, },
		poison_immune=0.25,
		cut_immune=0.25,
		resists={ [DamageType.COLD] = 10, [DamageType.DARKNESS] = 10,},
	},
	max_power = 40, power_regen = 1,
	set_list = { {"define_as", "SET_SCEPTRE_LICH"} },
	on_set_complete = function(self, who)
		game.logPlayer(who, "#DARK_GREY#Your ring releases a burst of necromantic energy!")
		self:specialSetAdd({"wielder","combat_spellpower"}, 10)
		self.use_talent = { id = "T_IMPENDING_DOOM", level = 2, power = 40 }
		self:specialSetAdd({"wielder","inc_damage"}, { [engine.DamageType.DARKNESS] = 14 })
		self:specialSetAdd({"wielder","resists"}, { [engine.DamageType.DARKNESS] = 5 })
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#DARK_GREY#Your ring's power fades away.")
		self.use_talent = nil
	end,
}

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {arcane = true},
	unique=true, rarity=240,
	type = "charm", subtype="wand",
	name = "Lightbringer's Rod", image = "object/artifact/lightbringers_rod.png",
	unided_name = "bright wand",
	color = colors.GOLD,
	level_range = {20, 30},
	desc = [[This gold-tipped wand shines with an unnatural sheen.]],
	cost = 320,
	material_level = 3,
	wielder = {
		resists={[DamageType.DARKNESS] = 12, [DamageType.LIGHT] = 12},
		inc_damage={[DamageType.LIGHT] = 10},
		on_melee_hit={[DamageType.LIGHT] = 18},
		combat_spellresist = 15,
		lite=2,
	},
		max_power = 35, power_regen = 1,
	use_power = { name = "summon a shining orb", power = 35,
		use = function(self, who)
			local tg = {type="bolt", nowarning=true, range=5, nolock=true}
			local tx, ty, target = who:getTarget(tg)
			if not tx or not ty then return nil end
			local _ _, _, _, tx, ty = who:canProject(tg, tx, ty)
			target = game.level.map(tx, ty, engine.Map.ACTOR)
			if target == who then target = nil end
			local x, y = util.findFreeGrid(tx, ty, 5, true, {[engine.Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "Not enough space to invoke!")
				return
			end
			local Talents = require "engine.interface.ActorTalents"
			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_ghost_will_o__the_wisp.png", display_h=1, display_y=0}}},
				name = "Lightbringer",
				type = "orb", subtype = "light",
				desc = "A shining orb.",
				rank = 1,
				blood_color = colors.YELLOW,
				display = "T", color=colors.YELLOW,
				life_rating=10,
				combat = {
					dam=resolvers.rngavg(50,60),
					atk=resolvers.rngavg(50,75), apr=25,
					dammod={mag=1}, physcrit = 10,
					damtype=engine.DamageType.LIGHT,
				},
				level_range = {1, nil}, exp_worth = 0,
				silent_levelup = true,
				combat_armor=30,
				combat_armor_hardiness=30,
				autolevel = "caster",
				ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
				never_move=1,
				stats = { str=14, dex=18, mag=20, con=12, wil=20, cun=20, },
				size_category = 2,
				lite=10,
				blind=1,
				esp_all=1,
				resists={[engine.DamageType.LIGHT] = 100, [engine.DamageType.DARKNESS] = 100},
				no_breath = 1,
				cant_be_moved = 1,
				stone_immune = 1,
				confusion_immune = 1,
				fear_immune = 1,
				teleport_immune = 1,
				disease_immune = 1,
				poison_immune = 1,
				stun_immune = 1,
				blind_immune = 1,
				cut_immune = 1,
				knockback_resist=1,
				combat_physresist=50,
				combat_spellresist=100,
				on_act = function(self) self:project({type="ball", range=0, radius=5, friendlyfire=false}, self.x, self.y, engine.DamageType.LITE_LIGHT, self:getMag()) end,
				
				faction = who.faction,
				summoner = who, summoner_gain_exp=true,
				summon_time=15,
			}

			m:resolve()
			game.zone:addEntity(game.level, m, "actor", x, y)
			m.remove_from_party_on_death = true,
			game.party:addMember(m, {
				control=false,
				type="summon",
				title="Summon",
				orders = {target=true, leash=true, anchor=true, talents=true},
			})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_SHIELD",
	power_source = {arcane=true},
	unique = true,
	unided_name = "handled hole in space",
	name = "Temporal Rift", image = "object/artifact/temporal_rift.png",
	moddable_tile = "special/%s_temporal_rift",
	moddable_tile_big = true,
	desc = [[Some mad Chronomancer appears to have affixed a handle to this hole in spacetime. It looks highly effective, in its own strange way.]],
	color = colors.LIGHT_GREY,
	rarity = 300,
	level_range = {35, 45},
	require = { stat = { str=40 }, },
	cost = 400,
	material_level = 5,
	special_combat = {
		dam = 50,
		block = 325,
		physcrit = 4.5,
		dammod = {str=1, mag=0.2},
		damtype = DamageType.TEMPORAL,
		talent_on_hit = { [Talents.T_TURN_BACK_THE_CLOCK] = {level=3, chance=25} },
	},
	wielder = {
		combat_armor = 4,
		combat_def = 8,
		combat_def_ranged = 10,
		fatigue = 0,
		combat_spellpower=12,
		combat_spellresist = 20,
		resists = {[DamageType.TEMPORAL] = 30},
		learn_talent = { [Talents.T_BLOCK] = 5, },
		flat_damage_armor = {all=20},
		slow_projectiles = 50,
	},
}

newEntity{ base = "BASE_ARROW",
	power_source = {technique=true},
	unique = true,
	name = "Arkul's Seige Arrows", image = "object/artifact/arkuls_seige_arrows.png",
	unided_name = "gigantic spiral arrows",
	desc = [[These titanic double-helical arrows seem to have been designed more for knocking down towers than for use in regular combat. They'll no doubt make short work of most foes.]],
	color = colors.GREY,
	level_range = {42, 50},
	rarity = 400,
	cost = 400,
	material_level = 5,
	require = { stat = { dex=20, str=30 }, },
	special_desc = function(self) return "25% of all damage splashes in a radius of 1 around the target." end,
	combat = {
		capacity = 14,
		dam = 68,
		apr = 100,
		physcrit = 10,
		dammod = {dex=0.5, str=0.7},
		siege_impact=0.25,		
	},
}

newEntity{ base = "BASE_LONGSWORD", --For whatever artists draws this: it's a rapier.
	power_source = {technique=true},
	unique = true,
	name = "Punae's Blade",
	unided_name = "thin blade", image = "object/artifact/punaes_blade.png",
	level_range = {28, 38},
	color=colors.GREY,
	rarity = 300,
	desc = [[This very thin sword cuts through the air with ease, allowing remarkably quick movement.]],
	cost = 400,
	require = { stat = { str=30 }, },
	material_level = 4,
	combat = {
		dam = 46,
		apr = 4,
		physcrit = 10,
		dammod = {str=1},
	},
	wielder = {
		evasion=10,
		combat_physcrit = 10,
		combat_physspeed = 0.1,
	},
}

newEntity{ base = "BASE_CLOTH_ARMOR", --Thanks SageAcrin!
	power_source = {psionic=true},
	unique = true,
	name = "Crimson Robe", color = colors.RED, image = "object/artifact/crimson_robe.png",
	unided_name = "blood-stained robe",
	desc = [[This robe was formerly owned by Callister the Psion, a powerful Psionic that pioneered many Psionic abilities. After his wife was murdered, Callister became obsessed with finding her killer, using his own hatred as a fuel for new and disturbing arts. After forcing the killer to torture himself to death, Callister walked the land, forcing any he found to kill themselves - his way of releasing them from the world's horrors. One day, he simply disappeared. This robe, soaked in blood, was the only thing he left behind.]],
	level_range = {40, 50},
	rarity = 230,
	cost = 350,
	material_level = 5,
	special_desc = function(self) return "Increases your solipsism threshold by 20% (if you have one). If you do, also grants 15% global speed when worn." end,
	wielder = {
		combat_def=12,
		inc_stats = { [Stats.STAT_WIL] = 10, [Stats.STAT_CUN] = 10, },
		combat_mindpower = 20,
		combat_mindcrit = 9,
		psi_regen=0.2,
		psi_on_crit = 4,
		hate_on_crit = 4, 
		hate_per_kill = 2,
		resists_pen={all = 20},
		on_melee_hit={[DamageType.MIND] = 35, [DamageType.RANDOM_GLOOM] = 10},
		melee_project={[DamageType.MIND] = 35, [DamageType.RANDOM_GLOOM] = 10},
		talents_types_mastery = { ["psionic/solipsism"] = 0.1, ["psionic/focus"] = 0.2, ["cursed/slaughter"] = 0.2, ["cursed/punishments"] = 0.2,},
	},
	on_wear = function(self, who)
		if who:attr("solipsism_threshold") then
			self:specialWearAdd({"wielder","solipsism_threshold"}, 0.2)
			self:specialWearAdd({"wielder","global_speed_add"}, 0.15)
			game.logPlayer(who, "#RED#You feel yourself lost in the aura of the robe.")
		end
	end,
	talent_on_mind  = { {chance=8, talent=Talents.T_HATEFUL_WHISPER, level=2}, {chance=8, talent=Talents.T_AGONY, level=2}  },
}

newEntity{ base = "BASE_RING", --Thanks Alex!
	power_source = {arcane=true},
	name = "Exiler", unique=true, image = "object/artifact/exiler.png",
	desc = [[The chronomancer known as Solith was renowned across all of Eyal. He always seemed to catch his enemies alone.
In the case of opponents who weren't alone, he had to improvise.]],
	unided_name = "insignia ring",
	level_range = {40, 50},
	rarity = 250,
	cost = 300,
	material_level = 5,
	wielder = {
		combat_spellpower = 10,
		paradox_reduce_fails = 20,
		talent_cd_reduction={
			[Talents.T_TIME_SKIP]=1,
		},
		inc_damage={ [DamageType.TEMPORAL] = 15, [DamageType.PHYSICAL] = 10, },
		resists={ [DamageType.TEMPORAL] = 15,},
		melee_project={ [DamageType.TEMPORAL] = 15,},
		talents_types_mastery = {
 			["chronomancy/timetravel"] = 0.2,
 		},
	},
	talent_on_spell = { {chance=10, talent="T_RETHREAD", level = 2} },
	max_power = 32, power_regen = 1,
	use_power = { name = "deal temporal damage to summons, and if they survive, remove them from time", power = 32,
		use = function(self, who)
			local Talents = require "engine.interface.ActorTalents"
			local tg = {type="ball", range=5, radius=2}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			who:project(tg, x, y, function(px, py) 
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end
			if target.summoner then
			who:forceUseTalent(Talents.T_TIME_SKIP, {ignore_cd=true, ignore_energy=true, force_target=target, force_level=2, ignore_ressources=true})
			end
			end)
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_SHIELD",
	power_source = {arcane=true},
	unique = true,
	name = "Piercing Gaze", image = "object/artifact/piercing_gaze.png",
	moddable_tile = "special/%s_piercing_gaze",
	moddable_tile_big = true,
	unided_name = "stone-eyed shield",
	desc = [[This gigantic shield has a stone eye embedded in it.]],
	color = colors.BROWN,
	level_range = {30, 40},
	rarity = 270,
	--require = { stat = { str=28 }, },
	cost = 400,
	material_level = 4,
	metallic = false,
	special_combat = {
		dam = 40,
		block = 180,
		physcrit = 5,
		dammod = {str=1},
	},
	wielder = {
		combat_armor = 25,
		combat_def = 5,
		combat_def_ranged = 10,
		fatigue = 12,
		learn_talent = { [Talents.T_BLOCK] = 4, },
		resists = { [DamageType.PHYSICAL] = 10, [DamageType.ACID] = 10, [DamageType.LIGHTNING] = 10, [DamageType.FIRE] = 10,},
	},
	on_block = {desc = "30% chance of petrifying the attacker.", fct = function(self, who, src, type, dam, eff)
		if rng.percent(30) then
			if not src then return end
			game.logSeen(src, "The eye locks onto %s, freezing it in place!", src.name:capitalize())
			if src:canBe("stun") and src:canBe("stone") and src:canBe("instakill") then
				src:setEffect(who.EFF_STONED, 5, {})
			end
		end
	end,}
}

-- No longer hits your own projectiles
-- Hopefully fixed LUA errors with DamageType require
-- Significant rescaling.  Base damage cut by 50%, crit by 5%.  The reason these hilariously bad numbers happened was derping and not accounting for the awesomeness of the 100% dex scaling.  APR is still extremely high.
-- Proc chance is now 100% up from 25%.  No matter how I test this--even at 100% and 500% global action speed--it is often a pain in the ass to get procs just to test.  This is supposed to be one of the main features of the item. 
newEntity{ base = "BASE_KNIFE", --Shibari's #1
	power_source = {nature=true},
	unique = true,
	name = "Shantiz the Stormblade",
	unided_name = "thin stormy blade", image = "object/artifact/shantiz_the_stromblade.png",
	level_range = {18, 33},
	material_level = 3,
	rarity = 300,
	desc = [[This surreal dagger crackles with the intensity of a vicious storm.]],
	cost = 400,
	color=colors.BLUE,
	require = { stat = { dex=30}},
	combat = {
		dam = 15,
		apr = 20,
		physcrit = 10,
		dammod = {dex=1},
		special_on_hit = {desc="Causes lightning to strike and destroy any projectiles in a radius of 10, dealing damage and dazing enemies in a radius of 5 around them.", on_kill=1, fct=function(combat, who, target)
			local grids = core.fov.circle_grids(who.x, who.y, 10, true)
			for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
				local i = 0
				local p = game.level.map(x, y, engine.Map.PROJECTILE+i)
				while p do
					local DamageType = require "engine.DamageType" -- I don't entirely follow why this is necessary
					if p.src and (p.src == who) then return end -- Keep Arcane Blade procs from hitting them since the projectile is still on top of them.
					if p.name then 
						game.logPlayer(who, "#GREEN#Lightning strikes the " .. p.name .. "!")
					else
						game.logPlayer(who, "#GREEN#Shantiz strikes down a projectile!")
					end
					
					p:terminate(x, y)
					game.level:removeEntity(p, true)
					p.dead = true
					game.level.map:particleEmitter(x, y, 5, "ball_lightning_beam", {radius=5, tx=x, ty=y})
				   
					local tg = {type="ball", radius=5, selffire=false}
					local dam = 4*who:getDex() -- no more crit or base damage.  no real reason, just like it better.

					who:project(tg, x, y, DamageType.LIGHTNING, dam)
				   
					who:project(tg, x, y, function(tx, ty)
							local target = game.level.map(tx, ty, engine.Map.ACTOR)
							if not target or target == who then return end
							target:setEffect(target.EFF_DAZED, 3, {apply_power=who:combatAttack()})
					end)
   
					i = i + 1
					p = game.level.map(x, y, engine.Map.PROJECTILE+i)
				end end end    
			return          
			end
		},
	},
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = 20 },
		slow_projectiles = 40, 
		quick_weapon_swap = 1, 
	},
}

newEntity{ base = "BASE_KNIFE",
	power_source = {technique=true},
	unique = true,
	name = "Swordbreaker", image = "object/artifact/swordbreaker.png",
	unided_name = "hooked blade",
	desc = [[This ordinary blade is made of fine, sturdy voratun and outfitted with jagged hooks along the edge. This simple appearance belies a great power - the hooked maw of this dagger broke many a blade and the stride of many would-be warriors.]],
	level_range = {20, 30},
	rarity = 250,
	require = { stat = { dex=10, cun=10 }, },
	cost = 300,
	material_level = 3,
	special_desc = function(self) return "Can block like a shield, potentially disarming the enemy." end,
	combat = {
		dam = 25,
		apr = 20,
		physcrit = 15,
		physspeed = 0.9,
		dammod = {dex=0.5,cun=0.5},
		special_on_crit = {desc="Breaks enemy weapon.", fct=function(combat, who, target)
			target:setEffect(target.EFF_SUNDER_ARMS, 5, {power=5+(who:combatPhysicalpower()*0.33), apply_power=who:combatPhysicalpower()})
		end},
	},
	wielder = {
		combat_def = 15,
		disarm_immune=0.5,
		combat_physresist = 15,
		inc_stats = { 
			[Stats.STAT_DEX] = 8, 
			[Stats.STAT_CUN] = 8, 
		},
		combat_armor_hardiness = 20,
		learn_talent = { [Talents.T_DAGGER_BLOCK] = 1, },
	},
}

newEntity{ base = "BASE_SHIELD",
	power_source = {arcane=true},
	unique = true,
	name = "Shieldsmaiden", image = "object/artifact/shieldmaiden.png",
	unided_name = "icy shield",
	desc = [[Myths tell of shieldsmaidens, a tribe of warrior women from the northern wastes of Maj'Eyal. Their martial prowess and beauty drew the fascination of swaths of admirers, yet all unrequited. So began the saying, that a shieldsmaiden's heart is as cold and unbreakable as her shield.]],
	color = colors.BLUE,
	level_range = {36, 48},
	rarity = 270,
	require = { stat = { str=28 }, },
	cost = 400,
	material_level = 5,
	metallic = false,
	special_desc = function(self) return "Granted talent can block up to 1 instance of damage each 10 turns." end,
	special_combat = {
		dam = 48,
		block = 150,
		physcrit = 8,
		dammod = {str=1},
		damtype = DamageType.ICE,
		talent_on_hit = { [Talents.T_ICE_SHARDS] = {level=3, chance=15} },
	},
	wielder = {
		combat_armor = 20,
		combat_def = 5,
		combat_def_ranged = 12,
		fatigue = 10,
		learn_talent = { [Talents.T_BLOCK] = 4, [Talents.T_SHIELDSMAIDEN_AURA] = 1,  },
		resists = { [DamageType.COLD] = 25, [DamageType.FIRE] = 25,},
	},
}

-- Thanks to Naghyal's Beholder code for the basic socket skeleton
newEntity{ base = "BASE_GREATMAUL",
	power_source = {arcane=true},
	unique = true,
	color = colors.BLUE,
	name = "Tirakai's Maul",
	desc = [[This massive hammer is formed from a thick mass of strange crystalline growths. In the side of the hammer itself you see an empty slot; it looks like a gem of your own could easily fit inside it.]],
	gemDesc = "None", -- Defined by the elemental properties and used by special_desc
	special_desc = function(self)
	-- You'll want to color this and such
		if not self.Gem then return ("No gem") end
		return ("%s: %s"):format(self.Gem.name:capitalize(), self.gemDesc or ("Write a description for this gem's properties!"))
	end,	
	cost = 1000,
	material_level = 2, -- Changes to gem material level on socket
	level_range = {1, 30},
	rarity = 280,
	combat = {
		dam = 32,
		apr = 6,
		physcrit = 8,
		damrange=1.3,
		dammod = {str=1.2, mag=0.1},
	},
	max_power = 1, power_regen = 1,
	use_power = { name = "imbue the hammer with a gem of your choice", power = 0,
		use = function(self, who)
			local DamageType = require "engine.DamageType"
			local Stats = require "engine.interface.ActorStats"
			local d
			d = who:showInventory("Use which gem?", who:getInven("INVEN"), function(gem) return gem.type == "gem" and gem.imbue_powers and gem.material_level end, function(gem, gem_item)
				local _, _, inven_id = who:findInAllInventoriesByObject(self)
				who:onTakeoff(self, inven_id)
				local name_old=self.name
				local old_hotkey
				for i, v in pairs(who.hotkey) do
					if v[2]==name_old then
						old_hotkey=i
					end
				end
				
				-- Recycle the old gem
				local old_gem=self.Gem
				if old_gem then
					who:addObject(who:getInven("INVEN"), old_gem)
					game.logPlayer(who, "You remove your %s.", old_gem:getName{do_colour=true, no_count=true})
				end
				
				if gem then
	
					-- The Blank Slate.
					self.Gem = nil
					self.Gem = gem
					self.gemDesc = "something has gone wrong"
					
					self.sentient = false
					self.act = mod.class.Object.act
					
					self.talent_on_spell = nil
					
					self.material_level=gem.material_level
					local scalingFactor = self.material_level 
					
					self.combat = {
						dam = 8 + (12 * scalingFactor),
						apr = (3 * scalingFactor),
						physcrit = 4 + (2 * scalingFactor),
						dammod = {str=1.2, mag=0.1},
						damrange = 1.3,
					}
							
					self.wielder = {
						inc_stats = {[Stats.STAT_MAG] = (2 * scalingFactor), [Stats.STAT_CUN] = (2 * scalingFactor), [Stats.STAT_DEX] = (2 * scalingFactor),},
					}
					
					who:removeObject(who:getInven("INVEN"), gem_item)

					-- Each element merges its effect into the combat/wielder tables (or anything else) after the base stats are scaled
					-- You can modify damage and such here too but you should probably make static tables instead of merging
					if gem.subtype =="black" then -- Acid
						self.combat.damtype = DamageType.ACID
						table.mergeAdd(self.wielder, {inc_damage = { [DamageType.ACID] = 4 * scalingFactor} }, true)
						
						self.combat.burst_on_crit = {[DamageType.ACID_DISARM] = 12 * scalingFactor,}
						self.gemDesc = "Acid"
					end
					if gem.subtype =="blue" then  -- Lightning
						self.combat.damtype = DamageType.LIGHTNING
						table.mergeAdd(self.wielder, {
							inc_damage = { [DamageType.LIGHTNING] = 4 * scalingFactor} 
						
							}, true)
						self.combat.burst_on_crit = {[DamageType.LIGHTNING_DAZE] = 12 * scalingFactor,}
						self.gemDesc = "Lightning"
					end
					if gem.subtype =="green" then  -- Nature
						self.combat.damtype = DamageType.NATURE
						table.mergeAdd(self.wielder, {
							inc_damage = { [DamageType.NATURE] = 4 * scalingFactor} 
							
							}, true)
						self.combat.burst_on_crit = {[DamageType.SPYDRIC_POISON] = 12 * scalingFactor,}
						self.gemDesc = "Nature"
					end
					if gem.subtype =="red" then  -- Fire					
						self.combat.damtype = DamageType.FIRE
						table.mergeAdd(self.wielder, {
							inc_damage = { [DamageType.FIRE] = 4 * scalingFactor}, 
						}, true)
						self.combat.burst_on_crit = {[DamageType.FLAMESHOCK] = 12 * scalingFactor,}
						self.gemDesc = "Fire"
					end
					if gem.subtype =="violet" then -- Arcane
						self.combat.damtype = DamageType.ARCANE
						table.mergeAdd(self.wielder, {
							inc_damage = { [DamageType.ARCANE] = 4 * scalingFactor} 
							
						}, true)
						self.combat.burst_on_crit = {[DamageType.ARCANE_SILENCE] = 12 * scalingFactor,}
						self.gemDesc = "Arcane"
					end
					if gem.subtype =="white" then  -- Cold
						self.combat.damtype = DamageType.COLD
						table.mergeAdd(self.wielder, {
							inc_damage = { [DamageType.COLD] = 4 * scalingFactor} 
							
						}, true)
						self.combat.burst_on_crit = {[DamageType.ICE] = 12 * scalingFactor,}
						self.gemDesc = "Cold"
					end
					if gem.subtype =="yellow" then -- Light
						self.combat.damtype = DamageType.LIGHT
						table.mergeAdd(self.wielder, {
							inc_damage = { [DamageType.LIGHT] = 4 * scalingFactor} 
							
						}, true)	
						self.combat.burst_on_crit = {[DamageType.LIGHT_BLIND] = 12 * scalingFactor,}
						self.gemDesc = "Light"
					end
					if gem.subtype == "multi-hued"  then -- Some but not all artifacts, if you want to do artifact specific effects make conditionals by name, don't use this
						table.mergeAdd(self.combat, {convert_damage = {[DamageType.COLD] = 25, [DamageType.FIRE] = 25, [DamageType.LIGHTNING] = 25, [DamageType.ARCANE] = 25,} }, true)
						table.mergeAdd(self.wielder, {
							inc_damage = { all = 2 * scalingFactor},
							resists_pen = { all = 2 * scalingFactor},
							}, true)	
							self.gemDesc = "Unique"							
					end
					if gem.subtype == "demonic"  then -- Goedalath Rock
						self.combat.damtype = DamageType.SHADOWFLAME
						table.mergeAdd(self.wielder, {
							inc_damage = { [DamageType.FIRE] = 3 * scalingFactor, [DamageType.DARKNESS] = 3 * scalingFactor,},
							resists_pen = { all = 2 * scalingFactor},
							}, true)	
							self.gemDesc = "Demonic"							
					end
					game.logPlayer(who, "You imbue your %s with %s.", self:getName{do_colour=true, no_count=true}, gem:getName{do_colour=true, no_count=true})

					--self.name = (gem.name .. " of Divinity")
					
					table.mergeAdd(self.wielder, gem.imbue_powers, true)
					
				end
				if gem.talent_on_spell then
					self.talent_on_spell = self.talent_on_spell or {}
					table.append(self.talent_on_spell, gem.talent_on_spell)
				end
				who:onWear(self, inven_id)
				for i, v in pairs(who.hotkey) do
					if v[2]==name_old then
						v[2]=self.name
					end
					if v[2]==self.name and old_hotkey and i~=old_hotkey then
						who.hotkey[i] = nil
					end
				end
				d.used_talent=true
				game:unregisterDialog(d)
				return true
			end)
			return {id=true, used=true}
		end
	},
	on_wear = function(self, who)

		return true
	end,
	wielder = {
	-- Stats only from gems
	},
}

newEntity{ base = "BASE_GLOVES", define_as = "SET_GLOVE_DESTROYER",
	power_source = {arcane=true, technique=true},
	unique = true,
	name = "Fist of the Destroyer", color = colors.RED, image = "object/artifact/fist_of_the_destroyer.png",
	unided_name = "vile gauntlets",
	desc = [[These fell looking gloves glow with untold power.]],
	level_range = {40, 50},
	rarity = 300,
	cost = 800,
	material_level = 5,
	special_desc = function(self)
		local num=4
		if self.set_complete then
			num=6
		end
		return ("Increases all damage by %d%% of current vim \nCurrent Bonus: %d%%"):format(num, num*0.01*(game.player:getVim() or 0)) 
	end,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 9, [Stats.STAT_MAG] = 9, [Stats.STAT_CUN] = 3, },
		demonblood_dam=0.04,
		max_vim = 25,
		combat_def = 8,
		stun_immune = 0.2,
		talents_types_mastery = { ["corruption/shadowflame"] = 0.2, ["corruption/vim"] = 0.2,},
		combat = {
			dam = 35,
			apr = 15,
			physcrit = 10,
			physspeed = 0,
			dammod = {dex=0.4, str=-0.6, cun=0.4, mag=0.2,},
			damrange = 0.3,
			talent_on_hit = { T_DRAIN = {level=2, chance=8}, T_SOUL_ROT = {level=3, chance=12}, T_BLOOD_GRASP = {level=3, chance=10}},
		},
	},
	max_power = 12, power_regen = 1,
	use_talent = { id = Talents.T_DARKFIRE, level = 5, power = 12 },
	set_list = { {"define_as", "SET_ARMOR_MASOCHISM"} },
	on_set_complete = function(self, who)
		game.logPlayer(who, "#STEEL_BLUE#The fist and the mangled clothing glow ominously!")
		self:specialSetAdd({"wielder","demonblood_dam"}, 0.02)
		self:specialSetAdd({"wielder","inc_damage"}, { [engine.DamageType.FIRE] = 15, [engine.DamageType.DARKNESS] = 15, all = 5 })
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#STEEL_BLUE#The ominous glow dies down.")
	end,
}

newEntity{ base = "BASE_LIGHT_ARMOR", define_as = "SET_ARMOR_MASOCHISM",
	power_source = {arcane=true, technique=true},
	unique = true,
	name = "Masochism", color = colors.RED, image = "object/artifact/masochism.png",
	unided_name = "mangled clothing",
	desc = [[Stolen flesh,
	Stolen pain,
	To give it up,
	Is to live again.]],
	level_range = {40, 50},
	rarity = 300,
	cost = 800,
	material_level = 5,
	special_desc = function(self)
		local num=7
		if self.set_complete then
			num=10
		end
		return ("Reduces all damage by %d%% of current vim or 50%% of the damage, whichever is lower; but at the cost of vim equal to 5%% of the damage blocked. \nCurrent Bonus: %d"):format(num, num*0.01*(game.player:getVim() or 0)) 
	end,
	wielder = {
		inc_stats = {[Stats.STAT_MAG] = 9, [Stats.STAT_CUN] = 3, },
		combat_spellpower = 10,
		demonblood_def=0.07,
		max_vim = 25,
		disease_immune = 1,
		combat_physresist = 10,
		combat_mentalresist = 10,
		combat_spellresist = 10,
		on_melee_hit={[DamageType.DRAIN_VIM] = 25},
		melee_project={[DamageType.DRAIN_VIM] = 25},
		talents_types_mastery = { ["corruption/sanguisuge"] = 0.2, ["corruption/blood"] = 0.2,},
	},
	max_power = 12, power_regen = 1,
	use_talent = { id = Talents.T_BLOOD_GRASP, level = 5, power = 12 },
	set_list = { {"define_as", "SET_GLOVE_DESTROYER"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","demonblood_def"}, 0.03)
		self:specialSetAdd({"wielder","resists"}, { [engine.DamageType.FIRE] = 15, [engine.DamageType.DARKNESS] = 15, all = 5 })
	end,
	on_set_broken = function(self, who)
	end,
}

newEntity{ base = "BASE_GREATMAUL",
	power_source = {technique=true},
	unique = true,
	name = "Obliterator", color = colors.UMBER, image = "object/artifact/obliterator.png",
	unided_name = "titanic maul",
	desc = [[This massive hammer strikes with deadly force. Bones crunch, splinter and grind to dust under its impact.]],
	level_range = {23, 30},
	rarity = 270,
	require = { stat = { str=40 }, },
	cost = 250,
	material_level = 3,
	combat = {
		dam = 48,
		apr = 10,
		physcrit = 0,
		dammod = {str=1.2},
		crushing_blow=1,

	},
	wielder = {
		combat_critical_power = 10,
		inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_CON] = 5, },
	},
}

newEntity{ base = "BASE_HELM",
	power_source = {technique=true},
	unique = true,
	name = "Yaldan Baoth", image = "object/artifact/yaldan_baoth.png",
	unided_name = "obscuring helm",
	desc = [[The golden bascinet crown, affiliated with Veluca of Yaldan. King of the mythical city of Yaldan, that was struck from the face of Eyal by the arrogance of its people. Lone survivor of his kin, he spent his last years wandering the early world, teaching man to stand against the darkness. With his dying words, "Fear no evil", the crown was passed onto his successor.]],
	level_range = {28, 39,},
	rarity = 240,
	cost = 700,
	material_level = 4,
	wielder = {
		combat_armor = 6,
		fatigue = 4,
		resist_unseen = 25,
		sight = -2,
		inc_stats = { [Stats.STAT_WIL] = 10, [Stats.STAT_CON] = 7, },
		inc_damage={
			[DamageType.LIGHT] = 10,
		},
		resists={
			[DamageType.LIGHT] = 10,
			[DamageType.DARKNESS] = 15,
		},
		resists_cap={
			[DamageType.DARKNESS] = 10,
		},
		blind_fight = 1,
	},
}

newEntity{ base = "BASE_GREATSWORD",
	power_source = {technique=true, arcane=true},
	name = "Champion's Will", unique=true, image = "object/artifact/champions_will.png",
	unided_name = "blindingly bright sword", color=colors.YELLOW,
	desc = [[This impressive looking sword features a golden engraving of a sun in its hilt. Etched into its blade are a series of runes claiming that only one who has mastered both their body and mind may wield this sword effectively.]],
	require = { stat = { str=35 }, },
	level_range = {40, 50},
	rarity = 240,
	cost = 280,
	material_level = 5,
	special_desc = function(self) return "Increases the damage of Sun Beam by 15%." end,
	combat = {
		dam = 67,
		apr = 22,
		physcrit = 12,
		dammod = {str=1.15, con = 0.2},
		special_on_hit = {desc="releases a burst of light, dealing damage equal to your spellpower in a 3 radius cone.", on_kill=1, fct=function(combat, who, target)
			who.turn_procs.champion_will = (who.turn_procs.champion_will or 0) + 1
			local tg = {type="cone", range=10, radius=3, force_target=target, selffire=false}
			local grids = who:project(tg, target.x, target.y, engine.DamageType.LIGHT, who:combatSpellpower() / (who.turn_procs.champion_will))
			game.level.map:particleEmitter(target.x, target.y, tg.radius, "light_cone", {radius=tg.radius, tx=target.x-who.x, ty=target.y-who.y})
			who.turn_procs.champion_will = (who.turn_procs.champion_will or 0) + 1
		end},
	},
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 12, [Stats.STAT_MAG] = 6, [Stats.STAT_CON] = 7},
		talents_types_mastery = {
			["celestial/crusader"] = 0.2,
			["celestial/sun"] = 0.2,
			["celestial/radiance"] = 0.1,
		},
		talent_cd_reduction= {
			[Talents.T_ABSORPTION_STRIKE] = 1,
			[Talents.T_SUN_BEAM] = 1,
			[Talents.T_FLASH_OF_THE_BLADE] = 1,
		},
		amplify_sun_beam = 15,
	},
	max_power = 30, power_regen = 1,
	use_power = { name = "strike with your weapon as 100% light damage, up to 4 spaces away, healing for 50% of the damage dealt", power = 30,
		use = function(self, who)
			local tg = {type="beam", range=4}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			local _ _, x, y = who:canProject(tg, x, y)
			who:attr("lifesteal", 50)
			who:project(tg, x, y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				who:attackTarget(target, engine.DamageType.LIGHT, 1, true)
			end)
			who:attr("lifesteal", -50)
			game.level.map:particleEmitter(who.x, who.y, tg.radius, "light_beam", {tx=x-who.x, ty=y-who.y})
			game:playSoundNear(self, "talents/lightning")
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_MASSIVE_ARMOR",
	power_source = {technique=true},
	unique = true,
	name = "Tarrasca", image = "object/artifact/terrasca.png",
	unided_name = "absurdly large armor",
	desc = [[This massive suit of plate boasts an enormous bulk and overbearing weight. Said to belong to a nameless soldier who safeguarded a passage across the bridge to his village, in defiance to the cohorts of invading orcs. After days of assault failed to fell him, the orcs turned back. The man however, fell dead on the spot - from exhaustion. The armor had finally claimed his life.]],
	color = colors.RED,
	level_range = {30, 40},
	rarity = 320,
	require = { stat = { str=52 }, },
	cost = 500,
	material_level = 4,
	special_desc = function(self) return ("When your effective movement speed (global speed times movement speed) is less than 100%%, reduces all incoming damage equal to the speed detriment, but never to less than 30%% of the original damage.\nCurrent Resistance: %d%%"):format(100*(1-(util.bound(game.player.global_speed * game.player.movement_speed, 0.3, 1)))) end,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 15, },
		combat_armor = 50,
		combat_armor_hardiness = 15,
		knockback_immune = 1,
		combat_physresist = 45,
		fatigue = 35,
		speed_resist=1,
	},
	max_power = 25, power_regen = 1,
	use_power = { name = "slow all units within 5 spaces (including yourself) by 40%", power = 25,
		use = function(self, who)
			who:project({type="ball", range=0, radius=5}, who.x, who.y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				target:setEffect(target.EFF_SLOW_MOVE, 3, {power=0.4, no_ct_effect=true, })
			end)
			game.logSeen(who, "%s thinks things really need to slow down for a bit.", who.name:capitalize())
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_LEATHER_CAP",
	power_source = {unknown=true},
	unique = true,
	name = "The Face of Fear",
	unided_name = "bone mask", image = "object/artifact/the_face_of_fear.png",
	level_range = {24, 32},
	color=colors.GREEN,
	moddable_tile = "special/the_face_of_fear",
	moddable_tile_big = true,
	encumber = 2,
	rarity = 200,
	desc = [[This mask appears to be carved out of the skull of a creature that never should have existed, malformed and distorted. You shiver as you look upon it, and it's hollow eye sockets seem to stare back into you.]],
	cost = 200,
	material_level=3,
	wielder = {
		combat_def=8,
		fear_immune = 0.6,
		inc_stats = { [Stats.STAT_WIL] = 8, [Stats.STAT_CUN] = 6, },
		combat_mindpower = 16,
		talents_types_mastery = { ["cursed/fears"] = 0.2,},
	},
	max_power = 45, power_regen = 1,
	use_talent = { id = Talents.T_INSTILL_FEAR, level = 2, power = 18 },
}

newEntity{ base = "BASE_LEATHER_BOOT",
	power_source = {arcane=true},
	unided_name = "flame coated sandals",
	name = "Cinderfeet", unique=true, image = "object/artifact/cinderfeet.png",
	desc = [[A cautionary tale tells of the ancient warlock by the name of Caim, who fancied himself daily walks through Goedalath, both to test himself and the harsh demonic wastes. He was careful to never bring anything back with him, lest it provide a beacon for the demons to find him. Unfortunately, over time, his sandals drenched in the soot and ashes of the fearscape and the fire followed his footsteps outside, drawing in the conclusion of his grim fate.]],
	require = { stat = { dex=10 }, },
	level_range = {28, 38},
	material_level = 4,
	rarity = 195,
	cost = 40,
	sentient=true,
	oldx=0,
	oldy=0,
	wielder = {
		lite = 2,
		combat_armor = 5,
		combat_def = 3,
		fatigue = 6,
		inc_damage = {
			[DamageType.FIRE] = 18,
		},
		resists = {
			[DamageType.COLD] = 20,
		},
		inc_stats = { [Stats.STAT_MAG] = 4, [Stats.STAT_CUN] = 4, },
	},
	special_desc = function(self) return "Trails fire behind you, dealing damage based on spellpower." end,
	on_wear = function(self, who)
		self.worn_by = who
		self.oldx=who.x
		self.oldy=who.y
	end,
	on_takeoff = function(self, who)
		self.worn_by = nil
	end,
	act = function(self)
		self:useEnergy()
		self:regenPower()
		
		local who=self.worn_by --Make sure you can actually act!
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) and not self.worn_by.player then self.worn_by = nil return end
		if self.worn_by:attr("dead") then return end
		if self.oldx ~= who.x or self.oldy ~= who.y then
			local DamageType = require "engine.DamageType"
			local duration = 6
			local radius = 0
			local dam = who:combatSpellpower()
			-- Add a lasting map effect
			game.level.map:addEffect(who,
				who.x, who.y, duration,
				DamageType.FIRE, dam,
				radius,
				5, nil,
				{type="inferno"},
				function(e)
					e.radius = e.radius 
					return true
				end,
				false
			)
		end
		self.oldx=who.x
		self.oldy=who.y
		return
	end
}

newEntity{ base = "BASE_MASSIVE_ARMOR",
	power_source = {arcane=true},
	unique = true,
	name = "Cuirass of the Dark Lord", image = "object/artifact/dg_casual_outfit.png",
	unided_name = "black, spiked armor",
	moddable_tile = "special/dgs_clothes",
	moddable_tile_big = true,
	desc = [[Worn by a villain long forgotten, this armor was powered by the blood of thousands of innocents. Decrepit and old, the dark lord died in solitude, his dominion crumbled, his subjects gone. Only the plate remained, dying to finally taste fresh blood again.]],
	color = colors.RED,
	level_range = {40, 50},
	rarity = 320,
	require = { stat = { str=52 }, },
	cost = 500,
	material_level = 5,
	sentient=true,
	blood_charge=0,
	blood_dur=0,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 10,  [Stats.STAT_CON] = 10, },
		combat_armor = 40,
		combat_dam=10,
		combat_physresist = 15,
		fatigue = 25,
		life_regen=0,
		on_melee_hit={[DamageType.PHYSICAL] = 30},
		resists={[DamageType.PHYSICAL] = 20},
	},
	max_power = 25, power_regen = 1,
	use_power = { name = "drain blood from all units within 5 spaces, causing them to bleed for 120 physical damage over 4 turns. For every unit (up to 10) drained, the armor's stats increase, but decrease over 10 turns until back to normal", power = 25,
		use = function(self, who)
			who:project({type="ball", range=0, radius=5, selffire=false}, who.x, who.y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				self.blood_charge=self.blood_charge + 1
				target:setEffect(target.EFF_CUT, 4, {power=30, no_ct_effect=true, src = who})
			end)
			if self.blood_charge > 10 then self.blood_charge = 10 end
			self.blood_dur = 10
			game.logSeen(who, "%s revels in blood!", self.name:capitalize())
			return {id=true, used=true}
		end
	},
	on_wear = function(self, who)
		self.worn_by = who
	end,
	on_takeoff = function(self, who)
		self.worn_by = nil
	end,
	act = function(self)
		self:useEnergy()
		self:regenPower()
		
		local who=self.worn_by --Make sure you can actually act!
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) and not self.worn_by.player then self.worn_by = nil return end
		local boost = self.blood_charge
		local dur = self.blood_dur
		local storepower=self.power
		local _, _, inven_id = who:findInAllInventoriesByObject(self)
		who:onTakeoff(self, inven_id, true)
		
		self.wielder = {
			inc_stats = { [Stats.STAT_STR] = math.ceil(10 + boost * dur/5),  [Stats.STAT_CON] = math.ceil(10 + boost * dur/5), },
			combat_armor = math.ceil(30 + boost * dur * 0.4),
			combat_dam = math.ceil(10 + boost/5 * dur),
			combat_physresist = math.ceil(15 + boost/5 * dur),
			fatigue = math.ceil(25 - boost/5 * dur),
			life_regen= math.ceil(boost/2 * dur),
			on_melee_hit={[DamageType.PHYSICAL] = math.ceil(30 + boost * dur * 0.8)},
			resists={[DamageType.PHYSICAL] = math.ceil(20 + boost/5 * dur)},
		}
		who:onWear(self, inven_id, true)
		self.power = storepower
		if self.blood_dur > 0 then
			self.blood_dur = self.blood_dur - 1
		end
		return
	end
}

--[=[
newEntity{
	unique = true,
	type = "jewelry", subtype="ankh",
	unided_name = "glowing ankh",
	name = "Anchoring Ankh",
	desc = [[As you lift the ankh you feel stable. The world around you feels stable.]],
	level_range = {15, 50},
	rarity = 400,
	display = "*", color=colors.YELLOW, image = "object/fireopal.png",
	encumber = 2,

	carrier = {

	},
}
]=]
