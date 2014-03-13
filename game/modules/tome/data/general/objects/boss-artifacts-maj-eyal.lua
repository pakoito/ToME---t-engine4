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

-- Design:  Revamp Wintertide to make it more unique, interesting, and not terrible.
-- Balance:  A cold themed weapon doesn't play nice with melee scalers, and Ice Block on hit, while useful overall, has some obvious anti-synergy.  So instead of focusing on stats I added a decent passive on hit and a very powerful active.  The active is a "better" Stone Wall but you have to be actively using the weapon in melee to make use of it.  The delayed expansion of the storm also limits its strength as an "oh shit" button.
newEntity{ base = "BASE_LONGSWORD",
	power_source = {arcane=true},
	define_as = "LONGSWORD_WINTERTIDE", unided_name = "glittering longsword", image="object/artifact/wintertide.png",
	name = "Wintertide", unique=true,
	desc = [[The air seems to freeze around the blade of this sword, draining all heat from the area.
It is said the Conclave created this weapon for their warmaster during the dark times of the first allure war.]],
	require = { stat = { str=35 }, },
	level_range = {35, 45},
	rarity = 280,
	cost = 1000,
	material_level = 5,
	winterStorm = nil,
	special_desc = function(self)
		if not self.winterStorm then 
			return ("Storm Duration:  None") 
		else
			return ("Storm Duration: " .. (self.winterStorm.duration or "None"))
		end
	end,
	combat = {
		dam = 39, -- lower damage, defensive item with extremely powerful effects
		apr = 10,
		physcrit = 10,
		dammod = {str=1},
		damrange = 1.4,
		melee_project={[DamageType.ICE] = 25}, -- Iceblock HP is based on damage, since were adding iceblock pierce we want this to be less generous
		special_on_hit = {desc="Create a Winter Storm that gradually expands, dealing cold damage to your enemies each turn and reducing their turn energy by 20%.  Melee attacks will relocate the storm on top of your target and increase its duration.", on_kill=1, fct=function(combat, who, target)
			 local self, item, inven_id = who:findInAllInventoriesBy("define_as", "LONGSWORD_WINTERTIDE")
			 if not self or not who:getInven(inven_id).worn then return end
			
			 if self.winterStorm and self.winterStorm.duration <= 0 then
				 self.winterStorm = nil
				 --return
			 end
			 
			 if (self.winterStorm and (game.level.id ~= self.winterStorm.checkZone) ) then
				self.winterStorm = nil
			 end
			 
			 if not self.winterStorm then
				local stormDam = who:combatStatScale("str", 20, 80, 0.75) -- does this need a require?
				 self.winterStorm = game.level.map:addEffect(who,
				 target.x, target.y, 5,
				 engine.DamageType.WINTER, {dam=stormDam, x=target.x, y=target.y}, -- Winter is cold damage+energy reduction, enemy only
				 1,
				 5, nil,
				 {type="icestorm", only_one=true},
				 function(e)	
					 if e.radius < 4 then
						e.radius = e.radius + 0.2
						 
						 -- this is a hack to fix the effect breaking if you reload with it active, whatever is going on is very weird but the table on the item no longer points to this
						local self2, item, inven_id = e.src:findInAllInventoriesBy("define_as", "LONGSWORD_WINTERTIDE")
						if not self2 then return end
						self2.winterStorm = e
					 end
					 return true
				 end,
			 false)
				self.winterStorm.checkZone = game.level.id
			else
				-- move the storm on top of the target
				self.winterStorm.x = target.x
				self.winterStorm.y = target.y
				if self.winterStorm.duration < 5 then -- duration can be extended forever while meleeing 
					self.winterStorm.duration = self.winterStorm.duration + 1
				end
			end
			
			end
			
		},	
		
	},
	wielder = {
		iceblock_pierce=35, -- this can be generous because of how melee specific the item is
		resists = { [DamageType.COLD] = 25 },
		on_melee_hit={[DamageType.ICE] = 40},
		inc_damage = { [DamageType.COLD] = 20 },
	},
	max_power = 40, power_regen = 1,
	use_power = { name ="intensify your winter storm creating unbreakable ice walls in each space", power = 30,
		use = function(self, who)
			
			local Object = require "mod.class.Object"
			local Map = require "engine.Map"
			
			if not self.winterStorm then return end
			
			if self.winterStorm and self.winterStorm.duration <= 0 then
				self.winterStorm = nil
				return
			end
			
			local grids = core.fov.circle_grids(self.winterStorm.x, self.winterStorm.y, self.winterStorm.radius, true)		
			local self = who


			for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
				local oe = game.level.map(x, y, engine.Map.TERRAIN)

				if oe then
					local e = Object.new{
						old_feat = oe,
						name = "winter wall", image = "npc/iceblock.png",
						display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
						desc = "a summoned wall of ice",
						type = "wall", --subtype = "floor",
						always_remember = true,
						can_pass = {pass_wall=1},
						does_block_move = true,
						show_tooltip = true,
						block_move = true,
						block_sight = true,
						temporary = 10,
						x = x, y = y,
						canAct = false,
						act = function(self)
							self:useEnergy()
							self.temporary = self.temporary - 1
							if self.temporary <= 0 then
								game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
								game.level:removeEntity(self)
	--							game.level.map:redisplay()
							end
						end,
						dig = function(src, x, y, old)
							game.level:removeEntity(old)
	--						game.level.map:redisplay()
							return nil, old.old_feat
						end,
						summoner_gain_exp = true,
						summoner = self,
					}
					e.tooltip = mod.class.Grid.tooltip
					game.level:addEntity(e)
					game.level.map(x, y, engine.Map.TERRAIN, e)				
				end
			end end
			
			return {id=true, used=true}
		end
	},
	on_wear = function(self, who)
		--self.winterStorm = nil
	end,
	on_pickup = function(self, who)
		self.winterStorm = nil
	end,
	
}

newEntity{ base = "BASE_LITE", define_as = "WINTERTIDE_PHIAL",
	power_source = {arcane=true},
	unided_name = "phial filled with darkness", unique = true, image="object/artifact/wintertide_phial.png",
	name = "Wintertide Phial", color=colors.DARK_GREY,
	desc = [[This phial seems filled with darkness, yet it cleanses your thoughts.]],
	level_range = {1, 10},
	rarity = 200,
	encumber = 2,
	cost = 50,
	material_level = 1,

	wielder = {
		lite = 1,
		infravision = 6,
	},

	max_power = 60, power_regen = 1,
	use_power = { name = "cleanse your mind (remove a few detrimental mental effects)", power = 40,
		use = function(self, who)
			local target = who
			local effs = {}
			local known = false

			-- Go through all spell effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type == "mental" and e.status == "detrimental" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			for i = 1, 3 + math.floor(who:getMag() / 10) do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)

				if eff[1] == "effect" then
					target:removeEffect(eff[2])
					known = true
				end
			end
			game.logSeen(who, "%s's mind is clear!", who.name:capitalize())
			return {id=true, used=true}
		end
	},
}

