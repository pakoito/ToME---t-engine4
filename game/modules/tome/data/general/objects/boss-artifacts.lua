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
		melee_project={[DamageType.ICE] = 15},
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
			local tg = {type="ball", range=0, radius=4, friendlyfire=false}
			who:project(tg, who.x, who.y, engine.DamageType.ICE, 10 + (who:getMag() + who:getWil()) / 2, {type="freeze"})
			game:playSoundNear(who, "talents/ice")
			game.logSeen(who, "%s invokes the power of %s!", who.name:capitalize(), self.name)
			return true
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
	material_level = 2,

	wielder = {
		lite = 1,
		infravision = 6,
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
	cost = 50,
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
		blind_immune = 1,
	},
}

-- Artifact, dropped by Rantha
newEntity{ base = "BASE_LEATHER_BOOT",
	power_source = {nature=true},
	define_as = "FROST_TREADS",
	unided_name = "icy covered boots",
	name = "Frost Treads", unique=true, image="object/artifact/frost_treads.png",
	desc = [[A pair of leather boots. Cold to the touch, they radiate a cold blue light.]],
	require = { stat = { dex=16 }, },
	level_range = {10, 18},
	rarity = 220,
	cost = 40,

	wielder = {
		lite = 1,
		combat_armor = 2,
		combat_def = 1,
		fatigue = 14,
		inc_damage = {
			[DamageType.COLD] = 5,
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
	name = "Dragonskull Helm", unique=true, unided_name="skull helm",
	desc = [[Traces of a dragon's power still remain in this bleached and cracked skull.]],
	require = { stat = { mag=24 }, },
	level_range = {45, 50},
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

newEntity{ base = "BASE_TRIDENT",
	power_source = {nature=true},
	define_as = "TRIDENT_TIDES",
	unided_name = "ever-dripping trident",
	name = "Trident of the Tides", unique=true,
	desc = [[As you wield this trident you can feel the power of the tides rushing through your arms.
Tridents require the exotic weapons mastery talent to use correctly.]],
	require = { stat = { str=35 }, },
	level_range = {30, 40},
	rarity = 230,
	cost = 300,
	material_level = 4,
	combat = {
		dam = 50,
		atk = 10,
		apr = 4,
		physcrit = 15,
		dammod = {str=1.3},
		damrange = 1.4,
		melee_project={
			[DamageType.COLD] = 15,
			[DamageType.NATURE] = 20,
		},
	},

	wielder = {
		combat_spellresist = 18,
		see_invisible = 2,
		resists={[DamageType.COLD] = 25},
		inc_damage = { [DamageType.COLD] = 20 },
	},

	max_power = 150, power_regen = 1,
	use_talent = { id = Talents.T_WATER_BOLT, level=3, power = 60 },
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {nature=true},
	define_as = "EEL_SKIN", rarity=false,
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
	use_talent = { id = Talents.T_LIGHTNING, level=2, power = 18 },
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {nature=true},
	define_as = "CHROMATIC_HARNESS", rarity=false,
	name = "Chromatic Harness", unique=true,
	unided_name = "multi-hued leather armour", color=colors.VIOLET,
	desc = [[This leather harness shines with multiple colors, quickly shifting through them in a seemingly chaotic manner.]],
	level_range = {40, 50},
	rarity = 280,
	cost = 500,
	material_level = 5,
	wielder = {
		talent_cd_reduction={[Talents.T_ICE_BREATH]=3, [Talents.T_FIRE_BREATH]=3, [Talents.T_SAND_BREATH]=3, },
		inc_stats = { [Stats.STAT_WIL] = 6, [Stats.STAT_CUN] = 4, [Stats.STAT_DEX] = 3, [Stats.STAT_LCK] = 10, },
		poison_immune = 0.7,
		combat_armor = 10,
		esp = { dragon = 1 },
		fatigue = 10,
	},
}

newEntity{ base = "BASE_RING",
	power_source = {technique=true},
	define_as = "PRIDE_GLORY", rarity=false,
	name = "Glory of the Pride", unique=true, image="object/artifact/glory_of_the_pride.png",
	desc = [[The most prized treasure of the Battlemaster of the Pride, Grushnak. This gold ring is inscribed in the orc tongue, the black speech.]],
	unided_name = "deep black ring",
	level_range = {40, 50},
	rarity = 280,
	cost = 500,
	material_level = 5,
	wielder = {
		max_mana = -40,
		max_stamina = 40,
		stun_immune = 1,
		confusion_immune = 1,
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
	name = "Nightsong", unique=true,
	desc = [[A pitch black ring, unadorned. It seems as though tendrils of darkness crept upon it.]],
	unided_name = "obsidian ring",
	level_range = {15, 23},
	rarity = 250,
	cost = 500,
	material_level = 4,
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

	wielder = {
		combat_armor = 4,
		fatigue = 8,
		inc_stats = { [Stats.STAT_STR] = 3, [Stats.STAT_CON] = 3, [Stats.STAT_WIL] = 4 },
		combat_physresist = 7,
		combat_mentalresist = 7,
		combat_spellresist = 7,
	},
}

newEntity{ base = "BASE_SHIELD",
	power_source = {nature=true},
	define_as = "LUNAR_SHIELD",
	unique = true,
	name = "Lunar Shield",
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
		physcrit = 10,
		dammod = {str=1},
		damtype = DamageType.ARCANE,
	},
	wielder = {
		resists={[DamageType.DARKNESS] = 25},
		inc_damage={[DamageType.DARKNESS] = 15},

		combat_armor = 7,
		combat_def = 12,
		combat_def_ranged = 5,
		fatigue = 12,

		lite = 1,
		talents_types_mastery = {["divine/star-fury"]=0.2,["divine/twilight"]=0.1,},
	},
}

newEntity{ base = "BASE_SHIELD",
	power_source = {nature=true},
	define_as = "WRATHROOT_SHIELD",
	unided_name = "large chunk of wood",
	name = "Wrathroot's Barkwood", unique=true,
	desc = [[The barkwood of Wrathroot, made into roughly the shape of a shield.]],
	require = { stat = { str=25 }, },
	level_range = {12, 2},
	rarity = 200,
	cost = 20,
	rarity = false,
	metallic = false,

	special_combat = {
		dam = resolvers.rngavg(20,30),
		physcrit = 2,
		dammod = {str=1.5},
	},
	wielder = {
		combat_armor = 5,
		combat_def = 9,
		fatigue = 14,
		resists = {
			[DamageType.FIRE] = -20,
			[DamageType.COLD] = 20,
			[DamageType.NATURE] = 20,
		},
	},
}

newEntity{ base = "BASE_GEM",
	power_source = {nature=true},
	unique = true, define_as = "PETRIFIED_WOOD",
	unided_name = "burned piece of wood",
	name = "Petrified Wood", subtype = "black",
	color = colors.WHITE, image="object/bloodstone.png",
	level_range = {35, 45},
	rarity = 280,
	desc = [[A piece of the scorched wood taken from the remains of Snaproot.]],
	rarity = false,
	cost = 100,
	material_level = 5,
	imbue_powers = {
		resists = { [DamageType.NATURE] = 25, [DamageType.FIRE] = -10, [DamageType.COLD] = 10 },
		inc_stats = { [Stats.STAT_CON] = 10, },
	},
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {arcane=true},
	define_as = "BLACK_ROBE", rarity=false,
	name = "Black Robe", unique=true,
	unided_name = "black robe", color=colors.DARK_GREY,
	desc = [[A silk robe, darker than the darkest night sky, it radiates power.]],
	level_range = {40, 50},
	rarity = 280,
	cost = 500,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 4, [Stats.STAT_CUN] = 3 },
		see_invisible = 10,
		blind_immune = 1,
		combat_spellpower = 10,
		combat_dam = 10,
		combat_def = 6,
	},
}

newEntity{ base = "BASE_WARAXE",
	power_source = {arcane=true},
	define_as = "MALEDICTION", rarity=false,
	unided_name = "pestilent waraxe",
	name = "Malediction", unique=true,
	desc = [[The land withers and crumbles wherever this cursed axe rests.]],
	require = { stat = { str=55 }, },
	level_range = {35, 45},
	rarity = 290,
	cost = 375,
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
	define_as = "STAFF_KOR", rarity=false,
	unided_name = "dark staff",
	name = "Kor's Fall", unique=true,
	desc = [[Made from the bones of many creatures, this staff glows with power. You can feel its evilness as you touch it.]],
	require = { stat = { mag=25 }, },
	level_range = {1, 10},
	rarity = 200,
	cost = 60,
	combat = {
		dam = 10,
		apr = 0,
		physcrit = 1.5,
		dammod = {mag=1.1},
	},
	wielder = {
		see_invisible = 2,
		combat_spellpower = 7,
		combat_spellcrit = 8,
		inc_damage={
			[DamageType.FIRE] = 4,
			[DamageType.COLD] = 4,
			[DamageType.ACID] = 4,
			[DamageType.LIGHTNING] = 4,
			[DamageType.BLIGHT] = 4,
		},
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	define_as = "VOX", rarity=false,
	name = "Vox", unique=true,
	unided_name = "ringing amulet", color=colors.BLUE,
	desc = [[No force can hope to silence the wearer of this amulet.]],
	level_range = {40, 50},
	rarity = 220,
	cost = 3000,
	wielder = {
		see_invisible = 20,
		silence_immune = 0.8,
		combat_spellpower = 9,
		combat_spellcrit = 4,
		mana = 50,
		vim = 50,
	},
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	define_as = "TELOS_TOP_HALF", rarity=false,
	slot_forbid = false,
	twohanded = false,
	unided_name = "broken staff",
	name = "Telos's Staff (Top Half)", unique=true,
	desc = [[The top part of Telos's broken staff.]],
	require = { stat = { mag=35 }, },
	level_range = {40, 50},
	rarity = 210,
	encumber = 2.5,
	cost = 500,
	combat = {
		dam = 35,
		apr = 0,
		physcrit = 1.5,
		dammod = {mag=1.0},
	},
	wielder = {
		combat_spellpower = 25,
		combat_spellcrit = 5,
		combat_mentalresist = 8,
		inc_stats = { [Stats.STAT_WIL] = 5, },
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	define_as = "AMULET_DREAD", rarity=false,
	name = "Choker of Dread", unique=true,
	unided_name = "dark amulet", color=colors.LIGHT_DARK,
	desc = [[The evilness of undeath radiates from this amulet.]],
	level_range = {20, 28},
	rarity = 220,
	cost = 5000,
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
			display = "V",
			name = "elder vampire", color=colors.RED,
			desc=[[A terrible robed undead figure, this creature has existed in its unlife for many centuries by stealing the life of others. It can
			summon the very shades of its victims from beyond the grave to come enslaved to its aid.]],

			combat = { dam=resolvers.rngavg(9,13), atk=10, apr=9, damtype=engine.DamageType.DRAINLIFE, dammod={str=1.9} },

			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

			autolevel = "warriormage",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=3, },
			energy = { mod=1 },
			stats = { str=12, dex=12, mag=12, con=12 },
			life_regen = 3,
			size_category = 3,
			rank = 3,
			infravision = 20,

			inc_damage = table.clone(who.inc_damage, true),

			resolvers.tmasteries{ ["technique/other"]=0.5, ["spell/phantasm"]=0.8, },

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
			summon_time = 10,
		}

		vampire:resolve()
		game.zone:addEntity(game.level, vampire, "actor", x, y)

		game:playSoundNear(who, "talents/spell_generic")
	end },
}

newEntity{ define_as = "RUNED_SKULL",
	power_source = {arcane=true},
	unique = true,
	type = "gem", subtype="red",
	unided_name = "human skull",
	name = "Runed Skull",
	display = "*", color=colors.RED,
	level_range = {40, 50},
	rarity = 390,
	cost = 150,
	encumber = 3,
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
	desc = [[This is a big, nasty-looking tree trunk that Bill was using as a weapon. It could still serve this purpose, should you be strong enough to wield it!]],
	require = { stat = { str=25 }, },
	level_range = {1, 10},
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
	name = "Sanguine Shield", unique=true,
	desc = [[Though tarnished and spattered with blood, the emblem of the Sun still manages to shine through on this shield.]],
	require = { stat = { str=39 }, },
	level_range = {35, 45},
	rarity = 240,
	cost = 120,

	special_combat = {
		dam = 40,
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
	},
}

newEntity{ base = "BASE_WHIP",
	power_source = {arcane=true},
	define_as = "WHIP_URH_ROK",
	unided_name = "fiery whip",
	name = "Whip of Urh'Rok", color=colors.PURPLE, unique = true,
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
	name = "Warmaster Gnarg's Murderblade", unique=true,
	unided_name = "blood-etched greatsword", color=colors.CRIMSON,
	desc = [[A blood-etched greatsword, it has seen many foes. From the inside.]],
	require = { stat = { str=35 }, },
	level_range = {35, 45},
	rarity = 230,
	cost = 300,
	material_level = 5,
	combat = {
		dam = 54,
		apr = 19,
		physcrit = 4.5,
		dammod = {str=1.2},
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
	name = "Crown of the Elements", unique=true,
	unided_name = "jeweled crown", color=colors.DARK_GREY,
	desc = [[Jeweled crown]],
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
	name = "Flamewrought", color = colors.RED,
	unided_name = "chitinous gloves",
	desc = [[Those gloves seems to be made out of the exoskeleton of ritches. They are hot to the touch.]],
	level_range = {5, 12},
	rarity = 180,
	cost = 50,
	material_level = 1,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 3, },
		resists = { [DamageType.FIRE]= 10, },
		inc_damage = { [DamageType.FIRE]= 5, },
	},
	max_power = 24, power_regen = 1,
	use_talent = { id = Talents.T_RITCH_FLAMESPITTER_BOLT, level = 2, power = 6 },
}
