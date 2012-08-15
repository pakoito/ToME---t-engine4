-- ToME - Tales of Middle-Earth
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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

-- This file describes artifacts associated with a boss of the game, they have a high chance of dropping their respective ones, but they can still be found elsewhere

newEntity{ base = "BASE_LONGSWORD",
	power_source = {nature=true},
	define_as = "LONGSWORD_WINTERTIDE", rarity=false, unided_name = "glittering longsword", image="object/artifact/wintertide.png",
	name = "Wintertide", unique=true,
	desc = [[The air seems to freeze around the blade of this sword, draining all heat from the area.
It is said the Conclave created this weapon for their warmaster during the dark times of the first allure war.]],
	require = { stat = { str=35 }, },
	level_range = {35, 45},
	rarity = 280,
	cost = 2000,
	material_level = 5,
	combat = {
		dam = 45,
		apr = 10,
		physcrit = 10,
		dammod = {str=1},
		damrange = 1.4,
		melee_project={[DamageType.ICE] = 45},
	},
	wielder = {
		lite = 1,
		see_invisible = 2,
		resists={[DamageType.COLD] = 25},
		inc_damage = { [DamageType.COLD] = 20 },
	},
	max_power = 18, power_regen = 1,
	use_power = { name = "generate a burst of ice", power = 8,
		use = function(self, who)
			local tg = {type="ball", range=0, radius=4, selffire=false}
			who:project(tg, who.x, who.y, engine.DamageType.ICE, 40 + (who:getMag() + who:getWil()), {type="freeze"})
			game:playSoundNear(who, "talents/ice")
			game.logSeen(who, "%s invokes the power of %s!", who.name:capitalize(), self.name)
			return {id=true, used=true}
		end
	},
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

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	define_as = "FIERY_CHOKER", rarity=false,
	unided_name = "flame-wrought amulet",
	name = "Fiery Choker", unique=true, image="object/artifact/fiery_choker.png",
	desc = [[A choker made of pure flame, forever shifting patterns around the neck of its wearer. Its fire seems to not harm the wearer.]],
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
	define_as = "EEL_SKIN", rarity=false, image = "object/artifact/eel_skin_armor.png",
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

newEntity{ base = "BASE_HEAVY_ARMOR",
	power_source = {nature=true},
	define_as = "CHROMATIC_HARNESS", rarity=false, image = "object/artifact/armor_chromatic_harness.png",
	name = "Chromatic Harness", unique=true,
	unided_name = "multi-hued scale-mail armour", color=colors.VIOLET,
	desc = [[This dragon scale harness shines with multiple colors, quickly shifting through them in a seemingly chaotic manner.]],
	level_range = {40, 50},
	rarity = 280,
	cost = 500,
	material_level = 5,
	wielder = {
		talent_cd_reduction={[Talents.T_ICE_BREATH]=3, [Talents.T_FIRE_BREATH]=3, [Talents.T_SAND_BREATH]=3, [Talents.T_LIGHTNING_BREATH]=3,},
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
			[DamageType.PHYSICAL] = 20,
		},
	},
}

newEntity{ base = "BASE_RING",
	power_source = {technique=true},
	define_as = "PRIDE_GLORY", rarity=false,
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
		fatigue = -15,
		talent_cd_reduction={
			[Talents.T_RUSH]=6,
		},
		inc_damage={ [DamageType.PHYSICAL] = 8, },
	},
}