-- Artifact, dropped by Rantha
newEntity{ base = "BASE_LEATHER_BOOT",
	power_source = {nature=true},
	define_as = "FROST_TREADS",
	unided_name = "ice-covered boots",
	name = "Frost Treads", unique=true, image="object/artifact/frost_treads.png",
	desc = [[A pair of leather boots. Cold to the touch, they radiate a cold blue light.]],
	require = { stat = { dex=16 }, },
	level_range = {10, 18},
	material_level = 2,
	rarity = 220,
	cost = 40,

	wielder = {
		lite = 1,
		combat_armor = 4,
		combat_def = 1,
		fatigue = 7,
		inc_damage = {
			[DamageType.COLD] = 15,
		},
		resists = {
			[DamageType.COLD] = 20,
			[DamageType.NATURE] = 10,
		},
		inc_stats = { [Stats.STAT_STR] = 4, [Stats.STAT_DEX] = 4, [Stats.STAT_CUN] = 4, },
	},
}

newEntity{ base = "BASE_HELM",
	power_source = {technique=true},
	define_as = "DRAGON_SKULL",
	name = "Dragonskull Helm", unique=true, unided_name="skull helm", image = "object/artifact/dragonskull_helmet.png",
	desc = [[Traces of a dragon's power still remain in this bleached and cracked skull.]],
	require = { stat = { wil=24 }, },
	level_range = {45, 50},
	material_level = 5,
	rarity = 280,
	cost = 200,

	wielder = {
		resists = {
			[DamageType.FIRE] = 15,
			[DamageType.COLD] = 15,
			[DamageType.ACID] = 15,
			[DamageType.LIGHTNING] = 15,
		},
		esp = {dragon=1},
		combat_armor = 2,
		fatigue = 12,
		combat_physresist = 12,
		combat_mentalresist = 12,
		combat_spellresist = 12,
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {nature=true},
	define_as = "EEL_SKIN", image = "object/artifact/eel_skin_armor.png",
	name = "Eel-skin armour", unique=true,
	unided_name = "slippery armour", color=colors.VIOLET,
	desc = [[This armour seems to have been patched together from many eels. Yuck.]],
	level_range = {5, 12},
	rarity = 200,
	cost = 500,
	material_level = 2,
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = 2, [Stats.STAT_CUN] = 3,  },
		poison_immune = 0.3,
		combat_armor = 1,
		combat_def = 10,
		fatigue = 2,
	},

	max_power = 50, power_regen = 1,
	use_talent = { id = Talents.T_CALL_LIGHTNING, level=2, power = 18 },
	talent_on_wild_gift = { {chance=10, talent=Talents.T_CALL_LIGHTNING, level=2} },
}

newEntity{ base = "BASE_RING",
	power_source = {psionic=true},
	define_as = "NIGHT_SONG",
	name = "Nightsong", unique=true, image = "object/artifact/ring_nightsong.png",
	desc = [[A pitch black ring, unadorned. It seems as though tendrils of darkness creep upon it.]],
	unided_name = "obsidian ring",
	level_range = {15, 23},
	rarity = 250,
	cost = 500,
	material_level = 2,
	wielder = {
		max_stamina = 25,
		combat_def = 6,
		fatigue = -7,
		inc_stats = { [Stats.STAT_CUN] = 6 },
		combat_mentalresist = 13,
		talent_cd_reduction={
			[Talents.T_SHADOWSTEP]=1,
		},
		inc_damage={ [DamageType.PHYSICAL] = 5, },
	},

	max_power = 50, power_regen = 1,
	use_talent = { id = Talents.T_DARK_TENDRILS, level=2, power = 40 },
}

newEntity{ base = "BASE_HELM",
	power_source = {nature=true},
	define_as = "HELM_OF_GARKUL",
	unided_name = "tribal helm",
	name = "Steel Helm of Garkul", unique=true, image="object/artifact/helm_of_garkul.png",
	desc = [[A great helm that belonged to Garkul the Devourer, one of the greatest orcs ever to live.]],
	require = { stat = { str=16 }, },
	level_range = {12, 22},
	rarity = 200,
	cost = 500,
	material_level = 2,
	skullcracker_mult = 5,

	wielder = {
		combat_armor = 6,
		fatigue = 8,
		inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_CON] = 5, [Stats.STAT_WIL] = 4 },
		inc_damage={ [DamageType.PHYSICAL] = 10, },
		combat_physresist = 12,
		combat_mentalresist = 12,
		combat_spellresist = 12,
		talents_types_mastery = {["technique/thuggery"]=0.2},
	},

	set_list = { {"define_as","SET_GARKUL_TEETH"} },
	on_set_complete = function(self, who)
		self:specialSetAdd("skullcracker_mult", 1)
		self:specialSetAdd({"wielder","melee_project"}, {[engine.DamageType.GARKUL_INVOKE]=5})
	end,
}

newEntity{ base = "BASE_SHIELD",
	power_source = {arcane=true},
	define_as = "LUNAR_SHIELD",
	unique = true,
	name = "Lunar Shield", image = "object/artifact/shield_lunar_shield.png",
	unided_name = "chitinous shield",
	desc = [[A large section of chitin removed from Nimisil. It continues to give off a strange white glow.]],
	color = colors.YELLOW,
	metallic = false,
	require = { stat = { str=35 }, },
	level_range = {40, 50},
	rarity = 280,
	cost = 350,
	material_level = 5,
	special_combat = {
		dam = 45,
		block = 250,
		physcrit = 10,
		dammod = {str=1},
		damrange = 1.4,
		damtype = DamageType.ARCANE,
	},
	wielder = {
		resists={[DamageType.DARKNESS] = 25},
		inc_damage={[DamageType.DARKNESS] = 15},

		combat_armor = 7,
		combat_def = 12,
		combat_def_ranged = 5,
		combat_spellpower = 10,
		fatigue = 2,

		lite = 1,
		talents_types_mastery = {["celestial/star-fury"]=0.2,["celestial/twilight"]=0.1,},
		learn_talent = { [Talents.T_BLOCK] = 5, },
	},
	talent_on_spell = { {chance=10, talent=Talents.T_MOONLIGHT_RAY, level=2} },
}

newEntity{ base = "BASE_SHIELD",
	power_source = {nature=true},
	define_as = "WRATHROOT_SHIELD",
	unided_name = "large chunk of wood",
	name = "Wrathroot's Barkwood", unique=true, image="object/artifact/shield_wrathroots_barkwood.png",
	desc = [[The barkwood of Wrathroot, made into roughly the shape of a shield.]],
	require = { stat = { str=25 }, },
	level_range = {12, 22},
	rarity = 200,
	cost = 20,
	material_level = 2,
	metallic = false,
	special_combat = {
		dam = resolvers.rngavg(20,30),
		block = 60,
		physcrit = 2,
		dammod = {str=1.5},
		damrange = 1.4,
	},
	wielder = {
		combat_armor = 10,
		combat_def = 9,
		fatigue = 14,
		resists = {
			[DamageType.DARKNESS] = 20,
			[DamageType.COLD] = 20,
			[DamageType.NATURE] = 20,
		},
		learn_talent = { [Talents.T_BLOCK] = 3, },
	},
}

newEntity{ base = "BASE_GEM",
	power_source = {nature=true},
	unique = true, define_as = "PETRIFIED_WOOD",
	unided_name = "burned piece of wood",
	name = "Petrified Wood", subtype = "red", --Visually black, but associate with fire, not acid
	color = colors.WHITE, image = "object/artifact/petrified_wood.png",
	level_range = {35, 45},
	rarity = 280,
	desc = [[A piece of the scorched wood taken from the remains of Snaproot.]],
	cost = 100,
	material_level = 4,
	identified = false,
	imbue_powers = {
		resists = { [DamageType.NATURE] = 25, [DamageType.DARKNESS] = 10, [DamageType.COLD] = 10 },
		inc_stats = { [Stats.STAT_CON] = 25, },
		ignore_direct_crits = 23,
	},
	wielder = {
		resists = { [DamageType.NATURE] = 25, [DamageType.DARKNESS] = 10, [DamageType.COLD] = 10 },
		inc_stats = { [Stats.STAT_CON] = 25, },
		ignore_direct_crits = 23,
	},
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	unique = true, define_as = "CRYSTAL_SHARD",
	name = "Crystal Shard",
	unided_name = "crystalline tree branch",
	flavor_name = "magestaff",
	level_range = {10, 22},
	color=colors.BLUE, image = "object/artifact/crystal_shard.png",
	rarity = 300,
	desc = [[This crystalline tree branch is remarkably rigid, and refracts light in myriad colors. Gazing at it entrances you, and you worry where its power may have come from.]],
	cost = 200,
	material_level = 2,
	require = { stat = { mag=20 }, },
	combat = {
		dam = 16,
		apr = 4,
		dammod = {mag=1.3},
		damtype = DamageType.ARCANE,
		convert_damage = {
			[DamageType.BLIGHT] = 50,
		},
	},
	wielder = {
		combat_spellpower = 14,
		combat_spellcrit = 4,
		inc_damage={
			[DamageType.ARCANE] = 18,
			[DamageType.BLIGHT] = 18,
		},
		resists={
			[DamageType.ARCANE] = 10,
			[DamageType.BLIGHT] = 10,
		},
		damage_affinity={
			[DamageType.ARCANE] = 20,
		},
	},
	max_power = 45, power_regen = 1,
	use_power = { name = "create living shards of crystal", power = 45, use = function(self, who)
		if not who:canBe("summon") then game.logPlayer(who, "You cannot summon; you are suppressed!") return end

		local NPC = require "mod.class.NPC"
		local list = NPC:loadList("/data/general/npcs/crystal.lua")
		for i = 1, 2 do
			-- Find space
			local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.ACTOR]=true})
			if not x then break end
				local e
			repeat e = rng.tableRemove(list)

			until not e.unique and e.rarity
			e = e:clone()
			local crystal = game.zone:finishEntity(game.level, "actor", e)
			crystal.make_escort = nil
			crystal.silent_levelup = true
			crystal.faction = who.faction
			crystal.ai = "summoned"
			crystal.ai_real = "dumb_talented_simple"
			crystal.summoner = who
			crystal.summon_time = 10
			crystal.exp_worth = 0
			crystal:forgetInven(crystal.INVEN_INVEN)

			local setupSummon = getfenv(who:getTalentFromId(who.T_SPIDER).action).setupSummon
			if who:knowTalent(who.T_BLIGHTED_SUMMONING) then
				crystal.blighted_summon_talent = who.T_BONE_SHIELD
				crystal:incIncStat("mag", who:getMag())
				crystal.summon_time=15
			end
			setupSummon(who, crystal, x, y)
			game:playSoundNear(who, "talents/ice")
		end
		return {id=true, used=true}
	end },
}