newEntity{ base = "BASE_RING",
	power_source = {arcane=true},
	define_as = "NIGHT_SONG", rarity=false,
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
	desc = [[A great helm that belonged to Garkul the Devourer, one of the greatest orcs to live.]],
	require = { stat = { str=16 }, },
	level_range = {12, 22},
	rarity = 200,
	cost = 20,
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
	power_source = {nature=true},
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
	rarity = false,
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
	name = "Petrified Wood", subtype = "black",
	color = colors.WHITE, image = "object/artifact/petrified_wood.png",
	level_range = {35, 45},
	rarity = 280,
	desc = [[A piece of the scorched wood taken from the remains of Snaproot.]],
	rarity = false,
	cost = 100,
	material_level = 4,
	imbue_powers = {
		resists = { [DamageType.NATURE] = 25, [DamageType.DARKNESS] = 10, [DamageType.COLD] = 10 },
		inc_stats = { [Stats.STAT_CON] = 25, },
	},
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {arcane=true},
	define_as = "BLACK_ROBE", rarity=false,
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

newEntity{ base = "BASE_WARAXE",
	power_source = {arcane=true},
	define_as = "MALEDICTION", rarity=false,
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
		melee_project={[DamageType.BLIGHT] = 20},
	},
	wielder = {
		life_regen = -0.3,
		inc_damage = { [DamageType.BLIGHT] = 20 },
	},
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	define_as = "STAFF_KOR", rarity=false, image = "object/artifact/staff_kors_fall.png",
	unided_name = "dark staff",
	flavor_name = "vilestaff",
	name = "Kor's Fall", unique=true,
	desc = [[Made from the bones of many creatures, this staff glows with power. You can feel its evilness even from a distance.]],
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
		learn_talent = {[Talents.T_COMMAND_STAFF] = 1},
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	define_as = "VOX", rarity=false,
	name = "Vox", unique=true,
	unided_name = "ringing amulet", color=colors.BLUE, image="object/artifact/jewelry_amulet_vox.png",
	desc = [[No force can hope to silence the wearer of this amulet.]],
	level_range = {40, 50},
	rarity = 220,
	cost = 3000,
	material_level = 5,
	wielder = {
		see_invisible = 20,
		silence_immune = 0.8,
		combat_spellpower = 9,
		combat_spellcrit = 4,
		max_mana = 50,
		max_vim = 50,
	},
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	define_as = "TELOS_TOP_HALF", rarity=false, image = "object/artifact/staff_broken_top_telos.png",
	slot_forbid = false,
	twohanded = false,
	unided_name = "broken staff", flavor_name = "magestaff",
	name = "Telos's Staff (Top Half)", unique=true,
	desc = [[The top part of Telos's broken staff.]],
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
	define_as = "AMULET_DREAD", rarity=false,
	name = "Choker of Dread", unique=true, image = "object/artifact/amulet_choker_of_dread.png",
	unided_name = "dark amulet", color=colors.LIGHT_DARK,
	desc = [[The evilness of undeath radiates from this amulet.]],
	level_range = {20, 28},
	rarity = 220,
	cost = 5000,
	material_level = 3,
	wielder = {
		see_invisible = 10,
		blind_immune = 1,
		combat_spellpower = 5,
		combat_dam = 5,
	},
	max_power = 60, power_regen = 1,
	use_power = { name = "summon an elder vampire to your side", power = 60, use = function(self, who)
		if not who:canBe("summon") then game.logPlayer(who, "You can not summon, you are suppressed!") return end

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
		dam = resolvers.rngavg(40,45),
		apr = 0,
		physcrit = 9,
		dammod = {dex=1},
		damtype = DamageType.FIREKNOCKBACK,
	},
	wielder = {
		esp = {["demon/minor"]=1, ["demon/major"]=1},
		see_invisible = 2,
	},
	carrier = {
		inc_damage={
			[DamageType.BLIGHT] = 8,
		},
	},
}

newEntity{ base = "BASE_GREATSWORD",
	power_source = {technique=true},
	define_as = "MURDERBLADE", rarity=false,
	name = "Warmaster Gnarg's Murderblade", unique=true, image="object/artifact/warmaster_gnargs_murderblade.png",
	unided_name = "blood-etched greatsword", color=colors.CRIMSON,
	desc = [[A blood-etched greatsword, it has seen many foes. From the inside.]],
	require = { stat = { str=35 }, },
	level_range = {35, 45},
	rarity = 230,
	cost = 300,
	material_level = 5,
	combat = {
		dam = 60,
		apr = 19,
		physcrit = 4.5,
		dammod = {str=1.2},
		special_on_hit = {desc="10% chance to send the wielder into a killing frenzy", fct=function(combat, who)
			if not rng.percent(10) then return end
			who:setEffect(who.EFF_FRENZY, 3, {crit=10, power=0.3, dieat=0.2})
		end},
	},
	wielder = {
		see_invisible = 25,
		inc_stats = { [Stats.STAT_CON] = 5, [Stats.STAT_STR] = 5, [Stats.STAT_DEX] = 5, },
		talents_types_mastery = {
			["technique/2hweapon-cripple"] = 0.2,
			["technique/2hweapon-offense"] = 0.2,
		},
	},
}

newEntity{ base = "BASE_LEATHER_CAP",
	power_source = {arcane=true},
	define_as = "CROWN_ELEMENTS", rarity=false,
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
		see_invisible = 15,
		combat_armor = 5,
		fatigue = 5,
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
		inc_stats = { [Stats.STAT_WIL] = 3, },
		resists = { [DamageType.FIRE]= 10, },
		inc_damage = { [DamageType.FIRE]= 5, },
		combat_armor = 2,
		combat = {
			dam = 5,
			apr = 7,
			physcrit = 1,
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
			melee_project={[DamageType.FIRE] = 10},
			convert_damage = { [DamageType.FIRE] = 100,},
		},
	},
	max_power = 24, power_regen = 1,
	use_talent = { id = Talents.T_RITCH_FLAMESPITTER_BOLT, level = 2, power = 6 },
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
	cost = 50,
	material_level = 2,

	max_power = 1, power_regen = 1,
	use_power = { name = "combine with a weapon", power = 1, use = function(self, who, gem_inven, gem_item)
		who:showInventory("Fuse with which weapon?", who:getInven("INVEN"), function(o) return (o.type == "weapon" or o.subtype == "hands") and o.subtype ~= "mindstar" and not o.egoed and not o.unique and not o.rare end, function(o, item)
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
			o.wielder = o.wielder or {}
			o.wielder.combat_spellpower = 12
			o.wielder.combat_dam = 12
			o.wielder.inc_stats = o.wielder.inc_stats or {}
			o.wielder.inc_stats[engine.interface.ActorStats.STAT_WIL] = 3
			o.wielder.inc_stats[engine.interface.ActorStats.STAT_CON] = 3
			o.wielder.inc_damage = o.wielder.inc_damage or {}
			o.wielder.inc_damage[engine.DamageType.ARCANE] = 10

			o.set_list = { {"is_crystalline_armor", true} }
			o.on_set_complete = function(self, who)
				self.talent_on_spell = { {chance=10, talent="T_MANATHRUST", level=3} }
				self.combat.talent_on_hit = { T_MANATHRUST = {level=3, chance=10} }
				self:specialSetAdd({"wielder","combat_spellcrit"}, 10)
				self:specialSetAdd({"wielder","combat_physcrit"}, 10)
				self:specialSetAdd({"wielder","resists_pen"}, {[engine.DamageType.ARCANE]=20, [engine.DamageType.PHYSICAL]=15})
				game.logPlayer(who, "#GOLD#As the crystalline weapon and armour are brought together, they begin to emit a constant humming.")
			end
			o.on_set_broken = function(self, who)
				self.talent_on_spell = nil
				self.combat.talent_on_hit = nil
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
	use_power = { name = "force some of your foes infusions, runes or talents on cooldown", power = 30,
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
		dam = 16,
		apr = 3,
		physcrit = 12,
		dammod = {str=1},
		talent_on_hit = { [Talents.T_GREATER_WEAPON_FOCUS] = {level=2, chance=10} },
		melee_project={[DamageType.DRAINLIFE] = 10},
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
	desc = [[These blackened boots have lost all vestige of any former glory they might have had. Now, they are a testament to the corruption of the Deep Bellow, and its power.]],
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
		combat_spellcrit = 9,
		life_regen = -0.20,
		inc_damage = { [DamageType.BLIGHT] = 15 },
	},
	max_power = 50, power_regen = 1,
	use_talent = { id = Talents.T_SPIT_BLIGHT, level=3, power = 10 },
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
	cost = 650,
	material_level = 5,
	combat = {
		dam = 72,
		apr = 4,
		physcrit = 8,
		dammod = {str=1.2},
		melee_project={[DamageType.SLIME] = 50, [DamageType.ACID] = 50},
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
	desc = [[Inch thick stralite plates lock together with voratun joints. The whole suit looks impenetrable, but has clearly been subjected to terrible treatment - great dents and misshaping warps, and caustic fissures bored across the surface.
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
	desc = [[This well-tended sling is made from the leather and sinews of a large hare. It feels smooth to the touch yet very durable. Some say that the skin of a hare brings luck and fortune.
Hard to tell if that really helped its former owner, but it's clear that the skin is at least also strong and reliable..]],
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
It has been kept somewhat intact with layers of salt and clay, but in spite of this it's clear that nature is beginning to take its course on the dead flesh. Some say the foot of a halfling brings luck to its bearer - right now the only thing you can be sure of is it stinks.]],
	level_range = {5, 12},
	rarity = 200,
	cost = 10,
	material_level = 1,
	metallic = false,
	sentient = true,
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
	end,
	on_wear = function(self, who)
		self.worn_by = who
		if who.descriptor and who.descriptor.race == "Halfling" then
			local Stats = require "engine.interface.ActorStats"
			self:specialWearAdd({"wielder","inc_stats"}, { [Stats.STAT_LCK] = -10}) -- Overcomes the +5 Bonus and adds a -5 penalty
			self:specialWearAdd({"wielder","combat_physicalsave"}, -5)
			self:specialWearAdd({"wielder","combat_mentalsave"}, -5)
			self:specialWearAdd({"wielder","combat_spellsave"}, -5)
			game.logPlayer(who, "#LIGHT_RED#You feel uneasy carrying %s.", self:getName())
		end
	end,
	on_takeoff = function(self)
		self.worn_by = nil
	end,
}

--Storm fury, lightning infused bow that automatically attacks nearby enemies with bolts of lightning.
newEntity{ base = "BASE_LONGBOW",
	power_source = {arcane=true},
	define_as = "STORM_FURY",
	name = "Storm Fury", unique=true, --THESE
	unided_name = "crackling longbow", color=colors.BLUE,
	desc = [[This dragonbone longbow is enhanced with bands of steel, which arc with intense lightning. Bolts travel up and down the string, ignorant of you.]],
	require = { stat = { dex=60 }, },
	level_range = {40, 50},
	rarity = 250,
	cost = 300,
	material_level = 5,
	sentient = true,
	combat = {
		range=10,
		physspeed = 0.7,
	},
	wielder = {
		combat_spellpower=8,
		ranged_project = {[DamageType.LIGHTNING] = 50},
		talents_types_mastery = {
			["spell/air"] = 0.2,
			["spell/storm"] = 0.1,
		},
		inc_damage={
			[DamageType.LIGHTNING] = 15,
		},
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
			game.logSeen(who, "#GOLD#A bolt of lightning fires from %s's bow, striking %s!", who.name:capitalize(), a.name:capitalize())
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
	name = "Frozen Shroud", --ARTIFACTS
	unided_name = "chilling cloak",
	desc = [[All that remains of the Glacial Legion. This cloak seems to exude an icy cold vapor that freezes all it touches.]],
	level_range = {40, 50},
	rarity = 250,
	cost = 300,
	material_level = 5,
	wielder = {
		resists= {[DamageType.FIRE] = -15,[DamageType.COLD] = 25, all=5},
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
				engine.Entity.new{alpha=100, display='', color_br=30, color_bg=60, color_bb=200},
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
	name = "Blighted Maul", color = colors.LIGHT_RED, --NEED
	unided_name = "rotten stone limb",
	desc = [[The massive stone limb of the Rotting Titan, a mass of stone and rotting flesh. You think you can lift it, but it is very heavy.]],
	level_range = {40, 50},
	rarity = 250,
	require = { stat = { str=60 }, },
	cost = 300,
	encumber = 12,
	material_level = 5,
	combat = {
		dam = 96,
		apr = 22,
		physcrit = 10,
		physspeed=1.2,
		dammod = {str=1.4},
		convert_damage = {[DamageType.BLIGHT] = 20},
		melee_project={[DamageType.CORRUPTED_BLOOD] = 30},
		special_on_hit = {desc="25% to damage nearby foes", on_kill=true, fct=function(combat, who, target)
			if rng.percent(25) then
			local o, item, inven_id = who:findInAllInventoriesBy("define_as", "ROTTING_MAUL")
				local dam = rng.avg(1,2) * (70+ who:getStr() * 1.8)
				game.logSeen(who, "The ground shakes as the %s hits!", o:getName())
				local tg = {type="ball", range=0, selffire=false, radius=2, no_restrict=true}
				who:project(tg, target.x, target.y, engine.DamageType.PHYSICAL, dam)
			end
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
	define_as = "ARMOR_MOLTEN", rarity=false,
	unided_name = "melting bony armour",
	name = "Molten Skin", unique=true,
	desc = [[This mass of fused molten bone from the Heavy Sentinel radiates intense power. It still glows red with the heat of the Sentinel's core, and yet seems to do you no harm.]],
	require = { stat = { mag=60 }, },
	level_range = {40, 50},
	rarity = 250,
	cost = 300,
	material_level=5,
	wielder = {
		combat_spellpower = 15,
		combat_spellcrit = 10,
		combat_physcrit = 8,
		combat_critical_power = 20,
		combat_def = 15,
		combat_armor = 12,
		inc_stats = { [Stats.STAT_MAG] = 6,[Stats.STAT_CUN] = 6,},
		melee_project={[DamageType.FIRE] = 30,},
 		inc_damage={
			[DamageType.FIRE] = 25,
			[DamageType.LIGHT] = 10,
			all=5,
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
 		},
	},
	max_power = 16, power_regen = 1,
	use_talent = { id = Talents.T_BLASTWAVE, level = 4, power = 12 },
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
	name = "The Bladed Rift", color = colors.BLUE,
	unided_name = "hole in space",
	desc = [[Upon defeat, Ak'Gishil collapsed into this tiny rift. How it remains stable, you are unsure. If you focus, you think you can call forth a sword from it.]],
	level_range = {30, 50},
	rarity = 500,
	cost = 500,
	material_level = 4,
	metallic = false,
	wielder = {
		combat_spellpower=5,
		combat_mindpower=5,
		on_melee_hit = {[DamageType.PHYSICALBLEED]=25},
		resists={
			[DamageType.TEMPORAL] 	= 15,
		},
		inc_damage={
			[DamageType.TEMPORAL] 	= 10,
			[DamageType.PHYSICAL] 	= 5,
		},
	},
	max_power = 40, power_regen = 1,
	use_talent = { id = Talents.T_ANIMATE_BLADE, level = 1, power = 40 },
}

newEntity{ base = "BASE_LONGSWORD", define_as = "RIFT_SWORD",
	power_source = {arcane=true},
	unique = true,
	name = "Blade of Distorted Time", image = "object/artifact/sword_of_potential_futures.png",
	unided_name = "time-warped sword",
	desc = [[The remnants of a damaged timeline, this blade shifts and fades at random.]],
	level_range = {30, 50},
	rarity = nil, --Not random!
	require = { stat = { str=44 }, },
	cost = 300,
	material_level = 4,
	combat = {
		dam = 40,
		apr = 10,
		physcrit = 8,
		dammod = {str=0.8,mag=0.2},
		convert_damage={[DamageType.TEMPORAL] = 20},
		special_on_hit = {desc="20% to slow target", fct=function(combat, who, target)
			if not rng.percent(20) then return end
			local dam = (20 + who:getMag()/2)
			local slow = (10 + who:getMag()/5)
			who:project(target.x, target.y, engine.DamageType.CHRONOSLOW, {dam=dam, slow=slow})
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
	name = "Rune of Reflection", unique=true,
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