newEntity{ base = "BASE_WARAXE",
	power_source = {arcane=true},
	define_as = "MALEDICTION",
	unided_name = "pestilent waraxe",
	name = "Malediction", unique=true, image = "object/artifact/axe_malediction.png",
	desc = [[The land withers and crumbles wherever this cursed axe rests.]],
	require = { stat = { str=55 }, },
	level_range = {35, 45},
	rarity = 290,
	cost = 375,
	material_level = 4,
	combat = {
		dam = 55,
		apr = 15,
		physcrit = 10,
		dammod = {str=1},
		damrange = 1.2,
		burst_on_hit={[DamageType.BLIGHT] = 25},
		lifesteal=5, --You can counter the life regen by fighting, muhuhahah
	},
	wielder = {
		life_regen = -0.3,
		inc_damage = { [DamageType.BLIGHT] = 20 },
	},
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	define_as = "STAFF_KOR", image = "object/artifact/staff_kors_fall.png",
	unided_name = "dark staff",
	flavor_name = "vilestaff",
	name = "Kor's Fall", unique=true,
	desc = [[Made from the bones of many creatures, this staff glows with power. You can feel its evil presence even from a distance.]],
	require = { stat = { mag=25 }, },
	level_range = {1, 10},
	rarity = 200,
	cost = 60,
	material_level = 1,
	modes = {"darkness", "fire", "blight", "acid"},
	combat = {
		is_greater = true,
		dam = 10,
		apr = 0,
		physcrit = 1.5,
		dammod = {mag=1.1},
		damtype = DamageType.DARKNESS,
	},
	wielder = {
		see_invisible = 2,
		combat_spellpower = 7,
		combat_spellcrit = 8,
		inc_damage={
			[DamageType.ACID] = 10,
			[DamageType.DARKNESS] = 10,
			[DamageType.FIRE] = 10,
			[DamageType.BLIGHT] = 10,
		},
		talents_types_mastery = { ["corruption/bone"] = 0.1, },
		learn_talent = {[Talents.T_COMMAND_STAFF] = 1},
	},
	max_power = 6, power_regen = 1,
	use_talent = { id = Talents.T_BONE_SPEAR, level = 3, power = 6 },
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	define_as = "VOX", 
	name = "Vox", unique=true,
	unided_name = "ringing amulet", color=colors.BLUE, image="object/artifact/jewelry_amulet_vox.png",
	desc = [[No force can hope to silence the wearer of this amulet.]],
	level_range = {40, 50},
	rarity = 220,
	cost = 3000,
	material_level = 5,
	wielder = {
		see_invisible = 20,
		silence_immune = 1,
		combat_spellpower = 9,
		combat_spellcrit = 4,
		max_mana = 50,
		combat_spellspeed = 0.15,
		max_vim = 50,
	},
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	define_as = "TELOS_TOP_HALF", image = "object/artifact/staff_broken_top_telos.png",
	slot_forbid = false,
	twohanded = false,
	unided_name = "broken staff", flavor_name = "magestaff",
	name = "Telos's Staff (Top Half)", unique=true,
	desc = [[The top part of Telos' broken staff.]],
	require = { stat = { mag=35 }, },
	level_range = {40, 50},
	rarity = 210,
	encumber = 2.5,
	material_level = 5,
	modes = {"fire", "cold", "lightning", "arcane"},
	cost = 500,
	combat = {
		dam = 35,
		apr = 0,
		physcrit = 1.5,
		dammod = {mag=1.0},
		damtype = DamageType.ARCANE,
	},
	wielder = {
		combat_spellpower = 30,
		combat_spellcrit = 15,
		combat_mentalresist = 8,
		inc_stats = { [Stats.STAT_WIL] = 5, },
		inc_damage = {[DamageType.ARCANE] = 35 },
		learn_talent = {[Talents.T_COMMAND_STAFF] = 1 },
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	define_as = "AMULET_DREAD",
	name = "Choker of Dread", unique=true, image = "object/artifact/amulet_choker_of_dread.png",
	unided_name = "dark amulet", color=colors.LIGHT_DARK,
	desc = [[The evilness of undeath radiates from this amulet.]],
	level_range = {20, 28},
	rarity = 220,
	cost = 500,
	material_level = 3,
	wielder = {
		see_invisible = 10,
		blind_immune = 1,
		combat_spellpower = 5,
		combat_dam = 5,
	},
	max_power = 60, power_regen = 1,
	use_power = { name = "summon an elder vampire to your side", power = 60, use = function(self, who)
		if not who:canBe("summon") then game.logPlayer(who, "You cannot summon; you are suppressed!") return end

		-- Find space
		local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.ACTOR]=true})
		if not x then
			game.logPlayer(who, "Not enough space to invoke the vampire!")
			return
		end
		print("Invoking guardian on", x, y)

		local NPC = require "mod.class.NPC"
		local vampire = NPC.new{
			type = "undead", subtype = "vampire",
			display = "V", image = "npc/elder_vampire.png",
			name = "elder vampire", color=colors.RED,
			desc=[[A terrible robed undead figure, this creature has existed in its unlife for many centuries by stealing the life of others. It can summon the very shades of its victims from beyond the grave to come enslaved to its aid.]],

			combat = { dam=resolvers.rngavg(9,13), atk=10, apr=9, damtype=engine.DamageType.DRAINLIFE, dammod={str=1.9} },

			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

			autolevel = "warriormage",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=3, },
			stats = { str=12, dex=12, mag=12, con=12 },
			life_regen = 3,
			size_category = 3,
			rank = 3,
			infravision = 10,

			inc_damage = table.clone(who.inc_damage, true),

			resists = { [engine.DamageType.COLD] = 80, [engine.DamageType.NATURE] = 80, [engine.DamageType.LIGHT] = -50,  },
			blind_immune = 1,
			confusion_immune = 1,
			see_invisible = 5,
			undead = 1,

			level_range = {who.level, who.level}, exp_worth = 0,
			max_life = resolvers.rngavg(90,100),
			combat_armor = 12, combat_def = 10,
			resolvers.talents{ [who.T_STUN]=2, [who.T_BLUR_SIGHT]=3, [who.T_PHANTASMAL_SHIELD]=2, [who.T_ROTTING_DISEASE]=3, },

			faction = who.faction,
			summoner = who,
			summon_time = 15,
		}

		vampire:resolve()
		game.zone:addEntity(game.level, vampire, "actor", x, y)
		vampire:forceUseTalent(vampire.T_TAUNT, {})
		game:playSoundNear(who, "talents/spell_generic")
		return {id=true, used=true}
	end },
}

newEntity{ define_as = "RUNED_SKULL",
	power_source = {arcane=true},
	unique = true,
	type = "gem", subtype="red", image = "object/artifact/bone_runed_skull.png",
	unided_name = "human skull",
	name = "Runed Skull",
	display = "*", color=colors.RED,
	level_range = {40, 50},
	rarity = 390,
	cost = 150,
	encumber = 3,
	material_level = 5,
	desc = [[Dull red runes are etched all over this blackened skull.]],

	carrier = {
		combat_spellpower = 7,
		on_melee_hit = {[DamageType.FIRE]=25},
	},
}

newEntity{ base = "BASE_GREATMAUL",
	power_source = {technique=true},
	define_as = "GREATMAUL_BILL_TRUNK",
	unided_name = "tree trunk", image = "object/artifact/bill_treestump.png",
	name = "Bill's Tree Trunk", unique=true,
	desc = [[This is a big, nasty-looking tree trunk that Bill the Troll used as a weapon. It could still serve this purpose, should you be strong enough to wield it!]],
	require = { stat = { str=25 }, },
	level_range = {1, 10},
	material_level = 1,
	rarity = 200,
	metallic = false,
	cost = 70,
	combat = {
		dam = 30,
		apr = 7,
		physcrit = 1.5,
		dammod = {str=1.3},
		damrange = 1.7,
	},

	wielder = {
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_SUNDER_ARMOUR, level = 2, power = 20 },
}


newEntity{ base = "BASE_SHIELD",
	power_source = {technique=true},
	define_as = "SANGUINE_SHIELD",
	unided_name = "bloody shield",
	name = "Sanguine Shield", unique=true, image = "object/artifact/sanguine_shield.png",
	desc = [[Though tarnished and spattered with blood, the emblem of the Sun still manages to shine through on this shield.]],
	require = { stat = { str=39 }, },
	level_range = {35, 45},
	material_level = 4,
	rarity = 240,
	cost = 120,

	special_combat = {
		dam = 40,
		block = 220,
		physcrit = 9,
		dammod = {str=1.2},
	},
	wielder = {
		combat_armor = 4,
		combat_def = 14,
		combat_def_ranged = 14,
		inc_stats = { [Stats.STAT_CON] = 5, },
		fatigue = 19,
		resists = { [DamageType.BLIGHT] = 25, },
		life_regen = 5,
		learn_talent = { [Talents.T_BLOCK] = 5, },
	},
}

newEntity{ base = "BASE_GLOVES", define_as = "FLAMEWROUGHT",
	power_source = {nature=true},
	unique = true,
	name = "Flamewrought", color = colors.RED, image = "object/artifact/gloves_flamewrought.png",
	unided_name = "chitinous gloves",
	desc = [[These gloves seems to be made out of the exoskeletons of ritches. They are hot to the touch.]],
	level_range = {5, 12},
	rarity = 180,
	cost = 50,
	material_level = 1,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 3, [Stats.STAT_CUN] = 2,},
		resists = { [DamageType.FIRE]= 10, },
		inc_damage = { [DamageType.FIRE]= 5, },
		combat_mindpower=2,
		combat_armor = 2,
		combat = {
			dam = 5,
			apr = 7,
			physcrit = 1,
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
			melee_project={[DamageType.FIRE] = 10},
			talent_on_hit = { T_RITCH_FLAMESPITTER_BOLT = {level=3, chance=30} },
			convert_damage = { [DamageType.FIRE] = 100,},
		},
	},
	max_power = 24, power_regen = 1,
	use_talent = { id = Talents.T_RITCH_FLAMESPITTER_BOLT, level = 3, power = 8 },
}

-- The crystal set
newEntity{ base = "BASE_GEM", define_as = "CRYSTAL_FOCUS",
	power_source = {arcane=true},
	unique = true,
	unided_name = "scintillating crystal",
	name = "Crystal Focus", subtype = "multi-hued",
	color = colors.WHITE, image = "object/artifact/crystal_focus.png",
	level_range = {5, 12},
	desc = [[This crystal radiates the power of the Spellblaze itself.]],
	rarity = 200,
	identified = false,
	cost = 50,
	material_level = 2,

	max_power = 1, power_regen = 1,
	use_power = { name = "combine with a weapon", power = 1, use = function(self, who, gem_inven, gem_item)
		who:showInventory("Fuse with which weapon?", who:getInven("INVEN"), function(o) return (o.type == "weapon" or o.subtype == "hands") and o.subtype ~= "mindstar" and not o.egoed and not o.unique and not o.rare and not o.archery end, function(o, item)
			local oldname = o:getName{do_color=true}

			-- Remove the gem
			who:removeObject(gem_inven, gem_item)
			who:sortInven(gem_inven)

			-- Change the weapon
			o.name = "Crystalline "..o.name:capitalize()
			o.unique = o.name
			o.no_unique_lore = true
			if o.combat and o.combat.dam then
				o.combat.dam = o.combat.dam * 1.25
				o.combat.damtype = engine.DamageType.ARCANE
			elseif o.wielder.combat and o.wielder.combat.dam then
				o.wielder.combat.dam = o.wielder.combat.dam * 1.25
				o.wielder.combat.convert_damage = o.wielder.combat.convert_damage or {}
				o.wielder.combat.convert_damage[engine.DamageType.ARCANE] = 100
			end
			o.is_crystalline_weapon = true
			o.power_source = o.power_source or {}
			o.power_source.arcane = true
			o.wielder = o.wielder or {}
			o.wielder.combat_spellpower = (o.wielder.combat_spellpower or 0) + 12
			o.wielder.combat_dam = (o.wielder.combat_dam or 0) + 12
			o.wielder.inc_stats = o.wielder.inc_stats or {}
			o.wielder.inc_stats[engine.interface.ActorStats.STAT_WIL] = 3
			o.wielder.inc_stats[engine.interface.ActorStats.STAT_CON] = 3
			o.wielder.inc_damage = o.wielder.inc_damage or {}
			o.wielder.inc_damage[engine.DamageType.ARCANE] = 10
			if o.wielder.learn_talent then o.wielder.learn_talent[who.T_COMMAND_STAFF] = nil end

			o.set_list = { {"is_crystalline_armor", true} }
			o.on_set_complete = function(self, who)
				self.talent_on_spell = { {chance=10, talent="T_MANATHRUST", level=3} }
				if(self.combat) then self.combat.talent_on_hit = { T_MANATHRUST = {level=3, chance=10} }
				else self.wielder.combat.talent_on_hit = { T_MANATHRUST = {level=3, chance=10} }
				end
				self:specialSetAdd({"wielder","combat_spellcrit"}, 10)
				self:specialSetAdd({"wielder","combat_physcrit"}, 10)
				self:specialSetAdd({"wielder","resists_pen"}, {[engine.DamageType.ARCANE]=20, [engine.DamageType.PHYSICAL]=15})
				game.logPlayer(who, "#GOLD#As the crystalline weapon and armour are brought together, they begin to emit a constant humming.")
			end
			o.on_set_broken = function(self, who)
				self.talent_on_spell = nil
				if (self.combat) then self.combat.talent_on_hit = nil
				else self.wielder.combat.talent_on_hit = nil
				end
				game.logPlayer(who, "#GOLD#The humming from the crystalline artifacts fades as they are separated.")
			end

			who:sortInven()
			who.changed = true

			game.logPlayer(who, "You fix the crystal on the %s and create the %s.", oldname, o:getName{do_color=true})
		end)
	end },
}

newEntity{ base = "BASE_GEM", define_as = "CRYSTAL_HEART",
	power_source = {arcane=true},
	unique = true,
	unided_name = "coruscating crystal",
	name = "Crystal Heart", subtype = "multi-hued",
	color = colors.RED, image = "object/artifact/crystal_heart.png",
	level_range = {35, 42},
	desc = [[This crystal is huge, easily the size of your head. It sparkles brilliantly almost of its own accord.]],
	rarity = 250,
	identified = false,
	cost = 200,
	material_level = 5,

	max_power = 1, power_regen = 1,
	use_power = { name = "combine with a suit of body armor", power = 1, use = function(self, who, gem_inven, gem_item)
		-- Body armour only, can be cloth, light, heavy, or massive though. No clue if o.slot works for this.
		who:showInventory("Fuse with which armor?", who:getInven("INVEN"), function(o) return o.type == "armor" and o.slot == "BODY" and not o.egoed and not o.unique and not o.rare end, function(o, item)
			local oldname = o:getName{do_color=true}

			-- Remove the gem
			who:removeObject(gem_inven, gem_item)
			who:sortInven(gem_inven)

			-- Change the weapon... err, armour. No, I'm not copy/pasting here, honest!
			o.name = "Crystalline "..o.name:capitalize()
			o.unique = o.name
			o.no_unique_lore = true
			o.is_crystalline_armor = true
			o.power_source = o.power_source or {}
			o.power_source.arcane = true

			o.wielder = o.wielder or {}
			-- This is supposed to add 1 def for crap cloth robes if for some reason you choose it instead of better robes, and then multiply by 1.25.
			o.wielder.combat_def = ((o.wielder.combat_def or 0) + 2) * 1.7
			-- Same for armour. Yay crap cloth!
			o.wielder.combat_armor = ((o.wielder.combat_armor or 0) + 3) * 1.7
			o.wielder.combat_spellresist = 35
			o.wielder.combat_physresist = 25
			o.wielder.inc_stats = o.wielder.inc_stats or {}
			o.wielder.inc_stats[engine.interface.ActorStats.STAT_MAG] = 8
			o.wielder.inc_stats[engine.interface.ActorStats.STAT_CON] = 8
			o.wielder.inc_stats[engine.interface.ActorStats.STAT_LCK] = 12
			o.wielder.resists = o.wielder.resists or {}
			o.wielder.resists = { [engine.DamageType.ARCANE] = 35, [engine.DamageType.PHYSICAL] = 15 }
			o.wielder.poison_immune = 0.6
			o.wielder.disease_immune = 0.6

			o.set_list = { {"is_crystalline_weapon", true} }
			o.on_set_complete = function(self, who)
				self:specialSetAdd({"wielder","stun_immune"}, 0.5)
				self:specialSetAdd({"wielder","blind_immune"}, 0.5)
			end
			who:sortInven()
			who.changed = true

			game.logPlayer(who, "You fix the crystal on the %s and create the %s.", oldname, o:getName{do_color=true})
		end)
	end },
}

newEntity{ base = "BASE_ROD", define_as = "ROD_OF_ANNULMENT",
	power_source = {arcane=true},
	unided_name = "dark rod",
	name = "Rod of Annulment", color=colors.LIGHT_BLUE, unique=true, image = "object/artifact/rod_of_annulment.png",
	desc = [[You can feel magic draining out around this rod. Even nature itself seems affected.]],
	cost = 50,
	rarity = 380,
	level_range = {5, 12},
	elec_proof = true,
	add_name = false,

	material_level = 2,

	max_power = 30, power_regen = 1,
	use_power = { name = "force some of your foe's infusions, runes or talents on cooldown", power = 30,
		use = function(self, who)
			local tg = {type="bolt", range=5}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			who:project(tg, x, y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end

				local tids = {}
				for tid, lev in pairs(target.talents) do
					local t = target:getTalentFromId(tid)
					if not target.talents_cd[tid] and t.mode == "activated" and not t.innate then tids[#tids+1] = t end
				end
				for i = 1, 3 do
					local t = rng.tableRemove(tids)
					if not t then break end
					target.talents_cd[t.id] = rng.range(3, 5)
					game.logSeen(target, "%s's %s is disrupted!", target.name:capitalize(), t.name)
				end
				target.changed = true
			end, nil, {type="flame"})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_WARAXE",
	power_source = {arcane=true},
	define_as = "SKULLCLEAVER",
	unided_name = "crimson waraxe",
	name = "Skullcleaver", unique=true, image = "object/artifact/axe_skullcleaver.png",
	desc = [[A small but sharp axe, with a handle made of polished bone.  The blade has chopped through the skulls of many, and has been stained a deep crimson.]],
	require = { stat = { str=18 }, },
	level_range = {5, 12},
	material_level = 1,
	rarity = 220,
	cost = 50,
	combat = {
		dam = 20,
		apr = 4,
		physcrit = 12,
		dammod = {str=1},
		talent_on_hit = { [Talents.T_GREATER_WEAPON_FOCUS] = {level=2, chance=10} },
		lifesteal = 10,
		convert_damage = {[DamageType.BLIGHT] = 25},
	},
	wielder = {
		inc_damage = { [DamageType.BLIGHT] = 8 },
	},
}

newEntity{ base = "BASE_DIGGER",
	power_source = {unknown=true},
	define_as = "TOOTH_MOUTH",
	unided_name = "a tooth", unique = true,
	name = "Tooth of the Mouth", image = "object/artifact/tooth_of_the_mouth.png",
	desc = [[A huge tooth taken from the Mouth, in the Deep Bellow.]],
	level_range = {5, 12},
	cost = 50,
	material_level = 1,
	digspeed = 12,
	wielder = {
		inc_damage = { [DamageType.BLIGHT] = 4 },
		on_melee_hit = {[DamageType.BLIGHT] = 15},
		combat_apr = 5,
	},
}

newEntity{ base = "BASE_HEAVY_BOOTS",
	define_as = "WARPED_BOOTS",
	power_source = {unknown=true},
	unique = true,
	name = "The Warped Boots", image = "object/artifact/the_warped_boots.png",
	unided_name = "pair of painful-looking boots",
	desc = [[These blackened boots have lost all vestiges of any former glory they might have had. Now, they are a testament to the corruption of the Deep Bellow, and its power.]],
	color = colors.DARK_GREEN,
	level_range = {35, 45},
	rarity = 250,
	cost = 200,
	material_level = 5,
	wielder = {
		combat_armor = 4,
		combat_def = 2,
		combat_dam = 10,
		fatigue = 8,
		combat_spellpower = 10,
		combat_mindresist = 10,
		combat_spellresist = 10,
 		resists={
			[DamageType.BLIGHT] = 10,
 		},
		max_life = 80,
		life_regen = -0.20,
	},
	max_power = 50, power_regen = 1,
	use_talent = { id = Talents.T_SPIT_BLIGHT, level=3, power = 10 },
}

newEntity{ base = "BASE_AMULET",
	power_source = {psionic=true},
	define_as = "WITHERING_ORBS",
	unique = true,
	name = "Withering Orbs", color = colors.WHITE, image = "object/artifact/artifact_jewelry_withering_orbs.png",
	unided_name = "shadow-strung orbs",
	desc = [[These opalescent orbs stare at you with deathly knowledge, undeceived by your vanities and pretences.  They have lived and died through horrors you could never imagine, and now they lie strung in black chords watching every twitch of the shadows.
If you close your eyes a moment, you can almost imagine what dread sights they see...]],
	level_range = {5, 12},
	rarity = 200,
	cost = 100,
	material_level = 1,
	metallic = false,
	wielder = {
		blind_fight = 1,
		see_invisible = 10,
		see_stealth = 10,
		combat_mindpower = 5,
		melee_project = {
			[DamageType.MIND] = 5,
		},
		ranged_project = {
			[DamageType.MIND] = 5,
		},
	},
}

newEntity{ base = "BASE_MASSIVE_ARMOR",
	power_source = {technique=true},
	define_as = "BORFAST_CAGE",
	unique = true,
	name = "Borfast's Cage",
	unided_name = "a suit of pitted and pocked plate-mail",
	desc = [[Inch-thick stralite plates lock together with voratun joints. The whole suit looks impenetrable, but has clearly been subjected to terrible treatment - great dents and misshaping warps, and caustic fissures bored across the surface.
Though clearly a powerful piece, it must once have been much greater.]],
	color = colors.WHITE, image = "object/artifact/armor_plate_borfasts_cage.png",
	level_range = {20, 28},
	rarity = 200,
	require = { stat = { str=35 }, },
	cost = 500,
	material_level = 3,
	wielder = {
		combat_def = 10,
		combat_armor = 15,
		fatigue = 24,

		inc_stats = { [Stats.STAT_CON] = 5, },
		resists = {
			[DamageType.ACID] = - 15,
			[DamageType.PHYSICAL] = 15,
		},

		max_life = 50,
		life_regen = 2,

		knockback_immune = 0.3,

		combat_physresist = 15,
		combat_crit_reduction = 20,
	},
}

newEntity{ base = "BASE_LEATHER_CAP", -- No armor training requirement
	power_source = {psionic=true},
	define_as = "ALETTA_DIADEM",
	name = "Aletta's Diadem", unique=true, unided_name="jeweled diadem", image = "object/artifact/diadem_alettas_diadem.png",
	desc = [[A filigree of silver set with many small jewels, this diadem seems radiant - ethereal almost. But its touch seems to freeze your skin and brings wild thoughts to your mind. You want to drop it, throw it away, and yet you cannot resist thinking of what powers it might bring you.
Is this temptation a weak will on your part, or some domination from the artifact itself...?]],
	require = { stat = { wil=24 }, },
	level_range = {20, 28},
	rarity = 200,
	cost = 1000,
	material_level = 3,
	metallic = true,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 4, [Stats.STAT_CUN] = 4, },
		combat_mindpower = 12,
		combat_mindcrit = 5,
		on_melee_hit={ [DamageType.MIND] = 12, },
		inc_damage={ [DamageType.MIND] = 10, },
	},
	max_power = 10, power_regen = 1,
	use_talent = { id = Talents.T_PSYCHIC_LOBOTOMY, level=3, power = 8 },
}

newEntity{ base = "BASE_SLING",
	power_source = {nature=true},
	define_as = "HARESKIN_SLING",
	name = "Hare-Skin Sling", unique=true, unided_name = "hare-skin sling", image = "object/artifact/sling_hareskin_sling.png",
	desc = [[This well-tended sling is made from the leather and sinews of a large hare. It feels smooth to the touch, yet very durable. Some say that the skin of a hare brings luck and fortune.
Hard to tell if that really helped its former owner, but it's clear that the skin is at least also strong and reliable.]],
	level_range = {20, 28},
	rarity = 200,
	require = { stat = { dex=35 }, },
	cost = 50,
	material_level = 3,
	use_no_energy = true,
	combat = {
		range = 10,
		physspeed = 0.8,
	},
	wielder = {
		movement_speed = 0.2,
		inc_stats = { [Stats.STAT_LCK] = 10, },
		combat_physcrit = 5,
		combat_def = 10,
		talents_types_mastery = { ["cunning/survival"] = 0.2, },
	},
	max_power = 8, power_regen = 1,
	use_talent = { id = Talents.T_INERTIAL_SHOT, level=3, power = 8 },
}

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {arcane=true},
	define_as = "LUCKY_FOOT",
	unique = true,
	name = "Prox's Lucky Halfling Foot", color = colors.WHITE,
	unided_name = "a mummified halfling foot", image = "object/artifact/proxs_lucky_halfling_foot.png",
	desc = [[A large hairy foot, very recognizably a halfling's, is strung on a piece of thick twine. In its decomposed state it's hard to tell how long ago it parted with its owner, but from what look like teeth marks around the ankle you get the impression that it wasn't given willingly.
It has been kept somewhat intact with layers of salt and clay, but in spite of this it's clear that nature is beginning to take its toll on the dead flesh. Some say the foot of a halfling brings luck to its bearer - right now the only thing you can be sure of is that it stinks.]],
	level_range = {5, 12},
	rarity = 200,
	cost = 10,
	material_level = 1,
	metallic = false,
	sentient = true,
	cooldown=0,
	special_desc = function(self) return "Detects traps.\nGives a 25% chance to shrug off up to three stuns, pins, and dazes each turn, with a 10 turn cooldown." end,
	wielder = {
		inc_stats = { [Stats.STAT_LCK] = 5, },
		combat_def = 5,
		disarm_bonus = 5,
	},
	act = function(self)
		self:useEnergy()
		if self.worn_by then
			local actor = self.worn_by
			local grids = core.fov.circle_grids(actor.x, actor.y, 1, true)
			local Map = require "engine.Map"
			local is_trap = false

			for x, yy in pairs(grids) do for y, _ in pairs(yy) do
				local trap = game.level.map(x, y, Map.TRAP)
				if trap and not (trap:knownBy(self) or trap:knownBy(actor)) then
					is_trap = true
					-- Set the artifact as knowing the trap, not the wearer
					trap:setKnown(self, true)
				end
			end end
			-- only one twitch per action
			if is_trap then
				game.logSeen(actor, "#CRIMSON#%s twitches, alerting %s that a trap is nearby.", self:getName(), actor.name:capitalize())
				if actor == game.player then
					game.player:runStop()
				end
			end
		end
		--Escape stuns/dazes/pins
		self:regenPower()
		
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) and not self.worn_by.player then self.worn_by = nil return end
		if self.worn_by:attr("dead") then return end
		if not rng.percent(25) or self.power < self.max_power then return end
		local who = self.worn_by
		local target = self.worn_by
			local effs = {}
			local known = false
			local num = 0

			-- Go through all spell effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.subtype.pin or e.subtype.stun then
					effs[#effs+1] = {"effect", eff_id}
					num = 1
				end
			end

			for i = 1, 3 do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)

				if eff[1] == "effect" then
					target:removeEffect(eff[2])
					known = true
				end
			end
			if num == 1 then
				game.logSeen(who, "%s shrugs off some effects!", who.name:capitalize())
				self.power = 0
			end
	end,
	on_wear = function(self, who)
		self.worn_by = who
		if who.descriptor and who.descriptor.race == "Halfling" then
			local Stats = require "engine.interface.ActorStats"
			self:specialWearAdd({"wielder","inc_stats"}, { [Stats.STAT_LCK] = -10}) -- Overcomes the +5 Bonus and adds a -5 penalty
			self:specialWearAdd({"wielder","combat_physresist"}, -5)
			self:specialWearAdd({"wielder","combat_mentalresist"}, -5)
			self:specialWearAdd({"wielder","combat_spellresist"}, -5)
			game.logPlayer(who, "#LIGHT_RED#You feel uneasy carrying %s.", self:getName())
		end
	end,
	on_takeoff = function(self)
		self.worn_by = nil
	end,
	max_power = 10, power_regen = 1,
	use_power = { name = "", power = 10, hidden = true, use = function(self, who) return end},
}

newEntity{ base = "BASE_MINDSTAR", define_as = "PSIONIC_FURY",
	power_source = {psionic=true},
	unique = true,
	name = "Psionic Fury",
	unided_name = "vibrating mindstar",
	level_range = {24, 32},
	color=colors.AQUAMARINE, image = "object/artifact/psionic_fury.png",
	rarity = 250,
	desc = [[This mindstar constantly shakes and vibrates, as if a powerful force is desperately trying to escape.]],
	cost = 85,
	require = { stat = { wil=24 }, },
	material_level = 3,
	combat = {
		dam = 12,
		apr = 25,
		physcrit = 5,
		dammod = {wil=0.4, cun=0.2},
		damtype = DamageType.MIND,
	},
	wielder = {
		combat_mindpower = 10,
		combat_mindcrit = 8,
		inc_damage={
			[DamageType.MIND] 		= 15,
			[DamageType.PHYSICAL]	= 5,
		},
		resists={
			[DamageType.MIND] 		= 10,
		},
		inc_stats = { [Stats.STAT_WIL] = 5, [Stats.STAT_CUN] = 4, },
	},
	max_power = 40, power_regen = 1,
	use_power = { name = "release a wave of psionic power", power = 40,
	use = function(self, who)
		local radius = 4
		local dam = (50 + who:getWil()*1.8)
		local blast = {type="ball", range=0, radius=5, selffire=false}
		who:project(blast, who.x, who.y, engine.DamageType.MIND, dam)
		game.level.map:particleEmitter(who.x, who.y, blast.radius, "force_blast", {radius=blast.radius})
		game.logSeen(who, "%s sends out a blast of psionic energy!", who.name:capitalize(), self:getName())
		return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_GAUNTLETS", define_as = "STORM_BRINGER_GAUNTLETS",
	power_source = {arcane=true},
	unique = true,
	name = "Storm Bringer's Gauntlets", color = colors.LIGHT_STEEL_BLUE, image = "object/artifact/storm_bringers_gauntlets.png",
	unided_name = "fine-mesh gauntlets",
	desc = [[This pair of fine mesh voratun gauntlets is covered with glyphs of power that spark with azure energy.  The metal is supple and light so as not to interfere with spell-casting.  When and where these gauntlets were forged is a mystery, but odds are the crafter knew a thing or two about magic.]],
	level_range = {25, 35},
	rarity = 250,
	cost = 1000,
	material_level = 3,
	require = nil,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = 4, },
		resists = { [DamageType.LIGHTNING] = 15, },
		inc_damage = { [DamageType.LIGHTNING] = 10 },
		resists_cap = { [DamageType.LIGHTNING] = 5 },
		combat_spellcrit = 5,
		combat_critical_power = 20,
		combat_armor = 3,
		combat = {
			dam = 22,
			apr = 10,
			physcrit = 4,
			physspeed = 0.2,
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
			melee_project={ [DamageType.LIGHTNING] = 20, },
			talent_on_hit = { [Talents.T_CHAIN_LIGHTNING] = {level=3, chance=20}, [Talents.T_NOVA] = {level=2, chance=15} },
			damrange = 0.3,
		},
	},
	max_power = 16, power_regen = 1,
	use_talent = { id = Talents.T_CHAIN_LIGHTNING, level = 3, power = 16 },
}

newEntity{ base = "BASE_TRIDENT",
	power_source = {arcane=true},
	define_as = "TRIDENT_STREAM",
	unided_name = "ornate trident",
	name = "The River's Fury", unique=true, image = "object/artifact/the_rivers_fury.png",
	desc = [[This gorgeous and ornate trident was wielded by Lady Nashva, and when you hold it, you can faintly hear the roar of a rushing river.]],
	require = { stat = { str=12 }, },
	level_range = {1, 10},
	rarity = 230,
	cost = 300,
	material_level = 1,
	combat = {
		dam = 23,
		apr = 8,
		physcrit = 5,
		dammod = {str=1.2},
		damrange = 1.4,
		melee_project={
			[DamageType.COLD] = 15,
		},
	},
	wielder = {
		combat_atk = 10,
		combat_spellpower = 10,
		resists={[DamageType.COLD] = 10},
		inc_damage = { [DamageType.COLD] = 10 },
		movement_speed=0.1,
	},
	talent_on_spell = { {chance=20, talent="T_GLACIAL_VAPOUR", level=1} },
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_TIDAL_WAVE, level=1, power = 80 },
}

newEntity{ base = "BASE_KNIFE",
	power_source = {arcane=true},
	define_as = "UNERRING_SCALPEL",
	unique = true,
	name = "Unerring Scalpel", image = "object/artifact/unerring_scalpel.png",
	unided_name = "long sharp scalpel",
	desc = [[This scalpel was used by the dread sorcerer Kor'Pul when he began learning the necromantic arts in the Age of Dusk.  Many were the bodies, living and dead, that became unwilling victims of his terrible experiments.]],
	level_range = {1, 12},
	rarity = 200,
	require = { stat = { cun=16 }, },
	cost = 80,
	material_level = 1,
	combat = {
		dam = 15,
		apr = 25,
		physcrit = 0,
		dammod = {dex=0.55, str=0.45},
		phasing = 50,
	},
	wielder = {
		combat_atk=20,
		blind_fight = 1,
	},
}

newEntity{ base = "BASE_GLOVES", define_as = "VARSHA_CLAW",
	power_source = {nature=true},
	unique = true,
	name = "Wyrmbreath", color = colors.RED, image = "object/artifact/wyrmbreath.png",
	unided_name = "clawed dragon-scale gloves",
	desc = [[These dragon scale gloves are tipped with the claws and teeth of a vicious Wyrm. The gloves are warm to the touch.]],
	level_range = {12, 22},
	rarity = 180,
	cost = 50,
	material_level = 2,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 5, },
		resists = { [DamageType.FIRE]= 18, [DamageType.DARKNESS]= 10, [DamageType.NATURE]= 10,},
		inc_damage = { [DamageType.FIRE]= 10, },
		combat_armor = 4,
		combat = {
			dam = 17,
			apr = 7,
			physcrit = 1,
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
			melee_project={[DamageType.FIRE] = 10},
			convert_damage = { [DamageType.FIRE] = 50,},
			talent_on_hit = { [Talents.T_BELLOWING_ROAR] = {level=3, chance=10}, [Talents.T_FIRE_BREATH] = {level=2, chance=10} },
		},
	},
	max_power = 24, power_regen = 1,
	use_talent = { id = Talents.T_FIRE_BREATH, level = 2, power = 24 },
}

newEntity{ base = "BASE_TOOL_MISC", define_as = "EYE_OF_THE_DREAMING_ONE",
	power_source = {psionic=true},
	unique=true, rarity=240,
	name = "Eye of the Dreaming One",
	unided_name = "translucent sphere",
	color = colors.YELLOW,
	level_range = {1, 10},
	image = "object/artifact/eye_of_the_dreaming_one_new.png",
	desc = [[This ethereal eye stares eternally, as if seeing things that do not truly exist.]],
	cost = 320,
	material_level = 1,
	wielder = {
		combat_mindpower=5,
		sleep_immune=1,
		combat_mentalresist = 10,
		inc_stats = {[Stats.STAT_WIL] = 5,},
	},
	max_power = 25, power_regen = 1,
	use_talent = { id = Talents.T_SLEEP, level = 3, power = 20 },
}
